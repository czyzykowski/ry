(define (display-buffer window x y width height)
  (define left-gutter-width (+ 1 (string-length (number->string (+ height 1)))))

  (if (window-focused? window)
    (let ([pointer (buffer-pointer (window-buffer window))])
      (term-move (+ x left-gutter-width (car pointer)) (+ y (cdr pointer)))))

  (let loop ([lines (buffer-lines (window-buffer window))]
             [current-y 0])
    (when (<= current-y height)
      (term-display-with x y term-c-white term-c-default #f (lambda (d)
        (d 0 current-y (string-append-char
          (string-pad (number->string (+ current-y 1)) (- left-gutter-width 1))
          #\space))))
      (if (null? lines)
        (begin
          (term-display-with x y term-c-white term-c-default #f (lambda (d)
            (d left-gutter-width current-y (string-pad-right "~" width))));"࿋")))
          (loop '() (+ current-y 1)))
        (begin
          (term-display-with x y term-c-white term-c-default #f (lambda (d)
            (d left-gutter-width current-y (string-pad-right (car lines) width))))
          (loop (cdr lines) (+ current-y 1)))))))

(define (display-status-bar window x y width)
  (let* ([buffer (window-buffer window)]
         [pos (buffer-pointer buffer)]
         [buffer-state-text (if (buffer-modified? buffer)
                              (if (buffer-readonly? buffer) "*%" "**")
                              "--")]
         [pos-text (string-append
                     "(" (number->string (car pos)) ", "
                     (number->string (cdr pos)) ")")]
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
