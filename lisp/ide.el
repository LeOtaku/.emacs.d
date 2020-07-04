;;; ide.el --- configurations for emacs as an ide -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(bk-block ide-backspace
  :hook
  (prog-mode-hook . ide-mode)
  (text-mode-hook . ide-mode)
  (conf-mode-hook . ide-mode)
  (TeX-mode-hook . ide-mode)
  (lispy-mode-hook . (lambda () (ide-mode -1)))
  :config
  (define-minor-mode ide-mode
    "IDE style backspace key."
    nil
    "IDE"
    '(([backspace] . ide-backspace)
      ([C-backspace] . ide-backspace-word))))

(defun ide-backspace ()
  (interactive)
  (cond
   ((region-active-p)
    (delete-region (region-beginning) (region-end)))
   ((looking-back "^[[:space:]]+")
    (ide-delete-to-previous-line))
   (t
    ;; delete char normally
    (call-interactively 'backward-delete-char))))

(defun ide-backspace-word ()
  (interactive)
  (cond
   ((looking-back "^[[:space:]]+")
    (ide-delete-to-previous-line))
   (t
    ;; delete word normally
    (call-interactively 'backward-delete-word))))

(defun backward-delete-word (arg)
  (interactive "p")
  (delete-region (point) (progn (backward-word arg) (point))))

(defun ide-delete-to-previous-line ()
  ;; delete all spaces
  (while (not (looking-back "[\n]"))
    (delete-char -1))
  ;; delete final newline
  (delete-char -1)
  ;; go to indentation
  (when (looking-back "[\n]")
    (indent-according-to-mode)))

(bk-block smartparens
  :requires .smartparens .smartparens-config
  :start smartparens-global-mode
  :bind ((:sp-pair-overlay-keymap
          :package smartparens
          ("TAB" . sp-forward-sexp)
          (">" . nil)
          ("<" . nil)))
  :config
  (dolist (paren-type '("(" "[" "{"))
    (sp-local-pair
     'prog-mode paren-type nil
     :post-handlers '((ide-insert-newlines "RET")
                      (ide-insert-spaces "SPC")))))

(defun ide-insert-newlines (&rest _)
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(defun ide-insert-spaces (&rest _)
  (insert " ")
  (backward-char))

(bk-block company
  :requires .company .company-posframe
  :hook
  (prog-mode-hook . company-mode)
  (text-mode-hook . company-mode)
  :bind ((:company-active-map
          :package company
          ("RET" . nil)
          ("<return>" . nil)
          ("C-h" . nil)
          ("<escape>" . nil)
          ("<tab>" . company-complete-selection)
          ("<backtab>" . company-select-previous)))
  :custom
  (company-minimum-prefix-length . 1)
  (company-idle-delay . 0.2)
  (company-dabbrev-downcase . nil)
  (company-dabbrev-ignore-case . nil)
  (company-require-match . nil)
  (company-tooltip-align-annotations . t)
  (company-frontends . '(company-tng-frontend
                         company-pseudo-tooltip-frontend
                         company-echo-metadata-frontend))
  (company-posframe-show-indicator . nil)
  (company-posframe-show-metadata . nil)
  (company-posframe-quickhelp-delay . nil)
  :config
  (fi-with-gui
   (company-posframe-mode 1)))

(bk-block fix-semantic
  :requires .semantic/db-file
  :at-load
  (with-eval-after-load 'semantic
    (defun hook-semantic-fix-lispy ()
      (dolist (x (default-value 'completion-at-point-functions))
        (when (string-prefix-p "semantic-" (symbol-name x))
          (remove-hook 'completion-at-point-functions x))))
    (add-hook 'semantic-mode-hook 'hook-semantic-fix-lispy)))

(bk-block lsp
  :requires .lsp-mode .company-lsp .lsp-ui
  :wanted-by delayed-target
  :hook
  (rust-mode-hook . lsp)
  (lsp-mode-hook . lsp-ui-mode)
  :custom
  (lsp-enable-symbol-highlighting . nil)
  (lsp-auto-configure . t)
  (lsp-diagnostic-package . :none)
  (lsp-ui-doc-enable . nil)
  ;; rust-analyzer
  (lsp-rust-server . 'rust-analyzer)
  (lsp-rust-analyzer-server-command
   .  (concat (getenv "CARGO_HOME") "/bin/rust-analyzer")))

(bk-block standard-env
  :requires .envrc .editorconfig
  :start editorconfig-mode
  :start envrc-global-mode)

;;; ide.el ends here
