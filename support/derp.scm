(import chicken scheme)
(use srfi-1)

(define (curry f . c)
  (lambda x (apply f (append c x))))

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
    (bitwise-and (arithmetic-shift hex 16) 255)
    (bitwise-and (arithmetic-shift hex 8) 255)
    (bitwise-and hex 255)))

(define (hex->rgb hex)
  (values
    (bitwise-and (arithmetic-shift hex 16) 255)
    (bitwise-and (arithmetic-shift hex 8) 255)
    (bitwise-and hex 255)))
