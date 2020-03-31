(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
; list the packages
(setq package-list
    '(ess ess-smart-underscore org-ref auto-complete))

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
 '(custom-enabled-themes (quote (tango-dark)))
 '(desktop-save-mode t)
 '(global-auto-complete-mode t)
 '(global-linum-mode t)
 '(hs-hide-comments-when-hiding-all nil)
 '(hs-minor-mode-hook (quote (ignore)))
 '(org-support-shift-select t)
 '(package-selected-packages
   (quote
    (org standoff-mode flycheck-stan eldoc-stan company-stan stan-snippets stan-mode r-autoyas ess-smart-equals babel-repl babel ess-view ess-R-data-view auto-complete org-ref ess-smart-underscore ess)))
 '(size-indication-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'ess-site)
(require 'ess-smart-underscore)

;; Active the R language in Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)))

;; Auto complete
(require 'auto-complete-config)
(ac-config-default)

;; stan-mode
(require 'stan-mode)
;; Add a hook to setup `stan-mode' upon `stan-mode' entry
(add-hook 'stan-mode-hook 'stan-mode-setup)
(setq stan-indentation-offset 2)
