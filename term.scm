(define term-height 0)
(define term-width 0)

(define (term-init)
  (initscr)
  (cbreak)
  (noecho)
  (keypad (stdscr) #t))

(define (term-shutdown)
  (endwin))

(define (term-update)
  (wclear (stdscr))
  (let-values ([[my mx] (getmaxyx (stdscr))])
    (set! term-width mx)
    (set! term-height my)))

(define (term-flush)
  (wrefresh (stdscr)))

(define (term-move x y)
  (move y x))

(define (term-display x y text)
  (mvaddstr y x text))

(define (term-display-with fg bg attr fn)
  (attron attr)
  (fn)
  (attroff attr))

(define (term-readch)
  (getch))

