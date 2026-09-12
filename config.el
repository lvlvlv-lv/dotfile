;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'gruber-darker)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(setq initial-frame-alist '((fullscreen . maximized)))

(setq doom-font (font-spec :family "monospace" :size 24 :weight 'regular)
      ;; variable-pitch 用于文本模式（如 Org-mode 属性栏、Markdown 预览等）
      doom-variable-pitch-font (font-spec :family "sans-serif" :size 24)
      ;; big-font 用于开启“大字号模式”（如演讲、分享屏幕时）
      doom-big-font (font-spec :family "monospace" :size 24))

(setq native-comp-async-report-warnings-errors 'silent)
(setq warning-minimum-level :error)

(after! ispell
  (setq ispell-alternate-dictionary "/usr/share/dict/words"))

(use-package! eaf
  :custom
  (eaf-apps-to-install '(browser
                         pdf-viewer
                         image-viewer
                         video-player
                         system-monitor))
  :config
  (eaf-setq eaf-proxy-type "socks5")
  (eaf-setq eaf-proxy-host "127.0.0.1")
  (eaf-setq eaf-proxy-port "7892")
  (setq eaf-byte-compile-apps t)
  (require 'eaf-browser)
  (require 'eaf-pdf-viewer)
  (require 'eaf-image-viewer)
  (require 'eaf-video-player)
  (require 'eaf-system-monitor))

(after! org
  (setq org-hide-emphasis-markers t)
  (setq org-startup-with-inline-images t))

(use-package! gtags-mode
  :defer t
  :hook (((prog-mode) . gtags-mode)) ; 可根据需要改成你常用的语言模式
  :config
  ;; 设置环境变量，使 gtags 在后台调用 universal-ctags（通常标签名为 new-ctags 或 universal-ctags）
  (setenv "GTAGSLABEL" "new-ctags")

  ;; 如果需要传递额外的生成参数，也可以在此调整
  ;; (setq gtags-mode-update-args "--gtagslabel=new-ctags")
  )

(use-package! fzf
  :defer t
  :config
  (setq fzf/executable "fzf"
        fzf/args (concat "-m --ansi --layout=reverse --height=40% "
                         "--preview 'bat --style=numbers --color=always --line-range :100 {}' "
                         "--bind 'ctrl-d:preview-page-down,ctrl-u:preview-page-up,"
                         "ctrl-j:preview-down,ctrl-k:preview-up,"
                         "ctrl-v:transform-query(echo -n {q}; xclip -o -selection clipboard)'")))
