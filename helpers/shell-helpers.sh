################################################################################
# Helpers for modifying shell init files
################################################################################

# Create a file (and its parent directory) if it doesn't exist.
ensure_file_exists() {
  local file="$1"

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"
}

# Ensure PATH contains a directory (without duplicates).
# Intended for quick "make it available in current session" updates.
ensure_path_contains() {
  local dir="$1"

  [[ -n "$dir" ]] || return 1

  # Normalize "/foo/bar/" -> "/foo/bar" (but keep "/" as-is).
  while [[ "$dir" != "/" && "$dir" == */ ]]; do
    dir="${dir%/}"
  done
  [[ -n "$dir" ]] || dir="/"

  case ":${PATH:-}:" in
  *":$dir:"*) ;;
  *) PATH="$dir${PATH:+:$PATH}" ;;
  esac

  export PATH
}

# Append an exact line to a file only if it isn't already present.
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

# Append a multi-line block only once, detected by a marker string.
append_block_if_missing() {
  local file="$1" marker="$2" block="$3"

  ensure_file_exists "$file"

  if ! grep -qF "$marker" "$file" 2>/dev/null; then
    # If file is non-empty and doesn't end with a newline, add one first
    if [[ -s "$file" ]] && [[ "$(tail -c 1 "$file" 2>/dev/null)" != $'\n' ]]; then
      printf '\n' >>"$file"
    fi
    printf '%s\n' "$block" >>"$file"
  fi
}

# Prepend a header to a file only once, detected by a marker string.
prepend_header_if_missing() {
  local file="$1" marker="$2" header="$3" tmp

  ensure_file_exists "$file"

  if grep -qF "$marker" "$file" 2>/dev/null; then
    return 0
  fi

  tmp="$(mktemp)" || return 1
  {
    printf '%s\n\n' "$header"
    cat "$file"
  } >"$tmp" || {
    rm -f "$tmp" 2>/dev/null || true
    return 1
  }

  mv "$tmp" "$file"
}

################################################################################
# Shell environment file helpers
################################################################################

# Returns the path to the POSIX env file (path/env only).
shell_env_file() {
  echo "${SHELL_ENV_FILE:-$HOME/.config/shell/env}"
}

# Ensures the env file exists and contains the header/guard.
ensure_shell_env_file() {
  local file marker header
  file="$(shell_env_file)"
  marker="# shell env header"

  header="$(
    cat <<'EOF'
# shell env header
# Path/env only. You may add your own exports/evals below, but do not modify or remove the header/guard lines.

if [ -n "${SHELL_ENV_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
export SHELL_ENV_LOADED=1
EOF
  )"

  prepend_header_if_missing "$file" "$marker" "$header"
}

# Returns the path to the POSIX interactive file (interactive-only init).
shell_bash_file() {
  echo "${SHELL_BASH_FILE:-$HOME/.config/shell/bash-interactive}"
}

# Ensures the Bash interactive file exists and sources the env file (and optional bash-only env).
ensure_shell_bash_file() {
  local file marker header
  file="$(shell_bash_file)"
  marker="# shell bash header"

  header="$(
    cat <<'EOF'
# shell bash header
# Bash interactive-only init (equivalent to ~/.bashrc).
# You may add your own lines below, but do not modify or remove the header/guard lines.

if [ -n "${SHELL_BASH_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
export SHELL_BASH_LOADED=1

[ -f "${SHELL_ENV_FILE:-$HOME/.config/shell/env}" ] && . "${SHELL_ENV_FILE:-$HOME/.config/shell/env}"
[ -f "${SHELL_ENV_BASH_FILE:-$HOME/.config/shell/env.bash}" ] && . "${SHELL_ENV_BASH_FILE:-$HOME/.config/shell/env.bash}"
EOF
  )"

  ensure_shell_env_file || return 1
  prepend_header_if_missing "$file" "$marker" "$header"
}

# Returns the path to the Zsh interactive file (interactive-only init).
shell_zsh_file() {
  echo "${SHELL_ZSH_FILE:-$HOME/.config/shell/zsh-interactive}"
}

