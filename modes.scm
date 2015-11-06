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
