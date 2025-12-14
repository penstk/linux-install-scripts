#!/usr/bin/env bash
# Run a command in a pseudo-TTY (PTY) when possible.
# Useful for tools like Homebrew that may invalidate sudo timestamps (e.g. `sudo -k`)
# or otherwise behave differently when not attached to a TTY. Running them in a PTY
# can isolate those side-effects from the main installer session.
#
# Requires util-linux `script` with `-c`. If unavailable, the command is run normally.

# Determine once whether `script` exists and supports `-c`.
__RUN_IN_PTY_HAS_SCRIPT_C=0
if command -v script >/dev/null 2>&1; then
  if script --help 2>&1 | grep -qE '(^|[[:space:]])-c([[:space:]]|,|$)'; then
    __RUN_IN_PTY_HAS_SCRIPT_C=1
  fi
fi

run_in_pty() {
  if (($# == 0)); then
    echo "run_in_pty: missing command" >&2
    return 2
  fi

  # Allow opting out (debugging / CI).
  if [[ "${DISABLE_PTY:-0}" == "1" ]]; then
    "$@"
    return $?
  fi

  if ((__RUN_IN_PTY_HAS_SCRIPT_C == 1)); then
    local cmd
    # Build a safely-quoted command string for `script -c`.
    printf -v cmd '%q ' "$@"
    cmd="${cmd% }"
    script -q -c "$cmd" /dev/null
    return $?
  fi

  # Fallback: run directly if we can't safely create a PTY.
  "$@"
}
