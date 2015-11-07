(define *buffers* '())

(define (kill-buffer-named name)
  (set! *buffers* (del-assq name *buffers*)))

(define (get-buffer-by-number n)
  (if (< n (length *buffers*))
    (list-ref *buffers* n)
    #f))

(define (new-buffer)
  '((saved? #t)
    (name "*unnamed*")
    (location #f)
    (lines ())))

(define (new-buffer-from-file filename)
  (let* ([full-filename (if (absolute-pathname? filename)
                         filename
                         (make-pathname (current-directory) filename))]
         [file-exists (file-exists? full-filename)]
         [file-lines (if file-exists (string-split (read-all full-filename) "\n") '())])
    (list (list 'modified? #f)
          (list 'readonly? #f)
          (list 'name (pathname-file full-filename))
          (list 'location full-filename)
          (list 'lines file-lines))))

(define (add-buffer buffer)
  (set! *buffers* (cons buffer *buffers*)))