# Ensures the Zsh interactive file exists and sources the env file (and optional zsh-only env).
ensure_shell_zsh_file() {
  local file marker header
  file="$(shell_zsh_file)"
  marker="# shell zsh header"

  header="$(
    cat <<'EOF'
# shell zsh header
# Zsh interactive-only init (equivalent to ~/.zshrc).
# You may add your own lines below, but do not modify or remove the header/guard lines.

if [ -n "${SHELL_ZSH_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
export SHELL_ZSH_LOADED=1

[ -f "${SHELL_ENV_FILE:-$HOME/.config/shell/env}" ] && . "${SHELL_ENV_FILE:-$HOME/.config/shell/env}"
[ -f "${SHELL_ENV_ZSH_FILE:-$HOME/.config/shell/env.zsh}" ] && . "${SHELL_ENV_ZSH_FILE:-$HOME/.config/shell/env.zsh}"
EOF
  )"

  ensure_shell_env_file || return 1
  prepend_header_if_missing "$file" "$marker" "$header"
}

# Small hook snippet to source the env file from login dotfiles.
shell_env_login_hook_block() {
  cat <<'EOF'
# shell env login hook
[ -f "${SHELL_ENV_FILE:-$HOME/.config/shell/env}" ] && . "${SHELL_ENV_FILE:-$HOME/.config/shell/env}"
EOF
}

# Small hook snippet to source the bash file from ~/.bashrc / oh-my-bash custom.
shell_bash_hook_block() {
  cat <<'EOF'
# shell bash hook
[ -f "${SHELL_BASH_FILE:-$HOME/.config/shell/bash-interactive}" ] && . "${SHELL_BASH_FILE:-$HOME/.config/shell/bash-interactive}"
EOF
}

# Small hook snippet to source the zsh file from ~/.zshrc / oh-my-zsh custom.
shell_zsh_hook_block() {
  cat <<'EOF'
# shell zsh hook
[ -f "${SHELL_ZSH_FILE:-$HOME/.config/shell/zsh-interactive}" ] && . "${SHELL_ZSH_FILE:-$HOME/.config/shell/zsh-interactive}"
EOF
}

# Append a single line into the env file (creating it if needed).
append_shell_env_line_if_missing() {
  local line="$1"
  ensure_shell_env_file || return 1
  append_line_if_missing "$(shell_env_file)" "$line"
}

# Append a marked block into the env file (creating it if needed).
append_shell_env_block_if_missing() {
  local marker="$1" block="$2"
  ensure_shell_env_file || return 1
  append_block_if_missing "$(shell_env_file)" "$marker" "$block"
}

# Append a single line into the bash file (creating it if needed).
append_shell_bash_line_if_missing() {
  local line="$1"
  ensure_shell_bash_file || return 1
  append_line_if_missing "$(shell_bash_file)" "$line"
}

# Append a marked block into the bash file (creating it if needed).
append_shell_bash_block_if_missing() {
  local marker="$1" block="$2"
  ensure_shell_bash_file || return 1
  append_block_if_missing "$(shell_bash_file)" "$marker" "$block"
}

# Append a single line into the zsh file (creating it if needed).
append_shell_zsh_line_if_missing() {
  local line="$1"
  ensure_shell_zsh_file || return 1
  append_line_if_missing "$(shell_zsh_file)" "$line"
}

# Append a marked block into the zsh file (creating it if needed).
append_shell_zsh_block_if_missing() {
  local marker="$1" block="$2"
  ensure_shell_zsh_file || return 1
  append_block_if_missing "$(shell_zsh_file)" "$marker" "$block"
}

################################################################################
# Fish shell env + interactive file helpers
################################################################################

# Returns the path to the fish env file (path/env only).
fish_env_file() {
  echo "${FISH_ENV_FILE:-$HOME/.config/fish/conf.d/shell-env.fish}"
}

