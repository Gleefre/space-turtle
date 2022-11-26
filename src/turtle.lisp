(in-package #:space-turtle)

(defstruct button
  (last-down nil)
  (last-up nil)
  (last-double-click nil))

(defstruct state
  (score 0)
  (pause-p nil)
  (pause-time nil)

  (turtle (make-turtle))
  (apple (make-apple))
  (bombs nil)

  (button (make-button)))

(defun respawn-apple (apple)
  (with-slots (x y) apple
    (incf x (random-between 150 250))
    (incf y (random-between 150 250))))

(defun add-bombs (state)
  (with-slots (bombs) state
    (unless bombs
      (push (make-bomb 200 200 0 0) bombs))))

(defun update (state)
  (with-slots (score pause-p turtle apple bombs) state
    (unless pause-p
      (add-bombs state)
      (when (collidep apple turtle)
        (respawn-apple apple)
        (incf score))
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
        (with-pen (make-pen :fill (gray 0.9 0.7))
          (rect 50 -100 50 200)
          (rect -100 -100 50 200))))))

(defun draw-lose (state))
(defun draw-win (state))

(defsketch 1b ((title "Space turtle")
               (state (make-state)))
  (background +black+)
  (fit 440 480 width height)
  (with-font (make-font :color (gray 0.6) :align :center :size 40)
    (text (format nil "Score: ~a" (state-score state)) 220 0))
  (update state)
  (with-current-matrix (translate 20 60)
    (with-pen (make-pen :stroke (gray 0.4) :weight 4)
      (rect 0 0 *width* *height*))
    (with-scissor (0 0 *width* *height*)
      (with-slots (turtle apple bombs) state
        (dolist (ent (list* apple turtle bombs))
          (draw-entity ent)))))
  (draw-pause state))

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
    (with-slots (pause-p pause-time) state
      (setf pause-time (get-internal-real-time)
            pause-p (not pause-p)))))

(defmethod kit.sdl2:keyboard-event ((app 1b) st ts rep? keysym)
  (with-slots (state) app
    (with-slots (button) state
      (with-slots (last-down last-up last-double-click) button
        (unless (or rep? (not (eq (sdl2:scancode keysym) :scancode-space)))
          (case st
            (:keydown
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
            (:keyup
             (setf last-up (get-internal-real-time))
             (hold-up app))))))))

(defun start ()
  #+deploy
  (sdl2:make-this-thread-main
   (lambda ()
     (let ((sketch::*build* t))
       (make-instance '1b :resizable t))))
  #-deploy
  (make-instance '1b :resizable t))
