-- Hunter Casillas
-- CS 330
-- Haskell and Laziness

import Data.Array

-- Takes integer n and returns true if n is prime, false otherwise
isPrime :: Int -> Bool
isPrime n = null [ x|x <- [2..(iSqrt n)], n `mod` x  == 0]

-- Creates an infinite list of all primes and names it primes
primes :: [Int]
primes = filter(isPrime) [2..]

-- Takes an integer n and returns true if n is prime
-- Tests for divisibility using only prime numbers in this range
isPrimeFast :: Int -> Bool
isPrimeFast n = null [ x|x <-takeWhile ( <= (iSqrt n)) primesFast, n `mod` x == 0]

-- Creates an infinite list of all primes and names it primesFast, constructed with isPrimeFast
primesFast :: [Int]
primesFast = 2 : filter (isPrimeFast) [3..]

-- Returns the largest integer smaller than the square root of another integer
iSqrt :: Int -> Int
iSqrt n = floor(sqrt(fromIntegral n))

-- Computes the length of the longest common subsequence of two strings s1 and s1
lcsLength :: String -> String -> Int
lcsLength string1 string2 = a!(length1, length2)
  where length1 = length string1
        length2 = length string2
        a = array ((0, 0), (length1, length2))
         ([((0, j), 0)| j <- [0..length2]]++
          [((i, 0), 0)| i <- [1..length1]]++
          [((i, j), if string1!!(i - 1) == string2!!(j - 1)
           then a!(i - 1, j - 1) + 1 else max (a!(i - 1, j))(a!(i, j - 1)))
             | i <- [1..length1], j <-[1..length2]])
