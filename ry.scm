(use srfi-1 termbox format files posix utils)
(require-extension utf8)
(require-extension utf8-srfi-13)
(require-extension utf8-srfi-14)

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
(include "cursor.scm")
(include "commands.scm")

(include "modes.scm")

; Take in the top level keybinding for current mode at first
; Then, if matching in a sub keybinding, poll for an other keypress
; until (mode-match-keypress) gives back a proc or nothing.
(define (poll-input keybinding)
  (term-poll (lambda (mod key ch)
    (cond [(eq? key key-esc) (set! ch key)]
          [(eq? key key-tab) (set! ch key)]
          [(eq? key key-enter) (set! ch key)]
          [(eq? key key-space) (set! ch key)]
          [(eq? key key-backspace) (set! ch key)]
          [(eq? key key-backspace2) (set! ch key)])
    (if (eq? key key-ctrl-c)
      (kill-ry))
    (debug-pp (list 'poll-recieve mod key (integer->char ch)))
    (let ([current-key-handler (mode-match-keypress keybinding (integer->char ch))])
      (cond [(procedure? current-key-handler) (current-key-handler)]
            [(list? current-key-handler) (poll-input current-key-handler)])))))

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
  (if (null? (command-line-arguments))
    (add-buffer (new-buffer))
    (add-buffer (new-buffer-from-file (car (command-line-arguments)))))
  (init-window-tree (get-buffer-by-number 0))
  (enter-mode 'normal)
  (set-minibuffer-message "Thanks for using ry!")

  ; loop
  (let loop ()
    (term-update)
    (display-windows)
    (display-minibuffer)
    (term-flush)
    (poll-input (current-mode-keybinding))
    (when *running* (loop))))

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
