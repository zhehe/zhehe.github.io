;;
(require 'cc-mode)

;; indent code
(setq-default c-basic-offset 4 c-default-style "linux")
(setq-default tab-width 4 indent-tabs-mode t)
(define-key c-mode-base-map (kbd "RET") 'newline-and-indent)

;; closing the bracket
(require 'autopair)
(autopair-global-mode 1)
(setq autopair-autowrap t)

(require 'highlight-parentheses)
(add-hook 'highlight-parentheses-mode-hook
          '(lambda ()
             (setq autopair-handle-action-fns
                   (append
					(if autopair-handle-action-fns
						autopair-handle-action-fns
					  '(autopair-default-handle-action))
					'((lambda (action pair pos-before)
						(hl-paren-color-update)))))))

(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)


;; cedet
;;(load-file "/usr/share/emacs/24.3/lisp/cedet/cedet.elc")
(require 'semantic)
(semantic-mode 1)

;;(add-to-list 'load-path "~/.emacs.d/elpa/company-20160109.1333")
;;(require 'company-semantic)
(add-hook 'after-init-hook 'global-company-mode)


(require 'semantic/ia)          ; names completion and display of tags
;;(require 'semantic-gcc)         ; auto locate system include files
(require 'semantic/analyze)
(provide 'semantic-analyze)
(provide 'semantic-ctxt)
(provide 'semanticdb)
(provide 'semanticdb-find)
(provide 'semanticdb-mode)
(provide 'semantic-load) 
(global-ede-mode 1)                      ; Enable the Project management system
;(semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion 

;; (global-semantic-idle-scheduler-mode 1) ;The idle scheduler with automatically reparse buffers in idle time.
(global-semantic-idle-completions-mode 1) ;Display a tooltip with a list of possible completions near the cursor.
(global-semantic-idle-summary-mode 1) ;Display a tag summary of the lexical token under the cursor.

(semantic-add-system-include "/usr/include/boost" 'c++-mode)
(semantic-add-system-include "~/linux/kernel")
(semantic-add-system-include "~/linux/include")
 
(require 'semanticdb)
(global-semanticdb-minor-mode 1)
 
(defun my-cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol)
  (local-set-key "\C-c>" 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c?" 'semantic-complete-analyze-inline)
  (local-set-key "\C-c=" 'semantic-decoration-include-visit)
  (local-set-key "\C-cj" 'semantic-ia-fast-jump)
  (local-set-key "\C-cq" 'semantic-ia-show-doc)
  (local-set-key "\C-cs" 'semantic-ia-show-summary)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  (local-set-key "\C-c+" 'semantic-tag-folding-show-block)
  (local-set-key "\C-c-" 'semantic-tag-folding-fold-block)
  ;; (local-set-key "\C-c\C-c+" 'semantic-tag-folding-show-all)
  ;; (local-set-key "\C-c\C-c-" 'semantic-tag-folding-fold-all)
  )

;; 2016.06.14 zhe
(setq-mode-local cpp-mode semanticdb-find-default-throttle 
                      '(project local unloaded system recursive)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          tags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq path-to-ctags "usr/bin/") ;; <- your ctags path here

 (defun create-tags (dir-name)
      "Create tags file."
      (interactive "DDirectory: ")
      (eshell-command 
       (format "find %s -type f -name \"*.[ch]\" | etags -" dir-name)))   

  (defadvice find-tag (around refresh-etags activate)
   "Rerun etags and reload tags if tag not found and redo find-tag.              
   If buffer is modified, ask about save before running etags."
  (let ((extension (file-name-extension (buffer-file-name))))
    (condition-case err
    ad-do-it
      (error (and (buffer-modified-p)
          (not (ding))
          (y-or-n-p "Buffer is modified, save it? ")
          (save-buffer))
         (er-refresh-etags extension)
         ad-do-it))))

  (defun er-refresh-etags (&optional extension)
  "Run etags on all peer files in current dir and reload them silently."
  (interactive)
  (shell-command (format "etags *.%s" (or extension "el")))
  (let ((tags-revert-without-query t))  ; don't query, revert silently          
    (visit-tags-table default-directory nil)))

(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              auto-complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete)

(require 'auto-complete-config)
(ac-config-default)
;;start after 3 characters were typed 
(setq ac-auto-start 1)
;;show menu immediately
(setq ac-auto-show-menu 0.3)

(require 'yasnippet)
(yas-global-mode 1)

(setq ac-source-yasnippet nil)

;;; auto complete mod
;;; should be loaded after yasnippet so that they can work together
;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")
(define-key yas-minor-mode-map (kbd "<tab>") nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)
(define-key yas-minor-mode-map (kbd "<C-tab>") 'yas-expand)

(require 'auto-complete-clang)
(define-key c++-mode-map (kbd "C-1") 'ac-complete-clang)
;; replace C-S-<return> with a key binding that you want

;;(require 'member-function)
;;(setq mf--source-file-extension "cpp")

(require 'flymake)

;;; set layout for ECB
;; (setq ecb-layout-name "left-symboldef")
;; (setq ecb-layout-name "left-dir-plus-speedbar")
(setq ecb-layout-name "left15")
;;; show source files in directories buffer
(setq ecb-show-sources-in-directories-buffer 'always)

;;; keep a persistent compile window in ECB
;; (setq ecb-compile-window-height 12)

;;; activate ecb
(require 'ecb)
;;(require 'ecb-autoloads)
(global-ede-mode t)

(defun my:ecb-hook ()
 ;; (local-set-key (kbd "C-;") 'ecb-show-ecb-windows)
 ;; (local-set-key (kbd "C-'") 'ecb-hide-ecb-windows)
 ;; (local-set-key (kbd "C-)") 'ecb-goto-window-edit1)
 ;; (local-set-key (kbd "C-1") 'ecb-goto-window-directories)
 ;; (local-set-key (kbd "C-2") 'ecb-goto-window-sources)
 ;; (local-set-key (kbd "C-3") 'ecb-goto-window-methods)
  ;; (local-set-key (kbd "C-4") 'ecb-goto-window-compilation)
 (local-set-key (kbd "<f5>") 'compile)
 (local-set-key (kbd "<f11>") 'semantic-speedbar-analysis))

;; (when window-system (speedbar t))

;;; activate and deactivate ecb
;; (global-set-key (kbd "C-x C-;") 'ecb-activate)
(global-set-key (kbd "C-x C-'") 'ecb-deactivate)

(global-set-key (kbd "C-x C-;")
				(lambda ()
				  (interactive)
				  (my:ecb-hook) (ecb-activate) (my-cedet-hook)))

;;;;;;;;;;;;;;;;;;;;;;
;; gdb
;;;;;;;;;;;;;;;;;;;;;
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t
 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 gdb-gud-control-all-threads t
 )

;; iedit, google-fly-make
;; https://www.youtube.com/watch?v=r_HW0EB67eY
;; iedit enable
(define-key global-map (kbd "C-c ;") 'iedit-mode)

(font-lock-add-keywords 'c++-mode
 `((,(concat
   "\\<[_a-zA-Z][_a-zA-Z0-9]*\\>"       ; Object identifier
   "\\s *"                              ; Optional white space
   "\\(?:\\.\\|->\\)"                   ; Member access
   "\\s *"                              ; Optional white space
   "\\<\\([_a-zA-Z][_a-zA-Z0-9]*\\)\\>" ; Member identifier
   "\\s *"                              ; Optional white space
   "(")                                 ; Paren for method invocation
   1 'font-lock-function-name-face t)))


;; fold code
(add-hook 'c-mode-common-hook 'hs-minor-mode)
(dolist (x '(emacs-lisp lisp java perl sh python))
  (add-hook (intern (concat (symbol-name x) "-mode-hook")) 'hs-minor-mode))

(setq hs-minor-mode-map
      (let ((map (make-sparse-keymap)))
        (define-key map (kbd "C-c @ h")   'hs-hide-block)
        (define-key map (kbd "C-c @ H")   'hs-show-block)
        (define-key map (kbd "C-c @ s")	  'hs-hide-all)
        (define-key map (kbd "C-c @ S")	  'hs-show-all)
        (define-key map (kbd "C-c @ l")   'hs-hide-level)
        (define-key map (kbd "<C-tab>")   'hs-toggle-hiding)
        (define-key map [(shift mouse-2)] 'hs-mouse-toggle-hiding)
        map))

(global-set-key (kbd "<C-tab>")   'hs-toggle-hiding)

;; https://github.com/Hawstein/my-emacs/blob/master/_emacs/hs-minor-mode-settings.el
(setq hs-isearch-open t)

(defvar hs-hide-all nil "Current state of hideshow for toggling all.")
(make-local-variable 'hs-hide-all)

(defun hs-toggle-hiding-all ()
  "Toggle hideshow all."
  (interactive)
  (setq hs-hide-all (not hs-hide-all))
  (if hs-hide-all
      (hs-hide-all)
    (hs-show-all)))

(defvar fold-all-fun nil "Function to fold all.")
(make-variable-buffer-local 'fold-all-fun)
(defvar fold-fun nil "Function to fold.")
(make-variable-buffer-local 'fold-fun)

(defun toggle-fold-all ()
  "Toggle fold all."
  (interactive)
  (if fold-all-fun
      (call-interactively fold-all-fun)
    (hs-toggle-hiding-all)))

(defun toggle-fold ()
  "Toggle fold."
  (interactive)
  (if fold-fun
      (call-interactively fold-fun)
    (hs-toggle-hiding)))

(defadvice goto-line (after expand-after-goto-line
                            activate compile)
  "hideshow-expand affected block when using goto-line in a collapsed buffer"
  (save-excursion
    (hs-show-block)))

(defadvice goto-line-with-feedback (after expand-after-goto-line-with-feedback
                                          activate compile)
  "hideshow-expand affected block when using goto-line in a collapsed buffer"
  (save-excursion
    (hs-show-block)))
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   doxygen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'doxymacs)
(add-hook 'c-mode-common-hook 'doxymacs-mode)

;; Get syntactic information for the current position
(defun im-doxymacs-get-syntactic-information ()
    (if (boundp 'c-syntactic-context)
        ;; Use `c-syntactic-context' in the same way as
        ;; `c-indent-line', to be consistent.
        c-syntactic-context
        (c-guess-basic-syntax)
        )
    )

;; Get required indentation column for the current position
(defun im-doxymacs-get-required-indent ()
    (c-get-syntactic-indentation (im-doxymacs-get-syntactic-information)))

;; Make a doxygen comment start string that's as long as fill-column
(defun im-doxymacs-multiline-comment-start ()
    (concat "/*" (make-string (- (- fill-column 6) (im-doxymacs-get-required-indent)) ?*) "/"))

;; Make a doxygen comment end string that's as long as fill-column
(defun im-doxymacs-multiline-comment-end ()
    (concat (make-string (- (- fill-column 2) (im-doxymacs-get-required-indent)) ?*) "/"))

;; Make a tempo tag list for doxymacs templates
(defvar im-doxymacs-tempo-tags nil
    "Tempo tags for doxymac")

;; make a tempo template for file comments
(tempo-define-template
    "im-doxymacs-file-comment"
    '(   "/**" > n
         "* @file " (file-name-nondirectory buffer-file-name) > n
         "* @orinigator Zhe HE" > n
         "*" > n
         "* @brief " > p > n
		 "*" > n
		 "* @history" > n
		 "*    "> n
		 "*" > n
		 "* @bug " > n
		 "*" > n
		 "* @todo " > n
		 "*    " > n
		 "*" > n
		 "* @claim " > n
		 "*     This source code is not freeware nor shareware and is only provided under" > n 
         "*     an agreement between authorized users/licensees and may only be used under " > n
         "*     the terms and conditions set forth therein." > n
		 "*" > n
         "* @copyright 2016-" (format-time-string "%Y" (current-time)) " Appropolis Inc. All Rights Reserved" > n
         "**/" > n >
         )
    "doxymacs-file-comment"
    "Insert a doxygen file comment"
    'im-doxymacs-tempo-tags)

;; make a tempo template for a blank multiline comment
(tempo-define-template
    "im-doxymacs-blank-multiline-comment"
    '(   "/**" > n
         "* " > p > n
         "**/" > n >
         )
    "doxymacs-blank-multiline-comment"
    "Insert a doxygen blank multiline comment"
    'im-doxymacs-tempo-tags)



;; make a tempo template for a blank multiline comment
(tempo-define-template
    "im-doxymacs-blank-multiline-comment"
    '(   "/**"  > n
         "*" > p > n
		 "*" > n
         "**/" > n >
         )
    "doxymacs-blank-multiline-comment"
    "Insert a doxygen blank multiline comment"
    'im-doxymacs-tempo-tags)

;;;; for function comments

(defun im-doxymacs-parm-tempo-element (parms)
    "Inserts tempo elements for the given parms in the given style."
    (if parms
        (list 'l "* @param " (car parms) 'p '> 'n
            (im-doxymacs-parm-tempo-element (cdr parms)))
        nil))

(defun im-doxymacs-parm-tempo (parms)
    "Inserts tempo elements for parms"
    (if parms
        (list 'l "*" '> 'n (im-doxymacs-parm-tempo-element parms))
        ))

;; make a tempo template for a function comment
(tempo-define-template
    "im-doxymacs-function-comment"
    '((let ((next-func (doxymacs-find-next-func)))
          (if next-func
              (list
                 'l
                  ;; " " (im-doxymacs-multiline-comment-start) '> 'n
			      "/** " '> 'n
                  "* @brief" '> 'p '> 'n
                  (im-doxymacs-parm-tempo (cdr (assoc 'args next-func)))
                  (unless (string-match
                              (regexp-quote (cdr (assoc 'return next-func)))
                              doxymacs-void-types)
                      '(l "*" > n " * @return" (p "Returns: ") > n))
                  ;; (im-doxymacs-multiline-comment-end) '> 'n '>
				  "**/" '> 'n ' >
                  )
              (progn (error "Can't find next function declaration.") nil)
              )))
    "doxymacs-function-comment"
    "Insert a doxygen function comment"
    'im-doxymacs-tempo-tags)

;; Enable all my custom templates
(setq doxymacs-file-comment-template tempo-template-im-doxymacs-file-comment)
(setq doxymacs-blank-multiline-comment-template tempo-template-im-doxymacs-blank-multiline-comment)
(setq doxymacs-function-comment-template tempo-template-im-doxymacs-function-comment)

;; Enable font lock
(defun custom-doxymacs-font-lock-hook ()
    (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
        (doxymacs-font-lock)))
(add-hook 'font-lock-mode-hook 'custom-doxymacs-font-lock-hook)
