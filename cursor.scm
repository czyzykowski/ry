(define (try-move lines pos)
  (let* ([x (car pos)]
         [y (cdr pos)]
         [height (lines-height lines)]
         [ny (cond [(> y height) height]
                   [(< y 0) 0]
                   [else y])]
         [width (lines-width lines ny)]
         [nx (cond [(> x width) width]
                   [(< x 0) 0]
                   [else x])])
    (cons nx ny)))

(define (previous-line)
  (values lines (try-move lines (pos-nudge-y pos -1)) r m))

(define (next-line)
  (values lines (try-move lines (pos-nudge-y pos 1)) r m))

(define (backward-char)
  #f)
;  (values lines (try-move lines (pos-nudge-x pos -1)) r m))

(define (forward-char)
  (values lines (try-move lines (pos-nudge-x pos 1)) r m))
