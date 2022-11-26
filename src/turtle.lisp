(in-package #:space-turtle)

(defstruct button
  (last-key nil)
  (last-down nil)
  (last-up nil)
  (last-double-click nil))

(defstruct state
  (score 0)
  (pause-p nil)
  (pause-time nil)

  (turtle (make-turtle))
  (apple (make-apple))
  (bomb-lines nil)
  (bombs nil)

  (button (make-button))
  (screen :start)
  (last-bombs))

(defun respawn-apple (apple)
  (with-slots (x y) apple
    (incf x (random-between 150 250))
    (incf y (random-between 150 250))))

;; bombs

(defparameter *bomb-score* 5)
(defparameter *bomb-many-score* 15)
(defparameter *bomb-time* 10)
(defparameter *bomb-lines-time* 2)
(defparameter *bomb-d* 30)

(defun make-bomb-lines% (score)
  (let* ((number (random-between 1 (floor score 5)))
         (angle (random 360))
         (cx (random-between 175 225))
         (cy (random-between 175 225))
         (dx (* *bomb-d* (cos (radians (+ angle 90)))))
         (dy (* *bomb-d* (sin (radians (+ angle 90)))))
         (angle (radians angle)))
    (loop repeat number
          for x = (- cx (* dx 1/2 number)) then (+ x dx)
          for y = (- cy (* dy 1/2 number)) then (+ y dy)
          collect (list (+ x (* 300 (cos angle)))
                        (+ y (* 300 (sin angle)))
                        (- x (* 300 (cos angle)))
                        (- y (* 300 (sin angle)))))))

(defun make-bomb-lines (score)
  (loop repeat (random-between 1 (1+ (floor score *bomb-many-score*)))
        append (make-bomb-lines% score)))

(defun make-bombs (bomb-lines)
  (loop for (x1 y1 x2 y2) in bomb-lines
        collect (make-bomb x1 y1 x2 y2)))

(defun update (state)
  (with-slots (last-bombs score pause-p turtle apple bombs bomb-lines screen) state
    (unless pause-p
      (when (and bomb-lines
                 (>= (time-from last-bombs *bomb-lines-time*) 1))
        (setf bombs (make-bombs bomb-lines)
              bomb-lines nil
              last-bombs (get-internal-real-time)))
      (when (and (>= score *bomb-score*)
                 (not bomb-lines)
                 (>= (time-from last-bombs *bomb-time* 1) 1))
        (setf bomb-lines (make-bomb-lines score)
              bombs nil
              last-bombs (get-internal-real-time)))
      (when (collidep apple turtle)
        (respawn-apple apple)
        (incf score))
      (unless (loop for bomb in bombs
                    never (collidep bomb turtle))
        (setf screen :win))
      (unless (loop for bomb in bombs
                    never (collidep bomb apple))
        (respawn-apple apple))
      (dolist (ent (list* apple turtle bombs))
        (move ent)))))

(defun draw-pause (state)
  (with-slots (pause-p pause-time) state
    (when pause-p
      (with-pen (make-pen :fill (gray 0.0 (min (time-from pause-time) 3/4)))
        (rect 0 0 440 480))
      (with-current-matrix
        (translate 220 260)
        (scale (easing:in-out-back (time-from pause-time)))
        (rotate (* 360 (easing:in-out-back (time-from pause-time))))
        (with-pen (make-pen :fill (name-color :pause))
          (rect 50 -100 50 200)
          (rect -100 -100 50 200))))))

(defun draw-start (state)
  (declare (ignorable state))
  (with-font (make-font :color (name-color :font) :align :center :size 20)
    (text *intro* 220 180)))

(let ((best 0))
  (defun state-best-score (state)
    (setf best (max best (state-score state)))))

(defun draw-win (state)
  (with-font (make-font :color (name-color :font) :align :center :size 20)
    (text (format nil "Last score: ~a" (state-score state)) 110 20)
    (text (format nil "Best score: ~a" (state-best-score state)) 330 20))
  (draw-start state))

(defun bomb-line-weight (last-bombs pause-time)
  (if (not last-bombs) 1
      (progn (when pause-time
               (incf last-bombs (- (get-internal-real-time) pause-time)))
             (let ((time (time-from last-bombs *bomb-lines-time*)))
               (1+ (floor time 1/8))))))

(defun draw-game (state)
  (with-font (make-font :color (name-color :font) :align :center :size 40)
    (text (format nil "Score: ~a" (state-score state)) 220 0))
  (update state)
  (with-current-matrix (translate 20 60)
    (with-pen (make-pen :stroke (gray 0.4) :weight 4)
      (rect 0 0 *width* *height*))
    (with-scissor (0 0 *width* *height*)
      (with-slots (turtle apple bombs bomb-lines last-bombs pause-time pause-p) state
        (dolist (ent (list* apple turtle bombs))
          (draw-entity ent))
        (with-pen (make-pen :stroke (name-color :bomb-line) :weight (bomb-line-weight last-bombs pause-time))
          (dolist (line bomb-lines)
            (apply #'line line))))))
  (draw-pause state))

(defun go-game (state)
  (with-slots (score turtle apple bombs screen) state
    (setf score 0
          turtle (make-turtle)
          apple (make-apple)
          bombs nil
          screen :game)))

(defsketch 1b ((title "Space turtle")
               (state (make-state)))
  (background +black+)
  #+nil (draw-background)
  (fit 440 480 width height)
  (case (state-screen state)
    (:game (draw-game state))
    (:start (draw-start state))
    (:win (draw-win state))
    (t (text "?!" 200 200))))

(defun hold-down (app)
  (with-slots (state) app
    (with-slots (turtle) state
      (with-slots (rotation-speed) turtle
        (setf rotation-speed
              (- rotation-speed))))))

(defun hold-up (app)
  (with-slots (state) app
    (with-slots (turtle) state
      (with-slots (rotation-speed) turtle
        (setf rotation-speed
              (- rotation-speed))))))

(defun double-click (app)
  (with-slots (state) app
    (with-slots (screen pause-p pause-time last-bombs) state
      (case screen
        (:game
         (when (and pause-p last-bombs)
           (incf last-bombs (- (get-internal-real-time)
                               pause-time)))
         (setf pause-time (get-internal-real-time)
               pause-p (not pause-p)))
        (t (go-game state))))))

;; down / up / double click

(defun button-event (app st name)
  (with-slots (state) app
    (with-slots (button) state
      (with-slots (last-down last-up last-double-click last-key) button
        (when (or (not last-key)
                  (eql name last-key))
          (case st
            ((:mousebuttondown :keydown)
             (setf last-key name)
             (if (and (< (time-from last-down 1/3 1) 1)
                      (or (not last-double-click)
                          (and (>= last-down last-double-click)
                               (>= (time-from last-double-click 1/3) 1))))
                 (progn (setf last-down (get-internal-real-time)
                              last-double-click last-down)
                        (double-click app)
                        (hold-down app))
                 (progn (setf last-down (get-internal-real-time))
                        (hold-down app))))
            ((:mousebuttonup :keyup)
             (setf last-up (get-internal-real-time)
                   last-key nil)
             (hold-up app))))))))

(defmethod kit.sdl2:keyboard-event ((app 1b) st ts rep? keysym)
  (when (not rep?)
    (button-event app st (sdl2:scancode keysym))))

(defmethod kit.sdl2:mousebutton-event ((app 1b) st ts button x y)
  (declare (ignorable ts x y))
  (button-event app st button))

;; sound
(defmethod setup ((app 1b) &key &allow-other-keys)
  (init-sound))

(defmethod kit.sdl2:close-window :before ((app 1b))
  (quit-sound))

(defun start ()
  #+deploy
  (sdl2:make-this-thread-main
   (lambda ()
     (let ((sketch::*build* t))
       (make-instance '1b :resizable t))))
  #-deploy
  (make-instance '1b :resizable t))
