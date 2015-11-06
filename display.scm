(define (display-lines lines)
  (let loop ([l lines]
             [y 0])
    (if (not (null? l))
      (begin
        (term-display 0 y (car l))
        (loop (cdr l) (+ y 1))))))

(define (display-status-bar lines pos)
  (let ([pos-text (string-append
                    " (" (number->string (car pos)) ", "
                    (number->string (cdr pos)) ") ")])
    (term-display-with 0 0 A_REVERSE (lambda ()
      (term-display 0 (- term-height 2) (make-string term-width #\-))
      (term-display 5 (- term-height 2) pos-text)))))

(define (display-minibuffer text)
  (term-display 0 (- term-height 1)
                (make-string (- term-width 1) #\space))
  (term-display 0 (- term-height 1) text))
