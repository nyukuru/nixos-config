#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os
import subprocess

SECRETS_PATH = "/run/calamares-secrets.json"


def ask_password(title, text):
    while True:
        result = subprocess.run(
            ["zenity", "--password", "--title", title, "--text", text],
            capture_output=True,
        )
        if result.returncode != 0:
            return None
        password = result.stdout.decode().rstrip("\n")

        if password:
            return password

        subprocess.run(["zenity", "--error", "--text", "Password cannot be empty, try again."])


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
