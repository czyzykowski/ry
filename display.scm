(define (display-lines lines pos)
  (term-move (car pos) (cdr pos))
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
    (term-display-with -1 -1 A_REVERSE (lambda ()
      (term-display 0 (- term-height 2) (make-string term-width #\-))
      (term-display 5 (- term-height 2) pos-text)))))

(define (display-minibuffer)
  (term-display 0 (- term-height 1)
                (make-string (- term-width 1) #\space))
    (term-display-with (if minibuffer-error? COLOR_RED -1) -1 A_BOLD
      (lambda ()
        (term-display 0 (- term-height 1) minibuffer-text))))
