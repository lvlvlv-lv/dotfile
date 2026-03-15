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

;; 禁用pacakge.el
(setq package-enable-at-startup nil)

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
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  ;; 设置字体名称和大小
  (set-face-attribute 'default nil :family "Monospace" :height 120)

  (setq custom-file (expand-file-name "customs.el" user-emacs-directory))
  (add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

  ;; 定义打开配置文件的函数
  (defun open-emacs-config ()
    "Open Emacs configuration file."
    (interactive)
    (find-file "~/.emacs.d/init.el"))

  ;; 自定义函数：方便调试 ido
  (defun my/ido-debug ()
    "显示当前 ido 状态，用于调试"
    (interactive)
    (message "ido-mode: %s, ido-ubiquitous-mode: %s, ido-vertical-mode: %s, ido-grid-mode: %s, flx-ido-mode: %s"
             (if (bound-and-true-p ido-mode) "on" "off")
             (if (bound-and-true-p ido-ubiquitous-mode) "on" "off")
	     (if (bound-and-true-p flx-ido-mode) "on" "off")
	     (if (bound-and-true-p ido-grid-mode) "on" "off")
	     (if (bound-and-true-p ido-vertical-mode) "on" "off")
	     ))

  :bind (
	 ("s-e" . open-emacs-config)
	 ;; 替代ctrl+alt+space
	 ("C-s-SPC" . mark-sexp)
	 ;; M-&打开Async shell command, M-*打开Compile command
	 ("M-*" . compile)
	 ;; 查看ido状态
	 ("C-c i d" . my/ido-debug)
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
   '(ido-virtual ((t (:foreground "#5c6370"))))))

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

  ;; 自定义函数，检查不是 Elisp 模式才启用 LSP
  (defun my/lsp-mode-enable-maybe ()
    "Enable lsp-mode for non-elisp buffers."
    (unless (derived-mode-p 'emacs-lisp-mode)
      (lsp)))

  :hook (
         ;; 在以下编程语言的主模式下自动启动 lsp-mode
         ;; (python-mode . lsp-deferred)  ;; Python
         ;; (go-mode . lsp-deferred)      ;; Go
         ;; (rust-mode . lsp-deferred)    ;; Rust
         ;; (js-mode . lsp-deferred)      ;; JavaScript
         ;; (typescript-mode . lsp-deferred) ;; TypeScript
         ;; (web-mode . lsp-deferred)      ;; 适用于 Vue/React 等
         ;; ;; 你可以按需添加更多，例如 (c-mode . lsp-deferred)
         ;; 如果你想对所有编程模式都启用，可以使用 (prog-mode . lsp)
         (prog-mode . my/lsp-mode-enable-maybe)  ;; 使用自定义函数
         )
  :commands (lsp lsp-deferred)        ;; 延迟加载，提升启动速度
  :config
  ;; 可选：集成 which-key，在你输入前缀键后显示可用的命令
  (lsp-enable-which-key-integration t))

;;; 模糊查找配置
;; 使用方法：
;; C-c p f - 模糊查找项目文件
;; C-c p g - 模糊搜索文件内容
;; C-c p a - 手动添加当前目录为项目
;; C-c p r - 移除当前项目
;; C-c p k - 查看所有已知项目
;; 
;; 在搜索时：
;; C-c i - 切换大小写敏感（默认忽略大小写）
;; C-c w - 切换全词匹配
;; C-c r - 切换正则表达式模式
;; C-c m - 显示当前激活的模式
;; C-c d - 重置所有模式到默认状态

;; 1. 核心功能：Projectile + Consult
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  ;; 移除自动扫描路径设置，只保留自动识别（通过 .git/.projectile 等标记）
  ;; 设置切换项目时的默认操作
  (setq projectile-switch-project-action 'projectile-dired)
  ;; 添加手动管理项目的快捷键
  :bind (("C-c p a" . projectile-add-known-project)     ;; 手动添加当前目录为项目
         ("C-c p r" . projectile-remove-known-project)  ;; 移除项目
         ("C-c p k" . projectile-known-projects)        ;; 查看所有已知项目
         ("C-c p f" . consult-projectile-find-file)     ;; 查找项目文件
         ("C-c p g" . consult-ripgrep)))                 ;; 搜索项目内容

(use-package consult
  :ensure t
  :bind (("C-c p f" . consult-projectile-find-file)  ;; 模糊查找项目文件
         ("C-c p g" . consult-ripgrep)                ;; 模糊搜索文件内容
         ("C-c s s" . consult-line)                    ;; 当前 buffer 搜索
         ("C-c s g" . consult-grep))                    ;; 手动指定目录 grep
  :config
  ;; 启用预览功能
  (setq consult-preview-key 'any)
  
  ;; 配置 ripgrep 参数，支持智能大小写
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 \
--path-separator /\
--smart-case --no-heading --with-filename --line-number --column")
  
  ;; 让 consult 记住上次搜索的目录
  (setq consult-project-root-function #'projectile-project-root))

;; 2. Orderless 模糊匹配
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

;; 3. 模式切换功能（开关模式）
;; 全局变量，记录当前搜索模式的状态
(defvar my/consult-case-sensitive nil "是否区分大小写")
(defvar my/consult-word-mode nil "是否全词匹配")
(defvar my/consult-regexp-mode nil "是否正则表达式模式")

(defun my/consult-toggle-case-sensitive ()
  "切换区分大小写开关。"
  (interactive)
  (setq my/consult-case-sensitive (not my/consult-case-sensitive))
  (setq-local completion-ignore-case (not my/consult-case-sensitive))
  (message "Case sensitive: %s" (if my/consult-case-sensitive "ON" "OFF")))

(defun my/consult-toggle-word-mode ()
  "切换全词匹配开关。"
  (interactive)
  (setq my/consult-word-mode (not my/consult-word-mode))
  (if my/consult-word-mode
      ;; 开启全词匹配：匹配完整的单词
      (setq-local orderless-match-components '((orderless-regexp . "\\b\\S-*\\b")))
    ;; 关闭全词匹配，恢复默认
    (setq-local orderless-match-components nil))
  (message "Word mode: %s" (if my/consult-word-mode "ON" "OFF")))

(defun my/consult-toggle-regexp-mode ()
  "切换正则表达式模式开关。"
  (interactive)
  (setq my/consult-regexp-mode (not my/consult-regexp-mode))
  (if my/consult-regexp-mode
      ;; 开启正则模式 - 使用基本 completion 风格以支持正则
      (setq-local completion-styles '(basic))
    ;; 关闭正则模式，恢复 orderless 模糊匹配
    (setq-local completion-styles '(orderless basic)))
  (message "Regexp mode: %s" (if my/consult-regexp-mode "ON" "OFF")))

(defun my/show-active-modes ()
  "显示当前激活的搜索模式。"
  (interactive)
  (let ((modes '()))
    (when my/consult-case-sensitive (push "Case" modes))
    (when my/consult-word-mode (push "Word" modes))
    (when my/consult-regexp-mode (push "Regexp" modes))
    (if modes
        (message "Active modes: %s" (string-join modes " + "))
      (message "Default fuzzy mode (ignore case, multi-word)"))))

(defun my/reset-search-modes ()
  "重置所有搜索模式到默认状态。"
  (interactive)
  (setq my/consult-case-sensitive nil
        my/consult-word-mode nil
        my/consult-regexp-mode nil)
  (setq-local completion-ignore-case t
              completion-styles '(orderless basic)
              orderless-match-components nil)
  (message "All modes reset to default (ignore case, fuzzy)"))

(defun my/consult-minibuffer-keymap-setup ()
  "在 minibuffer 中设置搜索模式切换快捷键。"
  ;; 每次进入搜索时重置状态
  (my/reset-search-modes)
  
  ;; 绑定快捷键
  (define-key minibuffer-local-map (kbd "C-c i") 
	      (lambda () (interactive) (my/consult-toggle-case-sensitive)))
  (define-key minibuffer-local-map (kbd "C-c w") 
	      (lambda () (interactive) (my/consult-toggle-word-mode)))
  (define-key minibuffer-local-map (kbd "C-c r") 
	      (lambda () (interactive) (my/consult-toggle-regexp-mode)))
  (define-key minibuffer-local-map (kbd "C-c m") 
	      (lambda () (interactive) (my/show-active-modes)))
  (define-key minibuffer-local-map (kbd "C-c d") 
	      (lambda () (interactive) (my/reset-search-modes))))

;; 添加到 consult 的 hook 中
(add-hook 'consult-after-jump-hook #'my/consult-minibuffer-keymap-setup)

;; 4. 更好的 UI：Vertico + Marginalia
(use-package vertico
  :ensure t
  :init
  (vertico-mode +1)
  :config
  (setq vertico-scroll-delay 0.1
        vertico-count 15  ;; 显示15个候选
        vertico-cycle t)) ;; 允许循环滚动

;; 在 minibuffer 中显示额外信息
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode +1)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy
                                marginalia-annotators-light)))

;; 5. 异步搜索方案：Affe（备选，追求极致速度时使用）
(use-package affe
  :ensure t
  :after consult
  :config
  ;; 配置 Orderless 作为 affe 的编译器
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)
  
  ;; 手动预览键
  (consult-customize affe-grep :preview-key "M-.")
  
  ;; 绑定快捷键（可选，与 consult 命令并存）
  :bind (("C-c p s f" . affe-find)    ;; 异步模糊查找文件
         ("C-c p s g" . affe-grep)))   ;; 异步模糊 grep

;; 6. 可选：让补全更加智能
(use-package consult-dir
  :ensure t
  :bind (("C-x C-d" . consult-dir)     ;; 快速切换目录
         :map vertico-map
         ("C-x C-d" . consult-dir)))   ;; 在 vertico 中也能用

;; 7. 可选：最近打开的文件
(use-package recentf
  :config
  (recentf-mode +1)
  (setq recentf-max-menu-items 25
        recentf-max-saved-items 100))

;; 8. 性能优化设置
;; 提升大项目中的搜索性能
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1MB

;; 提供更友好的 minibuffer 历史导航
(use-package savehist
  :init
  (savehist-mode +1))
