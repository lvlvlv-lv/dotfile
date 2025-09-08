;; -*- lexical-binding: t; -*-

;; multiple cursors
(setq package-selected-packages '(multiple-cursors))
(my/package-install package-selected-packages)

(global-set-key (kbd "C-S-c C-S-c")	'mc/edit-lines)
(global-set-key (kbd "C->")		'mc/mark-next-like-this)
(global-set-key (kbd "C-<")		'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C->")		'mc/mark-all-like-this)
(global-set-key (kbd "C-;")		'mc/skip-to-next-like-this)
(global-set-key (kbd "C-\"")		'mc/skip-to-previous-like-this)
