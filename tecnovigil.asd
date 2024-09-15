;;;; tecnovigil.asd

(asdf:defsystem #:tecnovigil
  :description "Sound Installation for Eureka #3 @ Porta-Jazz"
  :author "Nuno Trocado"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:cl-patterns/supercollider #:kai)
  :components ((:file "package")
               (:file "setup")
	       (:file "sc")
	       (:file "patterns")))
