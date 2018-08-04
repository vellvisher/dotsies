(when (memq window-system '(mac ns))
  ;; No icon on window.
  (setq ns-use-proxy-icon nil)

  ;; Transparent titlebar on macOS (prettier).
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))


(when (string-equal system-type "darwin")
  ;; Want menu bar on macOS.
  (use-package menu-bar
    :config
    (menu-bar-mode 1))

  ;; Fixes mode line separator issues on macOS.
  (setq ns-use-srgb-colorspace nil)

  ;; Make ⌘ meta modifier.
  (setq mac-command-modifier 'meta)

  ;; Add some exec paths I have on macOS.
  (setq exec-path (append exec-path '("~/homebrew/bin"
                                      "~/homebrew/Cellar/llvm/HEAD/bin"
                                      "/usr/local/bin"))))

;; macOS color picker.
(use-package color-picker
  :commands color-picker)

;; Convert binary plists to xml using host utilities.
(use-package ar-osx
  :commands ar/osx-convert-plist-to-xml)
