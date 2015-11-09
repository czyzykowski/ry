(define (kill-ry)
  (set-running-state #f))

(define q kill-ry)

; TODO Actually save
(define (save-buffers-kill-ry)
  (kill-ry))

; Callback getting command entered.
; Evals given text and pretty prints result to minibuffer
(define (smex-commit command-text)
  (if command-text
    (let* ([corrected-command-text ; automatically appen ) to commands if needed
              (if (eq? #\) (string-ref command-text (- (string-length command-text) 1)))
                command-text
                (string-append command-text ")"))]
            [eval-result (eval-string corrected-command-text)])
      (if (car eval-result)
        (set-minibuffer-message (cdr eval-result))
        (set-minibuffer-error (cdr eval-result))))))

; `smex` reading input from the minibuffer and evals it
; It's similar to ":" in vim or M-x in emacs
(define (smex)
  (edit-minibuffer "(" smex-commit))

(define *text-save-file* "Save file to: ")
(define *text-open-file* "Open file: ")

(define (save-file)
  (edit-minibuffer *text-save-file* (lambda (command-text)
    #f)))

(define (open-file)
  (edit-minibuffer *text-open-file* (lambda (command-text)
    (let* ([ques-length (string-length *text-open-file*)]
           [comm-length (string-length command-text)]
           [filename (substring command-text ques-length comm-length)]
           [buffer (new-buffer-from-file filename)])
      (add-buffer buffer)
      (update-current-window-prop 'buffer (lambda (window)
        buffer))))))

; Splits a list in two at a define `elt` index
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

(define (insert-string% lines pos str)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (if (null? rest) (set! rest '("")))
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (string->list str) lrest)) (cdr rest))))))))

(define (insert-char% lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (if (null? rest) (set! rest '("")))
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char lrest))) (cdr rest))))))))

(define (change-char% lines pos new-char)
  (call-with-values
    (lambda () (split-elt lines (cdr pos)))
    (lambda (head rest)
      (if (null? rest) (set! rest '("")))
      (call-with-values
        (lambda () (split-elt (string->list (car rest)) (car pos)))
        (lambda (lhead lrest) (append head (cons (list->string (append lhead (cons new-char (cdr lrest)))) (cdr rest))))))))

(define (delete-line% lines line)
  (if (< line (length lines))
    (call-with-values
      (lambda () (split-elt lines line))
      (lambda (head rest) (append head (cdr rest))))
    lines))

(define (delete-char% lines pos)
  (if (and (< (cdr pos) (length lines)) (>= (cdr pos) 0))
    (if (and (< (car pos) (string-length (list-ref lines (cdr pos)))) (>= (car pos) 0))
      (call-with-values
        (lambda () (split-elt lines (cdr pos)))
        (lambda (head rest)
          (call-with-values
            (lambda () (split-elt (string->list (car rest)) (car pos)))
            (lambda (lhead lrest) (append head (cons (list->string (append lhead (cdr lrest))) (cdr rest)))))))
        lines)
      lines))
(define (insert-line% lines line)
  (if (< line (length lines))
    (call-with-values
      (lambda () (split-elt lines line))
      (lambda (head rest) (append head '("") rest)))
    lines))

(define (self-insert-char ch)
  (lambda ()
    (update-current-buffer-prop 'lines (lambda (buffer)
      (insert-char% (buffer-lines buffer) (buffer-pointer buffer) ch)))
    (forward-char)))

(define (change-char ch)
  (lambda ()
    (update-current-buffer-prop 'lines (lambda (buffer)
      (change-char% (buffer-lines buffer) (buffer-pointer buffer) ch)))))

(define (kill-whole-line)
  (update-current-buffer-prop 'lines (lambda (buffer)
    (delete-line% (buffer-lines buffer) (cdr (buffer-pointer buffer)))))
  (ensure-valid-pointer))

(define (delete-char)
  (update-current-buffer-prop 'lines (lambda (buffer)
    (delete-char% (buffer-lines buffer) (buffer-pointer buffer))))
  (ensure-valid-pointer))

(define (delete-backward-char)
  (if (eq? (car (buffer-pointer (current-buffer))) 0)
    (begin
      (previous-line)
      (end-of-line)
      (update-current-buffer-prop 'lines (lambda (buffer)
        (let ([lines (buffer-lines buffer)]
              [pointer (buffer-pointer buffer)])
          (insert-string% lines pointer (list-ref lines (+ (cdr pointer) 1))))))
      (update-current-buffer-prop 'lines (lambda (buffer)
        (delete-line% (buffer-lines buffer) (+ (cdr (buffer-pointer buffer)) 1)))))
    (begin
      (backward-char)
      (delete-char))))

(define delete-forward-char delete-char)

(define (delete-char-under-cursor)
  (let* ([buffer (current-buffer)]
         [pointer (buffer-pointer buffer)]
         [lines (buffer-lines buffer)])
  (if (eq? (car pointer) (string-length (list-ref lines (cdr pointer))))
    (begin
      (backward-char)
      (delete-char))
    (delete-forward-char))))

(define (insert-line-up)
  (update-current-buffer-prop 'lines (lambda (buffer)
    (insert-line% (buffer-lines buffer) (cdr (buffer-pointer buffer)))))
  (beginning-of-line))

(define (insert-line-down)
  (next-line)
  (update-current-buffer-prop 'lines (lambda (buffer)
    (insert-line% (buffer-lines buffer) (cdr (buffer-pointer buffer)))))
  (beginning-of-line))
