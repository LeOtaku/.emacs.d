;;; early-init.el --- Early initialisation -*- lexical-binding: t; -*-

;;; Commentary:

;; This file is loaded before init.el.
;;
;; `early-init.el' is a new concept introduced in Emacs 27.
;;
;; Until that becomes stable I simply require the file at the top of
;; my `user-init-file'

;;; Code:

;; Never load outdated bytecode (why is this not the default?)

(setq load-prefer-newer t)

;; Defer garbage collection further back in the startup process

(let ((normal-gc-cons-threshold (* 8 1024 1024))
      (init-gc-cons-threshold (* 256 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (run-with-timer
   5 nil
   (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

;; Debug garbage collection performance

(setq garbage-collection-messages nil)

;; Unset `file-name-handler-alist' during startup

(defvar tmp--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun hook-reset-file-handler-alist ()
  (setq file-name-handler-alist
        (append file-name-handler-alist
                tmp--file-name-handler-alist)))
(add-hook 'emacs-startup-hook 'hook-reset-file-handler-alist)

;; Package initialization normally occurs automatically, but this can
;; be unset in the `early-init-file'.

(setq package-enable-at-startup nil)

;; Prevent the glimpse of un-styled Emacs by setting these early

(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(internal-border-width . 12))

;; Load straight and packages

(load-file
 (expand-file-name "load-packages.el"
                   user-emacs-directory))

(provide 'early-init)

;; early-init.el ends here