# Ensures the fish env file exists and contains the header.
ensure_fish_env_file() {
  local file marker header
  file="$(fish_env_file)"
  marker="# fish env header"

  header="$(
    cat <<'EOF'
# fish env header
# Path/env only. You may add your own set/fish_add_path lines below.
EOF
  )"

  prepend_header_if_missing "$file" "$marker" "$header"
}

# Returns the path to the fish interactive file (interactive-only init).
fish_interactive_file() {
  echo "${FISH_INTERACTIVE_FILE:-$HOME/.config/fish/conf.d/shell-interactive.fish}"
}

# Ensures the fish interactive file exists and only runs in interactive shells.
ensure_fish_interactive_file() {
  local file marker header
  file="$(fish_interactive_file)"
  marker="# fish interactive header"

  header="$(
    cat <<'EOF'
# fish interactive header
# Interactive-only fish init. You may add your own lines below.

status --is-interactive; or return
EOF
  )"

  prepend_header_if_missing "$file" "$marker" "$header"
}

# Append a single line into the fish env file (creating it if needed).
append_fish_env_line_if_missing() {
  local line="$1"
  ensure_fish_env_file || return 1
  append_line_if_missing "$(fish_env_file)" "$line"
}

# Append a marked block into the fish env file (creating it if needed).
append_fish_env_block_if_missing() {
  local marker="$1" block="$2"
  ensure_fish_env_file || return 1
  append_block_if_missing "$(fish_env_file)" "$marker" "$block"
}

# Append a single line into the fish interactive file (creating it if needed).
append_fish_interactive_line_if_missing() {
  local line="$1"
  ensure_fish_interactive_file || return 1
  append_line_if_missing "$(fish_interactive_file)" "$line"
}

# Append a marked block into the fish interactive file (creating it if needed).
append_fish_interactive_block_if_missing() {
  local marker="$1" block="$2"
  ensure_fish_interactive_file || return 1
  append_block_if_missing "$(fish_interactive_file)" "$marker" "$block"
}

################################################################################
# Ensure shell env gets sourced in bash and zsh
################################################################################
# Ensure login dotfiles source the env file (PATH/env available for login sessions/GUI).
ensure_shell_env_login_hooks() {
  local marker block
  marker="# shell env login hook"
  block="$(shell_env_login_hook_block)"

  ensure_shell_env_file || return 1

  append_block_if_missing "$HOME/.profile" "$marker" "$block"

  if [[ -f "$HOME/.bash_profile" ]]; then
    append_block_if_missing "$HOME/.bash_profile" "$marker" "$block"
  fi

  if command -v zsh >/dev/null 2>&1 || [[ -f "$HOME/.zprofile" ]]; then
    append_block_if_missing "$HOME/.zprofile" "$marker" "$block"
  fi
}

# Ensure bash interactive startup sources the bash file (preferring oh-my-bash custom when present).
ensure_shell_bash_hook() {
  local marker block
  marker="# shell bash hook"
  block="$(shell_bash_hook_block)"

  ensure_shell_bash_file || return 1

  if [[ -d "$HOME/.oh-my-bash/custom" ]]; then
    append_block_if_missing "$HOME/.oh-my-bash/custom/source-bash-interactive.sh" "$marker" "$block"
  else
    append_block_if_missing "$HOME/.bashrc" "$marker" "$block"
  fi
}

# Ensure zsh interactive startup sources the zsh file (preferring oh-my-zsh custom when present).
ensure_shell_zsh_hook() {
  local marker block
  marker="# shell zsh hook"
  block="$(shell_zsh_hook_block)"

  ensure_shell_zsh_file || return 1

  if [[ -d "$HOME/.oh-my-zsh/custom" ]]; then
    append_block_if_missing "$HOME/.oh-my-zsh/custom/source-zsh-interactive.zsh" "$marker" "$block"
    return 0
  fi

  if [[ -f "$HOME/.zshrc" ]] || command -v zsh >/dev/null 2>&1; then
    append_block_if_missing "$HOME/.zshrc" "$marker" "$block"
  fi
}
