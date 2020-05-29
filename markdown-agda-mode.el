;;; markdown-agda-mode.el --- Major mode for working with literate markdown agda files
;;; -*- lexical-binding: t

;;; Commentary:

;; A major mode for editing Agda code embedded in markdown files (.lagda.md files.)
;; https://agda.readthedocs.io/en/v2.6.1/tools/literate-programming.html#literate-org

;;; Code:

(require 'polymode)
(require 'agda2-mode)
(require 'markdown-mode)

(defgroup markdown-agda-mode nil
  "markdown-agda-mode customisations"
  :group 'languages)

(defcustom use-agda-input t
  "Whether to use Agda input mode in non-Agda parts of the file."
  :group 'org-agda-mode
  :type 'boolean)

(define-hostmode poly-markdown-agda-hostmode
  :mode 'markdown-mode
  :protect-font-lock t
  :protect-syntax t
  :keep-in-mode 'host)

(define-innermode poly-markdown-agda-innermode
  :mode 'agda2-mode
  :head-matcher "```agda"
  :tail-matcher "```"
  ;; Keep the code block wrappers in markdown mode, so they can be folded, etc.
  :head-mode 'markdown-mode
  :tail-mode 'markdown-mode
  ;; Disable font-lock-mode, which interferes with Agda annotations,
  ;; and undo the change to indent-line-function Polymode makes.
  :init-functions '((lambda (_) (let ((span (pm-innermost-range))
				      (beg (car span))
				      (end (cdr span)))
				  (remove-text-properties beg end '(face nil))))
                    (lambda (_) (setq indent-line-function #'indent-relative))))

(define-polymode markdown-agda-mode
  :hostmode 'poly-markdown-agda-hostmode
  :innermodes '(poly-markdown-agda-innermode)
  (when use-agda-input (set-input-method "Agda")))

(assq-delete-all 'background agda2-highlight-faces)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.lagda.md\\'" . markdown-agda-mode))

(provide 'org-agda-mode)
;;; markdown-agda-mode ends here
