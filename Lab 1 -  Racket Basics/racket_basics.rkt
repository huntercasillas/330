; Hunter Casillas
; CS 330 Lab 1

#lang racket
(require test-engine/racket-tests)

;;; sum-coins ;;;
(define (sum-coins pennies nickels dimes quarters)
  (+ pennies (* nickels 5) (* dimes 10) (* quarters 25)))


;;; degrees-to-radians ;;;
(define (degrees-to-radians angle)
  (* pi (/ angle 180)))


;;; sign ;;;
(define (sign x)
  (cond
    ((equal? x 0) 0)
    ((negative? x) -1)
    (else 1)))


;;; new-sin ;;;
(define (new-sin angle type)
  (cond
    ((symbol=? type 'radians) (sin angle))
    (else (sin (degrees-to-radians angle)))))

