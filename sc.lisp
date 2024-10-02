(in-package :col)

(defconstant +reset+ 0)
(defconstant +onset+ 1)

(defparameter *buf* (buffer-alloc (* (sc::sample-rate *s*) 60)))
(defparameter *voz* (buffer-read "~/OneDrive/Documents/Eureka/projectos/algoritmo/voz.wav"))

(defun test-audio ()
  (buffer-read-channel #p"~/Downloads/573814__trp__audience-crowd-party-voices-theatre-caa-190209.mp3" :channels 1 :bufnum (bufnum *buf*)))

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

(defparameter *rec-node* '())

(defun start-rec ()
  (setf *rec-node* (synth 'rec :to *persist*)))

(defun stop-rec ()
  (when *rec-node* (free *rec-node*))
  (setf *rec-node* nil))

;;; Play

(defsynth bit-player ((buf *buf*) (start 0) (reverb 0) (pan-speed .5) (atk .03) (rel .03) (amp 1))
  (out.ar 0 (pan2.ar (freeverb.ar (* (play-buf.ar 1 buf 1 :start-pos start)
				     (env-gen.ar (perc atk rel)
						 :act :free)
				     amp)
				  :mix reverb)
		     (range (lf-tri.kr pan-speed) -1.0 1.0))))


(defsynth grains ((buffer *buf*) (rate 1) (start-pos .5) (amp 1.0) (gate 1))
  (let* ((t-rate (range (lf-tri.kr .2) 15 24))
	 (dur (/ 12 t-rate))
	 (clk (impulse.kr t-rate))
	 (position (+ (* (buf-dur.kr buffer) start-pos)
		      (t-rand.kr 0 0.05 clk)))
	 (pan (range (lf-noise1.kr 10) -1 1)))
    (out.ar 0 (* (tgrains.ar 4 clk buffer rate position dur pan 0.5)
		 (env-gen.ar (asr 5 1 3) :gate gate :act :free)
		 amp))))
