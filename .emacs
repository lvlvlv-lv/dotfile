;; proxy
(defvar my-proxy nil)

(defun open-proxy ()
  (interactive)
  (setq my-proxy "127.0.0.1:7890")
  (setenv "http_proxy" "http://127.0.0.1:7890")
  (setenv "https_proxy" "http://127.0.0.1:7890")
  (setenv "all_proxy" "socks5://127.0.0.1:7890")
  (message "Current proxy is \"%s\"" my-proxy))

(defun close-proxy ()
  (interactive)
  (setq my-proxy nil)
  (setenv "http_proxy" "")
  (setenv "https_proxy" "")
  (setenv "all_proxy" "")
  (message "No proxy"))


(setq custom-file "~/.emacs.custom.el")
(package-initialize)

;; custom fucntion
(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/misc-rc.el")

;; Appearance
(add-to-list 'default-frame-alist `(font . "Iosevka-24"))
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(rc/require-theme 'gruber-darker)

;; ido
(rc/require 'smex 'ido-completing-read+)
(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; multiple cursors
(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C->")     'mc/mark-all-like-this)
(global-set-key (kbd "C-;")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-\"")         'mc/skip-to-previous-like-this)

(setq-default with-editor-emacsclient-executable "emacsclient")

;; magit
(rc/require 'magit)
(require 'magit)

;; IDE code reading config
(rc/require 'lsp-mode 'yasnippet 'lsp-treemacs 'helm-lsp 'projectile 'hydra 'flycheck 'company 'avy 'which-key 'helm-xref 'dap-mode)
;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
;; (helm-mode) ;; imcompatible whith ido-everywhere 
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

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

;; Expand region increases the selected region by semantic units. Just keep
;; pressing the key until it selects what you want.
(rc/require 'expand-region)
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;; indent style
(setq c-default-style
      '((java-mode . "java")
        (awk-mode . "awk")
        (c-mode . "cc-mode")
        (other . "gnu")))
;; org-mode
;; Disable the splash screen (to enable it agin, replace the t with 0)
(setq inhibit-splash-screen t)

;; Enable transient mark mode
(transient-mark-mode 1)

;;;;Org mode configuration
;; Enable Org mode
(rc/require 'org)
(require 'org)
;; Make Org mode work with files ending in .org
;; (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; The above is the default in recent emacsen

;; binding compile
(global-set-key (kbd "M-*") 'compile)

(load-file custom-file)
