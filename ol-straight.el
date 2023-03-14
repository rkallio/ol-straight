;;; ol-straight.el --- Create links to package homepage -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Roni Kallio
;; Author: Roni Kallio <roni.jj.kallio@gmail.com>
;; Keywords: outlines, hypermedia, calendar, wp
;; URL: https://github.com/rkallio/ol-straight
;; Version: 1
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Inside org mode buffers, create straight -type links with
;; autocompletion using `org-insert-link'.  Open the linked package's
;; repository URL with `org-open-at-point'.
;;
;; When exporting, links are converted into HTTPS type links.
;; Currently supported org-export back ends are html, latex, texino,
;; ascii, and md.
;;
;;; Code:

(require 'org-macs)
(org-assert-version)

(require 'ol)
(require 'straight)

(org-link-set-parameters "straight"
                         :export   #'ol-straight-export
                         :follow   #'ol-straight-follow
                         :complete #'ol-straight-complete)

(defun ol-straight-export (path description backend)
  (let ((recipe (intern path)))
    (straight--with-plist (straight--convert-recipe recipe) (host repo)
      (when (eq host 'sourcehut)
        (setq repo (concat "~" repo)))
      (let ((url (if-let ((domain (car (alist-get host straight-hosts))))
                     (format "https://%s/%s" domain repo)
                   (format "%s" repo)))
            (description (or description path)))
        (cond
         ((eq backend 'html)
          (format "<a target=\"_blank\" href=\"%s\">%s</a>"
                  url description))
         ((eq backend 'latex)
          (format "\\href{%s}{%s}" url description))
         ((eq backend 'texinfo)
          (format "@uref{%s,%s}" url description))
         ((eq backend 'ascii)
          (format "%s (%s)" description url))
         ((eq backend 'md)
          (format "[%s](%s)" description url))
         (t url))))))

(defun ol-straight-follow (path prefix)
  (straight-visit-package-website (intern path)))

(defun ol-straight-complete ()
  (concat
   "straight:"
   (completing-read "Package: " (straight-recipes-list))))

(provide 'ol-straight)
;;; ol-straight.el ends here
