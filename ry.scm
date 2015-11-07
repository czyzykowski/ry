(use srfi-1 ncurses format)

(include "util.scm")
(include "log.scm")
(include "term.scm")
(include "display.scm")
(include "movement.scm")
(include "editing.scm")
(include "buffer.scm")
(include "windows.scm")

;;; Minibuffer

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
  (display-minibuffer input-text #f)
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

;;; Commands

(define (smex lines pos running mode)
  (let ([command-text (edit-minibuffer "(")])
    (if command-text
      (let ([eval-result (eval-string command-text)])
        (if (car eval-result)
          (set-minibuffer-message (cdr eval-result))
          (set-minibuffer-error (cdr eval-result)))))
    (values lines pos running mode)))

(define *running* #t)

(define (set-running-state state)
  (set! *running* state))

(define (kill-ry)
  (set! *running* #f))

; TODO Actually save
(define (save-buffers-kill-ry)
  (kill-ry))

(include "modes.scm")

(define (main-loop)
  (let loop ()
    (if *running*
      (begin
        (term-update)
        (display-windows)
        (display-status-bar)
        (display-minibuffer)
        (term-flush)
        (loop)))))

(define (handle-exception exn)
  (term-shutdown)
  (print-error-message exn)
  (newline)
  (print-call-chain)
  (exit 1))

(define (main)
  (let ([filename (car (command-line-arguments))])
    (if (null? filename)
      (add-buffer (new-buffer))
      (add-buffer (new-buffer-from-file filename))))
  (handle-exceptions exn (handle-exception exn)
    (begin
      (term-init)
      (main-loop)
      (term-shutdown))))

(main)
