#import "../lib.typ": *

= The Complete Game

The full source of the game as it stands after Chapter 34. This is the reference version; the reader's own game may differ in details (item names, room descriptions, tests) but the structure is the one the book taught. Six files.

== `game.asd`

```lisp
;;;; game.asd
(asdf:defsystem "cave-of-noise"
  :description "A small text adventure"
  :version "1.0"
  :author "You"
  :license "MIT"
  :serial t
  :depends-on ()
  :components ((:file "packages")
               (:file "classes")
               (:file "data")
               (:file "persistence")
               (:file "commands")
               (:file "main")))

(asdf:defsystem "cave-of-noise/tests"
  :depends-on ("cave-of-noise")
  :components ((:file "tests"))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (let ((results (cave-of-noise/tests::run-tests)))
               (unless (every #'cdr results)
                 (error "Test suite failed: ~{~A~^, ~}"
                        (remove-if #'cdr results))))))
```

== `packages.lisp`

```lisp
;;;; packages.lisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :cave-of-noise)
    (defpackage :cave-of-noise
      (:use :cl)
      (:shadow #:room)
      (:nicknames #:con)
      (:export :play
               :run-command
               :look :take :drop :inventory :examine
               :save-game :load-game
               :*version*))))

(in-package :cave-of-noise)
```

== `classes.lisp`

```lisp
;;;; classes.lisp
(in-package :cave-of-noise)

(defstruct (room (:print-function print-room))
  name
  description
  exits
  (locked nil)
  (items nil))

(defun print-room (room stream depth)
  (declare (ignore depth))
  (format stream "<room ~(~A~)>" (room-name room)))

(defclass thing ()
  ((name :initarg :name :reader thing-name)
   (description :initarg :description
                :reader thing-description
                :initform "an ordinary thing"))
  (:documentation "Something the player can carry or examine."))

(defclass container (thing)
  ((contents :initarg :contents
             :accessor contents
             :initform nil)))

(defclass treasure (thing)
  ((value :initarg :value
          :reader value
          :initform 1)))

(defgeneric describe-thing (thing)
  (:documentation "Return a sentence describing THING."))

(defmethod describe-thing ((t2 thing))
  (format nil "You see ~(~A~): ~A."
          (thing-name t2) (thing-description t2)))

(defmethod describe-thing ((c container))
  (format nil "You see ~(~A~): ~A It holds ~{~(~A~)~^, ~}."
          (thing-name c) (thing-description c) (contents c)))

(defmethod describe-thing ((tr treasure))
  (format nil "You see ~(~A~): ~A It's worth ~D coins."
          (thing-name tr) (thing-description tr) (value tr)))

(defmethod initialize-instance :after ((c container) &key)
  (unless (listp (contents c))
    (setf (contents c) (list (contents c)))))

(defgeneric price (thing)
  (:method-combination +)
  (:documentation "How valuable is THING, summing contributions?"))

(defmethod price + ((t2 thing)) 1)
(defmethod price + ((c container)) 2)
(defmethod price + ((tr treasure)) (value tr))
```

== `data.lisp`

