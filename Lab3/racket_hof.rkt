; Hunter Casillas
; CS 330 Lab 3

#lang racket
(require test-engine/racket-tests)

;;; check-temps1 ;;;
(define (check-temps1 temps)
  (andmap (lambda (x)
            (cond
              ((< x 5) false)
              ((> x 95) false)
              (else true))) temps))


;;; check-temps ;;;
(define (check-temps temps low high)
  (andmap (lambda (x)
            (cond
              ((< x low) false)
              ((> x high) false)
              (else true))) temps))


;;; convert ;;;
(define (convert digits)
  (foldr (lambda (x y) (+ x (* 10 y))) 0 digits))


;;; duple ;;;
(define (duple lst)
  (map (lambda (x) (list x x)) lst))


;;; average ;;;
(define (average lst)
  (/ (foldr + 0 lst) (length lst)))


;;; convertFC ;;;
(define (convertFC temps)
  (map (lambda (x) (* (- x 32) (/ 5 9))) temps))


;;; eliminate-larger ;;;
(define (eliminate-larger lst)
  (if (empty? lst)
      empty
      (foldr (lambda (x y z)
               (if (< x (first z))
                   (cons x z) z))
             (list (last lst)) lst lst)))


;;; curry2 ;;;
(define (((curry2 func) parameter1) parameter2)
  (func parameter1 parameter2))

