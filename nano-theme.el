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

;; --- Todo label palettes -------------------------------------------
;; Each entry is (TIER BACKGROUND FOREGROUND). A nil background means the
;; label sits directly on the page with no chip. The tiers descend in
;; emphasis: next > waiting > open > later > done. Every pair clears WCAG
;; AA (4.5:1) for its own text, so no label is harder to read than another.

(defvar nano-labels-light
  '((next    "#1d4ed8" "#ffffff")
    (meeting "#0f766e" "#ffffff")
    (waiting "#f59e0b" "#3d2600")
    (open    "#d5dae3" "#333b47")
    (later   "#eceef2" "#5b6472")
    (done    "#e8eaee" "#616973"))
  "Todo label colours used when a light theme is active.")

(defvar nano-labels-dark
  '((next    "#a9c9ea" "#1b212b")
    (meeting "#8fc7bf" "#16221f")
    (waiting "#d8b878" "#1b212b")
    (open    "#4a5568" "#e5e9f0")
    (later   "#3b4252" "#a7b3c4")
    (done    "#3d4452" "#adbacc"))
  "Todo label colours used when a dark theme is active.")

(defface nano-label-next    '((t)) "Label for actionable tasks.")
(defface nano-label-meeting '((t)) "Label for scheduled meetings.")
(defface nano-label-waiting '((t)) "Label for tasks blocked on someone else.")
(defface nano-label-open    '((t)) "Label for open, unstarted tasks.")
(defface nano-label-later   '((t)) "Label for deferred tasks.")
(defface nano-label-done    '((t)) "Label for closed tasks.")

(defcustom nano-org-metadata-height 0.82
  "Text scale for org metadata: DEADLINE:/SCHEDULED:, drawers and timestamps.
1.0 matches body text. Faces are reapplied on every theme change, because
`load-theme' resets them."
  :type 'number
  :group 'nano)

(defun nano-install-org-metadata ()
  "Shrink org metadata so deadlines and logbook drawers stay out of the way."
  (interactive)
  (dolist (face '(org-special-keyword      ; DEADLINE: SCHEDULED: CLOSED:
                  org-drawer               ; :LOGBOOK: :PROPERTIES: :END:
                  org-property-value
                  org-modern-date-active
                  org-modern-date-inactive
                  org-modern-time-active
                  org-modern-time-inactive))
    (when (facep face)
      (set-face-attribute face nil :height nano-org-metadata-height))))

(defun nano-install-labels ()
  "Apply the todo label palette that matches the active theme."
  (interactive)
  (dolist (spec (if (nano-theme-dark-p) nano-labels-dark nano-labels-light))
    (let ((face (intern (format "nano-label-%s" (nth 0 spec))))
          (background (nth 1 spec))
          (foreground (nth 2 spec)))
      (set-face-attribute face nil
                          :foreground foreground
                          :background (or background 'unspecified)))))

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
    ;; Every heading level gets the same colour. Depth is already carried
    ;; by the org-modern bullets and by indentation, so colour stays
    ;; reserved for todo state. This also rescues org-level-4 and deeper,
    ;; which the theme left at #a0a0a0 (2.5:1 on white).
    (nano-link-face '(nano-strong)  '(org-level-1 org-level-2 org-level-3
                                      org-level-4 org-level-5 org-level-6
                                      org-level-7 org-level-8))))

;; --- Theme initialization -------------------------------------------
;; Run after every `load-theme'/`enable-theme', so the NANO faces survive a
;; theme switch and follow the light/dark palette.
(add-hook 'doom-load-theme-hook #'nano-install-theme)
(add-hook 'doom-load-theme-hook #'nano-install-labels)
(add-hook 'doom-load-theme-hook #'nano-install-org-metadata)
;; org and org-modern both load lazily, after the theme. Until they do, their
;; faces do not exist and `nano-install-org-metadata' silently skips them, so
;; run it again once each is actually available.
(with-eval-after-load 'org (nano-install-org-metadata))
(with-eval-after-load 'org-modern (nano-install-org-metadata))
(nano-install-theme)
(nano-install-labels)
(nano-install-org-metadata)

(provide 'nano-theme)
