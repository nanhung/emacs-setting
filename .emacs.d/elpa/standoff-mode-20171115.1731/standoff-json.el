;;; standoff-json.el --- functions and variables common to json backends.

;;; Commentary:


;;; Code:

(require 'cl-lib)
(require 'json)
(require 'standoff-api)
(require 'standoff-util)

(defun standoff-json/creation-meta-to-json (&optional created-at created-by)
  "Serialize creation meta data to json.
Use CREATED-AT or the current time for creation time.  Use
CREATED-BY or the return value of `standoff-util/user-name' for
creator."
  (let ((timestamp (or created-at (current-time)))
	(creator (or created-by (standoff-util/user-name))))
    (concat
     ", \"createdAt\": \"" (format-time-string "%FT%TZ" timestamp) "\""
     ", \"createdBy\": \"" creator "\"")))

;;; Markup

(defun standoff-json/range-to-json (elem-id range-id typ start end)
  "Serialize a markup range to json.
The range is given by ELEM-ID, RANGE-ID, TYP, START and END
offset."
  (concat
   "{\"tag\": \"MarkupRange\""
   ", \"markupElementId\": \"" elem-id "\""
   ", \"markupRangeId\": \"" range-id "\""
   ", \"qualifiedName\": \"" typ "\""
   ", \"sourceStart\": \"" (number-to-string start) "\""
   ", \"sourceEnd\": \"" (number-to-string end) "\""
   (standoff-json/creation-meta-to-json)
   "}"))

(defun standoff-json/range-plist-to-internal (range)
  "Convert a plist RANGE to a list representing a markup range.
Return a the range as a list like described in api."
  ;; FIXME: add some more? add markupRangeId!!
  (list
   ;; see api for order
   (plist-get range :markupElementId)
   (plist-get range :qualifiedName)
   (string-to-number (plist-get range :sourceStart))
   (string-to-number (plist-get range :sourceEnd))
   ))

(defun standoff-json/filter-markup (ranges &optional startchar endchar markup-type markup-inst-id markup-range-id)
  "Filter markup RANGES given as list of plists.
Filter markup between STARTCHAR and ENDCHAR or nil.  Filter for
MARKUP-TYPE or nil.  Filter for MARKUP-INST-ID or nil.  Filter
for MARKUP-RANGE-ID or nil.  RANGES has to be a list of plists."
  (unless (or (and startchar endchar) (and (null startchar) (null endchar)))
    (error "Use both offsets or none"))
  (cl-remove-if-not			; filter
   #'(lambda (r)
       (let ((start (string-to-number (plist-get r :sourceStart)))
	     (end (string-to-number (plist-get r :sourceEnd)))
	     (elem-id (plist-get r :markupElementId))
	     (range-id (plist-get r :markupRangeId))
	     (typ (plist-get r :qualifiedName)))
	 ;; condition
	 (and (or (and (not startchar) (not endchar))
		  (or (and (<= start startchar)
			   (>= end startchar))
		      (and (>= start startchar)
			   (<= end endchar))
		      (and (<= start endchar)
			   (>= end endchar))))
	      (or (not markup-type)
		  (equal typ markup-type))
	      (or (not markup-inst-id)
		  (equal elem-id markup-inst-id))
	      (or (not markup-range-id)
		  (equal range-id markup-range-id)))))
   ranges))

;;;; Relations

(defun standoff-json/relation-to-json (relation-id subject-id predicate object-id)
  "Serialize a relation to json.
The relation is given by RELATION-ID, SUBJECT-ID, PREDICATE and
OBJECT-ID."
  (concat
   "{\"tag\": \"Relation\""
   ", \"relationId\": \"" relation-id "\""
   ", \"subjectId\": \"" subject-id "\""
   ", \"predicate\": \"" predicate "\""
   ", \"objectId\": \"" object-id "\""
   (standoff-json/creation-meta-to-json)
   "}"))

(defun standoff-json/relation-plist-to-internal (relation)
  "Convert a plist RELATION to a list representing a relation.
Return a the relation as a list like described in api."
  ;; FIXME: add some more?
  (list
   ;; see api for order
   (plist-get relation :relationId)
   (plist-get relation :subjectId)
   (plist-get relation :predicate)
   (plist-get relation :objectId)
   ))

(defun standoff-json/filter-relations (relations &optional subject-id predicate object-id relation-id)
  "Filter RELATIONS given as list of plists.
Filter predicates are SUBJECT-ID, PREDICATE, OBJECT-ID and
RELATION-ID."
  (cl-remove-if-not			; filter
   #'(lambda (r)
       (let ((rel-id (plist-get r :relationId)) ; FIXME: do not hardcode
	     (sub (plist-get r :subjectId))
	     (pred (plist-get r :predicate))
	     (obj (plist-get r :objectId)))
	 ;; condition
	 (and (or (not relation-id)
		  (equal rel-id relation-id))
	      (or (not subject-id)
		  (equal sub subject-id))
	      (or (not predicate)
		  (equal pred predicate))
	      (or (not object-id)
		  (equal obj object-id)))))
   relations))

;;;; Literals

(defun standoff-json/literal-to-json (literal-id subject-id key value)
  "Serialize a relation to json.
The relation is given by LITERAL-ID, SUBJECT-ID, KEY and VALUE."
  (concat
   "{\"tag\": \"Literal\""
   ", \"literalId\": \"" literal-id "\""
   ", \"subjectId\": \"" subject-id "\""
   ", \"key\": \"" key "\""
   ", \"value\": \"" value "\""
   (standoff-json/creation-meta-to-json)
   "}"))

(defun standoff-json/literal-plist-to-internal (literal)
  "Convert a plist LITERAL attribute to a list representing a relation.
Return a the relation as a list like described in api."
  ;; FIXME: add some more?
  (list
   ;; see api for order
   (plist-get literal :literalId)
   (plist-get literal :subjectId)
   (plist-get literal :key)
   (plist-get literal :value)
   ))

(defun standoff-json/filter-literals (literals &optional subject-id key value value-regex literal-id)
  "Filter LITERALS given as list of plists.
Filter predicates are SUBJECT-ID, KEY, VALUE, VALUE-REGEX and
LITERAL-ID."
  (cl-remove-if-not			; filter
   #'(lambda (r)
       (let ((rel-id (plist-get r :literalId)) ; FIXME: do not hardcode
	     (sub (plist-get r :subjectId))
	     (lky (plist-get r :key))
	     (val (plist-get r :value)))
	 ;; condition
	 (and (or (not literal-id)
		  (equal rel-id literal-id))
	      (or (not subject-id)
		  (equal sub subject-id))
	      (or (not key)
		  (equal lky key))
	      (or (not value)
		  (equal val value))
	      (or (not value-regex)
		  (string-match value-regex val)))))
   literals))


(provide 'standoff-json)

;;; standoff-json.el ends here
