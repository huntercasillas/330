; Hunter Casillas
; CS 330 Lab 4

#lang racket
(require test-engine/racket-tests)

;;; default-parms ;;;
(define (default-parms f values)
  (lambda args
    (apply f (append args (list-tail values (length args))))))


;;; type-parms ;;;
(define (type-parms f types)
  (lambda args
    (map type-parms-aux types args)
     (apply f args)))

(define (type-parms-aux types args)
  (if (types args)
      true
      (error "Error. Invalid type.")))


;;; degrees-to-radians ;;;
(define (degrees-to-radians angle)
  (* pi (/ angle 180)))


;;; new-sin ;;;
(define (new-sin angle type)
  (cond
    ((symbol=? type 'radians) (sin angle))
    (else (sin (degrees-to-radians angle)))))


;;; new-sin2 ;;;
(define new-sin2 (default-parms
                   (type-parms
                    new-sin
                    (list number? symbol?))
                   (list 0 'radians)))

