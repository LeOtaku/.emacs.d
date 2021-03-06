;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;;; Setup:

;; Load `early-init.el' before Emacs 27.0

(unless (featurep 'early-init)
  (message "Early init: Emacs Version < 27.0")
  (load
   (expand-file-name "early-init.el" user-emacs-directory)))

;; Load `fi-emacs' dependencies

(prog1 "fi-setup"
  (require 'fi-config)
  (require 'fi-helpers)
  (require 'bk))

;;; Configuration:

(prog1 "no-littering"
  (require 'no-littering)
  (setq create-lockfiles nil)
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(bk-block custom-pre
  :custom
  (custom-file . (no-littering-expand-etc-file-name "custom.el"))
  :config
  (when (file-exists-p custom-file)
    (load-file custom-file)))

(bk-block* keyfreq
  :config
  (keyfreq-mode)
  (keyfreq-autosave-mode))

;; Load configuration files

(bk-block loads
  :load "lisp/helpers.el"
  :load "lisp/visual.el"
  :load "lisp/basics.el"
  :load "lisp/usability.el"
  :load "lisp/ide.el"
  :load "lisp/major.el"
  :load "lisp/org-cfg.el"
  :load "lisp/special.el")

;; Load keytheme config

(bk-block keytheme
  :load "lisp/keytheme.el"
  :custom
  (viper-mode . nil))

;; Execute some simple keybinds

(bk-block sensible-keys
  :bind (("<insert>" . nil)
         ("H-m" . newline)
         ("A-j" . next-line)
         ("A-k" . previous-line)
         ("<C-return>" . open-line))
  :config
  (fi-with-gui
   (keyboard-translate ?\C-i ?\H-i)
   (keyboard-translate ?\C-m ?\H-m))
  (define-key key-translation-map
    (kbd "ESC") (kbd "C-g")))

(bk-block bad-habits
  :bind (("<XF86Forward>" . nil)
         ("<XF86Back>" . nil)
         ("<prior>" . nil)
         ("<next>" . nil)
         ("C-<prior>" . nil)
         ("C-<next>" . nil)))

(bk-block misc-bindings
  :bind  (("C-x r" . revert-buffer)
          ("C-x f" . find-file)
          ("C-x e" . eval-defun)
          ("C-x s" . save-buffer))
  :bind* (("C-x i" . ibuffer)
          ("C-v" . yank)))

(bk-block window-management
  :requires .ace-window
  :bind (("C-x q" . split-window-left)
         ("C-x w" . split-window-above)
         ("C-x o" . ace-window)
         ("C-x c" . make-frame)
         ("C-x j" . delete-other-windows)
         ("C-x d" . kill-buffer)
         ("C-x k" . delete-window-or-frame))
  :custom (aw-scope . 'visible)
  :config
  (advice-add
   'keyboard-quit
   :around #'advice-keyboard-quit))

(defun advice-keyboard-quit (func)
  (let ((minibuffer (active-minibuffer-window)))
    (if minibuffer
        (minibuffer-keyboard-quit)
      (funcall func))))

;; Small tweaks

(bk-block0 local-files
  :at-load
  (defun expand-sync-file (name)
    (expand-file-name name sync-directory))
  :custom
  (sync-directory . "~/sync")
  (todo-file . (expand-sync-file "homework.org"))
  (things-file . (expand-sync-file "things.org"))
  (journal-file . (expand-sync-file "journal.org"))
  (archive-file . (expand-sync-file "archive.org"))
  (diary-file . (expand-sync-file "diary"))
  :custom
  (org-agenda-files . (list todo-file things-file journal-file))
  (org-archive-location . (concat archive-file "::* %s")))

;; Run Emacs startup

(bk-block setup-initial-buffer
  :requires emacs-lisp-mode
  :at-load
  (setq initial-major-mode 'text-mode)
  :config
  (fi-with-gui
   (with-current-buffer "*scratch*"
     (emacs-lisp-mode))))

(bk-register-target 'default-target)
(bk-reach-target 'default-target)

(fi-with-gui
 (when (get-buffer "*Warnings*")
   (warn "Warnings were emitted during Emacs startup!")))

(provide 'init)

;;; init.el ends here
