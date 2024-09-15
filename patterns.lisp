(in-package :tecnovigil)

(pb :pat
  :type (pwrand '(:note :rest) '(.7 .3))
  :instrument 'bit-player
  :dur (pseq '(1/8 1/2 1/3 1/5))
  :start (prand (or col:*onsets* '(0)))
  :quant 0)
