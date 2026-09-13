;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; =============================================================================
;; PERSONAL INFORMATION / LOCAL OVERRIDES
;; =============================================================================
;; Name, email, and org file locations are personal, so they live in
;; config.local.el instead -- gitignored, not tracked in this repo. Copy
;; config.local.el.example to config.local.el and fill in your own values.
;; The generic defaults below just let this config load (and find no org
;; files) without it.

(setq user-full-name "Your Name"
      user-mail-address "you@example.com")

(setq org-directory "~/org/"
      org-roam-directory "~/org/roam/")

(defvar org-focus-home-files '("~/org/home.org")
  "Org files considered \"home\" for `org-focus-home'.")
(defvar org-focus-work-files '("~/org/work.org")
  "Org files considered \"work\" for `org-focus-work'.")
(defvar my/maclink-file nil
  "Path to maclink.el's contrib file, if you use github.com/.../maclink.
Leave nil to skip it entirely.")

(load! "config.local" nil t) ;; noerror -- fine if you haven't created it

;; =============================================================================
;; FONT CONFIGURATION
;; =============================================================================

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept.

;; Set fonts: Roboto Mono for everything. No `doom-variable-pitch-font' --
;; this setup is monospace throughout (code, org, modeline), so the
;; `variable-pitch' face it would control is never actually displayed.
;; NOTE `:size' with a float is a point size; an integer is a pixel size.
(setq doom-font (font-spec :family "Roboto Mono" :size 14.0 :weight 'medium)
      doom-big-font (font-spec :family "Roboto Mono" :size 18.0 :weight 'medium))

;; If you want to adjust font size on the fly:
;; Use `C-x C-+` or `SPC z +` to increase
;; Use `C-x C--` or `SPC z -` to decrease
;; Use `C-x C-0` or `SPC z 0` to reset

;; =============================================================================
;; GENERAL EDITOR SETTINGS
;; =============================================================================

;; Display settings
(display-time-mode 1)
(setq display-time-day-and-date t)

;; File handling
(global-auto-revert-mode 1)
(setq auto-save-default nil)

;; Performance optimizations
(setq undo-limit 80000000
      inhibit-compacting-font-caches t)

;; Editing behavior
(setq evil-want-fine-undo t)

;; =============================================================================
;; ORG MODE - CORE SETTINGS
;; =============================================================================

;; org-directory / org-roam-directory are set at the top of this file
;; (overridable from config.local.el).

;; Task dependencies - prevent marking parent as DONE if children aren't DONE
(setq-default org-enforce-todo-dependencies t)

;; MEET is used by the "Meetings" agenda group below. Files that carry their
;; own #+SEQ_TODO line override this, so MEET is also added to those.
(after! org
  (add-to-list 'org-todo-keywords '(sequence "MEET(m)" "|" "DONE(d)") t))

;; Automatic blank lines before new entries
(setq org-blank-before-new-entry '((heading) (plain-list-item)))

;; Logging - track timestamps for task state changes
(setq org-log-done 'time          ; Log when tasks are marked DONE
      org-log-redeadline 'time    ; Log deadline changes
      org-log-reschedule 'time)   ; Log schedule changes

;; Clocking and archiving
(setq org-clock-into-drawer "TIME"
      org-archive-location "%s_archive::")

;; =============================================================================
;; ORG MODE - KEYBINDINGS
;; =============================================================================

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "<f6>") 'org-capture)
(global-set-key (kbd "C-c h") 'org-focus-home)
(global-set-key (kbd "C-c w") 'org-focus-work)
(global-set-key (kbd "C-c t") 'tp/load-new-theme)

;; =============================================================================
;; ORG MODE - AGENDA CONFIGURATION
;; =============================================================================

;; nano-agenda.el lives in this directory, which is not on `load-path'.
(autoload 'nano-agenda (expand-file-name "nano-agenda" doom-user-dir)
  "Display the NANO agenda." t)

;; Agenda file management functions
;; org-focus-home-files / org-focus-work-files are set at the top of this
;; file (overridable from config.local.el).

(defun org-focus-home ()
  "Narrow the agenda to home-related org files."
  (interactive)
  (setq org-agenda-files org-focus-home-files))

(defun org-focus-work ()
  "Narrow the agenda to work-related org files."
  (interactive)
  (setq org-agenda-files org-focus-work-files))

;; Default to both combined, so a cold agenda (before C-c h / C-c w is
;; ever pressed) shows real tasks instead of silently falling back to
;; Doom's default -- the bare org-directory, which directory-expands
;; non-recursively and so misses every file under home/ and work/.
(setq org-agenda-files (append org-focus-home-files org-focus-work-files))

;; Agenda display settings
(after! org-agenda
  (setq org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-agenda-block-separator nil
        org-agenda-compact-blocks t
        org-agenda-start-day nil      ; Start with today
        org-agenda-span 1
        org-agenda-start-on-weekday nil)

  ;; Custom agenda views
  (setq org-agenda-custom-commands
        '(("c" "Super view"
           ((agenda "" ((org-agenda-overriding-header "")
                        (org-agenda-span 'day)
                        (org-super-agenda-groups
                         '((:name "Today"
                                  :time-grid t
                                  :date today
                                  :scheduled today
                                  :order 1)
                           (:name "Due today"
                                  :deadline today)
                           (:name "Important"
                                  :priority "A")
                           (:name "Overdue"
                                  :deadline past)
                           (:name "Due soon"
                                  :deadline future)))))
            (alltodo "" ((org-agenda-overriding-header "")
                         (org-super-agenda-groups
                          '((:log t)
                            (:name "To refile"
                                   :file-path "refile\\.org")
                            (:name "Next to do"
                                   :todo "NEXT"
                                   :order 1)
                            (:name "Important"
                                   :priority "A"
                                   :order 6)
                            (:name "Today's tasks"
                                   :file-path "journal/")
                            (:name "Due Today"
                                   :deadline today
                                   :order 2)
                            (:name "Meetings"
                                   :todo "MEET"
                                   :order 3)
                            (:name "Scheduled Soon"
                                   :scheduled future
                                   :order 8)
                            (:name "Overdue"
                                   :deadline past
                                   :order 7)
                            (:discard (:not (:todo ("TODO" "MEET"))))))))))
          ("n" "Nano Agenda"
           (lambda (&optional arg)
             (interactive)
             (nano-agenda)))))

  (org-super-agenda-mode))

