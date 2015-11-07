(define *window-tree* '())

(define (new-window-leaf buffer)
  (list '(type leaf)
        '(focused #f)
        (list 'buffer buffer)))

; type=[left, horizontal, vertical]
; position=[left, right, top, bottom]
(define (new-window type a b)
  (list (list 'type type)
        (if (eq? type 'horizontal)
          (list 'top a)
          (list 'left a))
        (if (eq? type 'vertical)
          (list 'bottom b)
          (list 'right b))))

(define (window-set-focused win r)
  (set-assq win 'focused r))

(define (init-window-tree buffer)
  (let ([root-window (new-window-leaf buffer)])
    (set! *window-tree* (window-set-focused (new-window-leaf buffer) #t))))

(define (add-window window)
  (set! *window-tree* (cons window *window-tree*)))

(define (map-window-leafs fn window)
  (let ([type (assq 'type window)])
    (cond [(eq? 'leaf type) (fn window)]
          [(eq? 'horizontal type)
            (new-window 'horizontal
              (assq 'left (map-windows fn (assq 'left window)))
              (assq 'right (map-windows fn (assq 'right window))))]
          [(eq? 'vertical type)
            (new-window 'vertical
              (assq 'top (map-windows fn (assq 'top window)))
              (assq 'bottom (map-windows fn (assq 'bottom window))))])))

(define (current-window)
  (call-with-current-continuation
    (lambda (exit)
      (map-window-leafs
        (lambda (win)
          (if (eq? (assq 'focused win) #t)
            (exit win)))
        *window-tree*))))
