(import chicken scheme)
(use linenoise format utils)
(require-extension utf8)
(require-extension utf8-srfi-13)
(require-extension utf8-srfi-14)

(set-history-length! 300)
(define *history-file* (let ([home (get-environment-variable "HOME")]
                             [file ".chicken-history"])
                         (if home (make-pathname home file) file)))
(load-history-from-file *history-file*)

(define (eval-string input-text)
  (handle-exceptions
    exn
    (cons #f (begin
                (print-error-message exn)
                (newline)
                (print-call-chain)
                ""))
    (cons #t (string-trim-both
               (format #f "~Y"
                 (eval (with-input-from-string input-text read)))))))

(let loop ((l (linenoise "> ")))
  (cond ((or (not l) (equal? l "bye"))
          (save-history-to-file *history-file*)
          (display "Bye!")
          (newline))
        (else
          (display (cdr (eval-string l)))
          (newline)
          (history-add l)
          (loop (linenoise "> ")))))
