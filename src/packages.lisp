(defpackage #:space-turtle/resources
  (:use #:cl)
  (:export #:data-path
           #:*font* #:*sound* #:*intro*
           #:*turtle* #:*apple* #:*bomb*
           #:name-color)
  (:nicknames #:st/res))

(defpackage #:space-turtle/utils
  (:use #:cl #:sketch)
  (:export #:random-between
           #:time-from #:filter-alpha
           #:fit #:with-scissor)
  (:nicknames #:st/utils))

(defpackage #:space-turtle/sound
  (:use #:cl #:sdl2-mixer #:st/res)
  (:export #:init-sound #:quit-sound
           #:play-sound #:stop-sound)
  (:nicknames #:st/sound))

(defpackage #:space-turtle
  (:use #:cl #:sketch
        #:st/res #:st/utils #:st/sound)
  (:export #:start)
  (:nicknames #:st))
