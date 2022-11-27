(in-package #:st)

(defun make-star-flow ()
  (let ((c (make-canvas 110 120)))
    (loop repeat 10
          do (canvas-paint c (filter-alpha (name-color (if (zerop (random 5))
                                                           :rare :common))
                                           0.7)
                           (random 110) (random 120))
          finally (progn
                    (canvas-lock c)
                    (return c)))))

(defstruct star
  (canvas (make-star-flow))
  position rotation)

(let (stars)
  (defun draw-background ()
    (background +black+)
    (unless stars
      (setf stars (loop for i from 0 repeat 10
                        for rot = 1 then (- rot)
                        collect (make-star :position i :rotation rot))))
    (with-current-matrix
      (translate 220 240)
      (dolist (star stars)
        (with-current-matrix
          (with-slots (position rotation) star
            (rotate (degrees (* rotation (expt 1.01 position))))
            (scale (expt 1.1 position))
            (setf position (mod (+ position 1/500) 10)))
          (with-pen (make-pen :fill (canvas-image (star-canvas star)))
            (rect -150 -160 300 320)))))))
