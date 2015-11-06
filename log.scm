(define (log-err-abort msg)
  (display (string-append "Error: " msg) (current-error-port))
  (newline (current-error-port))
  (exit 1))

(define (log-err msg)
  (display msg (current-error-port))
  (newline (current-error-port))
  msg)
