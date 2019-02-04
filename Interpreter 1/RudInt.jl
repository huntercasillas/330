#
# Hunter Casillas
# CS 330
# Interpreter 1
#

module RudInt

push!(LOAD_PATH, pwd())

using Error
using Lexer
export parse, calc, interp

#
# ==================================================
#

abstract type AE
end

# <AE> ::= <number>
struct NumNode <: AE
    n::Real
end

struct BinopNode <: AE
	op::Function
	lhs::AE
	rhs::AE
end

struct UnopNode <: AE
	op::Function
	n::AE
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

opDict = Dict( :+ => +, :- => -, :* => *, :/ => /, :mod => mod, :collatz => collatz )

#
# ==================================================
#

function parse( expr::Number )
    return NumNode( expr )
end

function parse( expr::Array{Any} )
	# Check for Unary Operation
	if length( expr ) != 2 && length( expr ) != 3
		throw( LispError( "Error. Invalid expression." ) )

	elseif length( expr ) == 2
		operator = expr[1]
		number = parse( expr[2] )

		if operator == :-
			return UnopNode( opDict[:-], number )
		elseif operator == :collatz
			return UnopNode( opDict[:collatz], number )
		elseif operator !- :- && operator != :collatz
			throw( LispError( "Error. Invalid operator type.") )
		end

	# Check for Binary Operation
	elseif length( expr ) == 3
		operator = expr[1]
		lhs = parse( expr[2] )
		rhs = parse( expr[3] )

		if operator == :+
	        return BinopNode( opDict[:+], lhs, rhs )
	    elseif operator == :-
	        return BinopNode(opDict[:-], lhs, rhs )
		elseif operator == :*
			return BinopNode(opDict[:*], lhs, rhs )
		elseif operator == :/
			return BinopNode(opDict[:/], lhs, rhs )
		elseif operator == :mod
			return BinopNode(opDict[:mod], lhs, rhs )
		elseif operator == :collatz
			throw( LispError( "Error. Use collatz with a single number.") )
		elseif operator != :+ && operator != :- && operator != :* && operator != :/ && operator != :mod
			throw( LispError( "Error. Invalid operator type." ) )
		end

	else
		throw( LispError( "Error. Invalid syntax." ) )
	end
end

function parse( expr::Any )
  throw( LispError( "Error. Invalid type $expr." ) )
end

#
# ==================================================
#

function calc( ast::NumNode )
    return ast.n
end

function calc( ast::BinopNode )
	operator = ast.op
	lhs = calc( ast.lhs )
	rhs = calc( ast.rhs )

	if operator == opDict[:/] && rhs == 0
		throw( LispError( "Error. You cannot divide by zero." ) )
	else
    	return operator( lhs, rhs )
	end
end

function calc( ast::UnopNode )
	operator = ast.op
	number = calc( ast.n )

	if operator == opDict[:collatz] && number < 1
		throw( LispError( "Error. Collatz cannot be less than 1." ) )
	else
		return operator( number )
	end
end

#
# ==================================================
#

function interp( cs::AbstractString )
    lxd = Lexer.lex( cs )
    ast = parse( lxd )
    return calc( ast )
end

end #module
