;; -*- lexical-binding: t; -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; appearance
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq inhibit-startup-message t)
(add-to-list 'default-frame-alist '(font . "monospace-20"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; (add-to-list 'default-frame-alist '(alpha . 80))
(setq make-backup-files nil)

;; indent style
(setq c-default-style
      '((java-mode . "java")
        (awk-mode . "awk")
        (c-mode . "cc-mode")
        (other . "gnu")))

(transient-mark-mode 1)
(setq inhibit-splash-screen t)

(global-set-key (kbd "M-*") 'compile)
(global-set-key (kbd "C-c a") 'org-agenda)

;; custom function
(defun my/package-install (selected-packages)
  (when (cl-find-if-not #'package-installed-p selected-packages)
    (package-refresh-contents)
    (mapc #'package-install selected-packages)))

;; load all config file
(defun load-el-files-from-directory (dir)
  "安全地加载目录 DIR 下的所有 .el 文件"
  (when (file-directory-p dir)
    (dolist (file (directory-files dir t "\\.el$"))
      ;; 排除以 .elc 结尾的编译文件和以 -pkg.el 结尾的包文件
      (unless (or (string-match-p "\\.elc$" file)
                  (string-match-p "-pkg\\.el$" file))
        (condition-case err
            (progn
	                    (load (file-name-sans-extension file) nil t)
              (message "Loaded: %s" (file-name-nondirectory file)))
          (error (message "Load file %s error: %s" file (error-message-string err))))))))

;; 使用示例
(load-el-files-from-directory "~/.config/emacs/elisp/")


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
