;;; usability.el --- basic usability packages for emacs

;;; Commentary:
;; 

;;; Code:

(bk-block visual-regexp
  :requires .visual-regexp-steroids
  :custom
  (vr/engine . 'pcre2el))

(bk-block wgrep
  :requires .wgrep)

(bk-block ispell
  :bind (("C-." . ispell-word))
  :custom
  (ispell-dictionary . "en_US")
  (ispell-program-name . "aspell")
  (ispell-really-hunspell . nil)
  (ispell-silently-savep . t))

(bk-block which-key
  :start which-key-mode)

(bk-block ivy
  :bind ((:ivy-minibuffer-map
          :package ivy
          ("H-i" . ivy-insert-selection)))
  :start ivy-mode
  :custom
  (ivy-use-selectable-prompt . t))

(defun ivy-insert-selection ()
  (interactive)
  (ivy-exit-with-action
   (lambda (it)
     (interactive)
     (insert it)
     (signal 'quit nil))))

(bk-block counsel
  :bind (("C-s" . swiper-isearch)
         (:counsel-describe-map
          :package counsel
          ("C-h" . counsel-lookup-symbol)))
  :start counsel-mode)

(defun counsel-lookup-symbol ()
  "Lookup the current symbol in the help docs."
  (interactive)
  (ivy-exit-with-action
   (lambda (x)
     (if (featurep 'helpful)
         (helpful-symbol (intern x))
       (describe-symbol (intern x))
       (signal 'quit nil)))))

(bk-block projectile
  :init
  (fi-auto-keymap (kbd "C-x p") 'projectile-command-map 'projectile)
  :custom
  (projectile-completion-system . 'ivy)
  (projectile-project-root-files-functions . '(projectile-root-top-down))
  (projectile-project-root-files . '(".git" ".bzr" ".svn" ".hg" "_darcs" ".projectile"))
  :start projectile-mode counsel-projectile-mode
  :config
  (projectile-load-known-projects))

(bk-block amx
  :config
  (amx-mode))

(bk-block! undohist
  :requires .undohist no-littering
  :config
  (setq undohist-ignored-files  '("COMMIT_EDITMSG"))
  (setq undohist-directory (no-littering-expand-var-file-name "undohist"))
  :config
  (undohist-initialize))

(bk-block yankpad
  :requires .yasnippet
  :bind (("C-x y" . yankpad-insert)
         ("C-x Y" . yankpad-capture-snippet))
  :start yas-global-mode
  :config
  (setq yankpad-file (expand-file-name "yankpad.org" "~")))

(provide 'usability)

;;; usability.el ends here