;;;; package.lisp

(defpackage #:tecnovigil
  (:use #:cl #:cl-patterns))

(defpackage #:tecnovigil/sc-defs
  (:use #:cl #:sc)
  (:nicknames #:col)
  (:export
   #:*buf*
   #:*onsets*))
