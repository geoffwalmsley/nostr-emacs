;; -*- lexical-binding:t -*-

(require 'websocket)
(require 'cl)

;; Set these variables to use the tool

(setq nostr-root "")
(setq nostr-python-path (concat nostr-root ""))
(setq nostr-sk-path (concat nostr-root ""))
(setq nostr-keys-python (concat nostr-root "nostr_keys.py"))


(defun nostr-get-sk (filename)
  (replace-regexp-in-string "\n$" ""
    (shell-command-to-string
      (format "%s %s load_key %s" nostr-python-path nostr-keys-python filename)))
  )


(defun nostr-get-pk (sk)
  (replace-regexp-in-string "\n$" ""
    (shell-command-to-string
      (format "%s %s get_pk %s" nostr-python-path nostr-keys-python sk)))
  )


(defadvice json-encode (around encode-nil-as-json-empty-object activate)
  (if (null object)
    (setq ad-return-value "[]")
    ad-do-it))


(defun nostr-compute-id (pk created_at kind content)
  (secure-hash 'sha256 (json-encode-list (list 0 pk created_at kind nil content)))
  )


(defun nostr-sign (message sk)
  (replace-regexp-in-string "\n$" ""
    (shell-command-to-string
      (format "%s %s sign %s %s" nostr-python-path nostr-keys-python message sk)))
  )


(defun nostr-create-event (sk kind content)
  (let* ((pk (nostr-get-pk sk))
	 (created_at (time-convert (current-time) 'integer))
	 (id (nostr-compute-id pk created_at kind content))
	 (sig (nostr-sign id sk))
	 )
    (format "[\"EVENT\",%s]" (json-encode-alist `((id . ,id) (pubkey . ,pk) (created_at . ,created_at) (kind . ,kind) (tags . ()) (content . ,content) (sig . ,sig))))
    )
  )


(defun nostr-send-message (event)
  (setq nostr-socket
      (websocket-open "wss://nostr-pub.wellorder.net"
		      :on-message (lambda (_websocket frame)
                         (nostr-write-to-buf (format "ws frame: %S" (websocket-frame-text frame))))
		      :on-close (lambda (_websocket) (message "WS Closed"))
		      :on-error (lambda (_websocket frame)
				  (nostr-write-to-buf (format "ERROR: %S" (websocket-frame-text frame))))) 
      )
  (sleep-for 2)
  (websocket-send-text nostr-socket event)
  (websocket-close nostr-socket)
  ()
  )


(defun nostr-post (message)
  (interactive "s")
  (nostr-send-message (nostr-create-event (nostr-get-sk nostr-sk-path) 1 message))
  )

(defun nostr-update-metadata (sk name about picture)
  (let* ((pk (nostr-get-pk sk))
	 (created_at (time-convert (current-time) 'integer))
	 (content (format "%s" (json-encode-alist `((name . ,name) (about . ,about) (picture . ,picture)))))
	 (kind 0)
	 (id (nostr-compute-id pk created_at kind content))
	 (sig (nostr-sign id sk))
	 )
    (format "[\"EVENT\",%s]" (json-encode-alist `((id . ,id) (pubkey . ,pk) (created_at . ,created_at) (kind . ,kind) (tags . ()) (content . ,content) (sig . ,sig))))
    )
  )
