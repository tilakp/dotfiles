;;; nano-agenda.el -*- lexical-binding: t -*-

;; ---------------------------------------------------------------------
;; GNU Emacs / N A N O - Emacs made simple
;; Copyright (C) 2020 - N A N O developers
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
;; An experimental interactive nano-agenda that displays side by side a
;; mini calendar on the left and timestamped org entries on the right.
;; ---------------------------------------------------------------------

(require 'ts)
(require 'org)
(require 'org-agenda)
(require 'calendar)
(require 'holidays)

;; --- Faces ----------------------------------------------------------
(defgroup nano-agenda-faces nil
  "Nano-Agenda faces")

(defface nano-agenda-face-default
  '((t :inherit 'default ))
  "Default face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-selected
  '((t (:foreground "#ffffff"
       :background "#000000")))
  "Today face when not selected."
  :group 'nano-agenda-faces)

(defface nano-agenda-face-selected-today
  '((t (:foreground "#ffffff"
       :background "#0050a0")))
  "Today face when selected."
  :group 'nano-agenda-faces)

(defface nano-agenda-face-weekend
  '((t (:foreground "#909090")))
  "Weekend face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-holidays
  '((t (:foreground "#909090")))
  "Holidays face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-outday
  '((t (:foreground "#a0a0a0")))
  "Out day face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-today
  '((t (:foreground "#000000"
       :background "#d0d0d0")))
  "Today face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-month-name
  '((t (:inherit bold)))
  "Month name face (on first line)"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-mouse
  '((t (:inherit highlight)))
  "Mouse highlight face"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-button
  '((t (:foreground "#909090")))
  "Header button (left and right)"
  :group 'nano-agenda-faces)

