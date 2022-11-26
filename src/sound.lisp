(in-package #:st/sound)

(defparameter *sound-chunk* nil)

(defun play-sound ()
  (play-channel 0 *sound-chunk* -1))

(defun stop-sound ()
  (halt-channel 0))

(defun init-sound ()
  (unless *sound-chunk*
    (init :wave)
    (open-audio 44100 :s16sys 2 2048)
    (allocate-channels 1)
    (setf *sound-chunk* (sdl2-mixer:load-wav (data-path *sound*)))
    (play-sound)))

(defun quit-sound ()
  (when *sound-chunk*
    (halt-channel -1)
    (close-audio)
    (free-chunk *sound-chunk*)
    (setf *sound-chunk* nil)
    (quit)))
