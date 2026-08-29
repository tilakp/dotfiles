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
(setq-default line-spacing 0.15)
(set-face-attribute 'default nil :height 140 :weight 'light :family "Roboto Mono")
(set-face-attribute 'bold nil :weight 'regular)
(set-face-attribute 'bold-italic nil :weight 'regular)

;; --- Frame / window layout & behavior ------------------------------
(setq default-frame-alist
      '((height . 44) (width . 81) (left-fringe . 0) (right-fringe . 0)
        (internal-border-width . 32) (vertical-scroll-bars . nil)
        (bottom-divider-width . 0) (right-divider-width . 0)
        (undecorated-round . t)))

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
(defun nano-install-theme ()
  "Install light theme"

  (let ((bg "#ffffff")
        (fg "#000000"))
  
    ;; Main faces
    (nano-set-face 'nano-default fg bg)
    (nano-set-face 'nano-highlight fg "#f4f4f4")
    (nano-set-face 'nano-subtle "#505050" nil)
    (nano-set-face 'nano-faded "#a0a0a0" nil)
    (nano-set-face 'nano-salient "#4078f2" nil)
    (nano-set-face 'nano-popout "#9558b2" nil)
    (nano-set-face 'nano-strong "#000000" nil 'bold)
    (nano-set-face 'nano-critical "#ff0000" nil)
    
    ;; Mode and header lines
    (set-face-attribute 'header-line nil
                      :background 'unspecified
                      :underline nil
                      :box '(:line-width 1
                             :color "#f4f4f4"
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
(nano-install-theme)

(provide 'nano-theme)
