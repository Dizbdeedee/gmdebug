((nil . (
		 (local-run-project . "lix build.hxml")
		 (eval .
(eval-after-load "~/.emacs.d/init_finish.el"
  (progn
	(defun my-project-function ()
		(when mine-in-use
			(defun project-run ()
				(interactive)
				(let (
					  (proj local-run-project)
					  (name (buffer-file-name)))
				(le-run-eshell-other-window)
				(run-this-in-eshell (concat proj))
				(le-ev-l)))
			(defun project-format ()
				(interactive)
				(let ((name (buffer-file-name)))
				(le-run-eshell-other-window)
				(run-this-in-eshell (concat "fossil-hooks/format.cmd"))))
			(evil-leader-def
				"j" 'project-run
				"kk" 'le-checkstyle-compile
				"kf" 'project-format
				))
	)
	(my-project-function))
)
))))
