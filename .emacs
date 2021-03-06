;; Location of .emacs in my Windows (c:/Users/nan_1/AppData/Roaming/.emacs)

(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'default-frame-alist '(font . "Ubuntu Mono-12"))

;; list the packages
(setq package-list
    '(ess ess-smart-underscore org-ref auto-complete polymode))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(custom-enabled-themes (quote (deeper-blue)))
 '(desktop-save-mode t)
 '(electric-pair-mode t)
 '(ess-eval-visibly (quote nowait))
 '(global-auto-complete-mode t)
 '(global-linum-mode t)
 '(hs-hide-comments-when-hiding-all nil)
 '(hs-minor-mode-hook (quote (ignore)))
 '(org-support-shift-select t)
 '(package-selected-packages
   (quote
    (highlight-symbol magit ## markdown-preview-mode markdown-mode+ poly-R poly-markdown polymode org standoff-mode flycheck-stan eldoc-stan company-stan stan-snippets stan-mode r-autoyas ess-smart-equals babel-repl babel ess-view ess-R-data-view auto-complete org-ref ess-smart-underscore ess)))
 '(send-mail-function (quote mailclient-send-it))
 '(size-indication-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'stan-mode)
(require 'ess-site)
(require 'ess-smart-underscore)
;(require 'ess-rutils)
(require 'poly-R)
(require 'poly-markdown)

;; ESS pipe C/S-> ( https://emacs.stackexchange.com/a/8055)
(defun then_R_operator ()
  "R - %>% operator or 'then' pipe operator"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
  (reindent-then-newline-and-indent))
(define-key ess-mode-map (kbd "C->") 'then_R_operator)
(define-key inferior-ess-mode-map (kbd "C->") 'then_R_operator)

;; Active the R language in Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)))

;; Auto complete
(require 'auto-complete-config)
(ac-config-default)

;; Rmd modes (polymode)
(unless (package-installed-p 'polymode)
  (package-install 'poly-markdown))

(require 'poly-R)
(require 'poly-markdown)
(add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))
(add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))
(add-to-list 'auto-mode-alist '("\\.rmd" . poly-markdown+r-mode))

;; no Flymake
(setq ess-use-flymake nil)

;; no backup~ files
(setq make-backup-files nil)

;; no #autosave# files
(setq auto-save-default nil)

;; no bell
;(setq visible-bell 1)

;; removes *messages* from the buffer
;(setq-default message-log-max nil)
;(kill-buffer "*Messages*")

;; Removes *Completions* from buffer
(add-hook 'minibuffer-exit-hook
	  '(lambda ()
	     (let ((buffer "*Completions*"))
	       (and (get-buffer buffer)
		    (kill-buffer buffer)))))

;; auto highlight
(add-hook 'emacs-lisp-mode-hook 'highlight-symbol-mode)
(add-hook 'ess-mode-hook 'highlight-symbol-mode)
(add-hook 'poly-markdown+r-mode-hook 'highlight-symbol-mode)

;; Use "Shift+Enter" to send the current line to *R*
(defun my-ess-eval ()
  (interactive)
  (if (and transient-mark-mode mark-active)
      (call-interactively 'ess-eval-region)
    (call-interactively 'ess-eval-line-and-step)))

(add-hook 'ess-mode-hook
          '(lambda()
             (local-set-key [(shift return)] 'my-ess-eval)))

;; hotkey
(require 'highlight-symbol)
(define-key global-map [f1] 'previous-buffer)
(define-key global-map [f2] 'next-buffer)

(global-set-key [f3] 'highlight-symbol-prev)
(global-set-key [f4] 'highlight-symbol-next)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)

(define-key global-map [f7] 'other-window)
(define-key global-map [f8] 'delete-window)

(define-key global-map [f12] 'ess-eval-region-or-line-and-step)


;; vertical separate only
(setq
   split-width-threshold 0
   split-height-threshold nil)
