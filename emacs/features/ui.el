(require 'ar-vsetq)

;; No title. See init.el for initial value.
(when (display-graphic-p)
  (setq frame-title-format nil))

;; Set font face height. Value is 1/10pt.
(set-face-attribute 'default nil
                    :height 180)

;; Ensure window is maximized after window setup.
(use-package maxframe
  :ensure t
  :hook (window-setup . maximize-frame))

(use-package material-theme
  :ensure t
  :config
  (load-theme 'material t)

  ;; From https://gist.github.com/huytd/6b785bdaeb595401d69adc7797e5c22c#file-customized-org-mode-theme-el
  (set-face-attribute 'default nil :stipple nil :background "#212121" :foreground "#eeffff" :inverse-video nil
                      ;; :family "Menlo" ;; or Meslo if unavailable: https://github.com/andreberg/Meslo-Font
                      :family "mononoki" ;; https://madmalik.github.io/mononoki/
                      :box nil :strike-through nil :overline nil :underline nil :slant 'normal :weight 'normal
                      :width 'normal :foundry "nil")

  (eval-after-load 'font-lock
    (progn
      (set-face-attribute 'font-lock-constant-face nil :foreground "#C792EA")
      (set-face-attribute 'font-lock-keyword-face nil :foreground "#2BA3FF" :slant 'italic)
      (set-face-attribute 'font-lock-preprocessor-face nil :inherit 'bold :foreground "#2BA3FF" :slant 'italic :weight 'normal)
      (set-face-attribute 'font-lock-string-face nil :foreground "#C3E88D")
      (set-face-attribute 'font-lock-type-face nil :foreground "#FFCB6B")
      (set-face-attribute 'font-lock-variable-name-face nil :foreground "#FF5370")))

  (eval-after-load 'eshell
    (progn
      (require 'em-prompt)
      (set-face-attribute 'eshell-prompt nil :foreground "#eeffff")))

  (eval-after-load 'faces
    (progn
      ;; Hardcode region theme color.
      (set-face-attribute 'region nil :background "#3f464c" :foreground "#eeeeec" :underline nil)
      (set-face-attribute 'mode-line nil :background "#191919" :box nil)))

  (eval-after-load 'org
    (progn
      (require 'org-faces)
      (set-face-attribute 'org-level-1 nil :background nil :box nil)
      (set-face-attribute 'org-level-2 nil :background nil :box nil)
      (set-face-attribute 'org-level-3 nil :background nil :box nil)
      (set-face-attribute 'org-level-4 nil :background nil :box nil)
      (set-face-attribute 'org-level-5 nil :background nil :box nil)
      (set-face-attribute 'org-level-6 nil :background nil :box nil)
      (set-face-attribute 'org-level-7 nil :background nil :box nil)
      (set-face-attribute 'org-level-8 nil :background nil :box nil)
      (set-face-attribute 'org-block-begin-line nil :background nil :box nil)
      (set-face-attribute 'org-block-end-line nil :background nil :box nil)
      (set-face-attribute 'org-block nil :background nil :box nil)))

  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line nil :box nil)
    (set-face-attribute 'mode-line-inactive nil :box nil)
    (set-face-attribute 'mode-line-inactive nil :background "#212121" :foreground "#5B6268")))

;; No color for fringe, blends with the rest of the window.
(eval-after-load 'fringe
  (progn
    (set-face-attribute 'fringe nil
                        :foreground (face-foreground 'default)
                        :background (face-background 'default))))

(use-package moody
  :ensure t
  :config
  (setq x-underline-at-descent-line t)

  (setq-default mode-line-format
                '(" "
                  mode-line-front-space
                  mode-line-client
                  mode-line-frame-identification
                  mode-line-buffer-identification " " mode-line-position
                  (vc-mode vc-mode)
                  (multiple-cursors-mode mc/mode-line)
                  " " mode-line-modes
                  mode-line-end-spaces))

  (use-package minions
    :ensure t
    :config
    (minions-mode +1))

  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

;; Use y/n instead of yes/no confirms.
;; From http://pages.sachachua.com/.emacs.d/Sacha.html#sec-1-4-8
(fset 'yes-or-no-p 'y-or-n-p)

(use-package fullframe
  :ensure t
  :commands fullframe)

(use-package menu-bar
  ;; No need to confirm killing buffers.
  :bind ("C-x k" . kill-this-buffer))

(use-package face-remap
  :bind(("C-+" . text-scale-increase)
        ("C--" . text-scale-decrease)))

(use-package nyan-mode :ensure t
  :if (display-graphic-p)
  :config
  (nyan-mode +1))
