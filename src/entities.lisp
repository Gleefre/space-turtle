(in-package #:st)

;;; stuff on game screen

(defparameter *width* 400)
(defparameter *height* 400)

(defparameter *turtle-rad* 20)
(defparameter *turtle-speed* 1)
(defparameter *turtle-rotation-speed* 1)
(defparameter *apple-rad* 8)
(defparameter *bomb-rad* 10)
(defparameter *bomb-speed* 2)

(defstruct entity
  (x 0) (y 0) (rad 0)
  (speed 0) (angle 0) ; angle in degrees
  (rotation-speed 0)
  (wrap t)
  (image-name ""))

(defun collidep (ent1 ent2)
  (with-slots ((x1 x) (y1 y) (rad1 rad)) ent1
    (with-slots (x y rad) ent2
      (< (sqrt (+ (expt (- x1 x) 2)
                  (expt (- y1 y) 2)))
         (+ rad1 rad)))))

(defun move (entity)
  (with-slots (speed angle x y rotation-speed wrap) entity
    (incf x (* speed (cos (radians (+ -90 angle)))))
    (incf y (* speed (sin (radians (+ -90 angle)))))
    (incf angle rotation-speed)
    (when wrap
      (setf x (mod x *width*) y (mod y *height*)))))

(defun draw-entity% (entity dx dy)
  (with-slots (x y angle rad image-name) entity
    (with-current-matrix
      (translate (+ x dx) (+ y dy))
      (rotate angle)
      (with-pen (make-pen)
        (image (load-resource (data-path image-name))
               (- rad) (- rad)
               (* 2 rad) (* 2 rad))))))

(defun draw-entity (entity)
  (with-slots (x y angle rad image-name wrap) entity
    (loop for dx in (if wrap (list *width* (- *width*) 0) (list 0))
          do (loop for dy in (if wrap (list *height* (- *height*) 0) (list 0))
                   do (draw-entity% entity dx dy)))))

;; setup

(defun make-turtle ()
  (make-entity :y 200 :rad *turtle-rad*
               :speed *turtle-speed*
               :rotation-speed *turtle-rotation-speed*
               :image-name *turtle*))

(defun make-apple ()
  (make-entity :x (random 400)
               :y (random 400)
               :rad *apple-rad*
               :image-name *apple*))

(defun make-bomb (x y x-end y-end)
  (make-entity :x x :y y
               :speed *bomb-speed*
               :rad *bomb-rad*
               :angle (floor (degrees (atan (- y-end y) (- x-end x))))
               :image-name *bomb*
               :wrap nil))
