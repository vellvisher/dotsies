;;; ar-buffer.el --- Query and manipulate buffer text.

;;; Commentary:
;; Buffer text helpers.

;;; Code:

(defun ar/buffer-kill-others ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              ;; Disables "required at runtime" warning for cl package.
              (with-no-warnings
                (remove-if-not 'buffer-file-name (buffer-list))))))

(defun ar/buffer-switch-to-file (file-path)
  "Switch to buffer with FILE-PATH."
  (switch-to-buffer (find-file-noselect (expand-file-name file-path))))

;; Based on http://emacswiki.org/emacs/DuplicateLines
(defun ar/buffer-remove-region-dups (beg end)
  "Remove dups in region's adjacent lines or pass BEG END."
  (interactive "*r")
  (save-excursion
    (goto-char beg)
    (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
      (replace-match "\\1"))))

(defun ar/buffer-select-current-block ()
  "Select the current block of text between blank lines.
URL `http://ergoemacs.org/emacs/modernization_mark-word.html'
Version 2015-02-07."
  (interactive)
  (let (p1 p2)
    (if (re-search-backward "\n[ \t]*\n" nil "move")
        (progn (re-search-forward "\n[ \t]*\n")
               (setq p1 (point)))
      (setq p1 (point)))
    (if (re-search-forward "\n[ \t]*\n" nil "move")
        (progn (re-search-backward "\n[ \t]*\n")
               (setq p2 (point)))
      (setq p2 (point)))
    (set-mark p1)))

(defun ar/buffer-sort-lines-ignore-case ()
  "Sort region (case-insensitive)."
  (interactive)
  (let ((sort-fold-case t))
    (call-interactively #'sort-lines)))

(defun ar/buffer-sort-current-block ()
  "Select and sort current block."
  (interactive)
  ;; Why is save-excursion not working?
  (let ((saved-point (point)))
    (ar/buffer-select-current-block)
    (ar/buffer-sort-lines-ignore-case)
    (goto-char saved-point)))

(defun ar/buffer-first-match-begining (re)
  "Return the first match beginning position for RE."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward re nil t)
    (match-beginning 0)))

(defun ar/buffer-last-match-end (re)
  "Return the last match ending position for RE."
  (save-excursion
    (goto-char (point-min))
    (let ((end-pos nil))
      (while (re-search-forward re nil t)
        (setq end-pos (match-end 0)))
      end-pos)))

(defun ar/buffer-groups-of (re)
  "Return a list of any RE consecutive match separated by two or more newlines.

\(ar/buffer-groups-of \"#include\") =>

\(\"#include \"one.h\"\\n#include \"two.h\"\"
 \"#include \"three.h\"\\n#include \"four.h\"\"
 \"#include \"six.h\"\"
 \"#include \"seven.h\"\")

For:

#include \"one.h\"
#include \"two.h\"

#include \"three.h\"
#include \"four.h\"


#include \"six.h\"

#include \"seven.h\""
  (let ((beg-pos (ar/buffer-first-match-begining re))
        (end-pos (ar/buffer-last-match-end re))
        (substring nil))
    (when (and beg-pos end-pos)
      (setq substring (buffer-substring-no-properties beg-pos
                                                      end-pos))
      ;; Repeat match 2 or more consecutive new lines.
      (split-string substring "\\(\n\\)\\{2,\\}"))))

(provide 'ar-buffer)

;;; ar-buffer.el ends here