```lisp
;;;; data.lisp
(in-package :cave-of-noise)

(defparameter *version* "1.0")

(defparameter *rooms*
  (list
   (make-room :name 'bedroom
              :description "A small bedroom with an unmade bed."
              :exits '(hallway))
   (make-room :name 'hallway
              :description "A narrow hallway with creaky floorboards."
              :exits '(bedroom kitchen))
   (make-room :name 'kitchen
              :description "A warm kitchen that smells of bread."
              :exits '(hallway garden cellar))
   (make-room :name 'garden
              :description "An overgrown garden."
              :exits '(kitchen)
              :locked t)
   (make-room :name 'cellar
              :description "A damp cellar. Something drips in the dark."
              :exits '(kitchen))))

(defparameter *current-room* nil)

(defparameter *item-locations*
  '((lamp . cellar)
    (key . kitchen)
    (letter . bedroom)))

(defparameter *thing-registry* (make-hash-table :test #'eq))

(defun find-room (name)
  (find name *rooms* :key #'room-name))

(defun lookup-thing (sym)
  (gethash sym *thing-registry*))

(defun register-thing (sym instance)
  (setf (gethash sym *thing-registry*) instance))

(register-thing 'key (make-instance 'thing
                                    :name 'key
                                    :description "a small brass key"))
(register-thing 'lamp (make-instance 'thing
                                     :name 'lamp
                                     :description "an oil lamp"))
(register-thing 'letter (make-instance 'thing
                                       :name 'letter
                                       :description "a folded letter"))
(register-thing 'chest (make-instance 'container
                                      :name 'chest
                                      :description "a wooden chest."
                                      :contents '(crown gem)))
(register-thing 'crown (make-instance 'treasure
                                      :name 'crown
                                      :description "a tarnished crown."
                                      :value 100))

(defun make-history ()
  "Bounded undo history."
  (let ((snapshots nil)
        (limit 20))
    (lambda (message &optional arg)
      (ecase message
        (:add (push arg snapshots)
              (when (> (length snapshots) limit)
                (setf snapshots (subseq snapshots 0 limit)))
              t)
        (:recent (subseq snapshots 0 (min (or arg limit)
                                          (length snapshots))))
        (:undo-to (when snapshots
                    (let ((s (first snapshots)))
                      (pop snapshots) s)))
        (:clear (setf snapshots nil) t)))))

(defparameter *history* (make-history))

(defun snapshot ()
  (funcall *history* :add (copy-alist *item-locations*)))

(defun undo ()
  (let ((s (funcall *history* :undo-to)))
    (if s
        (progn (setf *item-locations* s) "Undone.")
        "Nothing to undo.")))

(defun set-location (pairs item place)
  (mapcar (lambda (pair)
            (if (eq (car pair) item)
                (cons item place)
                pair))
          pairs))

(defun item-location (item)
  (cdr (assoc item *item-locations*)))

(defun item-name (item)
  (string-downcase (symbol-name item)))

(defun items-here (place)
  (mapcar #'car
          (remove-if-not (lambda (p) (eq (cdr p) place))
                         *item-locations*)))

(defun item-names (items)
  (cond ((null items) "")
        ((null (cdr items)) (item-name (first items)))
        ((null (cddr items))
         (format nil "~A and ~A"
                 (item-name (first items))
                 (item-name (second items))))
        (t (format nil "~A, ~A"
                   (item-name (first items))
                   (item-names (rest items))))))

(defun item-list-string (items)
  (format nil "~{~(~A~)~^, ~}" (mapcar #'symbol-name items)))

(defparameter *game-output* t)

(defun say (control &rest args)
  (apply #'format *game-output* control args))

(defun sayln (control &rest args)
  (apply #'format *game-output*
         (concatenate 'string control "~%") args))
```

== `commands.lisp`

```lisp
;;;; commands.lisp
(in-package :cave-of-noise)

(defun describe-room-text (room)
  (let ((here (items-here (room-name room))))
    (if (null here)
        (format nil "You are in the ~(~A~). ~A"
                (room-name room) (room-description room))
        (format nil "You are in the ~(~A~). ~A You can see: ~A."
                (room-name room) (room-description room)
                (item-names here)))))

(defun look (&optional (place *current-room*))
  (describe-room-text place))

(defun take (item)
  (cond ((eq (item-location item) 'player)
         (format nil "You already have the ~(~A~)." item))
        ((eq (item-location item) (room-name *current-room*))
         (snapshot)
         (setf *item-locations*
               (set-location *item-locations* item 'player))
         (format nil "You take the ~(~A~)." item))
        (t "You don't see that here.")))

(defun drop (item)
  (if (eq (item-location item) 'player)
      (progn
        (snapshot)
        (setf *item-locations*
              (set-location *item-locations* item
                            (room-name *current-room*)))
        (format nil "You drop the ~(~A~)." item))
      "You don't have that."))

(defun inventory ()
  (let ((carried (sort (items-here 'player)
                       #'string< :key #'symbol-name)))
    (if (null carried)
        "You are carrying nothing."
        (format nil "You are carrying: ~A." (item-names carried)))))

(defun loot ()
  (let ((found (items-here (room-name *current-room*))))
    (if (null found)
        "There is nothing here to take."
        (progn
          (dolist (item found)
            (take item))
          (format nil "You take ~A." (item-names found))))))

(defun examine (sym)
  (let ((instance (lookup-thing sym)))
    (if instance
        (describe-thing instance)
        (format nil "You see nothing special about the ~(~A~)."
                sym))))

(defun go-to (name)
  (cond ((eq name (room-name *current-room*))
         "You are already there.")
        ((not (member name (room-exits *current-room*)))
         "You can't go there from here.")
        ((null (find-room name))
         (warn 'simple-warning
               :format-control "Exit to nonexistent room ~(~A~)"
               :format-arguments (list name))
         "You can't go there from here.")
        ((room-locked (find-room name))
         (format nil "The ~(~A~) is locked." name))
        (t (setf *current-room* (find-room name))
           (look))))

(defparameter *commands*
  (list (cons 'look #'look)
        (cons 'take #'take)
        (cons 'drop #'drop)
        (cons 'inventory #'inventory)
        (cons 'loot #'loot)
        (cons 'examine #'examine)
        (cons 'go #'go-to)
        (cons 'undo #'undo)
        (cons 'save #'cmd-save)
        (cons 'load #'cmd-load))
  "Command table.")

(defun call-command (command)
  (let ((entry (assoc (first command) *commands*)))
    (if (null entry)
        (values (format nil "No such command: ~(~A~)."
                        (first command))
                nil)
        (values (apply (cdr entry) (rest command))
                t))))

(defun run-command (command)
  (restart-case
      (handler-case (call-command command)
        (program-error ()
          (values "Wrong number of arguments for that command." t)))
    (retry-with (fixed)
      :report "Run a corrected command instead."
      (run-command fixed))))

(defun play ()
  "Start the game.  Reads s-expression commands from *standard-input*."
  (unless *current-room*
    (setf *current-room* (find-room 'kitchen)))
  (loop
    (format t "~&> ")
    (finish-output)
    (let ((input (read)))
      (when (eq (first input) 'quit)
        (format t "Goodbye.~%")
        (return))
      (multiple-value-bind (reply known-p)
          (run-command input)
        (declare (ignore known-p))
        (format t "~A~%" reply)))))
```

