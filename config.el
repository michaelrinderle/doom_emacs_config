;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; michaels emac config
;; 1.16.2020
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; General configuration
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;; gc
(setq gc-cons-threshold (* 4 1024 1024))
(setq gc-cons-percentage 0.3)

;; suppress diffie-hellman 256 bit warning
(setq gnutls-min-prime-bits 1024)

;; get username & echo starup message
(defvar current-user
  (getenv (if (equal system-type 'windows-nt) "USERNAME" "USER")))

;; echo starup message
(defun display-startup-echo-area-message ()
  (message "follow the white rabbit, %s!" current-user))

;; expliticy set auto save
(setq auto-save-default t)
(setq make-backup-files t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Doom configuration
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;; set theme
(setq doom-theme 'doom-nord)

;; installs all fonts so ui looks good, only run once
;; (all-the-icons-install-fonts)

(setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
       doom-variable-pitch-font (font-spec :family "sans" :size 13))

(setq display-line-numbers-type 'relative)
(setq org-startup-truncated 1)

;; set base path determined by os
(defvar base-path t)
;; setting base emacs cloud path
(cond ((equal system-type 'windows-nt)
        ;; setting windows base path
        (setq base-path "c:/*"))
    ((equal system-type 'gnu/linux)
    (when(string-match "Linux.*Microsoft.*Linux" (shell-command-to-string "uname -a"))
        ;; set wsl base path
        (setq base-path "/*")
        ;; set linux base path
        ;;(setq base-path "/*")
        ))
    ((equal system-type 'darwin
        ;; set unknown osx path
    (setq base-path "/idk/emacs"))))

;; org mode settings
(setq org-tags-column 75)
(setq org-image-actual-width nil)

;; set org directory
(setq org-directory (concat base-path "org/"))
(setq org-contacts-files '((concat base-path "*/contacts.org")))
(setq org-agenda-files (directory-files-recursively (concat base-path "org/") "\\.org$"))

;; org journal
(use-package org-journal
  :bind
  ("C-c n j" . org-journal-new-entry)
  :custom
  (org-journal-date-prefix "#+TITLE: ")
  (org-journal-file-format "%Y-%m-%d.org")
  (org-journal-dir (concat base-path "journal/"))
  (org-journal-date-format "%A, %d %B %Y"))

;; org roam
(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam)
  :init
  (setq org-roam-directory (concat base-path "roam/"))
  (setq org-roam-graph-viewer "/usr/bin/open")
  (map! :leader
        :prefix "n"
       :desc "Org-Roam-Insert" "i" #'org-roam-insert
        :desc "Org-Roam-Find"   "/" #'org-roam-find-file
        :desc "Org-Roam-Buffer" "r" #'org-roam)
  :config
  (org-roam-mode +1))

;; deft
(use-package deft
  :after org
  :bind
  ("C-c n d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory (concat base-path "org-roam")))

;; org-capture
(setq org-capture-todo-file (concat base-path "*/todo.org")
      org-capture-notes-file (concat base-path "*/notes.org")
      org-capture-templates
        '(("t" "Todo" entry (file+headline (concat base-path "*/todo.org") "Todos")
              "*TODO %?\n  %i\n")
          ("n" "Note" entry (file+headline (concat base-path "org/notes.org") "Notes")
                (file (concat base-path "*/templates/notes.orgcaptpl")))

          ("c" "Contact" entry (file+headline (concat base-path "org/contacts.org" "Contacts"),
                (file (concat base-path "*/template/contact.orgcaptpl"))))

          ("a" "Assignment" entry (file+headline (concat base-path "org/school/assignments.org" "Assigments")
                (file (concat base-path "*/templates/assignments.orgcaptpl"))))))

;; set inital buffer
;; (setq org-startup-with-inline-images t)
(setq initial-buffer-choice (concat base-path "org/global.org"))

;; ignore recent files in switch-buffer
(setq ivy-use-virtual-buffers nil)

;; set evil-vimish globally
;; folding [ za = toggle | zo = open | zc = close ]
(setq evil-vimish-fold-target-modes '(prog-mode conf-mode text-mode))
(evil-vimish-fold-mode 1)

;; example to define evil key binding
;; (evil-define-key 'normal' map "zf" 'vimish-fold)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; User-defined Org Bindings
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;; map meta up|down to move org-mode table row
(define-key input-decode-map "\e\eOA" [(meta up)])
(define-key input-decode-map "\e\eOB" [(meta down)])
(global-set-key [(meta up)] 'org-table-move-row-up)
(global-set-key [(meta down)] 'org-table-move-row-down)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Email Configuration
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(after! mu4e

  (add-hook 'mu4e-compose-mode-hook 'flyspell-mode)
  (add-hook 'mu4e-compose-mode-hook 'visual-line-mode)
  (add-hook 'mu4e-compose-mode-hook
            (defun ok-mu4e-keep-it-to-three-sentences ()
              (shell-command "notify-send -u critical 'Keep it to three sentences'")
              (message "Keep it to three sentences!")))

  (setq!
         ;; mml-secure-openpgp-encrypt-to-self t
         ;; mml-secure-openpgp-sign-with-sender t
         ;; mu4e-compose-crypto-rely-plain-policy 'sign     always sign emails
         fill-flowed-encode-column 998
         message-kill-buffer-on-exit t
         mm-sign-option 'guided
         mu4e-change-filenames-when-moving t
         mu4e-completing-read-function 'completing-read
         mu4e-compose-complete-addresses t
         mu4e-compose-context-policy nil
         mu4e-compose-dont-reply-to-self t
         mu4e-compose-format-flowed t
         mu4e-compose-in-new-frame t
         mu4e-compose-keep-self-cc nil
         mu4e-compose-signature-auto-include t
         mu4e-context-policy 'pick-first
         mu4e-get-mail-command "mbsync --all"
         mu4e-headers-date-format "%d-%m-%Y %H:%M"
         mu4e-headers-include-related t
         mu4e-index-update-in-background t
         mu4e-sent-messages-behavior 'sent
         mu4e-update-interval (* 15 60)
         mu4e-use-fancy-chars t
         mu4e-view-fields '()
         mu4e-view-show-addresses t
         mu4e-view-show-images t
         mu4e-view-use-gnus nil
         org-mu4e-convert-to-html t
         org-mu4e-link-query-in-headers-mode nil
         shr-color-visible-luminance-min 80
         smtpmail-debug-info t
         mu4e-view-fields '(:from
                            :to
                            :cc
                            :bcc
                            :subject
                            :flags
                            :date
                            :maildir
                            ;; :mailing-list
                            :tags
                            :attachments
                            :signature)
                            ;;:decription)
         message-citation-line-function 'message-insert-formatted-citation-line
         smtpmail-stream-type 'starttls
         mu4e-attachment-dir "~/downloads" fields '((:human-date . 20)
                                                   (:flags . 6)
                                                   (:mailing-list . 10)
                                                   (:from . 22)
                                                   (:subject)))
        (setq mu4e-contexts
        `( ,(make-mu4e-context
             :name "gmail"
             :enter-func (lambda ()
                           (mu4e-message "entering gmail context")
                           (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                             (revert-buffer)))
             :leave-func (lambda ()
                           (mu4e-message "leaving gmail context")
                           (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                             (revert-buffer)))
             :match-func (lambda (msg)
                           (when msg
                             (or (mu4e-message-contact-field-matches msg :to "*@gmail.com")
                                 (mu4e-message-contact-field-matches msg :from "*@gmail.com")
                                 (mu4e-message-contact-field-matches msg :cc "*@gmail.com")
                                 (mu4e-message-contact-field-matches msg :bcc "*@gmail.com")
                                 (string-match-p "^/gmail/Inbox" (mu4e-message-field msg :maildir)))))

             :vars '((user-mail-address            . "*@gmail.com" )
                     (user-full-name               . "Michael Rinderle, R.L.")
                     (mu4e-compose-signature       . "Michael G. Rinderle, R.L." )
                     (mu4e-update-interval         . 1800)
                     (smtpmail-debug-info          . t)
                     (smtpmail-smtp-server         . "smtp.gmail.com" )
                     (smtpmail-smtp-service        . 587)
                     (smtpmail-stream-type         . starttls)
                     (smtpmail-smtp-user           . "*@gmail.com" )
                     (mu4e-sent-messages-behavior  . 'delete)
                     (mu4e-maildir                 . "~/.mbsync/gmail/")
                     (message-signature-file (concat base-path "org/templates/.gmail-signature"))
                     (mu4e-draft-folder            . "/gmail/[Gmail]/Drafts")
                     (mu4e-sent-folder             . "/gmail/[Gmail]/Sent Mail")
                     (mu4e-trash-folder            . "/gmail/[Gmail]/Trash")))

           ,(make-mu4e-context
             :name "outlook"
             :enter-func (lambda ()
                           (mu4e-message "entering outlook context")
                           (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                             (revert-buffer)))
             :leave-func (lambda ()
                           (mu4e-message "leaving school context")
                           (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                             (revert-buffer)))
             :match-func (lambda (msg)
                           (when msg
                             (or (mu4e-message-contact-field-matches msg :to "*")
                                 (mu4e-message-contact-field-matches msg :from "*")
                                 (mu4e-message-contact-field-matches msg :cc "*")
                                 (mu4e-message-contact-field-matches msg :bcc "*")
                                 (string-match-p "^/outlook/Inbox" (mu4e-message-field msg :maildir)))))

             :vars '((user-mail-address            . "*" )
                     (user-full-name               . "Michael Rinderle, R.L.")
                     (mu4e-compose-signature       . "Michael G. Rinderle, R.L." )
                     (mu4e-compose-signature       . "Michael Rinderle, R.L." )
                     (mu4e-update-interval         . 1800)
                     (smtpmail-debug-info          . t)
                     (smtpmail-smtp-server         . "smtp.office365.com" )
                     (smtpmail-smtp-service        . 587 )
                     (smtpmail-stream-type         . starttls)
                     (smtpmail-smtp-user           . "*" )
                     (mu4e-sent-messages-behavior  . 'sent)
                     (mu4e-maildir                 . "~/.mbsync/outlook/")
                     (message-signature-file (concat base-path "org/templates/.outlook-signature"))
                     (mu4e-draft-folder            . "/outlook/Drafts")
                     (mu4e-refile-folder           . "/outlook/Archive")
                     (mu4e-sent-folder             . "/outlook/Sent Items")
                     (mu4e-trash-folder            . "/outlook/Deleted Items"))))))

;; email alerts
(use-package mu4e-alert
  :init
  (defun mu4e-alert-notify ()
    ;; display mode line & desktop alerts
    (interactive)
    (mu4e-update-mail-and-index 1)
    (mu4e-alert-enable-mode-line-display)
    (mu4e-alert-enable-notifications))
  (defun mu4e-alert-refresh ()
    ;; refresh every 300s & desktop alerts
    (interactive)
    (mu4e t)
    (run-with-timer 0 300 'mu4e-alert-notify))
  :after mu4e
  :bind ("<f4>" . mu4e-alert-refresh)
  :config
  (add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display)
  ;; desktop alerts using libnotify
  (mu4e-alert-set-default-style 'libnotify)
  (add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
  ;; filter junk from notification
  (setq mu4e-alert-interesting-mail-query
        (concat
        "flag:unread maildir:/Inbox"
         " AND NOT flag:trashed")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Ido
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(ido-mode t)
(ido-everywhere t)
(setq ido-enable-flex-matching t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; IRC
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(add-hook 'rcirc-mode-hook (lambda ()
                             (set (make-local-variable 'scroll-conservatively) 8192)
                             (flyspell-mode 1)
                             (rcirc-omit-mode)))
(setq rcirc-log-flag t)
(setq rcirc-buffer-maximum-lines 1000)

;; Identification for IRC server connections
(setq rcirc-default-user-name "*"
      rcirc-default-nick      "*"
      rcirc-default-full-name "god-mode")

;; Enable automatic authentication with rcirc-authinfo keys.
(setq rcirc-auto-authenticate-flag t)

;; Enable logging support by default.
(setq rcirc-log-flag t
      rcirc-log-directory (concat base-path "logs/irclogs/"))

;; Passwords for auto-identifying to nickserv and bitlbee.
(setq rcirc-authinfo '(("freenode"  nickserv "*"   "8d00909sd8d")))
(setq rcirc-server-alist
      '(("irc.freenode.net"
         :port 6697
         :encryption tls
         :channels ("#emacs"))))

;; Some UI options which I like better than the defaults.
(rcirc-track-minor-mode 1)
(setq rcirc-prompt      "»» "
      rcirc-time-format "%H:%M "
      rcirc-fill-flag   nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Dap-Mode
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(dap-mode 1)
(dap-ui-mode 1)

;; enables mouse hover support
(dap-tooltip-mode 1)

;; use tooltips for mouse hover
(tooltip-mode 1)

;; displays floating panel with debug buttons emacs >= 26
(dap-ui-controls-mode 1)

;; language support
(require 'dap-java)
(require 'dap-python)           ;; required ptvsd
(require 'dap-lldb)             ;; ren dap-cpptools-setup
(require 'dap-gdb-lldb)         ;; run dap-gdb-lldb-setup
(require 'dap-cpptools)
;; (require 'dap-pwsh)             ;; available for wsl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; WSL Bindings
;;::::::::::::::::::::::::::::::::::::::::::::::::: ::::::::::::::::::::

;; open web links outside wsl
(cond
 ((equal system-type 'gnu/linux)
  (when(string-match "Linux.*Microsoft.*Linux" (shell-command-to-string "uname -a"))
        ;; paste wsl clipboard buffer, just use (p)

        ;; open links outside wsl
        (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
                (cmd-args '("/c" "start")))
                (when (file-exists-p cmd-exe)
                (setq browse-url-generic-program cmd-exe
                        browse-url-generic-args cmd-args
                        browse-url-browser-function 'browse-url-generic))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Buffer Bindings
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;; toggle between horizontal and vertical split with two windows."
(defun toggle-split()
  (interactive)
  (if (> (length (window-list)) 2)
      (error "Can't toggle with more than 2 windows!")
    (let ((func (if (window-full-height-p)
                    #'split-window-vertically
                  #'split-window-horizontally)))
      (delete-other-windows)
      (funcall func)
      (save-selected-window
        (other-window 1)
        (switch-to-buffer (other-buffer))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Treemacs
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(setq doom-themes-treemacs-theme nil) ;; "doom-colors")
(setq treemacs--width-is-locked nil)
(setq treemacs-width 20)
(add-hook 'emacs-startup-hook 'treemacs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Deft
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(use-package deft
  :after org
  :bind
  ("C-c n d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory (concat base-path "org-roam")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Leader Bindings
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;; example to set leader w/ menu
;; (map! :leader
;;       (:prefix-map ("c" . "code")
;;            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            ;; VimishFold pre-fixed bindings
;;            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            (:prefix-map ("F" . "folding")
;;                 :desc "create"  "c" #'!vimish-fold
;;                 :desc "destroy" "d" #'!vimish-fold-delete
;;                 :desc "toggle" "t" #'!vimish-fold-toggle
;;                 :desc "toggle all" "T" #'vimish-fold-toggle-all)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Custom Methods
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(defun strike-through-region (b e)
  "Strike through selected region"
  (interactive "r")
  (when (use-region-p)
    (save-mark-and-excursion
      (goto-char b)
      (while (and (<= (point) e)
                  (not(eobp)))
        (unless (looking-back "[[:space:]]" (1 -(point)))
          (insert-char #x336)
          (setq e (1+e)))
        (forward-char 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::::::::::::::
;; Language Specific
;;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


;; ada
;; (ada-add-extensions "_s.ada" "_b.ada" ".adb" ".ads" ".body")
