(define *window-tree* '())

(define (new-window-leaf buffer)
  (list (cons 'type 'leaf)
        (cons 'focused? #f)
        (cons 'offsets (cons 0 0))
        (cons 'buffer buffer)))

; type=[left, horizontal, vertical]
; position=[left, right, top, bottom]
(define (new-window type a b)
  (list (cons 'type type)
        (if (eq? type 'horizontal)
          (cons 'top a)
          (cons 'left a))
        (if (eq? type 'vertical)
          (cons 'bottom b)
          (cons 'right b))))

(define (window-set-focused win r)
  (set-assq win 'focused? r))

(define (window-type window)
  (cdr (assq 'type window)))

(define (window-buffer window)
  (cdr (assq 'buffer window)))

(define (window-focused? window)
  (cdr (assq 'focused? window)))

(define (init-window-tree buffer)
  (let ([root-window (new-window-leaf buffer)])
    (set! *window-tree* (window-set-focused (new-window-leaf buffer) #t))))

(define (add-window window)
  (set! *window-tree* (cons window *window-tree*)))

(define (window-tree)
  *window-tree*)

; Recursively traverses window tree handing lead windows to provided callback
(define (map-window-leafs fn window)
  (let ([type (window-type window)])
    (cond [(eq? 'leaf type) (fn window)]
          [(eq? 'horizontal type)
            (new-window 'horizontal
              (assq 'left (map-windows fn (assq 'left window)))
              (assq 'right (map-windows fn (assq 'right window))))]
          [(eq? 'vertical type)
            (new-window 'vertical
              (assq 'top (map-windows fn (assq 'top window)))
              (assq 'bottom (map-windows fn (assq 'bottom window))))])))

; Finds the first window marked as focused
(define (current-window)
  (call-with-current-continuation
    (lambda (k)
      (map-window-leafs
        (lambda (win)
          (if (eq? (assq 'focused win) #t)
            (k win)))
        *window-tree*))))
