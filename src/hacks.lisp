(in-package #:sketch)
;; sketch loads default fonts on startup, but we don't want to ship them

(let ((font))
  (defun make-default-font ()
    (setf font (or font
                   (make-font :face (load-resource (st/res:data-path st/res:*font*))
                              :color +black+
                              :size 18))))
  (defun make-error-font ()
    (setf font (or font
                   (make-font :face (load-resource (st/res:data-path st/res:*font*))
                              :color +black+
                              :size 18)))))

;; sketch define `ESC` as "close window" button. We want to override this behaviour
(defmethod kit.sdl2:keyboard-event :before ((instance sketch) st ts rep-p keysym)
  (declare (ignorable instance st ts rep-p keysym)))