(defface nano-agenda-face-day-name
  '((t (:inherit bold)))
  "Day name face"
  :group 'nano-agenda-faces)

(defface nano-face-salient
  '((t (:foreground "#000000" :weight bold)))
  "Salient face for important information"
  :group 'nano-agenda-faces)

;; --- Global variable ------------------------------------------------
(setq nano-agenda-selected (ts-now))

;; --- Useful functions -----------------------------------------------
(defun center-string (string size)
  (let* ((lpad (max 0 (/ (- size (length string)) 2)))
         (rpad (max 0 (- size (length string) lpad))))
    (concat (make-string lpad ?\ ) string (make-string rpad ?\ ))))

;; --- Nano-Agenda minor mode -----------------------------------------
(defvar nano-agenda-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<left>") #'nano-agenda-backward-day)
    (define-key map (kbd "<right>") #'nano-agenda-forward-day)
    (define-key map (kbd "<up>") #'nano-agenda-backward-week)
    (define-key map (kbd "<down>") #'nano-agenda-forward-week)
    (define-key map (kbd "<S-left>") #'nano-agenda-backward-month)
    (define-key map (kbd "<S-right>") #'nano-agenda-forward-month)
    (define-key map (kbd "<S-up>") #'nano-agenda-backward-year)
    (define-key map (kbd "<S-down>") #'nano-agenda-forward-year)
    (define-key map (kbd ".") #'nano-agenda-select-today)
    (define-key map (kbd "t") #'nano-agenda-select-today)
    (define-key map (kbd "q") #'nano-agenda-close)
    (define-key map (kbd "<return>") #'nano-agenda-close)
    (define-key map (kbd "<escape>") #'nano-agenda-cancel)
    map)
  "Keymap for `nano-agenda-mode'.")

(define-minor-mode nano-agenda-mode
  "Minor mode for nano-agenda."
  :init nil
  :lighter "Calendar"
  :keymap nano-agenda-mode-map

  (when nano-agenda-mode
    (setq buffer-read-only t)
    (setq cursor-type nil)))

(defun nano-agenda-backward-day ()
  (interactive)
  (setq nano-agenda-selected (ts-dec 'day 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-forward-day ()
  (interactive)
  (setq nano-agenda-selected (ts-inc 'day 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-forward-week ()
  (interactive)
  (setq nano-agenda-selected (ts-inc 'day 7 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-backward-week ()
  (interactive)
  (setq nano-agenda-selected (ts-dec 'day 7 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-forward-month ()
  (interactive)
  (setq nano-agenda-selected (ts-inc 'month 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-backward-month ()
  (interactive)
  (setq nano-agenda-selected (ts-dec 'month 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-forward-year ()
  (interactive)
  (setq nano-agenda-selected (ts-inc 'year 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-backward-year ()
  (interactive)
  (setq nano-agenda-selected (ts-dec 'year 1 nano-agenda-selected))
  (nano-agenda))

(defun nano-agenda-select-today ()
  (interactive)
  (setq nano-agenda-selected (ts-now))
  (nano-agenda))

(defun nano-agenda-close ()
  (interactive)
  (kill-buffer "*nano-agenda*"))

(defun nano-agenda-select ()
  (interactive)
  (kill-buffer "*nano-agenda*"))

(defun nano-agenda-cancel ()
  (interactive)
  (kill-buffer "*nano-agenda*"))

;; --- Display --------------------------------------------------------

(defun nano-agenda-header (selected)
  "Create the header for the nano-agenda with the month and year."
  (let ((map-left (make-sparse-keymap))
        (map-right (make-sparse-keymap)))
    
    (define-key map-left (kbd "<down-mouse-1>") #'nano-agenda-backward-month)
    (define-key map-right (kbd "<down-mouse-1>") #'nano-agenda-forward-month)
    
    (concat
     (propertize "<" 'face 'nano-agenda-face-button
                 'mouse-face 'nano-agenda-face-mouse
                 'help-echo "Previous month"
                 'keymap map-left)
     " "
     (propertize (center-string (format "%s %d" (ts-month-name selected)
                                        (ts-year selected)) 16)
                 'face 'nano-agenda-face-month-name)
     " "
     (propertize ">" 'face 'nano-agenda-face-button
                 'mouse-face 'nano-agenda-face-mouse
                 'help-echo "Next month"
                 'keymap map-right)
     " ")))

(defun nano-agenda-header-names ()
  "Create the header with day names."
  (propertize "Mo Tu We Th Fr Sa Su "
              'face 'nano-agenda-face-day-name))

(defun nano-agenda-body-days (selected)
  "Create the calendar body with days."
  (let* ((today  (ts-now))
         (day    (ts-day   selected))
         (month  (ts-month selected))
         (year   (ts-year  selected))
         (first-day (ts-apply :day 1 :month month :year year selected))
         (dow (mod (- (ts-dow first-day) 1) 7))
         (start (ts-dec 'day dow first-day))
         (map (make-sparse-keymap))
         (result ""))

    (dotimes (row 6)
      (dotimes (col 7)
        (let* ((day-num (+ (* row 7) col))
               (date (ts-inc 'day day-num start))
               (is-today (and (= (ts-year date) (ts-year today))
                             (= (ts-doy date) (ts-doy today))))
               (is-selected (and (= (ts-year date) (ts-year selected))
                                (= (ts-doy date) (ts-doy selected))))
               (is-selected-today (and is-selected is-today))
               (is-outday (not (= (ts-month date) month)))
               (is-holidays (calendar-check-holidays (list
                                                     (ts-month date)
                                                     (ts-day date)
                                                     (ts-year date))))
               (is-weekend (or (= (ts-dow date) 0) (= (ts-dow date) 6)))
               (face (cond (is-selected-today 'nano-agenda-face-selected-today)
                          (is-selected      'nano-agenda-face-selected)
                          (is-today         'nano-agenda-face-today)
                          (is-outday        'nano-agenda-face-outday)
                          (is-weekend       'nano-agenda-face-weekend)
                          (is-holidays      'nano-agenda-face-holidays)
                          (t                'nano-agenda-face-default))))
          
          (setq result (concat result
                              (propertize (format "%2d " (ts-day date))
                                         'face face
                                         'mouse-face (cond (is-selected-today 'nano-agenda-face-selected-today)
                                                          (is-selected      'nano-agenda-face-selected)
                                                          (t               'nano-agenda-face-mouse))
                                         'help-echo (format "%s%s" (ts-format "%A %-e %B %Y" date)
                                                           (if is-holidays (format " (%s)" (nth 0 is-holidays)) ""))
                                         'keymap map)))))
      (setq result (concat result "\n")))
    result))

(defun nano-agenda-get-entries (date)
  "Get org agenda entries for DATE, pulled from `org-agenda-files'.
Calls the `org-agenda-files' function rather than reading the variable
directly, since the variable's value can be a bare directory (Doom's
default before `org-focus-home'/`org-focus-work' narrows it) and only
the function expands that into actual .org files."
  (let ((day (calendar-gregorian-from-absolute
              (time-to-days (ts-unix date)))))
    (apply #'append
           (mapcar (lambda (file) (org-agenda-get-day-entries file day))
                   (org-agenda-files)))))

(defun nano-agenda ()
  "Show a nano agenda view with calendar and org entries."
  (interactive)
  
  (let ((buffer (get-buffer-create "*nano-agenda*"))
        (inhibit-read-only t)
        (entries (nano-agenda-get-entries nano-agenda-selected)))
    
    (with-current-buffer buffer
      (erase-buffer)
      
      ;; Insert header
      (insert (nano-agenda-header nano-agenda-selected))
      (insert "\n")
      
      ;; Insert day names
      (insert (nano-agenda-header-names))
      (insert "\n")
      
      ;; Insert calendar days
      (insert (nano-agenda-body-days nano-agenda-selected))
      (insert "\n")
      
      ;; Insert org agenda entries
      (insert "Agenda:\n")
      (let ((num 0))
        (while (< num (min 5 (length entries)))
          (let* ((entry (nth num entries))
                 (text (substring-no-properties (format "%s" entry))))
            (insert (propertize
                     (truncate-string-to-width
                      (if (and (boundp 'org-link-bracket-re)
                               (string-match org-link-bracket-re text))
                          (replace-match "[…]" nil nil text) text) 
                      46 nil nil "…")
                     'face 'nano-face-salient))
            (insert "\n\n"))  ; Add double spacing between entries
          (setq num (1+ num)))
        
        (when (> (length entries) 5)
          (insert (propertize (format "  + %s non-displayed event(s)" (- (length entries) 5))
                             'face 'nano-agenda-face-holidays))
          (insert "\n")))
      
      ;; Go to beginning of buffer
      (goto-char (point-min))
      
      ;; Enable nano-agenda-mode
      (nano-agenda-mode 1))
    
    ;; Display buffer
    (switch-to-buffer buffer)
    
    ;; Show date in minibuffer
    (let ((message-log-max nil)
          (is-holidays (calendar-check-holidays (list
                                               (ts-month nano-agenda-selected)
                                               (ts-day nano-agenda-selected)
                                               (ts-year nano-agenda-selected)))))
      (message "%s%s" (ts-format "%A %-e %B %Y" nano-agenda-selected)
               (if is-holidays (format " (%s)" (nth 0 is-holidays)) "")))))

;;
(provide 'nano-agenda)
