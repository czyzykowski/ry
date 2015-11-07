(define minibuffer-error? #f)
(define minibuffer-text "")

(define (set-minibuffer-message message)
  (set! minibuffer-error? #f)
  (set! minibuffer-text message))

(define (set-minibuffer-error message)
  (set! minibuffer-error? #t)
  (set! minibuffer-text message))

(define (edit-minibuffer input-text)
  (term-move (string-length input-text) (- term-height 1))
  (display-minibuffer% input-text #f)
  (let ([c (getch)])
    (cond [(char=? c (integer->char 10)) ; enter
            input-text]
          [(char=? c (integer->char 27)) ; esc
            #f]
          [(or (int-for-char=? c 8) (int-for-char=? c 127)) ; del|bksp
            (edit-minibuffer (string-drop-right input-text 1))]
          [(char-visible? c)
            (edit-minibuffer (string-append-char input-text c))]
          [else
            (edit-minibuffer input-text)])))
