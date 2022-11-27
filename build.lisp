(push :deploy *features*)

(ql:quickload '(:deploy :space-turtle))

(deploy:define-resource-directory data "resources/")
(deploy:define-library cl-opengl-bindings::opengl :dont-deploy t)

(defmacro define-libraries (names)
  `(progn
     ,@(loop for path in names
             collect `(cffi:define-foreign-library ,(gensym) (:unix ,path)))))
#+linux
(define-libraries ("libmodplug.so.1" "libfluidsynth.so.2" "libvorbisfile.so.3"
                                     "libFLAC.so.8" "libmpg123.so.0" "libopusfile.so.0"
                                     "libasound.so.2" "libfreetype.so.6"
                                     "libpng16.so.16" "libjpeg.so.8"
                                     "libjpeg.so.8" "libtiff.so.5" "libwebp.so.6"))

(asdf:make :space-turtle)

(quit)
