(define *window-tree* '())

(define (new-window-leaf buffer)
  (list ('type 'leaf)
        ('focused #f)
        ('buffer buffer)))

; type:(left horizontal vertical) position:(left right top bottom)
(define (new-window type a b)
  (list ('type type)
        (if (eq? type 'horizontal)
          ('top a)
          ('left a))
        (if (eq? type 'vertical)
          ('bottom b)
          ('right b))))

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
      (map-window-leafs (lambda (win)
        (if (eq? (assq 'focused win) #t)
          (exit win)))))))
