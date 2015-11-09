(define *buffers* '())
(define *buffers-index* 0)

(define (kill-buffer-by-number n)
  (set! *buffers* (del-assq n *buffers*)))

(define (get-buffer-by-number n)
  (let loop ([buffers *buffers*])
    (cond [(null? buffers) #f]
          [else (if (eq? n (caar buffers))
                  (cdar buffers)
                  (loop (cdr buffers)))])))

(define (map-buffers! fn)
  (set! *buffers* (alist-map fn *buffers*)))

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
         [file-lines (if file-exists (string-split (read-all full-filename) "\n" #t) '())])
    (list (cons 'modified? #f)
          (cons 'readonly? #f)
          (cons 'name (pathname-strip-directory full-filename))
          (cons 'location full-filename)
          (cons 'pointer (cons 0 0))
          (cons 'lines file-lines))))

(define (current-buffer)
  (window-buffer (current-window)))

(define (add-buffer buffer)
  (set! *buffers-index* (+ *buffers-index*))
  (set! *buffers* (cons (cons *buffers-index* buffer) *buffers*))
  *buffers-index*)

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

(define (update-buffer-by-number k fn)
  (map-buffers! (lambda (n buffer)
    (cons n (if (eq? n k) (fn buffer) buffer)))))

(define (update-current-buffer-prop prop fn)
  (let ([buffer-n (cdr (assq 'buffer (current-window)))])
    (update-buffer-by-number buffer-n (lambda (buffer)
      (set-assq buffer prop (fn buffer))))))

(define (update-current-buffer-pointer fn)
  (update-current-buffer-prop 'pointer (lambda (buffer)
    (try-move buffer (fn buffer)))))
