#
# Hunter Casillas
# CS 330
# Interpreter 2
#

module ExtInt

push!(LOAD_PATH, pwd())

using Error
using Lexer
export parse, calc, interp, interpf

#
# ==================================================
#

abstract type AE
end

# <AE> ::= <number>
struct NumNode <: AE
    n::Real
end

# <AE> ::= (+,-,*,/,mod <AE> <AE>)
struct BinopNode <: AE
	op::Function
	lhs::AE
	rhs::AE
end

#<AE> ::= (-,collatz <AE>)
struct UnopNode <: AE
	op::Function
	body::AE
end

# <AE> ::= (if0 <AE> <AE> <AE>)
struct If0Node <: AE
    cond::AE
    zerobranch::AE
    nzerobranch::AE
end

# <AE> ::= (with ( (id <AE>)* ) <AE>)
struct WithNode <: AE
	sym_expr::Dict{Symbol, AE}
  	body::AE
end

# <AE> ::= <id>
struct VarRefNode <: AE
  	sym::Symbol
end

# <AE> ::= (lambda (id*) <AE>)
struct FuncDefNode <: AE
  	formal::Array{Symbol}
	body::AE
end

# <AE> ::= (<AE> <AE>*)
struct FuncAppNode <: AE
  	fun_expr::AE
  	arg_expr::Array{AE}
end

#
# ==================================================
#

abstract type RetVal
end

abstract type Environment
end

struct NumVal <: RetVal
    n::Real
end

struct ClosureVal <: RetVal
    formal::Array{Symbol}
    body::AE
    env::Environment
end

#
# ==================================================
#

struct EmptyEnv <: Environment
end

struct ExtendedEnv <: Environment
    sym_val::Dict{Symbol, RetVal}
    parent::Environment
end

#
# ==================================================
#

function collatz( n::Real )
  return collatz_helper( n, 0 )
end

function collatz_helper( n::Real, num_iters::Int )
  if n == 1
    return num_iters
  end
  if mod( n, 2 ) == 0
    return collatz_helper( n/2, num_iters+1 )
  else
    return collatz_helper( 3*n+1, num_iters+1 )
  end
end

#
# ==================================================
#

keyDict = Dict( :+ => +, :- => -, :* => *, :/ => /, :mod => mod,
:collatz => collatz, :if0 => "if0", :with => "with", :lambda => "lambda" )

#
# ==================================================
#

function valid_symbol( sym )
	if haskey( keyDict, sym )
		throw( LispError( "Error. Invalid use of symbol." ) )
	elseif typeof( sym ) != Symbol
		throw( LispError( "Error. Not a valid symbol." ) )
	else
		return sym
	end
end

#
# ==================================================
#

function parse( expr::Number )
  	return NumNode( expr )
end

function parse( expr::Symbol )
	# Check for valid syntax
	if haskey( keyDict, expr )
		throw( LispError( "Error. Invalid use of symbol/operator." ) )
	else
		return VarRefNode( expr )
	end
end

function parse( expr::Array{Any} )
	# Check to make sure expr is not empty
	if isempty( expr )
		throw( LispError( "Error. Expression cannot be empty." ) )
	end

	key = expr[1]

	# Check for unary operation
	if length( expr ) == 2
		# Check for valid unary operator
		if key == :- || key == :collatz
			return UnopNode( keyDict[key], parse( expr[2] ) )
		end
	end

	# Check for with, lambda, or binary operation
	if length( expr ) == 3
		# Check for with
		if key == :with
			expr2 = expr[2]
			withDict = Dict{Symbol, AE}()

			# Check for invalid type in expr[2]
			if !isa( expr2, Array{Any} )
				throw( LispError( "Error. Invalid type. Must be an Array." ) )
			end

			# Throws error for “(with (x 2) (+ x x))”
			# Allows “(with ((x 2)) (+ x x))”
			# Allows "(with () (+ 4 5))"
			if length( expr2 ) > 0
				if typeof( expr2[1] ) == Symbol
					throw( LispError( "Error. Invalid syntax." ) )
				end
			end

			for i = 1 : length( expr2 )
				# Check to make sure length is exactly two
				if length( expr2[i] ) != 2
					throw( LispError( "Error. Invalid syntax." ) )
				end

				# Check to see if the symbol is valid
				sym = valid_symbol( expr2[i][1] )

				# Check for duplicate symbols and AE after the id
				if length( expr2[i] ) == 1
					throw( LispError( "Error. With must include <AE> after the id." ) )
				elseif haskey( withDict, sym )
					throw( LispError( "Error. With cannot include duplicate symbols." ) )
				end

				value = parse( expr2[i][2] )
				withDict[sym] = value
			end

			return WithNode( withDict, parse( expr[3] ) )

		# Check for lambda
		elseif key == :lambda
			expr2 = expr[2]
			lambdaDict = Dict{Symbol, Symbol}()

			# Check for invalid type in expr[2]
			if !isa( expr2, Array{Any} )
				throw( LispError( "Error. Invalid type. Must be an Array." ) )
			end

			if length( expr2 ) > 1
				for i = 1 : length( expr2 )
					# Check to see if the symbol is valid
					sym = valid_symbol( expr2[i] )
					# Check for duplicate symbols
					if haskey( lambdaDict, sym )
						throw( LispError( "Error. Lambda cannot include duplicate symbols." ) )
					end
					lambdaDict[sym] = sym
				end
			end

			formal = map( valid_symbol, expr2 )
			return FuncDefNode( formal, parse( expr[3] ) )

		# Check for valid binary operator
		elseif key == :+ || key == :- || key == :* || key == :/ || key == :mod
			return BinopNode( keyDict[key], parse( expr[2] ), parse( expr[3] ) )
		end
	end

	# Check for If0
	if length( expr ) == 4
		if key == :if0
			return If0Node( parse( expr[2] ), parse( expr[3] ) , parse( expr[4] ) )
		end
	end

	# Final check for errors
	if haskey( keyDict, expr )
		throw( LispError( "Error. Invalid syntax." ) )
	end

	values = map( parse, expr[2 : end] )
	return FuncAppNode( parse( expr[1] ), values )
