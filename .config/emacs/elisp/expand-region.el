;; -*- lexical-binding: t; -*-

(setq package-selected-packages '(expand-region))
(my/package-install package-selected-packages)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

