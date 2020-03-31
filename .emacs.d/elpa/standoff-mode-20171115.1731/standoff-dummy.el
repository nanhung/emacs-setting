;;; standoff-dummy.el --- a reference implementation of the API for standoff-mode back-ends

;; Copyright (C) 2015 Christian Lueck

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with standoff-mode. If not, see
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A simple back-end for stand-off mode. Markup is stored in elisp und
;; can be dumped to and loaded from a file.

;; This is a reference implementation of the API for back-ends defined
;; in standoff-api.el

;; To use this, make it load after standoff-mode is loaded:

;; (eval-after-load 'standoff-mode (require 'standoff-dummy))

;;; Code:

(require 'standoff-api)
(require 'standoff-util)

;;;; IDs

(defun standoff-dummy-create-intid (data pos)
  "Create and return an integer ID for the next item in dummy backend.
The item's list is given by DATA and should be
`standoff-dummy-markup', `standoff-dummy-relations' or the like,
and POS gives the position (column) of the ID in the lists, data
is composed of.  E.g. `standoff-pos-markup-inst-id' is the POS of
the ids in standoff-dummy-markup."
  (if data
      (+ (apply 'max (mapcar #'(lambda (x) (nth pos x)) data)) 1)
    1))

(defcustom standoff-dummy-create-id-function 'standoff-util/create-uuid
  "The function for creating IDs used in the dummy backend."
  :group 'standoff-dummy
  :type 'function)

;;;; Markup

(defvar standoff-dummy-markup '()
  "The markup elements and ranges stored in the backend.")

(make-variable-buffer-local 'standoff-dummy-markup)

(defcustom standoff-dummy-user-logging t
  "Whether or not to log time and user information when creating markup.
You can keep out big brother by setting this to nil."
  :group 'standoff-dummy
  :type 'boolean)

(defun standoff-dummy-create-markup (buf startchar endchar markup-type)
  "Create a markup element and store it in dummy backend.
The markup element is of type MARKUP-TYPE, ranging from STARTCHAR
to ENDCHAR in the context of buffer BUF. The id of that markup
element is generated by the function given in the customizable
variable `standoff-dummy-create-id-function'."
  (with-current-buffer buf
    (let ((markup-inst-id (funcall standoff-dummy-create-id-function
				   standoff-dummy-markup
				   standoff-pos-markup-inst-id)))
      (setq standoff-dummy-markup
	    (cons (list markup-inst-id markup-type startchar endchar (buffer-substring-no-properties startchar endchar)
			(and standoff-dummy-user-logging (current-time))
			(and standoff-dummy-user-logging (user-full-name)))
		  standoff-dummy-markup))
      markup-inst-id)))

(defun standoff-dummy-add-range (buf startchar endchar markup-inst-id)
  "Add the range (interval) to an existing markup element.
The interval ranges from STARTCHAR to ENDCHAR, the markup
element, which is added to, is given by MARKUP-INST-ID in the
context of buffer BUF. This function aktually stores this range
to the dummy backend's variable `standoff-dummy-markup' yust as
`standoff-dummy-create-markup' but with an existing
MARKUP-INST-ID instead of an new one. The markup type is
determined from the backend."
  (with-current-buffer buf
    (let ((markup-type (standoff-dummy-markup-get-type-by-inst-id buf markup-inst-id)))
      (unless markup-type
	(error "Invalid ID. No markup type found"))
      (setq standoff-dummy-markup
	    (cons (list markup-inst-id markup-type startchar endchar (buffer-substring-no-properties startchar endchar))
		  standoff-dummy-markup))
      markup-inst-id)))

(defun standoff-dummy-markup-get-type-by-inst-id (buf markup-inst-id)
  "Return the markup type for the markup element.
The markup element is given by MARKUP-INST-ID in the context of
buffer BUF."
  (with-current-buffer buf
    (let ((markup-data standoff-dummy-markup)
	  (markup-inst nil)
	  (markup-type nil))
      (while markup-data
	(setq markup-inst (pop markup-data))
	(if (equal markup-inst-id (nth standoff-pos-markup-inst-id markup-inst))
	    (setq markup-type (nth standoff-pos-markup-type markup-inst)
		  markup-data nil)))
      markup-type)))

(defun standoff-dummy-read-markup (buf &optional startchar endchar markup-type markup-inst-id)
  "Return the markup for buffer BUF stored in the dummy backend.
A filter given by STARTCHAR ENDCHAR MARKUP-TYPE MARKUP-INST-ID is
applied to the result."
  (with-current-buffer buf
    (let ((backend standoff-dummy-markup)
	  (ranges-to-return '())
	  (range))
      (or (and (not startchar) (not endchar))
	  (and startchar endchar)
	  (error "Either give startchar *and* endchar or neither of them"))
      (while backend
	(setq range (pop backend))
	;; when COND
	(and (or (and (not startchar) (not endchar))
		 (or (and (<= (nth standoff-pos-startchar range) startchar)
			  (>= (nth standoff-pos-endchar range) startchar))
		     (and (>= (nth standoff-pos-startchar range) startchar)
			  (<= (nth standoff-pos-endchar range) endchar))
		     (and (<= (nth standoff-pos-startchar range) endchar)
			  (>= (nth standoff-pos-endchar range) endchar))))
	     (or (not markup-type)
		 (equal (nth standoff-pos-markup-type range) markup-type))
	     (or (not markup-inst-id)
		 (equal (nth standoff-pos-markup-inst-id range) markup-inst-id))
	     ;; BODY
	     (setq ranges-to-return (cons range ranges-to-return))))
      ranges-to-return)))

(defun standoff-dummy-delete-range (buf startchar endchar markup-type markup-inst-id)
  "Delete a markup range or element respectively  from the dummy backend.
It is identified by STARTCHAR, ENDCHAR, MARKUP-TYPE and
MARKUP-INST-ID in context of buffer BUF."
  (with-current-buffer buf
    (let ((old-markup standoff-dummy-markup) ;; make error tolerant
	  (old-length (length standoff-dummy-markup))
	  (new-markup '())
	  (range)
	  (deleted nil))
      (while old-markup
	(setq range (car old-markup))
	(if (and (equal (nth standoff-pos-markup-inst-id range) markup-inst-id)
		 (equal (nth standoff-pos-markup-type range) markup-type)
		 (equal (nth standoff-pos-startchar range) startchar)
		 (equal (nth standoff-pos-endchar range) endchar))
	    (setq deleted t)
	  (setq new-markup (cons range new-markup)))
	(setq old-markup (cdr old-markup)))
      (when deleted
	(setq standoff-dummy-markup new-markup))
      deleted)))

(defun standoff-dummy-markup-types (buf)
  "Return a list of the types of markup used in buffer BUF."
  (with-current-buffer buf
    (let ((markup standoff-dummy-markup)
	  (typel)
	  (used-types '()))
      (while markup
	(setq typel (nth standoff-pos-markup-type (pop markup)))
	(unless (member typel used-types)
	  (setq used-types (cons typel used-types))))
      used-types)))

;;;; Relations

(defvar standoff-dummy-relations '()
  "The relations stored in the backend.
See `standoff-pos-subject' etc. for structure of this list.")

(make-variable-buffer-local 'standoff-dummy-relations)

(defun standoff-dummy-used-predicates (buf subj-id obj-id)
  "Returns a list of predicates used for similar subject/object combinations.
The subject and object are given by id, SUBJ-ID and OBJ-ID
respectively which are interpreted in the context of buffer
BUF. Similarity here means equivalence of the subject's and
object's markup type respectivly."
  (with-current-buffer buf
    (let ((subj-type (standoff-dummy-markup-get-type-by-inst-id buf subj-id))
	  (obj-type (standoff-dummy-markup-get-type-by-inst-id buf obj-id))
	  (relations standoff-dummy-relations)
	  (relation)
	  (subj)
	  (obj)
	  (predicate)
	  (predicates '()))
      (while relations
	(setq relation (pop relations)
	      subj (nth standoff-pos-subject relation)
	      predicate (nth standoff-pos-predicate relation)
	      obj (nth standoff-pos-object relation))
	;; when COND
	(and (equal (standoff-dummy-markup-get-type-by-inst-id buf subj) subj-type)
	     (equal (standoff-dummy-markup-get-type-by-inst-id buf obj) obj-type)
	     (not (member predicate predicates))
	     ;; BODY
	     (setq predicates (cons predicate predicates))))
      predicates)))

(defun standoff-dummy-create-relation (buf subj-id predicate obj-id)
  "Create a 3-tier directed graph in the dummy backend.
The graph represents a relation between two markup elements with
the markup given by SUBJ-ID as subject, the predicate given by
PREDICATE and the markup given by OBJ-ID as object. The buffer
with the markup must be given by BUF. Returns the id of of the
relation created."
  (with-current-buffer buf
    (let ((relation-id (funcall standoff-dummy-create-id-function
				standoff-dummy-relations
				standoff-pos-relation-id)))
      (setq standoff-dummy-relations
	    (cons (list relation-id subj-id predicate obj-id
			(and standoff-dummy-user-logging (current-time))
			(and standoff-dummy-user-logging (user-full-name)))
			standoff-dummy-relations))
      relation-id)))

(defun standoff-dummy-read-relations (buf &optional subj-id predicate obj-id)
  "Returns a list with the relations in buffer BUF.
A filter defining a combination of subject given by SUBJ-ID,
PREDICATE and object given by OBJ-ID is applied to the results. A
value of `nil' in either of those three positions will be treated
as a wildcard."
  (with-current-buffer buf
    (let ((data standoff-dummy-relations)
	  (relations '())
	  (relation))
      (while data
	(setq relation (pop data))
	(and (or (not subj-id)
		 (equal subj-id (nth standoff-pos-subject relation)))
	     (or (not predicate)
		 (equal predicate (nth standoff-pos-predicate relation)))
	     (or (not obj-id)
		 (equal obj-id (nth standoff-pos-object relation)))
	     (setq relations (cons relation relations))))
      relations)))

(defun standoff-dummy-delete-relation (buf subj-id predicate obj-id &optional rel-id)
  "Delete a relation from the dummy backend.
The relation is given by SUBJ-ID, PREDICATE and OBJ-ID in the
context of buffer BUF. All duplicates of this relations are
removed."
  (with-current-buffer buf
    (let ((data standoff-dummy-relations)
	  (new-relations '())
	  (relation))
      (while data
	(setq relation (pop data))
	(when (or
	       (and rel-id		; rel-id given, only check id
		    (equal rel-id (nth standoff-pos-relation-id relation)))
	       (not (and (equal (nth standoff-pos-subject relation) subj-id)
			(equal (nth standoff-pos-predicate relation) predicate)
			(equal (nth standoff-pos-object relation) obj-id))))
	  (setq new-relations (cons relation new-relations))))
      (setq standoff-dummy-relations new-relations))))

;;;; Literals

(defvar standoff-dummy-literals '()
  "Literals stored in the dummy backend.")

(make-variable-buffer-local 'standoff-dummy-literals)

(defun standoff-dummy-create-literal (buf subj-id key val &optional typ other-typ)
  "Creates a literal and stores it to the dummy backend.
The subject SUBJ-ID in the source document present in buffer BUF
is assigned an attribute with a key/value pair given by KEY and
VAL. An optional type can be given by TYP and OTHER-TYP for
external applications respectively."
  (let ((literal-id (funcall standoff-dummy-create-id-function
			     standoff-dummy-literals
			     standoff-pos-literal-id)))
    (with-current-buffer buf
      (setq standoff-dummy-literals
	    (cons (list literal-id subj-id key val (or typ 'string) other-typ
			(and standoff-dummy-user-logging (current-time))
			(and standoff-dummy-user-logging (user-full-name)))
		  standoff-dummy-literals)))))

(defun standoff-dummy-read-literals (buf &optional subj-id key val val-re)
  "Returns the literals for the source document in buffer BUF.
  A filter is applied for literals matching subject SUBJ-ID, KEY
  and VAL or/and the regular expression VAL-RE."
  (with-current-buffer buf
    (let ((data standoff-dummy-literals)
	  (matches '())
	  (literal))
      (while data
	(setq literal (pop data))
	(and (or (not subj-id)
		 (equal (nth standoff-pos-literal-subject literal) subj-id))
	     (or (not key)
		 (equal (nth standoff-pos-literal-key literal) key))
	     (or (not val)
		 (equal (nth standoff-pos-literal-value literal) val))
	     (or (not val-re)
		 (string-match val-re (nth standoff-pos-literal-value literal)))
	     (push literal matches)))
      matches)))

(defun standoff-dummy-delete-literal (buf literal-id)
  "Delete literal given by LITERAL-ID.
The source document is given in buffer BUF."
  (with-current-buffer buf
    (let ((data standoff-dummy-literals)
	  (new-data '())
	  (literal))
      (while data
	(setq literal (pop data))
	(unless (equal (nth standoff-pos-literal-id literal) literal-id)
	  (push literal new-data)))
      (setq standoff-dummy-literals new-data))))

(defun standoff-dummy-literal-keys-used (buf &optional subj-id)
  "Returns a list of literal keys used for subjects similar to the one given by SUBJ-ID."
  (with-current-buffer buf
    (let ((subj-type (standoff-dummy-markup-get-type-by-inst-id buf subj-id))
	  (literals standoff-dummy-literals)
	  (literal)
	  (subj)
	  (key)
	  (keys '()))
      (while literals
	(setq literal (pop literals)
	      subj (nth standoff-pos-literal-subject literal)
	      key (nth standoff-pos-literal-key literal))
	;; when COND
	(and (equal (standoff-dummy-markup-get-type-by-inst-id buf subj) subj-type)
	     (not (member key keys))
	     ;; BODY
	     (setq keys (cons key keys))))
      keys)))

;;;; setup, reset and load back-end

(defun standoff-dummy-backend-reset ()
  "Reset the dummy backend.
It may be usefull during development to make this an interactive
function."
  (interactive)
  (when (yes-or-no-p "Do you really want to reset this buffer, which means that all markup information will be lost?")
    (standoff-dummy--backend-reset)))

(defun standoff-dummy--backend-reset ()
  "Reset the dummy backend."
  (setq-local standoff-dummy-markup '())
  (setq-local standoff-dummy-relations '())
  (setq-local standoff-dummy-literals '()))

(defcustom standoff-dummy-highlight-after-load t
  "Whether or not to highlight all markup in the buffer after loading from file."
  :group 'standoff-dummy
  :type 'boolean)

;; These variables are set when evaluating the dump file. In order to
;; silence the compiler we just define, but do not initialize them.
(defvar standoff-api-description-dumped)
(defvar standoff-source-md5-dumped)
(defvar standoff-markup-read-function-dumped)
(defvar standoff-relations-read-function-dumped)
(defvar standoff-literals-read-function-dumped)

(declare-function standoff-dump-filename-default "standoff-mode.el" nil)
(declare-function standoff-highlight-markup-buffer "standoff-mode.el" nil)

(defun standoff-dummy-evolve-make-value (buf item list-symbol cell dumped-api)
  "Make a value for the CELL in ITEM in the back-end's list LIST-SYMBOL.
ITEM follows the api generation DUMPED-API. Source document is
given in buffer BUF.

Right now we only need to make a non-nil value for the relation-id."
  (cond ((and (equal list-symbol :relations)
	      (equal cell :standoff-pos-relation-id))
	 (funcall standoff-dummy-create-id-function
		  standoff-dummy-relations
		  standoff-pos-relation-id))
	(t nil)))

(defun standoff-dummy-load-dumped (fname)
  "Load markup, relations etc. from a dumped file FNAME."
  (interactive
   (list (read-file-name "File to be loaded: "
			 nil
			 nil
			 'confirm
			 (file-relative-name (standoff-dump-filename-default)))))
  (let ((dumped-api))
    (require 'standoff-mode)
    ;; initialize dumped vars, because old values may be left over
    ;; after loading, if dump-file is incomplete
    ;; TODO: use standoff-dump-vars
    (setq standoff-api-description-dumped nil
	  standoff-source-md5-dumped nil
	  standoff-markup-read-function-dumped nil
	  standoff-relations-read-function-dumped nil
	  standoff-literals-read-function-dumped nil)
    (load fname)
    ;; checksum should not differ
    (unless (equal (md5 (current-buffer)) standoff-source-md5-dumped)
      (error "Did you edit the file? Checksum does not match. Not loading"))
    ;; get dumped api
    (setq dumped-api (or standoff-api-description-dumped
			 (cdr (assoc "first" standoff-api-generations))))
    (setq standoff-dummy-markup (standoff-api-evolve (current-buffer) :markup standoff-markup-read-function-dumped dumped-api)
	  standoff-dummy-relations (standoff-api-evolve (current-buffer) :relations standoff-relations-read-function-dumped dumped-api)
	  standoff-dummy-literals (standoff-api-evolve (current-buffer) :literals standoff-literals-read-function-dumped dumped-api))
    (message "File %s successfully loaded." fname)
    (when standoff-dummy-highlight-after-load
      (standoff-highlight-markup-buffer))))

(defun standoff-dummy-backend-setup ()
  "Setup the dummy backend. Called by mode hook."
  ;; reset and make buffer-local
  (standoff-dummy--backend-reset)
  ;; try to load from file
  (require 'standoff-mode)
  (when (file-readable-p (standoff-dump-filename-default))
    (standoff-dummy-load-dumped (standoff-dump-filename-default))))

(add-hook 'standoff-mode-hook 'standoff-dummy-backend-setup)

(defun standoff-dummy-backend-inspect ()
  "Display the dummy backend in the minibuffer.
This may be usefull for development."
  (interactive)
  (message "%s" (list standoff-dummy-markup
		      standoff-dummy-relations
		      standoff-dummy-literals)))

;;;; Registration / Set up

;; This actually restores the default values for handler function
;; variables defined in `standoff-dummy.el'.
(defun standoff-dummy-register-backend ()
  "Register the dummy backend.
See standoff-api.el for the functions."
  (setq
   ;; api evolution
   standoff-api-evolve-make-value-function 'standoff-dummy-evolve-make-value
   ;; markup
   standoff-markup-create-function 'standoff-dummy-create-markup
   standoff-markup-range-add-function 'standoff-dummy-add-range
   standoff-markup-read-function 'standoff-dummy-read-markup
   standoff-markup-delete-range-function 'standoff-dummy-delete-range
   standoff-markup-types-used-function 'standoff-dummy-markup-types
   ;; relations
   standoff-predicates-used-function 'standoff-dummy-used-predicates
   standoff-relation-create-function 'standoff-dummy-create-relation
   standoff-relations-read-function 'standoff-dummy-read-relations
   standoff-relations-delete-function 'standoff-dummy-delete-relation
   ;; literals
   standoff-literal-keys-used-function 'standoff-dummy-literal-keys-used
   standoff-literal-create-function 'standoff-dummy-create-literal
   standoff-literals-read-function 'standoff-dummy-read-literals
   standoff-literal-delete-function 'standoff-dummy-delete-literal
   ))

(add-hook 'standoff-mode-hook 'standoff-dummy-register-backend)

(provide 'standoff-dummy)

;;; standoff-dummy.el ends here