(define (update-cursor window x y width height left-gutter-width)
  (if (window-focused? window)
    (let* ([pointer (buffer-pointer (window-buffer window))]
           [offsets (window-offsets window)]
           [going-down (> (cdr pointer) (- height 1))]
           [going-up (< (cdr pointer) (abs (cdr offsets)))]
           [off-y (cond [going-down (- 0 (- (cdr pointer) (- height 1)))]
                        [going-up (- 0 (cdr pointer))]
                        [else 0])]
           [update-offsets (or
             (and (> (cdr offsets) off-y) going-down)
             (and (< (cdr offsets) off-y) going-up))]
           [cur-x (+ x left-gutter-width (car pointer) (car offsets))]
           [cur-y (+ y (cdr pointer) (if update-offsets off-y (cdr offsets)))])
      (when update-offsets
        (update-current-window-prop 'offsets (lambda (window)
          (cons 0 off-y)))
        (set! window (set-assq window 'offsets (cons 0 off-y))))
      (term-move cur-x cur-y)))
  window)

(define (display-buffer window x y width height)
  (define left-gutter-width (+ 1 (string-length (number->string (+ height 1)))))
  (set! window (update-cursor window x y width height left-gutter-width))

  (let loop ([lines (buffer-lines (window-buffer window))]
             [current-y 0]
             [current-buffer-y (abs (cdr (window-offsets window)))])
    (when (<= current-y height)
      (term-display-with x y term-c-white term-c-default #f (lambda (d)
        (d 0 current-y (string-append-char
          (string-pad (number->string (+ current-buffer-y 1)) (- left-gutter-width 1))
          #\space))))
      (if (>= current-buffer-y (length lines))
        (term-display-with x y term-c-white term-c-default #f (lambda (d)
          (d left-gutter-width current-y (string-pad-right "ø" width))))
        (term-display-with x y term-c-white-light term-c-default #f (lambda (d)
          (d left-gutter-width current-y (string-pad-right (list-ref lines current-buffer-y) width)))))
      (loop lines (+ current-y 1) (+ current-buffer-y 1)))))

(define (display-status-bar window x y width)
  (let* ([buffer (window-buffer window)]
         [pos (buffer-pointer buffer)]
         [buffer-state-text (if (buffer-modified? buffer)
                              (if (buffer-readonly? buffer) "*%" "**")
                              "--")]
         [pos-text-x (number->string (+ (car pos) 1))]
         [pos-text-y (number->string (+ (cdr pos) 1))]
         [pos-text (string-append "(" pos-text-x ", " pos-text-y ")")]
         [mode-text (symbol->string (current-mode-name))]
         [bg-color (if (window-focused? window) term-c-blue term-c-blue-light)])
    (term-display-with x y term-c-white bg-color #f (lambda (d)
      (d 0 0 (make-string width #\-))
      (d 1 0 buffer-state-text)
      (d 4 0 (string-append " " (buffer-name buffer) " " pos-text " "))
      (d (- width (string-length mode-text) 3) 0 (string-append "(" mode-text ")"))))))

(define (display-window window x y width height)
  (display-buffer window x y width (- height 1))
  (display-status-bar window x (+ y height -1) width))

; Traverse window tree and render windows evenly
(define (display-windows% window x y width height)
  (let ([type (window-type window)])
    (cond [(eq? type 'horizontal)
             (let ([half (floor (/ width 2))])
               (display-windows% (assq 'left window) x y half height)
               (display-windows% (assq 'right window) (+ x half) y (- width half) height))]
          [(eq? type 'vertical)
             (let ([half (floor (/ height 2))])
               (display-windows% (assq 'top window) x y width half)
               (display-windows% (assq 'bottom window) x (+ y half) width (- height half)))]
          [(eq? type 'leaf)
              (display-window window x y width height)])))

(define (display-windows)
  (display-windows% (window-tree) 0 0 term-width (- term-height 1)))

; Render minibuffer's current state
(define (display-minibuffer% minibuffer-text minibuffer-error?)
  (let ([fg-color (if minibuffer-error? term-c-red term-c-white)])
    (term-display-with 0 0 fg-color term-c-default #f
      (lambda (d)
        (d 0 (- term-height 1) (make-string term-width #\space))
        (d 0 (- term-height 1) minibuffer-text)))))

(define (display-minibuffer)
  (display-minibuffer% minibuffer-text minibuffer-error?))
