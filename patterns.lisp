(in-package :tecnovigil)

(setf (clock-condition-handler *clock*) 'skip-event)

(pb :pat
  :type (pwrand '(:note :rest) '(.7 .3))
  :instrument 'bit-player
  :amp 1.1
  :dur (pseq '(1/8 1/2 1/3 1/6))
  :rel (pseq '(.3  1.1  .4  .1))
  :start (prand (or col:*onsets* '(0)))
  :reverb (pseries* 0 1.0 5)
  :quant 1/8)

(pb :fast
  :instrument 'bit-player
  :dur (pseq (list (pr 1/16 24) 1/4 1/4 1/4 1/3 1/3 4 (pr 1/32 6) 2))
  :amp (pr (pwhite .01 .75) 12)
  :rel (pwhite .4 .9)
  :atk .01
  :start (pr (prand col:*onsets*) 12)
  :quant 0)

(pb :voz
  :type (pseq '(:note :rest))
  :instrument 'bit-player
  :buf col:*voz*
  :dur (pseq '(1.5 9 2 13 1.6 7))
  :rel (pwhite 1.5 2.2)
  :atk (pwhite 1.6 2.4)
  :start (pwhite 0 (sc:frames col:*voz*))
  :amp (pf (if col:*onsets*
	       (pwhite .05 .15)
	       0))
  :reverb (pseries* 0 .7 5)
  :pan-speed .1
  :quant 0)

(pb :voz-glitch
  :instrument 'bit-player
  :buf col:*voz*
  :dur (pseq (list (pr 1/64 12) (pr 1/8 12) (pr 3/32 12) 10))
  :rel (pwhite .05 .1)
  :atk .03
  :amp (pf (if col:*onsets*
	       (pwhite .03 .1)
	       0))
  :start (pwhite 0 (sc:frames col:*voz*))
  :pan-speed 1
  :quant 0)

(pb :grains
  :type (pseq '(:note :rest :note :rest))
  :instrument 'grains
  :dur (pseq '(5 2 16 3))
  :start-pos (loop :repeat 4 :collect (random 1.0))
  :rate (pf (loop :repeat 4 :collect (+ .5 (random 1.0))))
  :quant 0)

(defparameter *random-seq-on* nil)
(defparameter *rec-seq-on* nil)

(defun start-random-seq ()
  (setf *random-seq-on* t)
  (let ((top-level *standard-output*))
    (bt:make-thread
     (lambda ()
       (loop :while *random-seq-on*
	     :for pat := (alexandria:random-elt
			  '(:fast :voz :voz-glitch :grains))
	     :if (member pat (playing-pdef-names))
	       :do (progn (format top-level "stop ") (stop pat))
	     :else :do (progn (format top-level "play ") (play pat))
	     :do (format top-level "~a~%" pat)
	     :do (sleep 10)))
     :name "random-seq")))

(defun stop-random-seq ()
  (setf *random-seq-on* nil)
  (mapcar #'stop (clock-tasks)))

(defun start-rec-seq ()
  (setf *rec-seq-on* t)
  (let ((top-level *standard-output*))
    (bt:make-thread
     (lambda ()
       (loop :while *rec-seq-on*
	     :do (col:start-rec)
	     :do (format top-level "Recording started...~%")
	     :do (sleep 110)
	     :do (col:stop-rec)
	     :do (format top-level "Recording stopped...~%")
	     :do (sleep 70)))
     :name "rec-seq")))

(defun stop-rec-seq ()
  (setf *rec-seq-on* nil)
  (col:stop-rec))


;;; Go

(play :pat)
(start-rec-seq)
(start-random-seq)

;;; End

(defun end ()
  (stop-rec-seq)
  (stop-random-seq))
