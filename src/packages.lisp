(defpackage #:space-turtle/resources
  (:use #:cl)
  (:export #:data-path
           #:*font* #:*sound*
           #:*turtle* #:*apple* #:*bomb*
           #:name-color)
  (:nicknames #:st/res))

(defpackage #:space-turtle/utils
  (:use #:cl #:sketch)
  (:export #:random-between
           #:time-from
           #:fit #:with-scissor)
  (:nicknames #:st/utils))

(defpackage #:space-turtle
  (:use #:cl #:st/res #:st/utils #:sketch)
  (:export #:start)
  (:nicknames #:st))
