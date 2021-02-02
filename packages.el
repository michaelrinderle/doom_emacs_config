;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; add packages 
(package! org-roam)
(package! org-journal)
(package! deft)

;; mode packages
(package! dap-mode)
(package! lsp-java)
(package! ada-mode)

;; doom package examples
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;(package! builtin-package :disable t)
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))
;(package! builtin-package :recipe (:branch "develop"))
;(package! builtin-package :pin "1a2b3c4d5e")
;(unpin! pinned-package)