;; 设置代理
(setenv "http_proxy" "http://127.0.0.1:6984")
(setenv "https_proxy" "http://127.0.0.1:6984")
(setenv "all_proxy" "socks5://127.0.0.1:6984")

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
  :bind
  (("s-e" . open-emacs-config)
   ;; 替代ctrl+alt+space
   ("C-s-SPC" . mark-sexp)
   ;; M-&打开Async shell command, M-*打开Compile command
   ("M-*" . compile)
   ("C-c w" . whitespace-mode))
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
  (set-face-attribute 'default nil :family "Monospace" :height 240)
  ;; Enable line numbers globally for all buffers
  (global-display-line-numbers-mode)
  ;; Set the line number type to relative
  (setq display-line-numbers-type 'relative)
  ;; 启用空白符显示模式
  (setq-default indicate-empty-lines t)      ;; 显示空行
  (setq-default show-trailing-whitespace t)  ;; 红色显示行尾空格
  ;; 显示更多空白符类型
  (setq whitespace-style '(face           ; 使用颜色高亮
                           trailing       ; 行尾空格
                           tabs           ; 制表符
                           spaces         ; 普通空格
                           space-mark     ; 空格标记
                           tab-mark       ; 制表符标记
                           newline-mark   ; 换行符标记
                           empty          ; 空行
                           indentation    ; 缩进问题
                           space-before-tab
                           space-after-tab))
  ;; 设置显示符号
  (setq whitespace-display-mappings
        '((space-mark   ?\    [?\u00B7] [?.])      ; 空格显示为中点
          (tab-mark     ?\t   [?\u00BB ?\t] [?\\]) ; 制表符显示为 »
          (newline-mark ?\n   [?\u00A4 ?\n])))     ; 换行符显示为货币符号
  (setq-default tab-width 4)
  ;; 定义打开配置文件的函数
  (defun open-emacs-config ()
    "Open Emacs configuration file."
    (interactive)
    (find-file "~/.emacs.d/init.el"))
  ;; 加载customs.el文件的配置
  ;; (setq custom-file (expand-file-name "customs.el" user-emacs-directory))
  ;; (add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))
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
(use-package ivy
  :ensure t
  :hook (after-init . ivy-mode)  ; 启动自动开启
  :config
  (setq ivy-use-virtual-buffers t    ; 显示最近打开的文件
        ivy-count-format "(%d/%d) "   ; 显示匹配数量
        ivy-initial-inputs-alist nil  ; 不自动填充输入
        ivy-wrap t                    ; 列表循环
        ivy-enable-advanced-buffer-information t)
  :bind
  (("M-x" . counsel-M-x)
   ("C-s" . swiper)
   ("C-r" . swiper)
   ("C-x C-f" . counsel-find-file)
   ("C-x b" . ivy-switch-buffer)))

(use-package ivy-rich
  :ensure t
  :after ivy
  :config
  (ivy-rich-mode 1))

(use-package all-the-icons-ivy-rich
  :ensure t
  :after ivy-rich
  :config
  (all-the-icons-ivy-rich-mode 1))

(use-package counsel
  :ensure t
  :after ivy
  :bind
  (("M-x" . counsel-M-x)
   ("C-c f" . counsel-fzf)
   ("C-c r" . counsel-rg)
   ("C-c a" . counsel-ag)
   ("C-c g" . counsel-git))
  :config
  (counsel-mode 1)
  ;; (setq counsel-fzf-cmd "fd --type f --hidden --follow --exclude .git --color never '%s'")
  )

(use-package projectile
  :ensure t
  :config
  (when (executable-find "fd")
    (setq projectile-generic-command "fd . -0 --type f --color=never")
    (setq projectile-git-command "fd . -0 --type f --color=never"))
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)
  (projectile-mode 1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package counsel-projectile
  :ensure t
  :after (ivy counsel projectile)
  :config
  (counsel-projectile-mode 1))

(use-package exec-path-from-shell
  :ensure t
  :if (or (daemonp) (memq window-system '(mac ns x)))
  :custom
  (exec-path-from-shell-shell-name "zsh")
  ;; (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-check-startup-files t)
  ;; (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "NVM_BIN"))
  :config
  (exec-path-from-shell-initialize)
  ;; Optional: Print paths for debugging
  (message "exec-path: %s" exec-path)
  (message "PATH: %s" (getenv "PATH")))

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window)
         ("M-0" . ace-delete-window)    ;; Delete window
         ("M-=" . ace-window-display-mode))  ;; Show window numbers in mode-line

  :custom
  ;; Window label appearance
  (aw-scope 'frame)                      ;; Scope: 'frame, 'visible, 'global
  (aw-background nil)                    ;; Don't dim other windows
  (aw-dispatch-always t)                 ;; Always show action prompt

  :config
  ;; Use home row keys for faster access (if you have a keyboard with good layout)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l ?\;)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)               ; Edit each line in a region
         ("C->" . mc/mark-next-like-this)              ; Mark next identical occurrence
         ("C-<" . mc/mark-previous-like-this)          ; Mark previous identical occurrence
         ("C-c C-<" . mc/mark-all-like-this)           ; Mark all identical occurrences
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))  ; Add cursor by clicking

(use-package gt
  :ensure t
  :bind (("C-c t" . gt-translate))
  :config
  ;; 1. 基础语言设置
  (setq gt-langs '(en zh))
  ;; 2. 国内用户建议配置（加快访问速度）
  ;; (setq gt-google-host "https://translate.google.cn")
  ;; 3. 代理配置（按需取消注释）
  (setq gt-http-proxy "http://127.0.0.1:6984")
  ;; 4. GT v3 新语法：使用列表形式，通过 :if 条件判断
  (setq gt-default-translator
        (gt-translator
         :taker (list (gt-taker :pick 'region :if 'selection)   ; 有选中区域时翻译区域
                      (gt-taker :text 'word))                    ; 否则翻译当前单词
         :engines (list (gt-google-engine))
         :render (gt-buffer-render))))

(use-package cmake-mode
  :ensure t
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode))
  :hook (cmake-mode . (lambda ()
                        (setq indent-tabs-mode nil)))
  :config
  (message "CMake mode loaded"))

(use-package highlight-symbol
  :ensure t
  :bind (("<f8>" . highlight-symbol)
         ("<f9>" . highlight-symbol-remove-all))
  :config
  (setq highlight-symbol-idle-delay 0.3))

;; lsp
(use-package lsp-mode
  :ensure t                           ;; 确保安装
  :init
  ;; 设置 lsp-mode 相关命令的前缀键，例如 'C-c l' 后面可以接 'r' 来执行重命名
  (setq lsp-keymap-prefix "C-c l")
  ;; (setq lsp-enable-xref nil)  ; 禁用 LSP 的跳转，继续用 etags
  :hook
  (;; 在以下编程语言的主模式下自动启动 lsp-mode
   (c-mode . lsp-deferred))
  :commands (lsp lsp-deferred)        ;; 延迟加载，提升启动速度
  :config
  ;; 可选：集成 which-key，在你输入前缀键后显示可用的命令
  (lsp-enable-which-key-integration t))
