#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
"$script_dir/validate-palettes.py"
"$script_dir/validate-editors.py"
"$script_dir/validate-cli.py"
"$script_dir/validate-release.py"
"$script_dir/generate.py" --check
