#!/bin/bash

# split into two commands to allow creation of new / changed certificates without changing keys
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$SCRIPT_DIR/case3_create_keys.sh
$SCRIPT_DIR/case3_create_certs.sh