== `persistence.lisp`

```lisp
;;;; persistence.lisp
(in-package :cave-of-noise)

(defparameter *save-file* "/tmp/game-save.lisp")
(defparameter *save-format* 1)

(defun game-state ()
  (list *item-locations*
        (room-name *current-room*)
        (funcall *history* :recent)))

(defun restore-state (state)
  (setf *item-locations* (first state))
  (setf *current-room* (find-room (second state)))
  (let ((h *history*))
    (funcall h :clear)
    (dolist (snap (nreverse (third state)))
      (funcall h :add snap))))

(defun save-game ()
  (handler-case
      (progn
        (with-open-file (out *save-file*
                             :direction :output
                             :if-exists :supersede)
          (with-standard-io-syntax
            (format out "cave-of-noise v~D~%" *save-format*)
            (print (game-state) out)))
        (values t *save-file*))
    (file-error (c) (values nil (princ-to-string c)))))

(defun load-game ()
  (handler-case
      (with-open-file (in *save-file*)
        (let ((header (read-line in)))
          (unless (search "cave-of-noise" header)
            (error "Not a save file: ~S" header))
          (values (with-standard-io-syntax (read in)) t)))
    (file-error () (values nil nil))
    (end-of-file () (values nil nil))
    (error () (values nil nil))))

(defun cmd-save ()
  (multiple-value-bind (ok path-or-err) (save-game)
    (if ok
        (format nil "Saved to ~A." path-or-err)
        (format nil "Could not save: ~A" path-or-err))))

(defun cmd-load ()
  (multiple-value-bind (state loaded-p) (load-game)
    (if loaded-p
        (progn (restore-state state) (look))
        "No saved game found.")))
```

== `main.lisp`

```lisp
;;;; main.lisp
(in-package :cave-of-noise)

(defun main ()
  "Entry point for the deployed executable."
  (handler-case
      (let ((args (rest sb-ext:*posix-argv*)))
        (cond ((member "--help" args :test #'string=)
               (format t "Usage: game [--help] [--version]~%")
               (sb-ext:exit :code 0))
              ((member "--version" args :test #'string=)
               (format t "Cave of Noise, version ~A~%" *version*)
               (sb-ext:exit :code 0))
              (t nil)))
      (multiple-value-bind (state loaded-p) (load-game)
        (if loaded-p
            (restore-state state)
            (progn
              (setf *current-room* (find-room 'kitchen))
              (setf *item-locations*
                    '((lamp . cellar) (key . kitchen) (letter . bedroom)))
              (setf *history* (make-history)))))
      (play)
      (save-game)
      (sb-ext:exit :code 0)
    (error (c)
      (format *error-output* "cave: ~A~%" c)
      (sb-ext:exit :code 1))))
```

== `tests.lisp`

```lisp
;;;; tests.lisp
(defpackage :cave-of-noise/tests
  (:use :cl :cave-of-noise)
  (:import-from :cave-of-noise
                ;; state the tests read and rebind
                #:*item-locations* #:*current-room* #:*history*
                #:*save-file* #:*game-output*
                ;; functions and classes they call
                #:find-room #:item-location #:register-thing
                #:describe-thing #:make-history #:save-game
                #:load-game #:restore-state #:price #:treasure #:thing
                ;; command and data symbols: identity matters
                #:undo #:key #:kitchen #:player)
  (:export :run-tests))

(in-package :cave-of-noise/tests)

(defun run-tests ()
  (let ((results nil))
    (flet ((check (name got want)
             (push (cons name (equal got want)) results)))
      (check "take-moves-item"
             (progn
               (setf *item-locations* '((key . kitchen)))
               (setf *current-room* (find-room 'kitchen))
               (cave-of-noise::take 'key)
               (cave-of-noise::item-location 'key))
             'player)
      (check "inventory-alphabetical"
             (progn
               (setf *item-locations*
                     '((zebra . player) (apple . player)))
               (not (null (search "apple and zebra"
                                  (string-downcase
                                   (inventory))))))
             t))
    (nreverse results)))
```

That's the reference game. The chapters' individual project steps build it piece by piece; this is what they add up to. The reader's version may differ in room descriptions, item list, test set, and history limits — that's expected. The structure is what matters.

