;;; region-bindings.el --- Minor mode for mapping keys while region is active -*- lexical-binding: t -*-
;;
;; Author: Andrey Listopadov
;; Homepage: https://gitlab.com/andreyorst/region-bindings
;; Package-Requires: ((emacs "26.1"))
;; Keywords: tools
;; Prefix: region-bindings
;; Version: 0.0.1
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with region-bindings.el.  If not, see
;; <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; `region-bindings' is a minor mode that kicks in when the mark is
;; activated and the region is visible.  While the mark is active a
;; new `region-bindings-mode-map' is available.  When the mark becomes
;; inactive bindings are also disabled.
;;
;;; Code:

(defun region-bindings-doublequote ()
  "Double-quote active region, escaping strings if needed."
  (interactive)
  (let ((s (buffer-substring-no-properties (point) (mark))))
    (delete-region (point) (mark))
    (insert (format "%S" s))))

(defun region-bindings--mode-enable ()
  "Enable `region-bindings-mode' in the current buffer."
  (add-hook 'activate-mark-hook #'region-bindings-enable nil 'local)
  (add-hook 'deactivate-mark-hook #'region-bindings-disable nil 'local))

(defun region-bindings--mode-disable ()
  "Disable `region-bindings-mode' in the current buffer."
  (remove-hook 'activate-mark-hook #'region-bindings-enable 'local)
  (remove-hook 'deactivate-mark-hook #'region-bindings-disable 'local))

;;;###autoload
(defvar region-bindings-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") 'region-bindings-disable)
    (define-key map (kbd "r") 'replace-string)
    (define-key map (kbd "R") 'replace-regexp)
    (define-key map (kbd "\"") 'region-bindings-doublequote)
    map)
  "Keymap used for `region-bindings-mode'.")

;;;###autoload
(define-minor-mode region-bindings-mode
  "Minor mode for mapping commands while region is active.

 \\<region-bindings-mode-map>"
  :lighter " rbm"
  :group 'convenience
  :keymap region-bindings-mode-map
  (if (and region-bindings-mode
           (not current-prefix-arg))
      (region-bindings--mode-enable)
    (region-bindings--mode-disable)))

;;;###autoload
(defun region-bindings-disable ()
  "Turn off region bindings temporarily while keeping the region active.
Bindings will be enabled next time region is highlighted."
  (interactive)
  (region-bindings-mode -1)
  (region-bindings--mode-enable))

;;;###autoload
(defun region-bindings-enable ()
  "Enable bindings temporarily while keeping the region active."
  (interactive)
  (when (or transient-mark-mode
            (eq #'mouse-set-region this-command))
    (region-bindings-mode 1)))

;;;###autoload
(define-global-minor-mode global-region-bindings-mode
  region-bindings-mode
  region-bindings--mode-enable
  :group 'convenience)

(provide 'region-bindings)
