(setq inhibit-startup-message t)
(setq
 backup-directory-alist '((".+" . "~/.saves"))
 backup-by-copying t)
(setq scroll-conservatively 101)
(setq c-basic-offset 4)
(setq warning-minimum-level :error)

(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(column-number-mode)
(global-display-line-numbers-mode 1)

;; disable line numbers in these modes:
(dolist (m '(org-mode-hook
	     term-mode-hook
	     shell-mode-hook
	     eshell-mode-hook))
  (add-hook m (lambda ()
		(display-line-numbers-mode 0))))

;; (load-theme 'modus-vivendi t)

(hl-line-mode 1)
(blink-cursor-mode -1)

(recentf-mode 1)

;; When a file is loaded, open it in the place we were last working at
(save-place-mode 1)

;; When a file changes on disk, revert the buffer with disk changes
(global-auto-revert-mode 1)

(set-fringe-mode 10)

(setq help-window-select t)

(set-face-attribute 'default nil
		    :font "Fira Code"
		    :height 110)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initializes emacs' package manager, although we use use-package
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  :bind(("C-s" . swiper)))

(use-package counsel
  :diminish
  :config (counsel-mode 1))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; not using these for now, want a good high contrast theme!
(use-package doom-themes
  :init (load-theme 'doom-dracula t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; show extended help for key chords if the user waited for 0.3 seconds
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 1))

;; shows a help message in mini-buffer alongside each command
(use-package ivy-rich
  :init (ivy-rich-mode 1))

(use-package general
  :config
  (general-create-definer am/leader-keys
    :keymaps '(normal insert visual emacs)
    :global-prefix "C-SPC"))

(am/leader-keys
  :keymaps 'c++-mode-map
  "C-z" 'clang-format-buffer)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map
    (kbd "C-g") 'evil-normal-state)
  (evil-set-initial-state 'eshell-mode 'emacs))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package hydra)

(defhydra hydra-scale-text (:timeout 4)
  "scales text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(am/leader-keys
 "ts" '(hydra-scale-text/body :which-key "scale text"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/dev")
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; used for github interaction
(use-package forge)

(use-package org
  :config (setq org-ellipsis " +"
		org-hide-emphasis-markers t))

(defun clang-format-hook-for-this-buffer ()
  "Create a buffer local save hook."
  (add-hook 'before-save-hook
	    (lambda ()
	      (when (locate-dominating-file "." ".clang-format")
		(clang-format-buffer)
		nil)
	      nil)))

(add-hook 'c-mode-hook (lambda () (clang-format-hook-for-this-buffer)))
(add-hook 'c++-mode-hook (lambda () (clang-format-hook-for-this-buffer)))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-clangd-binary-path "/home/abhijat/dev/redpanda/vbuild/llvm/install/bin/clangd")
  :hook
  ((c++-mode . lsp)
   (python-mode . lsp)))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-ui)

(use-package company
  :hook
  (c++-mode . company-mode)
  (python-mode . company-mode))

(use-package clang-format
  :config (setq clang-format-style "file"))

(transient-append-suffix 'magit-rebase "-i"
  '("-b" "Keep base" "--keep-base"))