;; =============================================================================
;; ORG MODE - CAPTURE TEMPLATES
;; =============================================================================
;; Using doct for declarative org-capture templates
;; Icons from all-the-icons package for visual distinction

(use-package! all-the-icons)

(use-package! doct
  :commands (doct))

(after! (org-capture all-the-icons)
  (setq org-capture-templates
        (doct `(
                ;; Home-related captures
                (,(format "%s\thome capture"
                          (all-the-icons-octicon "home" :face 'all-the-icons-green :v-adjust 0.01))
                 :keys "h"
                 :file ,(expand-file-name "home/home.org" org-directory)
                 :prepend t
                 :children
                 ((,(format "%s\thome todo"
                            (all-the-icons-octicon "checklist" :face 'all-the-icons-green :v-adjust 0.01))
                   :keys "t"
                   :headline "Inbox"
                   :todo-state "TODO"
                   :template-file ,(expand-file-name "templates/tpl-todo.txt" org-directory))
                  (,(format "%s\tcapture email"
                            (all-the-icons-faicon "envelope" :face 'all-the-icons-blue :v-adjust 0.01))
                   :keys "e"
                   :prepend t
                   :headline "Inbox"
                   :type entry
                   :template-file ,(expand-file-name "templates/tpl-email.txt" org-directory))
                  (,(format "%s\tjournal entry"
                            (all-the-icons-faicon "sticky-note" :face 'all-the-icons-yellow :v-adjust 0.01))
                   :keys "j"
                   :file ,(expand-file-name "home/home-journal.org" org-directory)
                   :datetree t
                   :template "* %U - %^{Activity}")))

                ;; Work-related captures
                (,(format "%s\twork capture"
                          (all-the-icons-octicon "briefcase" :face 'all-the-icons-red :v-adjust 0.01))
                 :keys "w"
                 :file ,(expand-file-name "work/work.org" org-directory)
                 :prepend t
                 :children
                 ((,(format "%s\twork todo"
                            (all-the-icons-octicon "checklist" :face 'all-the-icons-green :v-adjust 0.01))
                   :keys "t"
                   :headline "Inbox"
                   :todo-state "TODO"
                   :template-file ,(expand-file-name "templates/tpl-todo.txt" org-directory))
                  (,(format "%s\tjournal entry"
                            (all-the-icons-faicon "sticky-note" :face 'all-the-icons-yellow :v-adjust 0.01))
                   :keys "j"
                   :file ,(expand-file-name "work/work-journal.org" org-directory)
                   :datetree t
                   :template "* %U - %?")
                  (,(format "%s\tcapture email"
                            (all-the-icons-faicon "envelope" :face 'all-the-icons-yellow :v-adjust 0.01))
                   :keys "e"
                   :file ,(expand-file-name "work/work.org" org-directory)
                   :prepend t
                   :template-file ,(expand-file-name "templates/tpl-email.txt" org-directory))))

                ;; General captures
                (,(format "%s\tbook to read"
                          (all-the-icons-octicon "book" :face 'all-the-icons-green :v-adjust 0.02))
                 :keys "b"
                 :file ,(expand-file-name "books.org" org-directory)
                 :headline "Books to read"
                 :prepend t
                 :template-file ,(expand-file-name "templates/tpl-book.txt" org-directory))

                (,(format "%s\tideas"
                          (all-the-icons-faicon "lightbulb-o" :face 'all-the-icons-yellow :v-adjust 0.02))
                 :keys "i"
                 :file ,(expand-file-name "ideas.org" org-directory)
                 :headline "Ideas"
                 :prepend t
                 :template-file ,(expand-file-name "templates/tpl-idea.txt" org-directory))

                (,(format "%s\tthoughts/observations"
                          (all-the-icons-faicon "bolt" :face 'all-the-icons-yellow :v-adjust 0.01))
                 :keys "o"
                 :file ,(expand-file-name "thoughts-and-observations-journal.org" org-directory)
                 :datetree t
                 :template "* %U - %?")))))

;; =============================================================================
;; ORG ROAM CONFIGURATION
;; =============================================================================
;; Knowledge base with bi-directional linking

(after! org-roam
  (map! :leader
        :prefix "n"
        :desc "org-roam-buffer-toggle" "l" #'org-roam-buffer-toggle
        :desc "org-roam-node-find" "f" #'org-roam-node-find
        :desc "org-roam-graph" "g" #'org-roam-graph
        :desc "org-roam-node-insert" "i" #'org-roam-node-insert
        :desc "org-roam-dailies-capture-today" "T" #'org-roam-dailies-capture-today
        :desc "org-roam-capture" "c" #'org-roam-capture))

;; =============================================================================
;; MACLINK CONFIGURATION
;; =============================================================================
;; maclink:// links already open with no config (org falls through to
;; browse-url, which shells out to /usr/bin/open on macOS). This loads the
;; optional sugar: maclink-insert-from-clipboard and a real `maclink' org
;; link type. See ~/workspace/maclink/README.md, "Using it from Emacs".

(when (and my/maclink-file (load! my/maclink-file nil t))
  (map! :leader
        :prefix "n"
        :desc "maclink-insert-from-clipboard" "m" #'maclink-insert-from-clipboard))

;; =============================================================================
;; ORG MODE - VISUAL ENHANCEMENTS
;; =============================================================================

;; Show hidden emphasis markers on cursor proximity
(add-hook 'org-mode-hook 'org-appear-mode)

;; org-modern provides modern styling for org-mode with better compatibility
(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  ;; Customize org-modern appearance
  (setq
   ;; Use rounded boxes for tags instead of sharp rectangles
   org-modern-tag-style 'rounded
   
   ;; Style for TODO keywords - will show as colored labels
   org-modern-keyword nil  ; Use default keyword styling

   ;; TODO keyword boxes are rendered by svg-tag-mode instead (see
   ;; nano-theme.el) so they can have real rounded corners -- Emacs's
   ;; `:box' face attribute, which org-modern-todo uses, cannot round.
   org-modern-todo nil

   ;; Modern styling for other elements
   org-modern-star '("◉" "○" "◈" "◇" "✳")  ; Bullet styles for headlines
   org-modern-table-vertical 1           ; Vertical table lines
   org-modern-table-horizontal 0.1       ; Horizontal table lines
   org-modern-list '((43 . "➤")          ; Custom list bullet for '+'
                     (45 . "–")          ; Custom list bullet for '-'
                     (42 . "•"))         ; Custom list bullet for '*'
   org-modern-block-fringe 8             ; Block fringe width
   org-modern-block-name t               ; Style block names
   org-modern-priority t                 ; Style priority markers
   org-modern-checkbox nil               ; Use default checkbox styling
   org-modern-horizontal-rule t))        ; Style horizontal rules

;; Disable hl-line-mode in org-mode to prevent TODO keyword color changes
(add-hook 'org-mode-hook (lambda () (hl-line-mode -1)))

;; Additional org-mode visual settings that work well with org-modern
(after! org
  (setq
   ;; Hide emphasis markers (bold, italic, etc.)
   org-hide-emphasis-markers t
   
   ;; Use pretty entities (e.g., \alpha shows as α)
   org-pretty-entities t
   
   ;; Custom ellipsis for folded sections
   org-ellipsis " ▼ "
   
   ;; Better tag alignment
   org-auto-align-tags nil
   org-tags-column 0))

;; =============================================================================
;; EXTERNAL INTEGRATIONS
;; =============================================================================

;; Hook app integration - create org-mode links to Hook.app resources
(after! org
  (defun my/hook (hook)
    "Open Hook.app bookmark using hook:// URL scheme."
    (shell-command (concat "open hook:\"" hook "\"")))
  (org-add-link-type "hook" 'my/hook))

;; =============================================================================
;; THEME CONFIGURATION
;; =============================================================================

;; Available themes for rotation
(setq tp-doom-themes '("doom-nano-dark" "doom-nano-light"))

;; NOTE The doom-nano-* theme files in ./themes/ are deliberate copies, not
;; duplicates to clean up. doom-nano-themes' README tells you to copy them into
;; $DOOMDIR/themes/, and the package's own build directory is not on
;; `custom-theme-load-path'. It also carries a stale doom-nano-light-theme.elc
;; that fails to load, so pointing at it directly does not work.

;; Load Nano theme
(setq doom-theme 'doom-nano-dark)

(load! "nano-theme")

;; Nano modeline configuration
(use-package! doom-nano-modeline
  :config
  ;; Today's date on the right side of the modeline, e.g. "Sep 12, 2026.
  ;; Saturday". Re-evaluated on every redisplay, so it rolls over at
  ;; midnight with no timer needed.
  (setq doom-nano-modeline-append-information
        (lambda ()
          `((,(format-time-string "%b %-d, %Y. %A") . doom-nano-modeline-cursor-position-face)
            (" " . nil))))
  (doom-nano-modeline-mode 1)
  (global-hide-mode-line-mode 1))

;; Theme cycling function
(defun tp/load-new-theme ()
  "Cycle to the next theme in `tp-doom-themes'."
  (interactive)
  ;; Rotate first, so the first press moves off the theme already in use.
  (setq tp-doom-themes (append (cdr tp-doom-themes)
                               (list (car tp-doom-themes))))
  (let ((next (intern (car tp-doom-themes))))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)
    (setq doom-theme next)
    (message "Theme: %s" next)))

;; =============================================================================
;; COMMENTED OUT / OPTIONAL CONFIGURATIONS
;; =============================================================================

;; Spell checking configuration (currently disabled)
;; Uncomment and set correct path if using ispell
;; (setq ispell-program-name "/usr/local/bin/ispell")
