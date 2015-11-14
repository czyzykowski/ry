(define *window-tree* '())

(define (new-window-leaf buffer-n)
  (list (cons 'type 'leaf)
        (cons 'focused? #f)
        (cons 'offsets (cons 0 0))
        (cons 'buffer buffer-n)))

; type=[leaf, horizontal, vertical]
; position=[left, right, top, bottom]
(define (new-window type a b)
  (list (cons 'type type)
        (if (eq? type 'vertical)
          (cons 'left a)
          (cons 'top a))
        (if (eq? type 'vertical)
          (cons 'right b)
          (cons 'bottom b))))

(define (window-set-focused win r)
  (set-assq win 'focused? r))

(define (window-type window)
  (cdr (assq 'type window)))

(define (window-buffer window)
  (get-buffer-by-number (cdr (assq 'buffer window))))

(define (window-offsets window)
  (cdr (assq 'offsets window)))

(define (window-focused? window)
  (cdr (assq 'focused? window)))

(define (init-window-tree buffer-n)
  (let ([root-window (new-window-leaf buffer-n)])
    (set! *window-tree* (window-set-focused root-window #t))))

(define (window-tree)
  *window-tree*)

; Recursively traverses window tree handing lead windows to provided callback
(define (map-window-leafs fn window)
  (let ([type (window-type window)])
    (cond [(eq? 'leaf type) (fn window)]
          [(eq? 'horizontal type)
            (new-window 'horizontal
              (map-window-leafs fn (cdr (assq 'top window)))
              (map-window-leafs fn (cdr (assq 'bottom window))))]
          [(eq? 'vertical type)
            (new-window 'vertical
              (map-window-leafs fn (cdr (assq 'left window)))
              (map-window-leafs fn (cdr (assq 'right window))))])))

(define (map-window-leafs! fn)
  (set! *window-tree*
    (map-window-leafs fn *window-tree*)))

(define (update-current-window-prop prop fn)
  (map-window-leafs!
    (lambda (window)
      (if (window-focused? window)
        (set-assq window prop (fn window))
        window))))

; Finds the first window marked as focused
(define (current-window)
  (call-with-current-continuation
    (lambda (k)
      (map-window-leafs
        (lambda (win)
          (if (window-focused? win) (k win)))
        *window-tree*))))

(define (path-to-current-window% window path)
  (let ([type (window-type window)])
    (cond [(eq? type 'leaf) (if (window-focused? window) path #f)]
          [(eq? type 'vertical)
            (or (path-to-current-window% (cdr (assq 'left window)) (cons 'left path))
                (path-to-current-window% (cdr (assq 'right window)) (cons 'right path)))]
          [(eq? type 'horizontal)
            (or (path-to-current-window% (cdr (assq 'top window)) (cons 'top path))
                (path-to-current-window% (cdr (assq 'bottom window)) (cons 'bottom path)))])))

(define (path-to-current-window)
  (let ([path (path-to-current-window% *window-tree* '())])
    (if path (reverse path) #f)))

; Orientation is horizontal or vertical, position is 'a or 'b
(define (split-window orientation)
  (map-window-leafs!
    (lambda (window)
      (if (window-focused? window)
        (new-window orientation
          window
          (set-assq window 'focused? #f))
        window))))

(define split-window-vertically (lambda () (split-window 'vertical)))
(define split-window-horizontally (lambda () (split-window 'horizontal)))

(define (quit-window)
  #f)

(define (replace-window window path fn)
  (cond [(not window) (error "Invalid path given to replace-window")]
        [(null? path) (fn window)]
        [else
          (set-assq window (car path)
            (replace-window (cdr (assq (car path) window)) (cdr path) fn))]))

(define (window-position-opposite position)
  (cond [(eq? position 'left) 'right]
        [(eq? position 'right) 'left]
        [(eq? position 'top) 'bottom]
        [(eq? position 'bottom) 'top]))

(define (window-move-left)
  (let* ([current-path (path-to-current-window)]
         [last-position (car (reverse current-path))]
         [last-position-opposite (window-position-opposite last-position)]
         [new-focused-window-path (reverse (cons last-position-opposite (cdr (reverse current-path))))])
    (set! *window-tree*
      (replace-window *window-tree* current-path (lambda (window)
        (set-assq window 'focused? #f))))
    (debug-pp (list current-path new-focused-window-path *window-tree*))
    (set! *window-tree*
      (replace-window *window-tree* new-focused-window-path (lambda (window)
        (set-assq window 'focused? #t))))))

(define (window-move-right)
  (window-move-left))

(define (window-move-down)
  #f)

(define (window-move-up)
  #f)
