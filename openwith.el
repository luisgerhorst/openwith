;;; openwith.el --- Open files with external programs

;; Copyright (C) 2007  Markus Triska
;; Copyright (C) 2020  Luis Gerhorst

;; Author: Markus Triska <markus.triska@gmx.at>
;; Keywords: files, processes
;; URL: https://github.com/luisgerhorst/openwith
;; Version: 20120531

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This lets you associate external applications with files so that
;; you can open them via C-x C-f, with RET in dired, etc.

;; Copy openwith.el to your load-path and add to your .emacs:

;;    (require 'openwith)
;;    (openwith-mode t)

;; To customize associations etc., use:

;;    M-x customize-group RET openwith RET

;;; Code:

(defgroup openwith nil
  "Associate external applications with file name patterns."
  :group 'files
  :group 'processes)

(defvar openwith-desktop-environment-open
  (cond ((string-equal system-type "darwin") "open")
        ((string-equal system-type "gnu/linux") "xdg-open")))

(defcustom openwith-associations
  (list (list "\\.pdf\\'" openwith-desktop-environment-open '(file))
        (list "\\.mp3\\'" openwith-desktop-environment-open '(file))
        (list "\\.\\(?:mpe?g\\|avi\\|wmv\\)\\'" openwith-desktop-environment-open '(file))
        (list "\\.\\(?:jp?g\\|png\\)\\'" openwith-desktop-environment-open '(file)))
  "Associations of file patterns to external programs.
File pattern is a regular expression describing the files to
associate with a program. The program arguments are a list of
strings and symbols and are passed to the program on invocation,
where the symbol 'file' is replaced by the file to be opened."
  :group 'openwith
  :type '(repeat (list (regexp :tag "Files")
                       (string :tag "Program")
                       (sexp :tag "Parameters"))))

(defcustom openwith-confirm-invocation nil
  "Ask for confirmation before invoking external programs."
  :group 'openwith
  :type 'boolean)

(defun openwith--make-extension-regexp (strings)
  "Make a regexp that matches a string that starts with a '.',
has any of the supplied STRINGS, and is at the end of the
string."
  (concat "\\." (regexp-opt strings) "$"))

(defun openwith--open-unix (command arglist)
  "Run external command COMMAND, in such a way that it is
  disowned from the parent Emacs process.  If Emacs dies, the
  process spawned here lives on.  ARGLIST is a list of strings,
  each an argument to COMMAND."
  (let ((process-connection-type nil))
    (set-process-query-on-exit-flag
     (apply #'start-process (append (list "openwith-process" nil "nohup" command) arglist)) nil)))

(defun openwith--open-windows (file)
  "Run external command COMMAND, in such a way that it is
  disowned from the parent Emacs process.  If Emacs dies, the
  process spawned here lives on.  ARGLIST is a list of strings,
  each an argument to COMMAND."
  (w32-shell-execute "open" file))

(defvar openwith--inhibit-open nil
  "When set, `openwith--open' does nothing.

Used to force opening files in Emacs when a prefix argument (C-u) is
passed to `openwith--find-file' (which replaces
`dired-find-file').")

(defun openwith--open (file)
  "Return t if file was opened with an external program."
  (unless openwith--inhibit-open
    (let ((assocs openwith-associations)
          oa)
      (catch 'while-assocs-break
        ;; do not use `dolist' here, since some packages (like cl)
        ;; temporarily unbind it
        (while assocs
          (setq oa (car assocs)
                assocs (cdr assocs))
          (when (save-match-data (string-match (car oa) file))
            (let ((params (mapcar (lambda (x) (if (eq x 'file) file x))
                                  (nth 2 oa))))
              (when (or (not openwith-confirm-invocation)
                        (y-or-n-p (format "%s %s? " (cadr oa)
                                          (mapconcat #'identity params " "))))
	            (if (eq system-type 'windows-nt)
		            (openwith--open-windows file)
		          (openwith--open-unix (cadr oa) params))
                (when (featurep 'recentf)
                  (recentf-add-file file))
                ;; inhibit further actions
                (throw 'while-assocs-break t)))))))))

(defun openwith--file-handler (operation &rest args)
  "Open file with external program, if an association is configured."
  (when (and openwith-mode (not (buffer-modified-p)) (zerop (buffer-size)))
    (let ((file (car args)))
      (when (openwith--open file)
        (kill-buffer nil)
        ;; inhibit further actions
        (error "Opened %s in external program"
               (file-name-nondirectory file)))))
  ;; when no association was found, relay the operation to other handlers
  (let ((inhibit-file-name-handlers
         (cons 'openwith--file-handler
               (and (eq inhibit-file-name-operation operation)
                    inhibit-file-name-handlers)))
        (inhibit-file-name-operation operation))
    (apply operation args)))

;;;###autoload
(defun openwith--find-file (&optional prefix-arg)
  (interactive "P")
  (unless (let ((openwith--inhibit-open prefix-arg))
            (openwith--open (ignore-errors (dired-get-file-for-visit))))
    (let ((openwith--inhibit-open t))
      (dired-find-file))))

;;;###autoload
(define-minor-mode openwith-mode
  "Automatically open files with external programs."
  :lighter ""
  :global t
  (if openwith-mode
      (progn
        ;; register `openwith--file-handler' for all files
        (put 'openwith--file-handler 'safe-magic t)
        (put 'openwith--file-handler 'operations '(insert-file-contents))
        (add-to-list 'file-name-handler-alist '("" . openwith--file-handler))

        ;; Directly hook into dired to catch prefix argument.
        (require 'dired)
        (define-key dired-mode-map [remap dired-find-file] #'openwith--find-file))
    (setq file-name-handler-alist
          (delete '("" . openwith--file-handler) file-name-handler-alist))
    (when (featurep 'dired)
      (define-key dired-mode-map [remap dired-find-file] nil))))

(provide 'openwith)

;;; openwith.el ends here
