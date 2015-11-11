(define *handlers* '())

(define (on event-names handler)
  (set! *handlers* (append *handlers*
    (map (lambda (event-name)
      (cons event-name handler)) event-names))))

(define (trigger event-name arg)
  (let loop ([handlers *handlers*])
    (when (not (null? handlers))
      (when (eq? event-name (caar handlers))
        ((cdar handlers) arg))
      (loop (cdr handlers)))))

;; Implemented events
;; - buffer-create
;; - buffer-write

(on '(buffer-edit) (lambda (buffer) #f))
