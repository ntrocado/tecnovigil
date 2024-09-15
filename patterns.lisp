(in-package :tecnovigil)

(pb :pat
  :type (pwrand '(:note :rest) '(.7 .3))
  :instrument 'bit-player
  :dur (pseq '(1/8 1/2 1/3 1/5))
  :start (prand (or col:*onsets* '(0)))
  :quant 0)

(pb :grains
  :type (pseq '(:note :rest :note :rest))
  :instrument 'grains
  :dur (pseq '(16 2 32 3))
  :start-pos (loop :repeat 4 :collect (random 1.0))
  :rate (pf (loop :repeat 4 :collect (+ .5 (random 1.0))))
  :quant 0)
