;;; company-projectile-cd.el --- Company projectile directory completion.

;;; Commentary:
;; Company projectile directory completion.


;;; Code:

(require 'cl-lib)
(require 'company)
(require 'dash)
(require 'f)
(require 's)
(require 'projectile)

(defun company-projectile-cd (command &optional arg &rest ignored)
  "Company shell completion for any projectile path."
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-projectile-cd))
    (prefix
     (company-projectile-cd--prefix))
    (candidates
     (company-projectile-cd--candidates
      (company-projectile-cd--prefix)))
    (post-completion
     (company-projectile-cd--expand-inserted-path arg))))

(defun company-projectile-cd--prefix ()
  (-some (lambda (p)
           (let ((prefix (company-grab-symbol-cons p (length p))))
             (when (consp prefix)
               prefix)))
         '("cd " "ls ")))

(defun company-projectile-cd--candidates (input)
  "Return candidates for given INPUT."
  (when (consp input)
    (let ((search-term (substring-no-properties
                        (car input) 0 (length (car input))))
          (prefix-found (cdr input)))
      (when prefix-found
        (if (projectile-project-p)
            (company-projectile-cd--projectile search-term)
          (company-projectile-cd--find-fallback search-term))))))

(defun company-projectile-cd--projectile (search-term)
  (-filter (lambda (path)
             (string-match-p (regexp-quote
                              search-term)
                             path))
           (-snoc
            (projectile-current-project-dirs)
            ;; Throw project root in there also.
            (projectile-project-root))))

(defun company-projectile-cd--find-fallback (search-term)
  (ignore-errors
    (-map (lambda (path)
            (string-remove-prefix "./" path))
          (apply #'process-lines
                 (list "find" "."
                       "(" "-type" "d" "-or" "-type" "l" ")"
                       "-maxdepth" "2"
                       "-not" "-path" "."
                       "-not" "-path" "./.*"
                       "-iname"
                       (format "\*%s\*" search-term))))))

(defun company-projectile-cd--expand-inserted-path (path)
  "Replace relative PATH insertion with its absolute equivalent if needed."
  (delete-region (point) (- (point) (length path)))
  (insert (if (s-contains-p " " path)
              ;; Quote if spaces found.
              (format "\"%s\"" path)
            path)))

(provide 'company-projectile-cd)

;;; company-projectile-cd.el ends here
