(define (curry f . c)
  (lambda x (apply f (append c x))))

(define (string-append-char str ch)
  (string-append str (make-string 1 ch)))

(define (set-assq al key value)
  (cond [(null? al) al]
        [(eq? key (caar al)) (cons (list key value) (cdr al))]
        [else (cons (car al) (set-assq (cdr al) key value))]))

(define (eval-string input-text)
  (string-trim-both
    (format #f "~Y"
      (eval (with-input-from-string input-text read)))))

(define (char-visible? ch)
  (let ([ascii-num (char->integer ch)])
    (if (and (>= ascii-num 32) ; space
             (<= ascii-num 126)) ; ~
      #t
      #f)))

(define (int-for-char=? ch num)
  (char=? ch (integer->char num)))

(define (pos-nudge-xy pos x-change y-change)
  (cons
    (+ (car pos) x-change)
    (+ (cdr pos) y-change)))

(define (pos-nudge-x pos x-change)
  (pos-nudge-xy pos x-change 0))

(define (pos-nudge-y pos y-change)
  (pos-nudge-xy pos 0 y-change))
