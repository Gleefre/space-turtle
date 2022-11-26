(push :deploy *features*)

(ql:quickload '(:deploy :space-turtle))

(deploy:define-resource-directory data "resources/")
(deploy:define-library cl-opengl-bindings::opengl :dont-deploy t)

(asdf:make :space-turtle)

(quit)
