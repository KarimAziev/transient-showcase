;;; transient-showcase.el --- Transient features & behavior showcase -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Positron Solutions

;; Author: Psionik K <73710933+psionic-k@users.noreply.github.com>
;; Keywords: convenience
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (transient "0.3.7"))
;; Homepage: http://github.com/positron-solutions/transient-showcase
;; URL: https://github.com/positron-solutions/transient-showcase

;;; License notice:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is created from the README and serves as a fast way to load
;; all of the examples without tangling the org document.  This is appropriate
;; if you just want to quickly browse through the examples and see their
;; source code.
;;
;; M-x transient-showcase contains most of the prefixes and can be bound for
;; use as a quick reference.  Just use transient's help for each
;; command to see the source.  C-h <suffix key>.
;;

;;; Code:

(require 'transient)
(require 'org-id)


;;;###autoload
(defun transient-showcase-suffix-wave ()
  "Wave at the user."
  (interactive)
  (message "Waves at the user at: %s." (current-time-string)))


(defvar transient-showcase-busy nil
  "Flag indicating if transient showcase is currently active.")

(defun transient-showcase--busy-p ()
  "Check if `transient-showcase' is currently busy."transient-showcase-busy)

(transient-define-suffix transient-showcase--toggle-busy ()
  "Toggle busy."
  (interactive)
  (setf transient-showcase-busy (not transient-showcase-busy))
  (message (propertize (format "busy: %s" transient-showcase-busy)
                       'face 'success)))


;;;###autoload (autoload 'transient-showcase-suffix-show-level "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-show-level ()
  "Show the current transient's level."
  :transient t
  (interactive)
  (message "Current level: %s" (oref transient-current-prefix level)))


;; Because command names are used to store and lookup child levels, we have
;; define a macro to generate unqiquely named wavers.  See #153 at
;; https://github.com/magit/transient/issues/153
(defmacro transient-showcase--define-waver (name)
  "Define a new suffix with NAME transient-showcase--wave-NAME."
  `(transient-define-suffix ,(intern (format "transient-showcase--wave-%s" name)) ()
     ,(format "Wave at the user %s" name)
     :transient t
     (interactive)
     (message (format "Waves at %s" (current-time-string)))))

;; Each form results in a unique suffix definition.
(transient-showcase--define-waver "surely")
(transient-showcase--define-waver "normally")
(transient-showcase--define-waver "non-essentially")
(transient-showcase--define-waver "definitely")
(transient-showcase--define-waver "eventually")
(transient-showcase--define-waver "hidden")


;;;###autoload (autoload 'transient-showcase-suffix-print-args "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-print-args (the-prefix-arg)
  "Report the PREFIX-ARG, prefix's scope, and infix values."
  :transient 'transient--do-call
  (interactive "P")
  (let ((args (transient-args (oref transient-current-prefix command)))
        (scope (oref transient-current-prefix scope)))
    (message "prefix-arg: %s \nprefix's scope value: %s \ntransient-args: %s"
             the-prefix-arg scope args)))

;; transient-showcase-suffix-print-args command is incidentally created


(transient-define-prefix transient-showcase-hello ()
  "Prefix that is minimal and uses an anonymous command suffix."
  [("s" "call suffix"
    (lambda ()
      (interactive)
      (message "Called a suffix")))])

;; First, use M-x org-babel-execute-src-blk to cause `transient-showcase-hello' to be defined
;; Second, M-x `eval-last-sexp' with your point at the end of the line below
;; (transient-showcase-hello)

;;;###autoload (autoload 'transient-showcase-suffix-wave-macroed "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-wave-macroed ()
  "Prefix that waves with macro-defined suffix."
  :transient t
  :key "T"
  :description "wave from macro definition"
  (interactive)
  (message "Waves from a macro definition at: %s" (current-time-string)))

;; Suffix definition creates a command
;; (transient-showcase-suffix-wave-macroed)
;; Because that's where the suffix object is stored
;; (get 'transient-showcase-suffix-wave-macroed 'transient--suffix)

;; transient-showcase-suffix-wave-suffix defined above

;;;###autoload (autoload 'transient-showcase-wave-macro-defined "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-wave-macro-defined ()
  "Prefix to wave using a macro-defined suffix."
  [(transient-showcase-suffix-wave-macroed)]) ; note, information moved from prefix to the suffix.

;; (transient-showcase-wave-macro-defined)

(defun transient-showcase--wave-override ()
  "Vanilla command used to override suffix's commands."
  (interactive)
  (message "This suffix was overridden.  I am what remains."))

;;;###autoload (autoload 'transient-showcase-wave-overridden "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-wave-overridden ()
  "Prefix that waves with overridden suffix behavior."
  [(transient-showcase-suffix-wave-macroed
    :transient nil
    :key "O"
    :description "wave overridingly"
    :command transient-showcase--wave-override)]) ; we overrode what the suffix even does

;; (transient-showcase-wave-overridden)

;;;###autoload (autoload 'transient-showcase-layout-descriptions "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-descriptions ()
  "Prefix with descriptions specified with slots."
  ["Let's Give This Transient a Title\n" ; yes the newline works
   ["Group One"
    ("wo" "wave once" transient-showcase-suffix-wave)
    ("wa" "wave again" transient-showcase-suffix-wave)]

   ["Group Two"
    ("ws" "wave some" transient-showcase-suffix-wave)
    ("wb" "wave better" transient-showcase-suffix-wave)]]

  ["Bad title" :description "Group of Groups"
   ["Group Three"
    ("k" "bad desc" transient-showcase-suffix-wave :description "key-value wins")
    ("n" transient-showcase-suffix-wave :description "no desc necessary")]
   [:description "Key Only Def"
    ("wt" "wave too much" transient-showcase-suffix-wave)
    ("we" "wave excessively" transient-showcase-suffix-wave)]])

;; (transient-showcase-layout-descriptions)

;;;###autoload (autoload 'transient-showcase-layout-dynamic-descriptions "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-dynamic-descriptions ()
   "Prefix that generate descriptions dynamically when transient is shown."
   ;; group using function-name to generate description
   [:description current-time-string
    ("-s" "--switch" "switch=") ; switch just to cause updates
    ;; single suffix with dynamic description
    ("wa" transient-showcase-suffix-wave
     :description (lambda ()
                    (format "Wave at %s" (current-time-string))))]
   ;; group with anonymoous function generating description
   [:description (lambda ()
                   (format "Group %s" (org-id-new)))
                 ("wu" "wave uniquely" transient-showcase-suffix-wave)])

;; (transient-showcase-layout-dynamic-descriptions)

;;;###autoload (autoload 'transient-showcase-layout-stacked "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-stacked ()
  "Prefix with layout that stacks groups on top of each other."
  ["Top Group" ("wt" "wave top" transient-showcase-suffix-wave)]
  ["Bottom Group" ("wb" "wave bottom" transient-showcase-suffix-wave)])

;; (transient-showcase-layout-stacked)

;;;###autoload (autoload 'transient-showcase-layout-columns "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-columns ()
  "Prefix with side-by-side layout."
  [["Left Group" ("wl" "wave left" transient-showcase-suffix-wave)]
   ["Right Group" ("wr" "wave right" transient-showcase-suffix-wave)]])

;; (transient-showcase-layout-columns)

;;;###autoload (autoload 'transient-showcase-layout-stacked-columns "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-stacked-columns ()
  "Prefix with stacked columns layout."
  ["Top Group"
   ("wt" "wave top" transient-showcase-suffix-wave)]

  [["Left Group"
    ("wl" "wave left" transient-showcase-suffix-wave)]
   ["Right Group"
    ("wr" "wave right" transient-showcase-suffix-wave)]])

;; (transient-showcase-layout-stacked-columns)

;;;###autoload (autoload 'transient-showcase-layout-spaced-out "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-spaced-out ()
  "Prefix lots of spacing for users to space out at."
  ["" ; cannot add another empty string because it will mix suffixes with groups
   ["Left Group"
    ""
    ("wl" "wave left" transient-showcase-suffix-wave)
    ("L" "wave lefter" transient-showcase-suffix-wave)
    ""
    ("bl" "wave bottom-left" transient-showcase-suffix-wave)
    ("z" "zone\n" zone)] ; the newline does pad

   [[]] ; empty vector will do nothing

   [""] ; vector with just empty line has no effect

   ;; empty group will be ignored
   ;; (useful for hiding in dynamic layouts)
   ["Empty Group\n"]

   ["Right Group"
    ""
    ("wr" "wave right" transient-showcase-suffix-wave)
    ("R" "wave righter" transient-showcase-suffix-wave)
    ""
    ("br" "wave bottom-right" transient-showcase-suffix-wave)]])

;; (transient-showcase-layout-spaced-out)

;;;###autoload (autoload 'transient-showcase-layout-the-grid "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-the-grid ()
  "Prefix with groups in a grid-like arrangement."

  [:description "The Grid\n" ; must use slot or macro is confused
   ["Left Column" ; note, no newline
    ("ltt" "left top top" transient-showcase-suffix-wave)
    ("ltb" "left top bottom" transient-showcase-suffix-wave)
    ""
    ("lbt" "left bottom top" transient-showcase-suffix-wave)
    ("lbb" "left bottom bottom" transient-showcase-suffix-wave)] ; note, no newline

   ["Right Column\n"
    ("rtt" "right top top" transient-showcase-suffix-wave)
    ("rtb" "right top bottom" transient-showcase-suffix-wave)
    ""
    ("rbt" "right bottom top" transient-showcase-suffix-wave)
    ("rbb" "right bottom bottom\n" transient-showcase-suffix-wave)]])

;; (transient-showcase-layout-the-grid)

;;;###autoload (autoload 'transient-showcase-layout-explicit-classes "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-layout-explicit-classes ()
  "Prefix with group class used to explicitly specify layout."
  [:class transient-row "Row"
          ("l" "wave left" transient-showcase-suffix-wave)
          ("r" "wave right" transient-showcase-suffix-wave)]
  [:class transient-column "Column"
          ("t" "wave top" transient-showcase-suffix-wave)
          ("b" "wave bottom" transient-showcase-suffix-wave)])

;; (transient-showcase-layout-explicit-classes)

;;;###autoload (autoload 'transient-showcase-stay-transient "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-stay-transient ()
  "Prefix where some suffixes do not exit."
  ["Exit or Not?"

   ;; this suffix will not exit after calling sub-prefix
   ("we" "wave & exit" transient-showcase-wave-overridden)
   ("ws" "wave & stay" transient-showcase-wave :transient t)])

;; (transient-showcase-stay-transient)

(transient-define-prefix transient-showcase--simple-child ()
  ["Simple Child"
   ("wc" "wave childishly" transient-showcase-suffix-wave)])

;;;###autoload (autoload 'transient-showcase-simple-parent "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-simple-parent ()
  "Prefix that calls a child prefix."
  ["Simple Parent"
   ("w" "wave parentally" transient-showcase-suffix-wave)
   ("b" "become child" transient-showcase--simple-child)])

;; (transient-showcase--simple-child)
;; (transient-showcase-simple-parent)

;;;###autoload (autoload 'transient-showcase-simple-parent-with-return "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-simple-parent-with-return ()
  "Prefix with a child prefix that returns."
  ["Parent With Return"
   ("w" "wave parentally" transient-showcase-suffix-wave)
   ("b" "become child with return" transient-showcase--simple-child :transient t)])

;; Child does not "return" when called independently
;; (transient-showcase--simple-child)
;; (transient-showcase-simple-parent-with-return)

;;;###autoload (autoload 'transient-showcase-suffix-setup-child "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-setup-child ()
  "A suffix that uses `transient-setup' to manually load another transient."
  (interactive)
  ;; note that it's usually during the post-command side of calling the
  ;; command that the actual work to set up the transient will occur.
  ;; This is an implementation detail because it depends if we are calling
  ;; `transient-setup' while already transient or not.
  (transient-setup 'transient-showcase--simple-child))

;;;###autoload (autoload 'transient-showcase-parent-with-setup-suffix "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-parent-with-setup-suffix ()
  "Prefix with a suffix that calls `transient-setup'."
  ["Simple Parent"
   ("wp" "wave parentally" transient-showcase-suffix-wave :transient t) ; remain transient

   ;; You may need to specify a different pre-command (the :transient) key
   ;; because we need to clean up this transient or create some conditions
   ;; to trigger the following transient correctly.  This example will
   ;; work with `transient--do-replace' or no custom pre-command

   ("bc" "become child" transient-showcase-suffix-setup-child :transient transient--do-replace)])

;; (transient-showcase-parent-with-setup-suffix)

(transient-define-suffix transient-showcase--suffix-interactive-string (user-input)
  "An interactive suffix that obtains string input from the user."
  (interactive "sPlease just tell me what you want!: ")
  (message "I think you want: %s" user-input))

(transient-define-suffix transient-showcase--suffix-interactive-buffer-name (buffer-name)
  "An interactive suffix that obtains a buffer name from the user."
  (interactive "b")
  (message "You selected: %s" buffer-name))

;;;###autoload (autoload 'transient-showcase-interactive-basic "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-interactive-basic ()
  "Prefix with interactive user input."
  ["Interactive Command Suffixes"
   ("s" "enter string" transient-showcase--suffix-interactive-string)
   ("b" "select buffer" transient-showcase--suffix-interactive-buffer-name)])

;; (transient-showcase-interactive-basic)

(defvar transient-showcase--complex nil "Show complex menu or not.")

(transient-define-suffix transient-showcase--toggle-complex ()
  "Toggle `transient-showcase--complex'."
  :transient t
  :description (lambda () (format "toggle complex: %s" transient-showcase--complex))
  (interactive)
  (setf transient-showcase--complex (not transient-showcase--complex))
  (message (propertize (concat "Complexity set to: "
                               (if transient-showcase--complex "true" "false"))
                       'face 'success)))

;;;###autoload (autoload 'transient-showcase-complex-messager "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-complex-messager ()
  "Prefix that sends complex messages, unles `transient-showcase--complex' is nil."
  ["Send Complex Messages"
   ("s" "snow people"
    (lambda () (interactive)
      (message (propertize "snow people! ☃" 'face 'success))))
   ("k" "kitty cats"
    (lambda () (interactive)
      (message (propertize "🐈 kitty cats! 🐈" 'face 'success))))
   ("r" "radiations"
    (lambda () (interactive)
      (message (propertize "Oh no! radiation! ☢" 'face 'success)))
    ;; radiation is dangerous!
    :transient transient--do-exit)]

  (interactive)
  ;; The command body either sets up the transient or simply returns
  ;; This is the "early return" we're talking about.
  (if transient-showcase--complex
      (transient-setup 'transient-showcase-complex-messager)
    (message "Simple and boring!")))

;;;###autoload (autoload 'transient-showcase-simple-messager "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-simple-messager ()
  "Prefix that toggles child behavior!"
  [["Send Message"
    ;; using `transient--do-recurse' causes suffixes in transient-showcase-child to perform
    ;; `transient--do-return' so that we come back to this transient.
    ("m" "message" transient-showcase-complex-messager :transient transient--do-recurse)]
   ["Toggle Complexity"
    ("t" transient-showcase--toggle-complex)]])

;; (transient-showcase-simple-messager)
;; does not "return" when called independently
;; (transient-showcase-complex-messager)

;; infix defined with a macro
(transient-define-argument transient-showcase--exclusive-switches ()
  "This is a specialized infix for only selecting one of several values."
  :class 'transient-switches
  :argument-format "--%s-snowcone"
  :argument-regexp "\\(--\\(grape\\|orange\\|cherry\\|lime\\)-snowcone\\)"
  :choices '("grape" "orange" "cherry" "lime"))

;;;###autoload (autoload 'transient-showcase-basic-infixes "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-basic-infixes ()
  "Prefix that just shows off many typical infix types."
  ["Infixes"

   ;; from macro
   ("-e" "exclusive switches" transient-showcase--exclusive-switches)

   ;; shorthand definitions
   ("-b" "switch with shortarg" ("-w" "--switch-short")) ; with :short-arg != :key
   ("-s" "switch" "--switch")
   ( "n" "no dash switch" "still works")
   ("-a" "argument" "--argument=" :prompt "Let's argue because: ")

   ;; a bit of inline EIEIO in our shorthand
   ("-n" "never empty" "--non-null=" :always-read t  :allow-empty nil
    :init-value (lambda (obj) (oset obj value "better-than-nothing")))

   ("-c" "choices" "--choice=" :choices (foo bar baz))]

  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-basic-infixes)

(transient-define-suffix transient-showcase--read-prefix-scope ()
  "Read the scope of the prefix."
  :transient 'transient--do-call
  (interactive)
  (let ((scope (oref transient-current-prefix scope)))
    (message "scope: %s" scope)))

(transient-define-suffix transient-showcase--double-scope-re-enter ()
  "Re-enter the current prefix with double the scope."
  ;; :transient 'transient--do-replace ; builds up the stack
  :transient 'transient--do-exit
  (interactive)
  (let ((scope (oref transient-current-prefix scope)))
    (if (numberp scope)
        (transient-setup transient-current-command nil nil :scope (* scope 2))
      (message (propertize (format "scope was non-numeric! %s" scope) 'face 'warning))
      (transient-setup transient-current-command))))

(transient-define-suffix transient-showcase--update-scope-with-prefix-re-enter (new-scope)
  "Re-enter the prefix with double the scope."
  ;; :transient 'transient--do-replace ; builds up the stack
  :transient 'transient--do-exit ; do not build up the stack
  (interactive "P")
  (message "universal arg: %s" new-scope)
  (transient-setup transient-current-command nil nil :scope new-scope))

;;;###autoload (autoload 'transient-showcase-scope "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-scope (scope)
  "Prefix demonstrating use of scope."

  ;; note!  this is a location where we definitely had to use
  ;; `transient--prefix' or get the transient object from the transient-showcase-scope symbol.
  ;; `transient-current-prefix' is not correct here!
  [:description (lambda () (format "Scope: %s" (oref transient--prefix scope)))
   [("r" "read scope" transient-showcase--read-prefix-scope)
    ("d" "double scope" transient-showcase--double-scope-re-enter)
    ("o" "update scope (use prefix argument)" transient-showcase--update-scope-with-prefix-re-enter)]]
  (interactive "P")
  (transient-setup 'transient-showcase-scope nil nil :scope scope))

;; Setting an interactive argument for `eval-last-sexp' is a little different
;; (let ((current-prefix-arg 4)) (call-interactively 'transient-showcase-scope))

;; (transient-showcase-scope)
;; Then press "C-u 4 o" to update the scope
;; Then d to double
;; Then r to read
;; ... and so on
;; C-g to exit

;;;###autoload (autoload 'transient-showcase-suffix-eat-snowcone "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-eat-snowcone (args)
  "Eat the snowcone!
This command can be called from it's parent, `transient-showcase-snowcone-eater' or independently."
  :transient t
  ;; you can use the interactive form of a command to obtain a default value
  ;; from the user etc if the one obtained from the parent is invalid.
  (interactive (list (transient-args 'transient-showcase-snowcone-eater)))

  ;; `transient-arg-value' can (with varying success) pick out individual
  ;; values from the results of `transient-args'.

  (let ((topping (transient-arg-value "--topping=" args))
        (flavor (transient-arg-value "--flavor=" args)))
    (message "I ate a %s flavored snowcone with %s on top!" flavor topping)))

;;;###autoload (autoload 'transient-showcase-snowcone-eater "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-snowcone-eater ()
  "Prefix demonstrating set & save infix persistence."
  ;; This prefix has a default value that transient-showcase-suffix-eat-snowcone can see
  ;; even before the prefix has been called.
  :value '("--topping=fruit" "--flavor=cherry")
  ;; always-read is used below so that you don't save nil values to history
  ["Arguments"
   ("-t" "topping" "--topping="
    :choices ("ice cream" "fruit" "whipped cream" "mochi")
    :always-read t)
   ("-f" "flavor" "--flavor="
    :choices ("grape" "orange" "cherry" "lime")
    :always-read t)]
  ;; Definitely check out the =C-x= menu
  ["C-x Menu Behaviors"
   ("S" "save snowcone settings"
    (lambda ()
      (interactive)
      (message "saved!")
      (transient-save)) :transient t)
   ("R" "reset snowcone settings"
    (lambda ()
      (interactive)
      (message "reset!")
      (transient-reset)) :transient t)]
  ["Actions"
   ("m" "message arguments" transient-showcase-suffix-print-args)
   ("e" "eat snowcone" transient-showcase-suffix-eat-snowcone)])

;; First call will use the transient's default value
;; M-x transient-showcase-suffix-eat-snowcone or `eval-last-sexp' below
;; (call-interactively 'transient-showcase-suffix-eat-snowcone)
;; (transient-showcase-snowcone-eater)
;; Eat some snowcones with different flavors
;; ...
;; ...
;; ...
;; Now save the value and exit the transient.
;; When you call the suffix independently, it can still read the saved values!
;; M-x transient-showcase-suffix-eat-snowcone or `eval-last-sexp' below
;; (call-interactively 'transient-showcase-suffix-eat-snowcone)

;;;###autoload (autoload 'transient-showcase-ping "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-ping ()
  "Define a transient prefix for showcasing ping commands and options."
  :history-key 'non-unique-name
  ["Ping"
   ("-g" "game" "--game=")
   ("p" "ping the pong" transient-showcase-pong)
   ("a" "print args" transient-showcase-suffix-print-args :transient nil)])

;;;###autoload (autoload 'transient-showcase-pong "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-pong ()
  "Prefix demonstrating history sharing."

  :history-key 'non-unique-name

  ["Pong"
   ("-g" "game" "--game=")
   ("p" "pong the ping" transient-showcase-ping)
   ("a" "print args" transient-showcase-suffix-print-args :transient nil)])

;; (transient-showcase-ping)
;; Okay here's where it gets weird
;; 1.  Set the value of game to something and remember it
;; 2.  Press a to print the args
;; 3.  Re-open transient-showcase-ping.
;; 4.  C-x p to load the previous history, see the old value?
;; 5.  p to switch to the transient-showcase-pong transient
;; 6.  C-x p to load the previous history, see the old value from transient-showcase-ping???
;; 7. Note that transient-showcase-pong uses the same history as transient-showcase-ping!

;;;###autoload (autoload 'transient-showcase-goldfish "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-goldfish ()
  "A prefix that cannot remember anything."
  ["Goldfish"
   ("-r" "rememeber" "--i-remember="
    :unsavable t ; infix isn't saved
    :always-read t ; infix always asks for new value
    ;; overriding the method to provide a starting value
    :init-value (lambda (obj) (oset obj value "nothing")))
   ("a" "print args" transient-showcase-suffix-print-args :transient nil)])

;; (transient-showcase-goldfish)

;;;###autoload (autoload 'transient-showcase-suffix-remember-and-wave "transient-showcase.el" nil t)
(transient-define-suffix transient-showcase-suffix-remember-and-wave ()
  "Wave, and force the prefix to set it's saveable infix values."
  (interactive)

  ;; (transient-reset) ; forget
  (transient-set) ; save for this session
  ;; If you combine reset with set, you get a reset for future sessions only.
  ;; (transient-save) ; save for this and future sessions
  ;; (transient-reset-value some-other-prefix-object)

  (message "Waves at user at: %s.  You will never be forgotten." (current-time-string)))

;;;###autoload (autoload 'transient-showcase-elephant "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-elephant ()
  "A prefix that always remembers its infixes."
  ["Elephant"
   ("-r" "rememeber" "--i-remember="
    :always-read t)
   ("w" "remember and wave" transient-showcase-suffix-remember-and-wave)
   ("a" "print args (skips remembering)" transient-showcase-suffix-print-args :transient nil)])

