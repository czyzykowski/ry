(use srfi-1 ncurses format files posix utils)

(define *running* #t)

(define (set-running-state state)
  (set! *running* state))

(include "util.scm")
(include "log.scm")
(include "term.scm")

(include "minibuffer.scm")
(include "buffer.scm")
(include "windows.scm")

(include "display.scm")
(include "currsor")
(include "commands.scm")

(include "modes.scm")

; Take in the top level keybinding for current mode at first
; Then, if matching in a sub keybinding, poll for an other keypress
; until (mode-match-keypress) gives back a proc or nothing.
(define (poll-input keybinding)
  (let ([current-key-handler (mode-match-keypress keybinding (term-readch))])
    (debug-pp current-key-handler)
    (cond [(procedure? current-key-handler) (current-key-handler)]
          [(list? current-key-handler) (poll-input current-key-handler)])))

; Main application loop, at this point our code is wrapped in exception
; handling.
; All we need to do is set up the editor:
;  - Load file if one was passed as CLI arg
;  - Ensure we have a buffer (empty or from file)
;  - Initialize window tree with newly created buffer
;  - Enter normal mode
;  - Welcome user
; After that we loop alternating between rendering and polling for keys
(define (main-loop)
  ; setup
  (let ([filename (car (command-line-arguments))])
    (if (null? filename)
      (add-buffer (new-buffer))
      (add-buffer (new-buffer-from-file filename))))
  (init-window-tree (get-buffer-by-number 0))
  (enter-mode 'normal)
  (set-minibuffer-message "Thanks for using ry!")

  ; loop
  (let loop ()
    (if *running*
      (begin
        (term-update)
        (display-windows)
        (display-minibuffer)
        (term-flush)
        (poll-input (current-mode-keybinding))
        (loop)))))

(define (handle-exception exn)
  (term-shutdown)
  (print-error-message exn)
  (newline)
  (print-call-chain)
  (exit 1))

(define (main)
  (handle-exceptions exn (handle-exception exn)
    (begin
      (term-init)
      (main-loop)
      (term-shutdown))))

(main)
