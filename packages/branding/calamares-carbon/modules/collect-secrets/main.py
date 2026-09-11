#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os
import subprocess

SECRETS_PATH = "/run/calamares-secrets.json"


def ask_password(title, text):
    while True:
        first = subprocess.run(
            ["zenity", "--password", "--title", title, "--text", text],
            capture_output=True,
        )
        if first.returncode != 0:
            return None
        pw1 = first.stdout.decode().rstrip("\n")

        second = subprocess.run(
            ["zenity", "--password", "--title", title, "--text", f"Confirm: {text}"],
            capture_output=True,
        )
        if second.returncode != 0:
            return None
        pw2 = second.stdout.decode().rstrip("\n")

        if pw1 and pw1 == pw2:
            return pw1

        subprocess.run(["zenity", "--error", "--text", "Passwords did not match, try again."])


def run():
    login_password = ask_password(
        "Account password", "Choose a password for your user account"
    )
    if login_password is None:
        return ("Installation cancelled", "No account password was provided.")

    luks_password = ask_password(
        "Disk encryption password", "Choose a passphrase to encrypt the disk"
    )
    if luks_password is None:
        return ("Installation cancelled", "No disk encryption passphrase was provided.")

    fd = os.open(SECRETS_PATH, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump({"loginPassword": login_password, "luksPassword": luks_password}, f)

    return None
