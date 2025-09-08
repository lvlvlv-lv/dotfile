;; -*- lexical-binding: t; -*-

(setq package-selected-packages '(org))
(my/package-install package-selected-packages)
(require 'org)

(setq org-todo-keywords
  '((sequence "TODO" "IN-PROGRESS" "WAITING" "DONE")))

;; (setq org-tag-alist '(("@work" . ?w) ("@home" . ?h) ("laptop" . ?l)))
(setq org-hide-emphasis-markers t)
