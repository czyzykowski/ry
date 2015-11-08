(define *buffers* '())

(define (kill-buffer-named name)
  (set! *buffers* (del-assq name *buffers*)))

(define (get-buffer-by-number n)
  (if (< n (length *buffers*))
    (list-ref *buffers* n)
    #f))

(define (new-buffer)
  (list (cons 'modified? #f)
        (cons 'readonly? #f)
        (cons 'name "*unnamed*")
        (cons 'location #f)
        (cons 'pointer (cons 0 0))
        (cons 'lines '())))

(define (new-buffer-from-file filename)
  (let* ([full-filename (if (absolute-pathname? filename)
                         filename
                         (make-pathname (current-directory) filename))]
         [file-exists (file-exists? full-filename)]
         [file-lines (if file-exists (string-split (read-all full-filename) "\n") '())])
    (list (cons 'modified? #f)
          (cons 'readonly? #f)
          (cons 'name (pathname-strip-directory full-filename))
          (cons 'location full-filename)
          (cons 'pointer (cons 0 0))
          (cons 'lines file-lines))))

(define (add-buffer buffer)
  (set! *buffers* (cons buffer *buffers*)))

(define (buffer-name buffer)
  (cdr (assq 'name buffer)))

(define (buffer-modified? buffer)
  (cdr (assq 'modified? buffer)))

(define (buffer-readonly? buffer)
  (cdr (assq 'readonly? buffer)))

(define (buffer-pointer buffer)
  (cdr (assq 'pointer buffer)))

(define (buffer-lines buffer)
  (cdr (assq 'lines buffer)))
