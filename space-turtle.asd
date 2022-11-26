(asdf:defsystem "space-turtle"
  :description "Snake like game in space"
  :version "0.1.0"
  :author "Gleefre <varedif.a.s@gmail.com>"
  :licence "Apache 2.0"
  :depends-on ("sketch" "sdl2-mixer" "easing")
  :pathname "src"
  :components ((:file "packages")
               (:file "resources")
               (:file "utils")
               (:file "hacks")
               (:file "entities")
               (:file "turtle"))

  :defsystem-depends-on (:deploy)
  :build-operation #-darwin "deploy-op" #+darwin "osx-app-deploy-op"
  :build-pathname "space-turtle"
  :entry-point "st:start")

