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

  if ! grep -qxF "$line" "$file" 2>/dev/null; then
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
