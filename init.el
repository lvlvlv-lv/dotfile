;; -*- lexical-binding: t; -*-

(require 'package)
;; 增加 melpa 库
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;; 初始化包系统
(package-initialize)

;; 只有当 use-package 不是内置时才安装
(unless (fboundp 'use-package)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; 设置 use-package 总是确保包已安装
(setq use-package-always-ensure t)

;; appearance
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(transient-mark-mode 1)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq inhibit-startup-message t)
(add-to-list 'default-frame-alist '(font . "monospace-20"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; (add-to-list 'default-frame-alist '(alpha . 80))
(setq make-backup-files nil)
;; indent style
(setq c-default-style '((c-mode . "cc-mode") (other . "gun")))
(setq inhibit-splash-screen t)

;; global key maps
(global-set-key (kbd "M-*") 'compile)
(global-set-key (kbd "C-c a") 'org-agenda)

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

(setq custom-file "~/.config/emacs/custom.el")
(load-file custom-file)
