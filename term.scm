;;; termbox wrapper layer
;;;
;;; This abstraction layer is user to give us the flexibility for change the
;;; backing terminal drawing library, ncurses and it's quirks and is pretty
;;; heavy for our use case but works out of the box on many systems.

(define term-c-default #x00)
(define term-c-black black)
(define term-c-red red)
(define term-c-green green)
(define term-c-yellow yellow)
(define term-c-blue blue)
(define term-c-magenta magenta)
(define term-c-cyan cyan)
(define term-c-white white)

(define term-a-bold bold)
(define term-a-underline underline)
(define term-a-reversed reversed)

(define term-height 0)
(define term-width 0)

(define (term-init)
  (init)
  ;(input-mode 'alt)
  (output-mode 'normal))

(define (term-shutdown)
  (shutdown))

(define (term-update)
  (clear term-c-default term-c-default)
  (set! term-width (width))
  (set! term-height (height)))

(define (term-flush)
  (present))

(define (term-move x y)
  (cursor-set! x y))

(define (term-display x y text #!optional
                               (fg term-c-black)
                               (bg term-c-default)
                               (attr #f))
  (let* ([fg-style (if attr (style fg attr) (style fg))]
         [bg-style (style bg)]
         [cells (create-cells text fg-style bg-style)])
    (let loop ([i 0]
              [cells-left cells])
      (if (not (null? cells-left))
        (begin
          (put-cell! (+ x i) y (car cells-left))
          (loop (+ i 1) (cdr cells-left)))))))

(define (term-display-with base-x base-y fg bg attr fn)
  (fn (lambda (x y text)
    (let ([rx (+ base-x x)]
          [ry (+ base-y y)])
      (term-display rx ry text fg bg attr)))))

(define (term-poll fn)
  (poll fn (lambda (x y) (term-poll fn))))
