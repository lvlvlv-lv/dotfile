;; -*- lexical-binding: t; -*-
;; https://emacs-lsp.github.io/lsp-mode/tutorials/CPP-guide/
;; config emacs as an c/c++ IDE
(setq package-selected-packages
      '(lsp-mode
	yasnippet
	lsp-treemacs
	projectile
	hydra
	flycheck
	company
	ivy
	counsel
	swiper
	avy
	which-key
	dap-mode
	lsp-sourcekit))

(my/package-install package-selected-packages)

(add-hook 'c-mode-hook	 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'sh-mode	 'lsp)

(setq ivy-use-selectable-prompt t)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))

(ivy-mode)
(counsel-mode)
(which-key-mode)
