# Hunter Casillas
# CS 330
# Elixir Basics

defmodule Elixir_Intro do

	# Fibonacci Functions
	def fib(0) do
		0
	end

	def fib(1) do
		1
	end

	def fib(n) do
		fib(n-1) + fib(n-2)
	end

	# Area Functions
	def area(:rectangle, {length, height}) do
		length * height
	end

	def area(:square, side) do
		side * side
	end

	def area(:circle, radius) do
		:math.pi * (radius * radius)
	end

	def area(:triangle, {base, height}) do
		0.5 * base * height
	end

	# Square List Function
	def sqrList(nums) do
		for i <- nums do
			i * i
		end
	end

	# Calculate Totals Function
	def calcTotals(inventory) do
		for {item, quantity, price} <- inventory do
			{item, (quantity * price)}
		end
	end

	# Map Function
	def map(function, vals) do
		for i <- vals do
			function.(i)
		end
	end

	# Quick Sort Server Functions
	def quickSortServer() do
		receive do
			{list, pid} -> send(pid, {quickSort(list), self()})
		end
		quickSortServer()
	end

	def quickSort([]) do
		[]
	end

	# Got this code from the Elixir 1 slide on Learning Suite
	def quickSort(list) do
		random = :random.uniform(length(list))
		pivot = :lists.nth(random, list)
		rest = :lists.delete(pivot, list)
		lower = for i <- rest, i < pivot do i end
		higher = for i <- rest, i >= pivot do i end
		quickSort(lower) ++ [pivot] ++ quickSort(higher)
	end
end

# Module to test Quick Sort Server
# defmodule Client do
#     def callServer(pid,nums) do
#         send(pid, {nums, self()})
#	 listen()
#     end
#     def listen do
#         receive do
#	     {sorted, pid} -> sorted
#	 end
#     end
# end

# pid = spawn &Elixir_Intro.quickSortServer/0
# IO.inspect(Client.callServer(pid, [5, 6, 3, 2, 8]))
