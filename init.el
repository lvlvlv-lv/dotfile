;; 设置代理
;; export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
(setenv "http_proxy" "http://127.0.0.1:7897")
(setenv "https_proxy" "http://127.0.0.1:7897")
(setenv "all_proxy" "socks5://127.0.0.1:7897")

;; 下载elpaca
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; elpaca最佳实践
;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.
;; (elpaca example-package)
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

;; Expands to: (elpaca evil (use-package evil :demand t))
;; (use-package evil :ensure t :demand t)

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs
  :ensure nil
  :config
  (setq ring-bell-function #'ignore)
  ;; 禁用启动画面
  (setq inhibit-startup-screen t)
  ;; 禁用工具栏
  (tool-bar-mode -1)
  ;; 禁用菜单栏
  (menu-bar-mode -1)
  ;; 禁用备份文件（filename~）
  (setq make-backup-files nil)
  ;; 禁用自动保存文件（#filename#）
  (setq auto-save-default nil)
  ;; 禁用锁定文件（.#filename）
  (setq create-lockfiles nil)
  ;; 启动时最大化窗口
  (add-to-list 'default-frame-alist '(fullscreen . maximized))

  ;; 设置字体名称和大小
  (set-face-attribute 'default nil :family "Monospace" :height 120)

  ;; 加载customs.el文件的配置
  ;; (setq custom-file (expand-file-name "customs.el" user-emacs-directory))
  ;; (add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

  ;; Enable line numbers globally for all buffers
  (global-display-line-numbers-mode)

  ;; Set the line number type to relative
  (setq display-line-numbers-type 'relative)

  ;; 定义打开配置文件的函数
  (defun open-emacs-config ()
    "Open Emacs configuration file."
    (interactive)
    (find-file "~/.emacs.d/init.el"))

  :bind (
	 ("s-e" . open-emacs-config)
	 ;; 替代ctrl+alt+space
	 ("C-s-SPC" . mark-sexp)
	 ;; M-&打开Async shell command, M-*打开Compile command
	 ("M-*" . compile)
	 )
  )

;; 主题
(use-package gruber-darker-theme
  :ensure t
  :custom
  ;; 设置默认主题，Emacs 启动时会自动加载
  (custom-enabled-themes '(gruber-darker))
  (custom-safe-themes t))

;; 代码补全
(use-package company
  :ensure t
  :hook (prog-mode . company-mode)  ; 只在编程模式启用
  :config
  (setq company-idle-delay 0.2)      ; 补全延迟 0.2秒
  )

;; Git客户端
(use-package transient
  :ensure t
  :demand t)  ; 先确保 transient 是最新的
(use-package magit
  :ensure t
  :after transient  ; 确保在 transient 之后加载
  :bind ("C-x g" . magit-status))

;; 交互式补全
;; 基础 Ido 配置
(use-package ido
  :ensure nil  ;; ido 是内置的
  :custom
  ;; 启用模糊匹配 - 可以在文件名任意位置输入字符匹配
  (ido-enable-flex-matching t)
  ;; 在所有可能的地方使用 ido（如 M-x，但会被 smex 增强）
  (ido-everywhere t)
  ;; 智能获取当前光标处的文件名/路径作为初始输入
  (ido-use-filename-at-point 'guess)
  ;; 支持 URL 作为文件名
  (ido-use-url-at-point t)
  ;; 显示隐藏文件（点开头的文件）
  (ido-enable-dot-prefix t)
  ;; 支持 TRAMP 远程文件编辑
  (ido-enable-tramp-completion t)
  ;; 新建 buffer 时的行为：'prompt 表示询问
  (ido-create-new-buffer 'prompt)
  ;; 显示匹配项的数量
  (ido-max-prospects 10)
  ;; 使用 faces 高亮匹配字符
  (ido-use-faces t)
  ;; 不保留最近访问过的文件的顺序（可选，如果不需要可以注释掉）
  ;; (ido-record-commands nil)
  ;; 忽略这些文件（不显示在补全列表中）
  (ido-ignore-buffers 
   '("\\` " "^\*Mess" "^\*Back" "^\*Quail" "^\*Completions" "^\*Ido" "^\*trace" 
     "^\*compilation" "^\*GTAGS" "^session\\*" "^\*EMMS"))
  (ido-ignore-files
   '("\\`\\.?#" "\\`\\.\\'" "\\`\\.\\.\\'" "\\`#.*#" "^\\.DS_Store" "^\\.git"))
  
  :config
  ;; 自定义函数：方便调试 ido
  (defun my/ido-debug ()
    "显示当前 ido 状态，用于调试"
    (interactive)
    (message "ido-mode: %s, ido-ubiquitous-mode: %s, flx-ido-mode: %s, ido-grid-mode: %s, ido-vertical-mode: %s"
             (if (bound-and-true-p ido-mode) "on" "off")
             (if (bound-and-true-p ido-ubiquitous-mode) "on" "off")
	     (if (bound-and-true-p flx-ido-mode) "on" "off")
	     (if (bound-and-true-p ido-grid-mode) "on" "off")
	     (if (bound-and-true-p ido-vertical-mode) "on" "off")
	     ))

  ;; 启用 ido 模式
  (ido-mode t)
  ;; 配置 ido 的 faces，让匹配的字符更明显
  (custom-set-faces
   ;; 当前选中的项（粗体 + 蓝色）
   '(ido-first-match ((t (:weight bold :foreground "#61afef" :underline nil))))
   ;; 唯一匹配项（绿色）
   '(ido-only-match ((t (:foreground "#98c379"))))
   ;; 子目录（黄色）
   '(ido-subdir ((t (:foreground "#e5c07b"))))
   ;; 匹配到的字符（红色背景高亮）
   '(ido-match ((t (:background "#e06c75" :foreground "#282c34"))))
   ;; 虚拟 buffer（灰色）
   '(ido-virtual ((t (:foreground "#5c6370")))))
  :bind
  (
   ;; 查看ido状态
   ("C-c i d" . my/ido-debug)
   )
  )

;; 让所有 completing-read 都使用 Ido
(use-package ido-completing-read+
  :ensure t
  :after ido
  :custom
  ;; 如果遇到某些命令表现不正常，可以在这里排除
  (ido-ubiquitous-command-exceptions
   '("find-file"  ;; 这些命令已经由 ido 本身处理
     "switch-to-buffer"
     "dired"
     "compile"))
  
  ;; 对于某些命令，如果 ido 不太适合，可以回退到原始 completing-read
  (ido-cr+-fallback-command-alist
   '(("org-tags-view" . nil)
     ("org-set-tags" . nil)))
  
  :config
  ;; 确保 ido-ubiquitous 在所有可能的上下文中启用
  (ido-ubiquitous-mode t))

;; 增强的模糊匹配
(use-package flx-ido
  :ensure t
  :after ido
  :config
  ;; 启用 flx 增强的模糊匹配算法
  (flx-ido-mode t)
  
  ;; 覆盖默认的 flex 匹配，使用 flx 的更智能算法
  (setq ido-enable-flex-matching t)  ;; flx-ido 会接管这个
  
  ;; 提高匹配分数阈值，使结果更精确
  (setq flx-ido-threshold 0.6))

;; 增强 M-x 体验
(use-package smex
  :ensure t
  :after ido
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)
         ("C-c C-c M-x" . smex))
  :custom
  (smex-save-file (expand-file-name ".smex-items" user-emacs-directory))
  :config
  (smex-initialize))

;; 让 ido 补全列表网格显示
(use-package ido-grid-mode
  :ensure t
  :after ido
  :config
  (ido-grid-mode 1))

;; 让 ido 补全列表竖直显示
(use-package ido-vertical-mode
  :ensure t
  :after ido
  :custom
  ;; 定义上下键：使用 C-n/C-p 在列表中导航
  (ido-vertical-define-keys 'C-n-and-C-p-only)
  
  ;; 竖直显示模式下的其他设置
  (ido-vertical-show-count t)           ;; 显示匹配项数量
  (ido-vertical-buffer-display-height 0.3) ;; 补全窗口高度比例
  
  :config
  ;; (ido-vertical-mode t)
  )

;; lsp
;; 安装并配置 lsp-mode 核心
(use-package lsp-mode
  :ensure t                           ;; 确保安装
  :init
  ;; 设置 lsp-mode 相关命令的前缀键，例如 'C-c l' 后面可以接 'r' 来执行重命名
  (setq lsp-keymap-prefix "C-c l")

  :hook
  (
   ;; 在以下编程语言的主模式下自动启动 lsp-mode
   (c-mode . lsp-deferred)
   )
  :commands (lsp lsp-deferred)        ;; 延迟加载，提升启动速度
  :config
  ;; 可选：集成 which-key，在你输入前缀键后显示可用的命令
  (lsp-enable-which-key-integration t))
