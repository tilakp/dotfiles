;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Your Name"
      user-mail-address "you@example.com")

(display-time-mode 1)
(setq display-time-day-and-date t)
(global-auto-revert-mode 1)
(setq undo-limit 80000000
      evil-want-fine-undo t
      auto-save-default nil
      inhibit-compacting-font-caches t)
(whitespace-mode -1)

;; This is so I cannot set a headline to DONE if children aren’t DONE.
(setq-default org-enforce-todo-dependencies t)

;; setting up some shortcuts 
(global-set-key "\C-ca" 'org-agenda)
(global-set-key (kbd "<f6>") 'org-capture)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-roam-directory "~/org/roam/")

;; some useful utilities from https://blog.aaronbieber.com/2016/01/30/dig-into-org-mode.html
;; This causes Org to automatically place a blank line before a new heading or plain text list item
(setq org-blank-before-new-entry (quote ((heading) (plain-list-item))))
;; it forces you to mark all child tasks as “DONE” before you can mark the parent as “DONE.”
(setq org-enforce-todo-dependencies t)
;; Setting this option causes Org to insert an annotation in a task when it is marked as
;; done including a timestamp of when exactly that happened.
(setq org-log-done (quote time))
;; this option causes Org to insert annotations when you change the deadline of a task
(setq org-log-redeadline (quote time))
;; This does the same as above, but for the scheduled dates
(setq org-log-reschedule (quote time))

;; set up ispell for flychecker https://emacs.stackexchange.com/questions/19175/where-is-ispell
;; (setq ispell-program-name "/usr/local/bin/ispell")

;; custom clocking drawer
(setq org-clock-into-drawer "TIME")
(setq org-archive-location "%s_archive::")

;; separate agenda files for home stuff and work stuff 
(defun org-focus-home() "Set focus on home stuff." 
  (interactive)
  (setq org-agenda-files '("~/org/home/home.org" 
	"~/org/home/home_repair.org"))
  )

(defun org-focus-work() "Set focus on work stuff." 
  (interactive)
  (setq org-agenda-files '("~/org/work/work.org")))

;; Make sure all-the-icons is loaded before using it in capture templates
(use-package! all-the-icons)

;; capture templates, very much work in progress
;; learned about doct and all-the-icons from https://www.reddit.com/r/emacs/comments/fzuv4f/my_prettified_orgcapture/ 
;; specific diff: https://github.com/tecosaur/emacs-config/compare/6bcdbaa..49c790e 
;; complete config: https://github.com/tecosaur/emacs-config/blob/43a19e7f785e70ee6717131437b0d91657ddc334/config.el#L720
;; doct documentation: https://github.com/progfolio/doct 
;; and all the icons can be found on https://github.com/domtronn/all-the-icons.el/blob/master/data/data-octicons.el 
(after! (org-capture all-the-icons)
  (setq org-capture-templates
        (doct `(
                    (,(format "%s\thome capture" (all-the-icons-octicon "home" :face 'all-the-icons-green :v-adjust 0.01))
                                :keys "h"
                                :file "~/org/home/home.org"
                                :prepend t
                                :children
                                ((,(format "%s\thome todo" (all-the-icons-octicon "checklist" :face 'all-the-icons-green :v-adjust 0.01))
        	                         :keys "t"
                	                 :headline   "Inbox"
                  	                 :todo-state "TODO"
                                         :template-file "~/org/templates/tpl-todo.txt")
				                 (,(format "%s\tEmail" (all-the-icons-faicon "envelope" :face 'all-the-icons-blue :v-adjust 0.01))
				   	                 :keys "e"
				   	                 :prepend t
				   	                 :headline "Inbox"
				   	                 :type entry
					                 :template-file "~/org/templates/tpl-email.txt")
                                 (,(format "%s\tjournal entry" (all-the-icons-faicon "sticky-note" :face 'all-the-icons-yellow :v-adjust 0.01))
					                 :keys "j"
				                     :file "~/org/home/home-journal.org"
				                     :datetree t
				                     :template "* %U - %^{Activity}")
                                 (,(format "%s\tcapture email" (all-the-icons-faicon "envelope" :face 'all-the-icons-yellow :v-adjust 0.01))
                                          :keys "e"
                                          :file "~/org/home/home.org"
                                          :prepend t
                                          :template-file "~/org/templates/tpl-email.txt")
                                 )
                    )
                    (,(format "%s\twork capture" (all-the-icons-octicon "briefcase" :face 'all-the-icons-red :v-adjust 0.01))
                                :keys "w"
                                :file "~/org/work/work.org"
                                :prepend t
                                :children
                                ((,(format "%s\twork todo" (all-the-icons-octicon "checklist" :face 'all-the-icons-green :v-adjust 0.01))
                                          :keys "t"
                                          :headline "Inbox"
                                          :todo-state "TODO"
                                          :template-file "~/org/templates/tpl-todo.txt")
				                 (,(format "%s\tjournal entry" (all-the-icons-faicon "sticky-note" :face 'all-the-icons-yellow :v-adjust 0.01)) 
					                      :keys "j"
					                      :file "~/org/work/work-journal.org"
				 	                      :datetree t
				  	                      :template "* %U - %?")
                                 (,(format "%s\tcapture email" (all-the-icons-faicon "envelope" :face 'all-the-icons-yellow :v-adjust 0.01))
                                          :keys "e"
                                          :file "~/org/work/work.org"
                                          :prepend t
                                          :template-file "~/org/templates/tpl-email.txt")
                                 )
                    )
                    (,(format "%s\tbook to read" (all-the-icons-octicon "book" :face 'all-the-icons-green :v-adjust 0.02))
                                :keys "b"
                                :file "~/org/books.org"
                                :headline "Books to read"
                                :prepend t
                                :template-file "~/org/templates/tpl-book.txt")
                    (,(format "%s\tideas" (all-the-icons-faicon "lightbulb-o" :face 'all-the-icons-yellow :v-adjust 0.02))
                                :keys "i"
                                :file "~/org/ideas.org"
                                :headline "Ideas"
                                :prepend t
                                :template-file "~/org/templates/tpl-idea.txt")
			        (,(format "%s\tthoughts/observations" (all-the-icons-faicon "bolt" :face 'all-the-icons-yellow :v-adjust 0.01))
                                :keys "o"
                                :file "~/org/thoughts-and-observations-journal.org"
                                :datetree t
                                :template "* %U - %?")
 
		))

  )
)

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default: doom-ephemeral
;; Load the nano theme setup from Nicolas Rougier's implementation
(setq doom-theme 'doom-nano-light)
(after! doom-themes
  (load-theme 'doom-nano-light t))

(load! "nano-theme")

(use-package! doom-nano-modeline
  :config
  (doom-nano-modeline-mode 1)
  (global-hide-mode-line-mode 1))

;; picked up from https://github.com/nmartin84/.doom.d/blob/master/config.el
;; (setq tp-doom-themes '("nano-light" "nano-dark" "doom-ayu-light" "doom-plain" "doom-rouge" "doom-badger" "doom-challenger-deep" "doom-snazzy"  "doom-solarized-light" "doom-ephemeral" "doom-nord-light" "doom-spacegrey" "doom-flatwhite" "doom-nord" "doom-tomorrow-night" "doom-homage-white" "doom-one" "doom-opera"))
(setq tp-doom-themes '("doom-nano-light" "doom-nano-dark" "doom-nano-modeline" "doom-ayu-light" "doom-plain" "doom-rouge" "doom-badger" "doom-challenger-deep" "doom-snazzy"  "doom-solarized-light" "doom-ephemeral" "doom-nord-light" "doom-spacegrey" "doom-flatwhite" "doom-nord" "doom-tomorrow-night" "doom-homage-white" "doom-one" "doom-opera"))

(defun tp/load-new-theme ()
  (interactive)
  (let* ((themes tp-doom-themes)
         (first (car tp-doom-themes)))
    (counsel-load-theme-action (car themes))
    (setq doom-theme (car themes))
    (pop tp-doom-themes)
    (add-to-list 'tp-doom-themes first t)))

;; org-appear, https://github.com/awth13/org-appear
(add-hook 'org-mode-hook 'org-appear-mode)

; (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(after! org
  (add-hook 'org-mode-hook 'svg-tag-mode))

(after! org
  (setq org-tags-column -120)
  (setq svg-tag-tags
      `(
        ; Org tags
        (":\\([a-z0-9]+\\):" . ((lambda (tag) (svg-tag-make tag))))
        ("NEXT" . ((lambda (tag) (svg-tag-make "NEXT" :face 'org-todo :inverse t ))))
        ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t ))))
        ("WAITING" . ((lambda (tag) (svg-tag-make "WAITING" :face 'org-todo ))))
        ("SOMEDAY" . ((lambda (tag) (svg-tag-make "SOMEDAY" :face 'org-todo ))))
		("SCHEDULED" . ((lambda (tag) (svg-tag-make "SCHEDULED" :face 'org-todo ))))
		("LATER" . ((lambda (tag) (svg-tag-make "LATER" :face 'org-todo ))))
        ("PROJ" . ((lambda (tag) (svg-tag-make "PROJ" :face 'org-todo ))))
        ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-todo ))))
        ("CANCELLED" . ((lambda (tag) (svg-tag-make "CANCELLED" :face 'org-todo ))))
  ))
  (svg-tag-mode t)
)

;; from https://ianjones.us/own-your-second-brain
(after! org-roam
        (map! :leader
            :prefix "n"
            :desc "org-roam-buffer-toggle" "l" #'org-roam
            :desc "org-roam-node-find" "f" #'org-roam-node-find
            :desc "org-roam-graph" "g" #'org-roam-graph
            :desc "org-roam-node-insert" "i" #'org-roam-insert
            :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today
            :desc "org-roam-capture" "c" #'org-roam-capture))

;; enable hook
;; taken from https://discourse.hookproductivity.com/t/integrating-emacs-and-hook-with-org-mode/932/17
(after! org 
    (defun my/hook (hook)
        "Create an org-link target string using `hook://` url scheme."
        (shell-command (concat "open hook:\"" hook "\"")))
    (org-add-link-type "hook" 'my/hook)
)

;; picked from https://www.rousette.org.uk/archives/doom-emacs-tweaks-org-journal-and-org-super-agenda/
(after! org-agenda
  :init
  (setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-day nil ;; i.e. today
      org-agenda-span 1
      org-agenda-start-on-weekday nil)
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
                            (:name "Scheduled Soon"
                                   :scheduled future
                                   :order 8)
                            (:name "Overdue"
                                   :deadline past
                                   :order 7)
                            (:name "Meetings"
                                   :and (:todo "MEET" :scheduled future)
                                   :order 10)
                            (:discard (:not (:todo "TODO")))))))))
          ("n" "Nano Agenda" (lambda (&optional arg) (interactive) (nano-agenda)))))
  :config
  (org-super-agenda-mode))

; https://github.com/rougier/nano-calendar
(load! "non-calendar")
(nano-calendar)