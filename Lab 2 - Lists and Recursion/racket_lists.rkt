; Hunter Casillas
; CS 330 Lab 2

#lang racket
(require test-engine/racket-tests)

;;; check-temps1 ;;;
(define (check-temps1 temps)
  (if (empty? temps)
      true
      (cond
        ((< (first temps) 5) false)
        ((> (first temps) 95) false)
        (else (check-temps1 (rest temps))))))


;;; check-temps ;;;
(define (check-temps temps low high)
  (if (empty? temps)
      true
      (cond
        ((< (first temps) low) false)
        ((> (first temps) high) false)
        (else (check-temps (rest temps) low high)))))


;;; convert ;;;
(define (convert digits)
  (convert-aux digits 1))
        
(define (convert-aux digits power)
  (if (empty? digits)
      0
      (+ (* (first digits) power) (convert-aux (rest digits) (* 10 power)))))


;;; duple ;;;
(define (duple lst)
  (if (empty? lst)
      empty
      (cons (list (first lst) (first lst))
            (duple (rest lst)))))


;;; average ;;;
(define (average lst)
  (/ (average-aux lst) (length lst)))

(define (average-aux lst)
  (if (empty? lst)
      0
      (+ (first lst) (average-aux (rest lst)))))


;;; convertFC ;;;
(define (convertFC temps)
  (if (empty? temps)
      empty
      (cons (* (- (first temps) 32) (/ 5 9)) (convertFC (rest temps)))))


;;; eliminate-larger ;;;
(define (eliminate-larger lst)
  (if (empty? lst)
      empty
      (if (check-size? (rest lst) (first lst))
          (cons (first lst) (eliminate-larger (rest lst)))
          (eliminate-larger (rest lst)))))

(define (check-size? lst size)
  (if (empty? lst)
      true
      (if (< (first lst) size)
          false
          (check-size? (rest lst) size))))


;;; get-nth ;;;
(define (get-nth lst n)
  (if (equal? 0 n)
      (first lst)
      (get-nth (rest lst) (- n 1))))


;;; find-item ;;;
(define (find-item lst target)
  (find-item-aux lst target 0))

(define (find-item-aux lst target index)
  (if (empty? lst)
      -1
      (if (equal? (first lst) target)
          index
          (find-item-aux (rest lst) target (+ 1 index)))))