;; (transient-showcase-elephant)

;;;###autoload (autoload 'transient-showcase-default-values "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-default-values ()
  "A prefix with a default value."

  :value '("--toggle" "--value=5")

  ["Arguments"
   ("t" "toggle" "--toggle")
   ("v" "value" "--value=" :prompt "an integer: ")]

  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-default-values)

;;;###autoload (autoload 'transient-showcase-enforcing-inputs "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-enforcing-inputs ()
  "A prefix with enforced input type."

  ["Arguments"
   ("v" "value" "--value=" :prompt "an integer: " :reader transient-read-number-N+)]

  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-enforcing-inputs)

(defvar transient-showcase--position '(0 0) "A transient prefix location.")

  (transient-define-infix transient-showcase--pos-infix ()
    "A location, key, or command symbol."
    :class 'transient-lisp-variable
    :transient t
    :prompt "An expression such as (0 0), \"p\", nil, 'transient-showcase--msg-pos: "
    :variable 'transient-showcase--position)

  (transient-define-suffix transient-showcase--msg-pos ()
    "Message the element at location."
    :transient 'transient--do-call
    (interactive)
    ;; lisp variables are not sent in the usual (transient-args) list.
    ;; Just read `transient-showcase--position' directly.
    (let ((suffix (transient-get-suffix transient-current-command transient-showcase--position)))
      (message "%s" (oref suffix description))))

;;;###autoload (autoload 'transient-showcase-lisp-variable "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-lisp-variable ()
  "A prefix that updates and uses a Lisp variable."
  ["Location Printing"
   [("p" "position" transient-showcase--pos-infix)]
   [("m" "message" transient-showcase--msg-pos)]])

  ;; (transient-showcase-lisp-variable)

;;;###autoload (autoload 'transient-showcase-switches-and-arguments "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-switches-and-arguments (arg)
  "A prefix with switch and argument examples."
  [["Arguments"
    ("-s" "switch" "--switch")
    ("-a" "argument" "--argument=")
    ("t" "toggle" "--toggle")
    ("v" "value" "--value=")]
   ["More Arguments"
    ("-f" "argument with forced class" "--forced-class " :class transient-option)
    ("I" "argument with inline" "--inline-shortarg "
     :class transient-option
     :multi-value t
     :choices ("fox" "kitten" "peregrine" "otter"))
    ("S" "inline shortarg switch" ("-n" "--inline-shortarg-switch"))]]
  ["Commands"
   ("w" "wave some" transient-showcase--random-init-infix)
   ("s" "show arguments" transient-showcase-suffix-print-args)]) ; use to analyze the switch values

;; (transient-showcase-switches-and-arguments)

(transient-define-infix transient-showcase--random-init-infix ()
  "Switch on and off."
  :argument "--switch"
  :shortarg "-s" ; will be used for :key when key is not set
  :description "switch"
  :init-value (lambda (obj)
                (oset obj value
                      (eq 0 (random 2))))) ; write t with 50% probability

;;;###autoload (autoload 'transient-showcase-maybe-on "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-maybe-on ()
  "A prefix with a randomly intializing switch."
  ["Arguments"
   (transient-showcase--random-init-infix)]
  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-maybe-on)
;; (transient-showcase-maybe-on)
;; ...
;; Run the command a few times to see the random initialization of `transient-showcase--random-init-infix'
;; It will only take more than ten tries for one in a thousand users.  Good luck.

(transient-define-argument transient-showcase--animals-argument ()
  "Animal picker."
  :argument "--animals="
  :multi-value t      ; multi-value can be set to --animals=fox,otter,kitten etc
  :class 'transient-option
  :choices '("fox" "kitten" "peregrine" "otter"))

;;;###autoload (autoload 'transient-showcase-animal-choices "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-animal-choices ()
  "Prefix demonstrating selecting animals from choices."
  ["Arguments"
   ("-a" "--animals=" transient-showcase--animals-argument)]
  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-animal-choices)

(transient-define-argument transient-showcase--snowcone-flavor ()
  :description "Flavor of snowcone."
  :class 'transient-switches
  :key "f"
  :argument-format "--%s-snowcone"
  :argument-regexp "\\(--\\(grape\\|orange\\|cherry\\|lime\\)-snowcone\\)"
  :choices '("grape" "orange" "cherry" "lime"))

;;;###autoload (autoload 'transient-showcase-exclusive-switches "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-exclusive-switches ()
  "Prefix demonstrating exclusive switches."
  :value '("--orange-snowcone")

  ["Arguments"
   (transient-showcase--snowcone-flavor)]
  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-exclusive-switches)

;;;###autoload (autoload 'transient-showcase-incompatible "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-incompatible ()
  "Prefix demonstrating incompatible switches."
  ;; update your transient version if you experience #129 / #155
  :incompatible '(("--switch" "--value=")
                  ("--switch" "--toggle" "--flip")
                  ("--argument " "--value=" "--special-arg="))
  ["Arguments"
   ("-s" "switch" "--switch")
   ("-t" "toggle" "--toggle")
   ("-f" "flip" "--flip")
   ("-a" "argument" "--argument " :class transient-option)
   ("v" "value" "--value=")
   ("C-a" "special arg" "--special-arg=")]
  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-incompatible)

(defun transient-showcase--animal-completion-table (_complete-me _predicate flag)
  "Programmed completion for animal choice.
_COMPLETE-ME: whatever the user has typed so far
_PREDICATE: function you should use to filter candidates (only nil seen so far)
FLAG: request for metadata (which can be disrespected)"

  ;; if you want to respect metadata requests, here's what the form might
  ;; look like, but no behavior was observed.
  (if (eq flag 'metadata)
      '(metadata . '((annotation-function . (lambda (c) "an annotation"))))

    ;; when not handling a metadata request from completions, use some
    ;; logic to generate the choices, possibly based on input or some time
    ;; / context sensitive process.  FLAG will be `t' when these are reqeusted.
    (if (eq 0 (random 2))
        '("fox" "kitten" "otter")
      '("ant" "peregrine" "zebra"))))

(defun transient-showcase--animal-choices ()
  #'transient-showcase--animal-completion-table)

;;;###autoload (autoload 'transient-showcase-choices-with-completions "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-choices-with-completions ()
  "Prefix with completions for choices."
  ["Arguments"
   ("-a" "Animal" "--animal="
    :always-read t                ; don't allow unsetting, just read a new value
    :choices transient-showcase--animal-choices)]
  ["Show Args"
   ("s" "show arguments" transient-showcase-suffix-print-args)])

;; (transient-showcase-choices-with-completions)

(defun transient-showcase--quit-cowsay ()
  "Kill the cowsay buffer and exit."
  (interactive)
  (kill-buffer "*cowsay*"))

(defun transient-showcase--cowsay-buffer-exists-p ()
  "Visibility predicate."
  (not (equal (get-buffer "*cowsay*") nil)))

(transient-define-suffix transient-showcase--cowsay-clear-buffer (&optional buffer)
  "Delete the *cowsay* buffer.  Optional BUFFER name."
  :transient 'transient--do-call
  :if 'transient-showcase--cowsay-buffer-exists-p
  (interactive) ; todo look at "b" interactive code

  (save-excursion
    (let ((buffer (or buffer "*cowsay*")))
      (set-buffer buffer)
      (delete-region 1 (+ 1 (buffer-size))))))

(transient-define-suffix transient-showcase--cowsay (&optional args)
  "Run cowsay."
  (interactive (list (transient-args transient-current-command)))
  (let* ((buffer "*cowsay*")
         ;; TODO ugly
         (cowmsg (if args (transient-arg-value "--message=" args) nil))
         (cowmsg (if cowmsg (list cowmsg) nil))
         (args (if args
                   (seq-filter
                    (lambda (s) (not (string-prefix-p "--message=" s))) args)
                 nil))
         (args (if args
                   (if cowmsg
                       (append args cowmsg)
                     args)
                 cowmsg)))

    (when (transient-showcase--cowsay-buffer-exists-p)
      (transient-showcase--cowsay-clear-buffer))
    (apply #'call-process "cowsay" nil buffer nil args)
    (switch-to-buffer buffer)))

;;;###autoload (autoload 'transient-showcase-cowsay "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-cowsay ()
  "Say things with animals!"

  ; only one kind of eyes is meaningful at a time
  :incompatible '(("-b" "-g" "-p" "-s" "-t" "-w" "-y"))

  ["Message"
   ("m" "message" "--message=" :always-read t)] ; always-read, so clear by entering empty string
  [["Built-in Eyes"
    ("b" "borg" "-b")
    ("g" "greedy" "-g")
    ("p" "paranoid" "-p")
    ("s" "stoned" "-s")
    ("t" "tired" "-t")
    ("w" "wired" "-w")
    ("y" "youthful" "-y")]
   ["Actions"
    ("c" "cowsay" transient-showcase--cowsay :transient transient--do-call)
    ""
    ("d" "delete buffer" transient-showcase--cowsay-clear-buffer)
    ("q" "quit" transient-showcase--quit-cowsay)]])

;; (transient-showcase-cowsay)

;;;###autoload (autoload 'transient-showcase-visibility-predicates "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-visibility-predicates ()
  "Prefix with visibility predicates.
Try opening this prefix in buffers with modes deriving from different
abstract major modes."
  ["Empty Groups Not Displayed"
   ;; in org mode for example, this group doesn't appear.
   ("we" "wave elisp" transient-showcase-suffix-wave :if-mode emacs-lisp-mode)
   ("wc" "wave in C" transient-showcase-suffix-wave :if-mode cc-mode)]

  ["Lists of Modes"
   ("wm" "wave multiply" transient-showcase-suffix-wave :if-mode (dired-mode gnus-mode))]

  [["Function Predicates"
    ;; note, after toggling, the transient needs to be re-displayed for the
    ;; predicate to take effect
    ("bs" "toggle busy" transient-showcase--toggle-busy)
    ("bw" "wave busily" transient-showcase-suffix-wave :if transient-showcase--busy-p)]

   ["Programming Actions"
    :if-derived prog-mode
    ("pw" "wave programishly" transient-showcase-suffix-wave)
    ("pe" "wave in elisp" transient-showcase-suffix-wave :if emacs-lisp-mode)]
   ["Special Mode Actions"
    :if-derived special-mode
    ("sw" "wave specially" transient-showcase-suffix-wave)
    ("sd" "wave dired" transient-showcase-suffix-wave :if-mode dired-mode)]
   ["Text Mode Actions"
    :if-derived text-mode
    ("tw" "wave textually" transient-showcase-suffix-wave)
    ("to" "wave org-modeishly" transient-showcase-suffix-wave :if-mode org-mode)]])

;; (transient-showcase-visibility-predicates)

(defun transient-showcase--child-scope-p ()
  "Return the scope of the current transient.
When this is called in layouts, it's the transient being layed out"
  (let ((scope (oref transient--prefix scope)))
    (message "The scope is: %s" scope)
    scope))

;; the wave suffixes were :transient t as defined, so we need to manually
;; override them to the `transient--do-return' value for :transient slot so
;; that they return back to the parent.
(transient-define-prefix transient-showcase--inapt-children ()
  "Prefix with children using inapt predicates."
  ["Inapt Predicates Child"
   ("s" "switched" transient-showcase--wave-surely
    :transient transient--do-return
    :if transient-showcase--child-scope-p)
   ("u" "unswitched" transient-showcase--wave-normally
    :transient transient--do-return
    :if-not transient-showcase--child-scope-p)]

  ;; in the body, we read the value of the parent and set our scope to
  ;; non-nil if the switch is set
  (interactive)
  (let ((scope (transient-arg-value "--switch" (transient-args 'transient-showcase-inapt-parent))))
    (message "scope: %s" scope)
    (message "type: %s" (type-of scope))
    (transient-setup 'transient-showcase--inapt-children nil nil :scope (if scope t nil))))

;;;###autoload (autoload 'transient-showcase-inapt-parent "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-inapt-parent ()
  "Prefix that configures child with inapt predicates."

  [("-s" "switch" "--switch")
   ("a" "show arguments" transient-showcase-suffix-print-args)
   ("c" "launch child prefix" transient-showcase--inapt-children :transient transient--do-recurse)])

;; (transient-showcase-inapt-parent)

;;;###autoload (autoload 'transient-showcase-levels-and-visibility "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-levels-and-visibility ()
  "Prefix with visibility levels for hiding rarely used commands."
  [["Setting the Current Level"
    ;; this binding is normally not displayed.  The value of
    ;; `transient-show-common-commands' controls this by default.
    ("C-x l" "set level" transient-set-level)
    ("s" "show level" transient-showcase-suffix-show-level)]
   [2 "Per Group"												; 1 is the default default-child-level
      ("ws" "wave surely" transient-showcase--wave-surely) ; 1 is the default default-child-level
      (3 "wn" "wave normally" transient-showcase--wave-normally)
      (5 "wb" "wave non-essentially" transient-showcase--wave-non-essentially)]
   [3 "Per Group Somewhat Useful"
      ("wd" "wave definitely" transient-showcase--wave-definitely)]
   [6 "Groups hide visible children"
      (1 "wh" "wave hidden" transient-showcase--wave-hidden)]
   [5 "Per Group Rarely Useful"
      ("we" "wave eventually" transient-showcase--wave-eventually)]])

;; (transient-showcase-levels-and-visibility)


;;;###autoload (autoload 'transient-showcase-generated-child "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-generated-child ()
  "Prefix that uses `setup-children' to generate single child."
  ["Replace this child"
   ;; Let's override the group's method
   :setup-children
   (lambda (_)                          ; we don't care about the stupid suffix
     ;; remember to return a list
     (list (transient-parse-suffix
            (oref transient--prefix command)
            '("r" "replacement" (lambda ()
                                  (interactive)
                                  (message "okay!"))))))
   ("s" "haha stupid suffix" (lambda ()
                               (interactive)
                               (message "You should replace me!")))])

;; (transient-showcase-generated-child)

;;;###autoload (autoload 'transient-showcase-generated-group "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-generated-group ()
  "Prefix that uses `setup-children' to generate a group."
  ["Replace this child"
   ;; Let's override the group's method
   :setup-children
   (lambda (_args)
     (transient-parse-suffixes
      (oref transient--prefix command)
      ["Group Name" ("r" "replacement" (lambda ()
                                         (interactive)
                                         (message "okay!")))]))])

;; (transient-showcase-generated-group)

(defun transient-showcase--self-modifying-add-command (command-sym sequence)
  "Add suffix with SEQUENCE and COMMAND-SYM to transient-showcase-self-modifying."
  (interactive "CSelect a command: \nMkey sequence: ")
  ;; Generate an infix that will call the command and add it to the
  ;; second group (index 1 at the 0th position)
  (transient-insert-suffix
    'transient-showcase-self-modifying
    '(0 1 0)			; set the child in `tsc-inception' for help with this argument
    (list sequence (format "Call %s" command-sym) command-sym :transient t))
  ;; we must re-enter the transient to force the layout update
  (transient-setup 'transient-showcase-self-modifying))

;;;###autoload (autoload 'transient-showcase-self-modifying "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-self-modifying ()
  "Prefix that uses `transient-insert-suffix' to add commands to itself."
  [["Add New Commands"
    ("a" "add command" transient-showcase--self-modifying-add-command)]
   ["User Defined"
    ""]]) ; blank line suffix creates an insertion point

;; (transient-showcase-self-modifying)

;; The children we will be picking can be of several forms.  The
;; transient--layout symbol property of a prefix is a vector of vectors, lists,
;; and strings.  It's not the actual eieio types or we would use
;; `transient-format-description' to just ask them for the descriptions.
(defun transient-showcase--layout-child-desc (layout-child)
  "Get the description from LAYOUT-CHILD.
LAYOUT-CHILD is a transient layout vector or list."
  (let ((description
         (cond
          ((vectorp layout-child) (or (plist-get (aref layout-child 2) :description) "<group, no desc>")) ; group
          ((stringp layout-child) layout-child) ; plain-text child
          ((listp layout-child) (plist-get (elt layout-child 2) :description)) ; suffix
          (t (message (propertize "You traversed into a child's list elements!" 'face 'warning))
             (format "(child's interior) element: %s" layout-child)))))
    (cond
     ;; The description is sometimes a callable function with no arguments,
     ;; so let's call it in that case.  Note, the description may be
     ;; designed for one point in the transient's lifecycle but we could
     ;; call it in a different one, causing its behavior to change.
     ((functionp description) (apply description))
     (t description))))

;; We repeat the read using a lisp expression from `read-from-minibuffer' to get
;; the LOC key for `transient-get-suffix' until we get a valid result.  This
;; ensures we don't store an invalid LOC.
(defun transient-showcase-child-infix--reader (prompt initial-input history)
  "Read a location and check that it exists within the current transient.
PROMPT, INITIAL-INPUT, and HISTORY are forwarded to `read-from-minibuffer'."
  (let ((command (oref transient--prefix command))
        (success nil))
    (while (not success)
      (let* ((loc (read (read-from-minibuffer prompt initial-input nil nil history)))
             (child (ignore-errors (transient-get-suffix command loc))))
        (if child (setq success loc)
          (message (propertize
                    (format
                     "Location could not be found in prefix %s"
                     command)
                    'face 'error))
          (sit-for 3))))
    success))

;; Inherit from variable abstract class
(defclass transient-showcase-child-infix (transient-variable)
  ((value-object :initarg value-object :initform nil)
   ;; this is a new slot for storing the hydrated value.  we re-use the
   ;; value infrastructure for storing the serialization-friendly value,
   ;; which is basically a suffix addres or id.

   (reader :initform #'transient-showcase-child-infix--reader)
   (prompt :initform "Location, a key \"c\", suffix-command-symbol like transient-showcase--wave-normally or coordinates like (0 2 0): ")))

;; We have to define this on non-abstract infix classes.  See
;; `transient-init-value' in transient source.  The method on
;; `transient-argument' class was used to make this example, but it
;; does support a lot of behaviors.  In short, the prefix has a value
;; and you rehydrate the infix by looking into the prefix's value to
;; find the suffix value.  Because our stored value is basically a
;; serialization, we rehydrate it to be sure it's a valid value.
;; Remember to handle values you can't rehydrate.
(cl-defmethod transient-init-value ((obj transient-showcase-child-infix))
  "Set the `value' and `value-object' in OBJ slots using the prefix's value."
  ;; in the prefix declaration, the initial description is a reliable key
  (let ((variable (oref obj description)))
    (oset obj variable variable)
    ;; rehydrate the value if the prefix has one for this infix
    (when-let* ((prefix-value (oref transient--prefix value))
                ;; (argument (and (slot-boundp obj 'argument)
                ;;   (oref obj argument)))
                (value (cdr (assoc variable prefix-value)))
                (value-object (transient-get-suffix (oref transient--prefix
                                                          command) value))) ; rehydrate
      (oset obj value value)
      (oset obj value-object value-object))))

(cl-defmethod transient-infix-set ((obj transient-showcase-child-infix) value)
  "Update `value' slot to VALUE.
Update OBJ slot to the value corresponding to VALUE."
  (let* ((command (oref transient--prefix command))
         (child (ignore-errors (transient-get-suffix command value))))
    (oset obj value-object child)
    (oset obj value (if child value nil)))) ; TODO a bit ugly

;; If you are making a suffix that needs history, you need to define
;; this method.  The example here almost identical to the method
;; defined for `transient-option',
(cl-defmethod transient-infix-value ((obj transient-showcase-child-infix))
  "Return our actual value for OBJ rehydration later."
  ;; Note, returning a cons for the value is very flexible and will
  ;; work with homoiconicity in persistence.
  (cons (oref obj variable)
        (oref obj value)))

;; Show user's a useful representation of your ugly value
(cl-defmethod transient-format-value ((obj transient-showcase-child-infix))
  "All transient children have some description we can display.
Show either the child's description from OBJ
 or a default if no child is selected."
  (if-let* ((value (and (slot-boundp obj 'value)
                        (oref obj value)))
            (value-object (and (slot-boundp obj 'value-object)
                               (oref obj value-object))))
      (propertize
       (format "(%s)" (transient-showcase--layout-child-desc value-object))
       'face 'transient-value)
    (propertize "¯\_(ツ)_/¯" 'face 'transient-inactive-value)))

;; Now that we have our class defined, we can create an infix the usual
;; way, just specifying our class
(transient-define-infix transient-showcase--inception-child-infix ()
  :class transient-showcase-child-infix)

;; All set!  This transient just tests our or new toy.
;;;###autoload (autoload 'transient-showcase-inception "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-inception ()
  "Prefix that picks a suffix from its own layout."

  [["Pick a suffix"
    ("-s" "just a switch" "--switch") ; makes history value structure apparent
    ("c" "child" transient-showcase--inception-child-infix :class transient-showcase-child-infix)]

   ["Some suffixes"
    ("s" "wave surely" transient-showcase--wave-surely)
    ("d" "wave definitely" transient-showcase--wave-definitely)
    ("e" "wave eventually" transient-showcase--wave-eventually)
    ("C" "call & exit normally" transient-showcase--wave-normally :transient nil)]

   ["Read variables"
    ("r" "read args" transient-showcase-suffix-print-args )]])

;; (tsc-inception)
;;
;; Try setting the infix to "e" (yes, include quotes)
;; Try: (1 2)
;; Try: tsc--wave-normally
;;
;; Observe that the LOC you enter is displayed using the description at that poin
;;
;; Set the infix and re-open it with C-x s, C-g, and M-x tsc-inception
;; Observe that the set value persists across invocations
;;
;; Save the infix, with C-x C-s, re-evaluate the prefix, and open the prefix again.
;; Observe that the
;;
;; Try flipping through history, C-x n, C-x p
;; Now do think of doing things like this with org ids, magit-sections, buffers etc.

(transient-define-suffix transient-showcase--inception-update-description ()
   "Update the description of of the selected child."
   (interactive)
   (let* ((args (transient-args transient-current-command))
          (description (transient-arg-value "--description=" args))
          ;; This is the part where we read the other infix
          (loc (car (cdr (assoc 'transient-showcase--inception-child-infix args))))
          (layout-child (transient-get-suffix 'transient-showcase-inception-update loc)))
     (cond
      ((or (listp layout-child) ; child
          (vectorp layout-child) ; group
          (stringp layout-child)) ; string child
       (if (stringp layout-child)
           (transient-replace-suffix 'transient-showcase-inception-update loc description) ; plain-text child
         (plist-put (elt layout-child 2) :description description)))
      (t (message
          (propertize (format "Don't know how to modify whatever is at: %s" loc)
                      'face 'warning))))

     ;; re-enter the transient manually to display the modified layout
     (transient-setup transient-current-command)))

;;;###autoload (autoload 'transient-showcase-inception-update "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase-inception-update ()
  "Prefix that picks and updates its own suffix."
  [["Pick a suffix"
    ("c" "child" transient-showcase--inception-child-infix :argument child)]
   ["Update the description!"
    ("-d" "description" "--description=") ; makes history value structure apparent
    ("u" "update" transient-showcase--inception-update-description :transient
     transient--do-exit)]
   ["Some suffixes"
    ("s" "wave surely" transient-showcase--wave-surely)
    ("d" "wave definitely" transient-showcase--wave-definitely)
    ("e" "wave eventually" transient-showcase--wave-eventually)
    ("C" "call & exit normally" transient-showcase--wave-normally :transient nil)]
   ["Read variables"
    ("r" "read args" transient-showcase-suffix-print-args)]])

;; (transient-showcase-inception-update)
;; Pick a suffix,
;; Then set the description
;; Then update the suffix's you picked with the new description!
;; Using a transient to modify a transient (⊃｡•́‿•̀｡)⊃━✿✿✿✿✿✿
;;
;; Observe that the set values are persisted across invocations.
;; Saving also works.  This makes it easier to set the description
;; multiple times in succession.  The Payoff when building larger
;; applications like magit rapidly adds up.

;;;###autoload (autoload 'transient-showcase "transient-showcase.el" nil t)
(transient-define-prefix transient-showcase ()
  "A launcher for a currated selection of examples.
While most of the prefixes have their :transient slot set to t, it's not
possible to return from all of them, especially if they demonstrate flow
control such as replacing or exiting."
  [["Layouts"
    ("ls" "stacked" transient-showcase-layout-stacked :transient t)
    ("lc" "columns" transient-showcase-layout-columns :transient t)
    ("lt" "stacked columns" transient-showcase-layout-stacked-columns :transient
     t)
    ("lg" "grid" transient-showcase-layout-the-grid :transient t)
    ("lp" "spaced out" transient-showcase-layout-spaced-out :transient t)
    ("le" "explicit class" transient-showcase-layout-explicit-classes :transient
     t)
    ("ld" "descriptions" transient-showcase-layout-descriptions :transient t)
    ;; padded description to sc
    ("lD" "dynamic descriptions        "
     transient-showcase-layout-dynamic-descriptions
     :transient t)]
   ["Nesting & Flow Control"
    ("fs" "stay transient" transient-showcase-stay-transient :transient t)
    ("fb" "binding sub-prefix" transient-showcase-simple-parent :transient t)
    ("fr" "sub-prefix with return" transient-showcase-simple-parent-with-return
     :transient t)
    ("fm" "manual setup in suffix" transient-showcase-parent-with-setup-suffix
     :transient t)
    ("fi" "mixing interactive" transient-showcase-interactive-basic :transient t)
    ("fe" "early return" transient-showcase-simple-messager :transient t)]]
  [["Managing State"                    ; padded right group
    ("sb" "a bunch of infixes" transient-showcase-basic-infixes :transient t)
    ("sc" "using scope (accepts prefix)" transient-showcase-scope :transient t)
    ("sn" "set & save / snowcones" transient-showcase-snowcone-eater :transient
     t)
    ("sp" "history key / ping-pong" transient-showcase-ping :transient t)
    ("sg" "always forget / goldfish" transient-showcase-goldfish :transient t)
    ("se" "always remember / elephant" transient-showcase-elephant :transient t)
    ("sd" "default values" transient-showcase-default-values :transient t)
    ("sf" "enforcing inputs" transient-showcase-enforcing-inputs :transient t)
    ("sl" "lisp variables" transient-showcase-lisp-variable :transient t)]
   ["CLI arguments"
    ("cb" "basic arguments" transient-showcase-switches-and-arguments :transient
     t)
    ("cm" "random-init infix" transient-showcase-maybe-on :transient t)
    ("cc" "basic choices" transient-showcase-animal-choices :transient t)
    ("ce" "exclusive switches" transient-showcase-exclusive-switches :transient
     t)
    ("ci" "incompatible switches" transient-showcase-incompatible :transient t)
    ("co" "completions for choices" transient-showcase-choices-with-completions
     :transient t)
    ("cx" "cowsay cli wrapper" transient-showcase-cowsay :transient t)]]
  [["Visibility"
    ;; padded description to sc
    ("vp" "predicates                  " transient-showcase-visibility-predicates :transient t)
    ("vi" "inapt (not suitable)" transient-showcase-inapt-parent :transient t)
    ("vl" "levels" transient-showcase-levels-and-visibility :transient t)]
   ["Advanced"
    ("ac" "generated child" transient-showcase-generated-child :transient t)
    ("ag" "generated group" transient-showcase-generated-group :transient t)
    ("as" "self-modifying" transient-showcase-self-modifying :transient t)
    ("ai" "custom infixes" transient-showcase-inception :transient t)
    ("au" "custom infixes & updaxte" transient-showcase-inception-update
     :transient t)]])

(provide 'transient-showcase)
;;; transient-showcase.el ends here
