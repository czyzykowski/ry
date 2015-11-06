(use srfi-1 srfi-14 ncurses format)

(include "util.scm")
(include "log.scm")
(include "term.scm")
(include "display.scm")

;;; Minibuffer
(define minibuffer-text "")

(define (set-minibuffer-message message)
  (set! minibuffer-text message))

(define (lines-height lines)
  (if (not (null? lines))
    (max 0 (- (length lines) 1))
    0))

(define (lines-width lines y)
  (if (< y (length lines))
    (max 0 (- (string-length (list-ref lines y)) 1))
    0))

;;; Movement
(define (try-move lines pos)
  (let* ([x (car pos)]
         [y (cdr pos)]
         [height (lines-height lines)]
         [ny (cond [(> y height) height]
                   [(< y 0) 0]
                   [else y])]
         [width (lines-width lines ny)]
         [nx (cond [(> x width) width]
                   [(< x 0) 0]
                   [else x])])
    (cons nx ny)))

(define (previous-line lines pos r m)
  (values lines (try-move lines (pos-nudge-y pos -1)) r m))

(define (next-line lines pos r m)
  (values lines (try-move lines (pos-nudge-y pos 1)) r m))

(define (backward-char lines pos r m)
  (values lines (try-move lines (pos-nudge-x pos -1)) r m))

(define (forward-char lines pos r m)
  (values lines (try-move lines (pos-nudge-x pos 1)) r m))

(define (split-elt l elt)
  (let loop ((head '())
             (tail l)
             (i 0))
   (if (eq? tail '())
     (values l '())
     (if (= elt i)
       (values (reverse head) tail)
       (loop (cons (car tail) head)
             (cdr tail)
             (+ i 1))))))

(define (insert-string lines pos str)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (string->list str) lrest)) (cdr rest))))))))

(define (insert-char lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char lrest))) (cdr rest))))))))

(define (self-insert-char c)
  (lambda (lines pos running mode)
    (values
      (insert-char lines pos c)
      (try-move lines (pos-nudge-x pos 1))
      running mode)))

#|
(define (change-char lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char (cdr lrest)))) (cdr rest))))))))
|#

(define (change-char lines pos running mode)
  (values lines pos running mode))

(define (delete-char lines pos running mode)
  (values
    (if (and (< (cdr pos) (length lines)) (>= (cdr pos) 0))
      (if (and (< (car pos) (string-length (list-ref lines (cdr pos)))) (>= (car pos) 0))
        (call-with-values
          (lambda () (split-elt lines (cdr pos)))
          (lambda (head rest)
            (call-with-values
              (lambda () (split-elt (string->list (car rest)) (car pos)))
              (lambda (lhead lrest) (append head (cons (list->string (append lhead (cdr lrest))) (cdr rest)))))))
        lines)
      lines)
    pos running mode))

(define (delete-line lines line)
  (if (< line (length lines))
    (call-with-values
      (lambda () (split-elt lines line))
      (lambda (head rest) (append head (cdr rest))))
    lines))

(define delete-backward-char (compose delete-char backward-char))
(define delete-forward-char delete-char)

(define (kill-whole-line lines pos running mode)
  (let* ([new-lines (delete-line lines (cdr pos))]
         [new-pos (try-move new-lines pos)])
    (values new-lines new-pos running mode)))

(define (edit-minibuffer input-text)
  (term-move (string-length input-text) (- term-height 1))
  (display-minibuffer input-text)
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

(define (smex lines pos running mode)
  (let ([command-text (edit-minibuffer "")])
    (if command-text
      (set-minibuffer-message (eval-string command-text)))
    (values lines pos running mode)))

; TODO Actually save
(define (save-buffers-kill-ry lines pos running mode)
  (values lines pos #f mode))

(define (enter-mode new-mode)
  (lambda (lines pos running mode)
    (values lines pos running new-mode)))

(define (define-binding alist)
  (lambda (lines pos running mode)
    (term-move (car pos) (cdr pos))
    (let ([f (assv (getch) alist)])
     (if f
       ((cdr f) lines pos running mode)
       (values lines pos running mode)))))

(define (input-string end-marker)
  (term-move 0 (- term-height 1))
  (let loop ([l (list)])
   (let ([c (term-readch)])
    (if (char=? c end-marker)
      (list->string (reverse l))
      (let* ([updated-list (cons c l)]
             [current-input (list->string (reverse updated-list))])
        (term-display 0 (- term-height 1) current-input)
        (term-move (string-length current-input) (- term-height 1))
        (loop updated-list))))))

(define (normal-mode l p r m)
  (normal-mode% l p r m))
(define enter-normal-mode (enter-mode normal-mode))

(define (insert-mode l p r m)
  (insert-mode% l p r m))
(define enter-insert-mode (enter-mode insert-mode))

(define normal-mode%
  (define-binding
    (list
      (cons #\q save-buffers-kill-ry)
      (cons #\i enter-insert-mode)
      (cons #\h backward-char)
      (cons #\j next-line)
      (cons #\k previous-line)
      (cons #\l forward-char)
      (cons #\d
        (define-binding
          (list
            (cons #\d kill-whole-line)
            (cons #\h delete-backward-char)
            (cons #\j delete-backward-char)
            (cons #\k delete-forward-char)
            (cons #\l delete-forward-char))))
      (cons #\: smex)
      (cons #\x delete-char)
      (cons #\r change-char))))

(define (insert-mode% lines pos running mode)
  (term-move (car pos) (cdr pos))
  (let ([c (getch)])
   (cond [(char=? c (integer->char 27)) ; esc
            (backward-char lines pos running normal-mode)]
         [(or (int-for-char=? c 8) (int-for-char=? c 127)) ; del|bksp
            (delete-char
              lines (try-move lines (pos-nudge-x pos -1))
              running mode)]
         [(char-visible? c)
            ((self-insert-char c) lines pos running mode)]
         [else (values lines pos running mode)])))

(define (main-loop)
  (let loop ([lines (list "Welcome to ry!" "" "A basic editor.")]
             [pos (cons 0 0)]
             [running #t]
             [mode normal-mode])
    (if running
      (begin
        (term-update)
        (display-lines lines)
        (display-status-bar lines pos)
        (display-minibuffer minibuffer-text)
        (term-flush)
        (call-with-values (lambda () (mode lines pos running mode)) loop)))))

(define (main)
  (term-init)
  (handle-exceptions
    exn
    (begin
      (term-shutdown)
      (print-error-message exn)
      (newline)
      (print-call-chain)
      (exit 1))
    (main-loop))
  (term-shutdown))

(main)
