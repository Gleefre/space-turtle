(in-package #:st/utils)

;; general
(defun random-between (x y)
  (+ x (random (- y x))))

;; animation
(defun time-from (x &optional (divisor 1) (default 0))
  (if (not (integerp x)) default
      (/ (- (get-internal-real-time) x)
         internal-time-units-per-second
         divisor)))

;; fit -- function to fit desired width/height to rectangle on screen
(defun fit (width height from-width from-height &optional (to-x 0) (to-y 0) (from-x 0) (from-y 0) max-scale)
  (translate from-x from-y)
  (let* ((scale (min (/ from-width width)
                     (/ from-height height)
                     (if max-scale max-scale 10000)))
         (x-shift (/ (- from-width (* width scale)) 2))
         (y-shift (/ (- from-height (* height scale)) 2)))
    (translate x-shift y-shift)
    (scale scale))
  (translate (- to-x) (- to-y)))

;; scissors

(defun enable-scissor (x y w h)
  (gl:enable :scissor-test)
  (destructuring-bind ((x1 y1) (x2 y2))
      (list
       (sketch::transform-vertex (list x (+ y h)) (sketch::env-model-matrix sketch::*env*))
       (sketch::transform-vertex (list (+ x w) y) (sketch::env-model-matrix sketch::*env*)))
    (let* ((height (sketch::sketch-height sketch::*sketch*))
           (y1 (- height y1))
           (y2 (- height y2)))
      (gl:scissor x1 y1 (- x2 x1) (- y2 y1)))))

(defun disable-scissor ()
  (gl:disable :scissor-test))

(defmacro with-scissor ((x y w h) &body body)
  `(progn
     (enable-scissor ,x ,y ,w ,h)
     ,@body
     (disable-scissor)))
