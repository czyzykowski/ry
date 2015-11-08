(define minibuffer-error? #f)
(define minibuffer-text "")

(define (set-minibuffer-message message)
  (set! minibuffer-error? #f)
  (set! minibuffer-text message))

(define (set-minibuffer-error message)
  (set! minibuffer-error? #t)
  (set! minibuffer-text message))

(define command-mode-handler (make-parameter #f))
(define command-mode-previous-mode (make-parameter #f))

(define (command-mode-insert-char ch)
  (lambda ()
    (set-minibuffer-message (string-append-char minibuffer-text ch))
    (term-move (string-length minibuffer-text) (- term-height 1))))

(define (command-mode-delete-char)
  (set-minibuffer-message (string-drop-right minibuffer-text 1))
  (term-move (string-length minibuffer-text) (- term-height 1)))

(define (command-mode-commit)
  (let ([text minibuffer-text]
        [handler (command-mode-handler)]
        [previous-mode (command-mode-previous-mode)])
    (set-minibuffer-message "")
    (command-mode-handler #f)
    (command-mode-previous-mode #f)
    (if previous-mode (enter-mode previous-mode))
    (if handler (handler text))))

(define (edit-minibuffer input-text fn)
  (set-minibuffer-message input-text)
  (term-move (string-length input-text) (- term-height 1))
  (command-mode-previous-mode (current-mode-name))
  (enter-mode 'command)
  (command-mode-handler fn))