end

function parse( expr::Any )
  throw( LispError( "Error. Invalid type $expr" ) )
end

#
# ==================================================
#

function calc( ast::NumNode, env::Environment )
    return NumVal( ast.n )
end

function calc( ast::BinopNode, env::Environment )
	operator = ast.op
    lhs = calc( ast.lhs, env )
    rhs = calc( ast.rhs, env )

	# Check for invalid use of operators
	if typeof( lhs ) != NumVal || typeof( rhs ) != NumVal
		throw( LispError( "Error. Invalid type. Must be NumVal." ) )
	elseif operator == keyDict[:mod] && rhs.n == 0
		throw( LispError( "Error. You cannot mod by zero." ) )
	elseif operator == keyDict[:/] && rhs.n == 0
		throw( LispError( "Error. You cannot divide by zero." ) )
	else
    	return NumVal( operator( lhs.n, rhs.n ) )
	end
end

function calc( ast::UnopNode, env::Environment )
	operator = ast.op
	number = calc( ast.body, env )

	if typeof( number ) != NumVal
		throw( LispError( "Error. Invalid type. Must be NumVal." ) )
	elseif operator == keyDict[:collatz] && number.n < 1
		throw( LispError( "Error. Collatz cannot be less than 1." ) )
	else
		return NumVal( operator( number.n ) )
	end
end

function calc( ast::If0Node, env::Environment )
    cond = calc( ast.cond, env )

	if typeof( cond ) != NumVal
		throw( LispError( "Error. Invalid type. Must be NumVal." ) )
	elseif cond.n == 0
        return calc( ast.zerobranch, env )
    else
        return calc( ast.nzerobranch, env )
    end
end

function calc( ast::WithNode, env::Environment )
	sym_val = Dict{Symbol, RetVal}()
	sym_expr = ast.sym_expr

	for i in keys( sym_expr )
		value = calc( sym_expr[i], env )
		sym_val[i] = value
	end

    ext_env = ExtendedEnv( sym_val, env )
    return calc( ast.body, ext_env )
end

function calc( ast::VarRefNode, env::EmptyEnv )
    throw( Error.LispError( "Undefined variable " * string( ast.sym ) ) )
end

function calc( ast::VarRefNode, env::ExtendedEnv )
	if haskey( env.sym_val, ast.sym )
		return env.sym_val[ast.sym]
	else
        return calc( ast, env.parent )
    end
end

function calc( ast::FuncDefNode, env::Environment )
    return ClosureVal( ast.formal, ast.body , env )
end

function calc( ast::FuncAppNode, env::Environment )
    closure_val = calc( ast.fun_expr, env )

	if typeof( closure_val ) != ClosureVal
		throw( LispError( "Error. Invalid type. Must be ClosureVal." ) )
	else
		formal = closure_val.formal
		expr = ast.arg_expr

		if length( formal ) != length( expr )
			throw( LispError( "Error. Incorrect number of parameters." ) )
		end

		funcDict = Dict{Symbol, RetVal}()
		for i = 1 : length( formal )
			funcDict[ formal[i] ] = calc( expr[i], env )
		end

    	ext_env = ExtendedEnv(funcDict, closure_val.env )
    	return calc( closure_val.body, ext_env )
	end
end

function calc( ast::AE )
    return calc( ast, EmptyEnv() )
end

#
# ==================================================
#

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast, EmptyEnv() )
end

# Evaluate a series of tests in a file
function interpf( fn::AbstractString )
  f = open( fn )

  cur_prog = ""
  for ln in eachline(f)
      ln = chomp( ln )
      if length(ln) == 0 && length(cur_prog) > 0
          println( "" )
          println( "--------- Evaluating ----------" )
          println( cur_prog )
          println( "---------- Returned -----------" )
          try
              println( interp( cur_prog ) )
          catch errobj
              println( ">> ERROR: lxd" )
              lxd = Lexer.lex( cur_prog )
              println( lxd )
              println( ">> ERROR: ast" )
              ast = parse( lxd )
              println( ast )
              println( ">> ERROR: rethrowing error" )
              throw( errobj )
          end
          println( "------------ done -------------" )
          println( "" )
          cur_prog = ""
      else
          cur_prog *= ln
      end
  end

  close( f )
end

end #module
