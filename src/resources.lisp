(in-package #:st/res)

;; data-path function

(defparameter *data-folder* "resources/")
(defparameter *system* "space-turtle")

(let ((data-folder nil))
  (defun data-path (relative-path)
    (setf data-folder
          (or data-folder
              #-deploy (asdf:system-relative-pathname *system* *data-folder*)
              #+deploy (let ((deploy:*data-location* *data-folder*))
                         (deploy:data-directory))))
    (format nil "~a" (merge-pathnames relative-path data-folder))))

;; font, sound, images

(defparameter *font* "RobotoMono-Bold.ttf")
(defparameter *sound* "soundtrack.wav")
(defparameter *apple* "apple-240.png")
(defparameter *turtle* "big-turtle-240.png")
(defparameter *bomb* "weird-missle-200.png")

;; color palette

(defparameter *colors*
  '((:... . "ff00ff")))

(defun name-color (name)
  (sketch:hex-to-color (cdr (assoc name *colors*))))

(defparameter *intro*
  (format nil "Use any button to play this game.~%~
               But you can use only one button.~2% ~
               Double click  -- pause/start.~%~
               Press and hold -- turn left.  ~%~
               Unpress button -- turn right. ~%~
               Good luck!"))
