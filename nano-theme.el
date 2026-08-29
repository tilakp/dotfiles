;;; nano-theme.el -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------
;; GNU Emacs / N A N O - Minimal Theme
;; Copyright (c) 2023-2025 Nicolas P. Rougier
;; Adapted for Doom Emacs
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
;; along with this program. If not, see <http://www.gnu.org/licenses/>.
;;
;; ---------------------------------------------------------------------
;; A minimal NANO theme implementation for Doom Emacs
;; ---------------------------------------------------------------------

;; --- Typography settings --------------------------------------------
;; NOTE The default face family/size/weight lives in config.el (`doom-font'),
;; which Doom applies after this file loads. Setting it here as well was dead
;; code that Doom overwrote every startup.
(setq-default line-spacing 0.15)

;; --- Frame / window layout & behavior ------------------------------
(dolist (param '((height . 44) (width . 81) (left-fringe . 0) (right-fringe . 0)
                 (internal-border-width . 32) (vertical-scroll-bars . nil)
                 (bottom-divider-width . 0) (right-divider-width . 0)
                 (undecorated-round . t)))
  (setf (alist-get (car param) default-frame-alist) (cdr param)))

;; --- Minimal NANO theme faces --------------------------------------
(defface nano-default
  '((t)) "Default face")

(defface nano-highlight
  '((t)) "Highlight face")

(defface nano-subtle
  '((t)) "Subtle face")

(defface nano-faded
  '((t)) "Faded face")

(defface nano-salient
  '((t)) "Salient face")

(defface nano-popout
  '((t)) "Popout face")

(defface nano-strong
  '((t)) "Strong face")

(defface nano-critical
  '((t)) "Critical face")

(defface nano-default-i
  '((t)) "Default face (inverted)")

(defface nano-highlight-i
  '((t)) "Highlight face (inverted)")

(defface nano-subtle-i
  '((t)) "Subtle face (inverted)")

(defface nano-faded-i
  '((t)) "Faded face (inverted)")

(defface nano-salient-i
  '((t)) "Salient face (inverted)")

(defface nano-popout-i
  '((t)) "Popout face (inverted)")

(defface nano-strong-i
  '((t)) "Strong face (inverted)")

(defface nano-critical-i
  '((t)) "Critical face (inverted)")

;; --- Face setting function -----------------------------------------
(defun nano-set-face (name &optional foreground background weight)
  "Set NAME and NAME-i faces with given FOREGROUND, BACKGROUND and WEIGHT"
  
  (apply #'set-face-attribute `(,name nil
         ,@(when foreground `(:foreground ,foreground))
         ,@(when background `(:background ,background))
         ,@(when weight     `(:weight ,weight))))

  (apply #'set-face-attribute `(,(intern (concat (symbol-name name) "-i")) nil
         ,@(when foreground `(:background ,foreground))
         ,@(when background `(:foreground ,background))
         :weight regular)))

;; --- Face linking function -----------------------------------------
(defun nano-link-face (sources faces &optional attributes)
  "Make FACES to inherit from SOURCES faces and unspecify ATTRIBUTES."
  
  (let ((attributes (or attributes
                        '(:foreground :background :family :weight
                          :height :slant :overline :underline :box))))
    (dolist (face (seq-filter #'facep faces))
      (dolist (attribute attributes)
        (set-face-attribute face nil attribute 'unspecified))
      (set-face-attribute face nil :inherit sources))))

;; --- Theme installation function -----------------------------------
(defvar nano-theme-light
  '((bg . "#ffffff") (fg . "#000000") (highlight . "#f4f4f4")
    (subtle . "#505050") (faded . "#a0a0a0") (salient . "#4078f2")
    (popout . "#9558b2") (strong . "#000000") (critical . "#ff0000"))
  "NANO palette used when a light theme is active.")

(defvar nano-theme-dark
  '((bg . "#2e3440") (fg . "#eceff4") (highlight . "#3b4252")
    (subtle . "#434c5e") (faded . "#677691") (salient . "#81a1c1")
    (popout . "#d08770") (strong . "#eceff4") (critical . "#ebcb8b"))
  "NANO palette used when a dark theme is active.")

(defun nano-theme-dark-p ()
  "Return non-nil when the active theme is a dark one.
Prefer the enabled theme's name, because `background-mode' is unreliable
before a graphical frame exists (for example under `emacs --daemon')."
  (let ((name (symbol-name (or (car custom-enabled-themes) 'unknown))))
    (cond ((string-match-p "dark" name) t)
          ((string-match-p "light" name) nil)
          (t (eq (frame-parameter nil 'background-mode) 'dark)))))

(defun nano-theme-palette ()
  "Return the NANO palette that matches the active theme."
  (if (nano-theme-dark-p) nano-theme-dark nano-theme-light))

(defun nano-install-theme ()
  "Apply the NANO faces on top of the active theme."
  (interactive)

  (let* ((palette (nano-theme-palette))
         (bg (alist-get 'bg palette))
         (fg (alist-get 'fg palette))
         (highlight (alist-get 'highlight palette)))

    ;; Main faces
    (nano-set-face 'nano-default fg bg)
    (nano-set-face 'nano-highlight fg highlight)
    (nano-set-face 'nano-subtle (alist-get 'subtle palette) nil)
    (nano-set-face 'nano-faded (alist-get 'faded palette) nil)
    (nano-set-face 'nano-salient (alist-get 'salient palette) nil)
    (nano-set-face 'nano-popout (alist-get 'popout palette) nil)
    (nano-set-face 'nano-strong (alist-get 'strong palette) nil)
    (nano-set-face 'nano-critical (alist-get 'critical palette) nil)
    
    ;; Mode and header lines
    (set-face-attribute 'header-line nil
                      :background 'unspecified
                      :underline nil
                      :box `(:line-width 1
                             :color ,highlight
                             :style nil)
                      :inherit 'nano-subtle)
    
    (set-face-attribute 'mode-line nil
                      :background 'unspecified
                      :underline nil
                      :box nil
                      :inherit 'nano-subtle)
    
    (set-face-attribute 'mode-line-inactive nil
                      :box nil
                      :inherit 'nano-faded)
    
    ;; Basic faces
    (set-face-attribute 'default nil
                      :foreground (face-foreground 'nano-default)
                      :background (face-background 'nano-default))
    
    (set-face-attribute 'cursor nil
                      :foreground (face-background 'nano-default)
                      :background (face-foreground 'nano-default))
    
    (set-face-attribute 'region nil
                      :foreground 'unspecified
                      :background (face-background 'nano-highlight))
    
    (set-face-attribute 'highlight nil
                      :foreground 'unspecified
                      :background (face-background 'nano-highlight))
    
    (set-face-attribute 'fixed-pitch nil
                      :foreground 'unspecified)
    
    (set-face-attribute 'variable-pitch nil
                      :foreground 'unspecified)
    
    (set-face-attribute 'bold nil
                      :weight 'bold)

    (set-face-attribute 'bold-italic nil
                      :weight 'bold)

    ;; Font lock faces
    (nano-link-face '(nano-default) '(font-lock-builtin-face
                                   font-lock-comment-face
                                   font-lock-doc-face
                                   font-lock-constant-face
                                   font-lock-function-name-face
                                   font-lock-keyword-face
                                   font-lock-string-face
                                   font-lock-type-face
                                   font-lock-variable-name-face
                                   font-lock-warning-face))

    ;; Enhanced font lock faces
    (nano-link-face '(nano-strong)   '(font-lock-function-name-face
                                      font-lock-variable-name-face))
    (nano-link-face '(nano-salient)  '(font-lock-string-face
                                      font-lock-keyword-face))
    (nano-link-face '(nano-faded)    '(font-lock-comment-face
                                      font-lock-doc-face))
    (nano-link-face '(nano-popout)   '(font-lock-warning-face))
    (nano-link-face '(nano-subtle)   '(font-lock-builtin-face
                                      font-lock-constant-face
                                      font-lock-type-face))
    
    ;; Org mode
    (nano-link-face '(nano-salient) '(org-link))
    (nano-link-face '(nano-faded)   '(org-document-info))
    (nano-link-face '(nano-popout)  '(org-level-1))
    (nano-link-face '(nano-strong)  '(org-level-2 org-level-3))))

;; --- Theme initialization -------------------------------------------
;; Run after every `load-theme'/`enable-theme', so the NANO faces survive a
;; theme switch and follow the light/dark palette.
(add-hook 'doom-load-theme-hook #'nano-install-theme)
(nano-install-theme)

(provide 'nano-theme)
