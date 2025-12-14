################################################################################
# Helpers for modifying shell init files
################################################################################

ensure_file_exists() {
  local file="$1"

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"
}

append_line_if_missing() {
  local file="$1" line="$2"

  ensure_file_exists "$file"

  if ! grep -qxF -- "$line" "$file" 2>/dev/null; then
    # If file is non-empty and doesn't end with a newline, add one first
    if [[ -s "$file" ]] && [[ "$(tail -c 1 "$file" 2>/dev/null)" != $'\n' ]]; then
      printf '\n' >>"$file"
    fi
    printf '%s\n' "$line" >>"$file"
  fi
}

append_block_if_missing() {
  local file="$1" marker="$2" block="$3"

  ensure_file_exists "$file"

  if ! grep -qF "$marker" "$file" 2>/dev/null; then
    printf '%s\n' "$block" >>"$file"
  fi
}
