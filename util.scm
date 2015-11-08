(define (curry f . c)
  (lambda x (apply f (append c x))))

(define (string-append-char str ch)
  (string-append str (make-string 1 ch)))

(define (set-assq al key value)
  (cond [(null? al) al]
        [(eq? key (caar al)) (cons (list key value) (cdr al))]
        [else (cons (car al) (set-assq (cdr al) key value))]))

(define *rgb-cubelevels* (list #x00 #x5f #x87 #xaf #xd7 #xff))
(define *rgb-snaps* (map
  (lambda (xy) (floor (/ (+ (car xy) (cadr xy)) 2)))
  (cdr (zip *rgb-cubelevels* (cons 0 *rgb-cubelevels*)))))

(define (rgb->term base-r base-g base-b)
  (let ([r (length (filter-map (curry < base-r) *rgb-snaps*))]
        [g (length (filter-map (curry < base-r) *rgb-snaps*))]
        [b (length (filter-map (curry < base-r) *rgb-snaps*))])
  (+ (* r 36) (* g 6) b 16)))

(define (hex->term hex)
  (rgb->term
    (bitwise-and (arithmetic-shift hex -16) 255)
    (bitwise-and (arithmetic-shift hex -8) 255)
    (bitwise-and hex 255)))

(define (eval-string input-text)
  (handle-exceptions
    exn
    (cons #f (string-append "Error: "
               ((condition-property-accessor 'exn 'message) exn)))
    (cons #t (string-trim-both
               (format #f "~Y"
                 (eval (with-input-from-string input-text read)))))))

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

(define (lines-height lines)
  (if (not (null? lines))
    (max 0 (- (length lines) 1))
    0))

(define (lines-width lines y)
  (if (< y (length lines))
    (max 0 (- (string-length (list-ref lines y)) 1))
    0))
