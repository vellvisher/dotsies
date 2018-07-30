(use-package shell-pop
  :ensure t
  :bind (([f5] . ar/shell-pop))
  :config
  (use-package eshell
    :hook (eshell-mode . ar/eshell-mode-hook-function)
    :init
    (defun ar/eshell-mode-hook-function ()
      ;; Turn off semantic-mode in eshell buffers.
      (semantic-mode -1)

      (eshell-smart-initialize)

      (setq-local global-hl-line-mode nil)

      (add-to-list 'eshell-visual-commands "ssh")
      (add-to-list 'eshell-visual-commands "tail")
      (add-to-list 'eshell-visual-commands "top")

      ;; TODO: Enable company.
      ;; (setq-local company-backends '((company-projectile-cd company-escaped-files)))

      ;; comint-magic-space needs to be whitelisted to ensure we receive company-begin events in eshell.
      (when (boundp 'company-begin-commands)
        (setq-local company-begin-commands
                    (append company-begin-commands (list 'comint-magic-space))))

      (bind-key "C-l" #'ar/eshell-cd-to-parent eshell-mode-map))
    :config
    (use-package em-hist)
    (use-package em-glob)

    (use-package esh-mode
      :config
      ;; Why is vsetq not finding it?
      (setq eshell-scroll-to-bottom-on-input 'all))

    (use-package em-dirs)
    (use-package em-smart)

    ;; Avoid "WARNING: terminal is not fully functional."
    ;; http://mbork.pl/2018-06-10_Git_diff_in_Eshell
    (setenv "PAGER" "cat")

    (vsetq eshell-where-to-jump 'begin)
    (vsetq eshell-review-quick-commands nil)
    (vsetq eshell-smart-space-goes-to-end t)

    (vsetq eshell-history-size (* 10 1024))
    (vsetq eshell-hist-ignoredups t)
    (vsetq eshell-error-if-no-glob t)
    (vsetq eshell-glob-case-insensitive t)
    (vsetq eshell-list-files-after-cd nil)

    (defun ar/eshell-cd-to-parent ()
      (interactive)
      (goto-char (point-max))
      (insert "cd ..")
      (eshell-send-input nil t))

    (use-package ar-eshell-config))

  ;; (csetq shell-pop-term-shell "/bin/bash")
  ;; (csetq shell-pop-shell-type '("ansi-term"
  ;;                              "terminal"
  ;;                              (lambda
  ;;                                nil (ansi-term shell-pop-term-shell))))

  ;; Must use custom set for these.
  (csetq shell-pop-window-position "full")
  (csetq shell-pop-shell-type '("eshell" "*eshell*" (lambda ()
                                                      (eshell))))
  (csetq shell-pop-term-shell "eshell")

  (defun ar/shell-pop (shell-pop-autocd-to-working-dir)
    "Shell pop with arg to cd to working dir. Else use existing location."
    (interactive "P")
    ;; shell-pop-autocd-to-working-dir is defined in shell-pop.el.
    ;; Using lexical binding to override.
    (if (string= (buffer-name) shell-pop-last-shell-buffer-name)
        (shell-pop-out)
      (shell-pop-up shell-pop-last-shell-buffer-index))))