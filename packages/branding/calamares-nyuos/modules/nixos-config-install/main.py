#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import subprocess

import libcalamares

NIXOS_CONFIG = "/home/nixos/nixos-config"
LUKS_KEYFILE = "/tmp/secret.key"


def run():
    hostname = libcalamares.globalstorage.value("nyuHostname")
    if not hostname:
        return ("installer failed", "nixos-config-generate did not record a hostname.")

    try:
        proc = subprocess.Popen(
            ["installer", "--yes", f"{NIXOS_CONFIG}#{hostname}"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        output = ""
        while True:
            line = proc.stdout.readline().decode("utf-8")
            if not line:
                break

            output += line
            libcalamares.utils.debug("installer: {}".format(line.strip()))

        exit_code = proc.wait()
        if exit_code != 0:
            return ("installer failed", output)
    except Exception as e:
        return ("installer failed", str(e))
    finally:
        try:
            os.remove(LUKS_KEYFILE)
        except FileNotFoundError:
            pass

    libcalamares.job.setprogress(1.0)
    return None
