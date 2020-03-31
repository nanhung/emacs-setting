;;; standoff-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "standoff-api" "standoff-api.el" (0 0 0 0))
;;; Generated autoloads from standoff-api.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-api" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-dummy" "standoff-dummy.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from standoff-dummy.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-dummy" '("standoff-dummy-")))

;;;***

;;;### (autoloads nil "standoff-json" "standoff-json.el" (0 0 0 0))
;;; Generated autoloads from standoff-json.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-json" '("standoff-json/")))

;;;***

;;;### (autoloads nil "standoff-json-file" "standoff-json-file.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from standoff-json-file.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-json-file" '("standoff-json-file/")))

;;;***

;;;### (autoloads nil "standoff-log" "standoff-log.el" (0 0 0 0))
;;; Generated autoloads from standoff-log.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-log" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-mark" "standoff-mark.el" (0 0 0 0))
;;; Generated autoloads from standoff-mark.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-mark" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-mode" "standoff-mode.el" (0 0 0 0))
;;; Generated autoloads from standoff-mode.el

(autoload 'standoff-mode "standoff-mode" "\
Stand-Off mode is an Emacs major mode for creating stand-off
markup and annotations. It makes the file (the buffer) which the
the markup refers to read only, and the markup is stored
externally (stand-off).

Since text insertion to a file linked by standoff markup is not
sensible at all, keyboard letters don't allow inserting text but
are bound to commands instead.

\\{standoff-mode-map}

\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-mode" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-relations" "standoff-relations.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from standoff-relations.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-relations" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-util" "standoff-util.el" (0 0 0 0))
;;; Generated autoloads from standoff-util.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-util" '("standoff-")))

;;;***

;;;### (autoloads nil "standoff-xml" "standoff-xml.el" (0 0 0 0))
;;; Generated autoloads from standoff-xml.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "standoff-xml" '("standoff-xml-")))

;;;***

;;;### (autoloads nil nil ("standoff-mode-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; standoff-mode-autoloads.el ends here
