# Use Nostr from Emacs

Currently just allows you to post a message to Nostr from the minibuffer.

https://nostr.io/p/fdb50f6a0c89825f18a8dd5d8828e62fadce6f24a3c402e8f6363b981a174fdd

## Setup
- nostr_keys.py provides a way to generate the secp256k1 keys necessary to make posts, I don't know of any emacs packages that do this. 
- Setup a venv and `pip install -r requirements.txt`
- Set the required variables in `nostr.el`, and generate a private key (can be done from the python tool)
- Load `nostr.el` into your emacs
- `M-x nostr-post` will prompt you for a message in the minibuffer and will post to a relay

