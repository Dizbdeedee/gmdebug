((nil . ((eval .
(eval-after-load "~/.emacs.d/init_finish.el"
	(defun my-project-function ()
		(when mine-in-use
			(defun project-run ()
				(interactive)
				(let ((name (buffer-file-name)))
				(le-run-eshell-other-window)
				(run-this-in-eshell (concat "lix buildall.hxml"))
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
)
))))
