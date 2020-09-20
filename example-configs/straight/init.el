;;; Required:

;; Install straight.el, copied from https://github.com/raxod502/straight.el#getting-started
;;
;; This is required but you only need it once in your whole config. AOT Virtual
;; Auto Fill mode is not yet available via MELPA (i.e. package.el).
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install this mode using straight.el
(straight-use-package
 '(openwith :fork (:host github :repo "luisgerhorst/openwith")))

;;; Activate it automatically in recognized desktop environments.
(require 'openwith)
(when openwith-desktop-environment-open
  (openwith-mode t))
