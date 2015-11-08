(define (pos-nudge-xy pos x-change y-change)
  (cons
    (+ (car pos) x-change)
    (+ (cdr pos) y-change)))

(define (pos-nudge-x pos x-change)
  (pos-nudge-xy pos x-change 0))

(define (pos-nudge-y pos y-change)
  (pos-nudge-xy pos 0 y-change))

(define (try-move buffer new-pointer)
  (let* ([x (car new-pointer)]
         [y (cdr new-pointer)]
         [lines (buffer-lines buffer)]
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
  (update-current-buffer-pointer (lambda (buffer)
    (pos-nudge-y (buffer-pointer buffer) -1))))

(define (next-line)
  (update-current-buffer-pointer (lambda (buffer)
    (pos-nudge-y (buffer-pointer buffer) 1))))

(define (backward-char)
  (update-current-buffer-pointer (lambda (buffer)
    (pos-nudge-x (buffer-pointer buffer) -1))))

(define (forward-char)
  (update-current-buffer-pointer (lambda (buffer)
    (pos-nudge-x (buffer-pointer buffer) 1))))
