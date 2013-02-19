;;----------------------------------------------------------------------------
;; An auto-complete source using word-help completions
;;
;; Author: Yang Xiaofeng <n.akr.akiiya at gmail dot codelete-regionm>
;;
;; Usage:
;;   (require 'ac-word-help)
;;   (add-hook 'word-help-load-hook 'set-up-word-help-ac)
;;   (eval-after-load "auto-complete"
;;     '(add-to-list 'ac-modes 'word-help-mode))
;;----------------------------------------------------------------------------

(eval-when-compile
  (require 'cl))

(require 'word-help)

(defun init-ac-word-help-indexing ()
  "initialize system-level word-help indexing"
  (interactive)
  (while (not word-help-help-mode)
    (word-help-find-help-file))
  (word-help-get-complete word-help-help-mode))

(defun ac-source-word-help-simple-candidates ()
  "Return a possibly-empty list of completions for the symbol at point."
  ;; (if (word-help-connected-p)
  ;;       (car (word-help-simple-completions (substring-no-properties ac-prefix)))))
  (interactive "*")
  (while (not word-help-help-mode)
    (word-help-find-help-file))
  (let* ((cmpl-idx (word-help-get-complete word-help-help-mode))
         (cmpl-this nil) (completion nil)
         (close nil) (words nil) (completed nil)
         (all-match (word-help-guess-all
                     cmpl-idx (word-help-ignore-case word-help-help-mode) t))
         (completion-ignore-case (word-help-ignore-case
                                  word-help-help-mode))
         (this-match nil))

    ;; Loop over and try to find a match wor
    (while (and all-match (not completed))
      (setq this-match (car all-match)
            all-match (cdr all-match)
            cmpl-this (car cmpl-idx)
            cmpl-idx (cdr cmpl-idx))
      (cond
       ;; Ignore non-matches
       ((null this-match))
       ;; Use backend?
       ((symbolp this-match)
        (setq completed
              (if (interactive-p)
                  (call-interactively this-match)
                (eval (list this-match)))))
       (this-match
        (setq close (nth 3 cmpl-this)
              words (nth 4 cmpl-this)
              ;; Find the maximum completion for this word
              completion (try-completion this-match words))

        (cond
         ;; ;; Was the match exact
         ;; ((eq completion t)
         ;;  (and close
         ;;       (not (looking-at (regexp-quote close)))
         ;;       ;; (insert close) 
         ;;       )
         ;;  (setq completed t))

         ;; ;; Silently ignore non-matches
         ;; ((not completion))

         ;; ;; May we complete more unambiguously
         ;; ((not (string-equal completion this-match))
         ;;  ;; (delete-region (- (point) (length this-match)) ; delete the origin words
         ;;  ;;                (point))
         ;;  ;; (insert completion) 
         ;;  ;; Was the completion full?
         ;;  (if (eq t (try-completion completion words))
         ;;      (progn
         ;;        (and close
         ;;             (not (looking-at (regexp-quote close)))
         ;;             ;; (insert close)
         ;;             )))
         ;;  (setq completed t))

         ;; ;; Just part-match found. Show completion list
         (t
          (message "Making completion list...")
          (let ((list (all-completions this-match words nil)))
            (setq completed list)
            ;; (with-output-to-temp-buffer "*Completions*"
            ;;   (display-completion-list list))
            (message "Making completion list...done")))))))
    (if (not completed) (message "No match."))
    completed))

(defvar ac-word-help-current-doc nil "Holds word-help docstring for current symbol")
(defun ac-word-help-documentation (symbol-name)
  ;; (let ((symbol-name (substring-no-properties symbol-name)))
  ;;   (word-help-eval `(swank:documentation-symbol ,symbol-name)))
  )

(defun ac-word-help-init ()
  (setq ac-word-help-current-doc nil))

(defface ac-word-help-menu-face
  '((t (:inherit 'ac-candidate-face)))
  "Face for word-help candidate menu."
  :group 'auto-complete)

(defface ac-word-help-selection-face
  '((t (:inherit 'ac-selection-face)))
  "Face for the word-help selected candidate."
  :group 'auto-complete)

(defvar ac-source-word-help-simple
  '((init . ac-word-help-init)
    (candidates . ac-source-word-help-simple-candidates)
    (candidate-face . ac-word-help-menu-face)
    (selection-face . ac-word-help-selection-face)
    (prefix . slime-symbol-start-pos)   ; TODO fix it !
    (symbol . "l")
    (document . ac-word-help-documentation))
  "Source for word-help completion")


(defun set-up-word-help-ac (&optional fuzzy)
  "Add an word-help completion source to the
front of `ac-sources' for the current buffer."
  (interactive)
  (setq ac-sources (add-to-list 'ac-sources
                                'ac-source-word-help-simple)))

(provide 'ac-word-help)
