(define *buffers* '())

(define (kill-buffer-named name)
  (set! *buffers* (del-assq name *buffers*)))

(define (new-buffer)
  '((saved? #f)
    (name "*unnamed*")
    (location #f)
    (lines ())))

(define (add-buffer buffer)
  (set! *buffers* (cons buffer *buffers*)))
