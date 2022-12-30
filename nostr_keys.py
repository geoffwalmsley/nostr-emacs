import json
import sys
import time
from secrets import token_bytes
from hashlib import sha256
from typing import List

import secp256k1

def create_seed(filename: str) -> str:
    seed = token_bytes(32)
    with open(filename, "w") as f:
        f.write(seed.hex())
    return seed.hex()

def load_seed(filename: str) -> str:
    with open(filename, "r") as f:
        seed = f.read()
    return seed

def secp_key(seed):
    key = secp256k1.PrivateKey(bytes.fromhex(seed))
    return key

def pk(key):
    return key.pubkey.serialize()[1:]

def sk(key):
    return key.private_key

def secp_sign(message, sk):
    key = secp_key(sk)
    sig = key.schnorr_sign(bytes.fromhex(message), None, raw=True)
    return sig

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "sign":
            message = sys.argv[2]
            sk = sys.argv[3]
            sig = secp_sign(message, sk)
            print(sig.hex())
        elif sys.argv[1] == "load_key":
            filename = sys.argv[2]
            sk = load_seed(filename)
            print(sk)
        elif sys.argv[1] == "get_pk":
            seed = sys.argv[2]
            key = secp_key(seed)
            print(pk(key).hex())
        
