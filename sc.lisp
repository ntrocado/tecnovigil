(in-package :col)

(defvar +reset+ 0)
(defvar +onset+ 1)

(defparameter *buf* (buffer-alloc (* (sc::sample-rate *s*) 5)))

(defparameter *onsets* '())

(defun osc-responder (node id value &optional (qobject nil))
  (declare (ignore node qobject))
  (force-output)
  (case id
    (#.+reset+
     (setf *onsets* '()))
    (#.+onset+
     (push value *onsets*))))

(add-reply-responder "/tr" #'osc-responder)

(defsynth rec ((in 0) (buf *buf*))
  (let* ((index (phasor.ar 0 (buf-rate-scale.kr buf) 0 (buf-frames.kr buf)))
	 (sig (sound-in.ar in))
	 (chain (fft (local-buf 512) sig)))
    (buf-wr.ar sig buf index)
    (send-trig.kr (onsets.kr chain) +onset+ index)
    (send-trig.ar (trig.ar (+ 1 (* -1 index))) +reset+ index)))

(defparameter *persist* (make-group :pos :before :to 1))

(defparameter *rec-node* (synth 'rec :to *persist*))

(defsynth bit-player ((buf *buf*) (start 0) (dur .5))
  (out.ar 0 (pan2.ar (* (play-buf.ar 1 buf 1 :start-pos start)
			(env-gen.ar (env '(0 1 1 0) (list .03 dur .03))
				    :act :free)))))

;(synth 'bit-player :start (random (frames *buf*)))

