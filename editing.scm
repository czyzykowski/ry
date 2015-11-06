(define (split-elt l elt)
  (let loop ((head '())
             (tail l)
             (i 0))
   (if (eq? tail '())
     (values l '())
     (if (= elt i)
       (values (reverse head) tail)
       (loop (cons (car tail) head)
             (cdr tail)
             (+ i 1))))))

(define (insert-string lines pos str)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (string->list str) lrest)) (cdr rest))))))))

(define (insert-char lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char lrest))) (cdr rest))))))))

(define (self-insert-char c)
  (lambda (lines pos running mode)
    (values
      (insert-char lines pos c)
      (try-move lines (pos-nudge-x pos 1))
      running mode)))

#|
(define (change-char lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char (cdr lrest)))) (cdr rest))))))))
|#

(define (change-char lines pos running mode)
  (values lines pos running mode))

(define (delete-char lines pos running mode)
  (values
    (if (and (< (cdr pos) (length lines)) (>= (cdr pos) 0))
      (if (and (< (car pos) (string-length (list-ref lines (cdr pos)))) (>= (car pos) 0))
        (call-with-values
          (lambda () (split-elt lines (cdr pos)))
          (lambda (head rest)
            (call-with-values
              (lambda () (split-elt (string->list (car rest)) (car pos)))
              (lambda (lhead lrest) (append head (cons (list->string (append lhead (cdr lrest))) (cdr rest)))))))
        lines)
      lines)
    pos running mode))

(define (delete-line lines line)
  (if (< line (length lines))
    (call-with-values
      (lambda () (split-elt lines line))
      (lambda (head rest) (append head (cdr rest))))
    lines))

(define delete-backward-char (compose delete-char backward-char))
(define delete-forward-char delete-char)

(define (kill-whole-line lines pos running mode)
  (let* ([new-lines (delete-line lines (cdr pos))]
         [new-pos (try-move new-lines pos)])
    (values new-lines new-pos running mode)))
