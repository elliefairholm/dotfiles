{ pkgs, lib, ... }:
{
  # Claude Code keeps its user settings in ~/.claude/settings.json, and it WRITES
  # to that file itself (theme, /config preferences, "dialog accepted" flags,
  # /autocompact). So it must not be managed with home.file: that would make it a
  # read-only symlink into the nix store and break those writes.
  #
  # Instead merge in only the keys we want to pin and leave the rest of the file,
  # and its mutability, alone. Idempotent: re-running just re-asserts these keys.
  #
  #   attribution.commit     = ""     -> no Co-Authored-By trailer on commits
  #   attribution.sessionUrl = false  -> no Claude-Session trailer from remote sessions
  #
  # (includeCoAuthoredBy is deprecated in favour of the attribution object.)
  home.activation.claudeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settings="$HOME/.claude/settings.json"
      $DRY_RUN_CMD mkdir -p "$(dirname "$settings")"

      current='{}'
      if [ -s "$settings" ]; then
        current="$(cat "$settings")"
      fi

      tmp="$(mktemp)"
      if printf '%s' "$current" | ${pkgs.jq}/bin/jq \
           '.attribution.commit = "" | .attribution.sessionUrl = false' > "$tmp"; then
        $DRY_RUN_CMD mv "$tmp" "$settings"
      else
        rm -f "$tmp"
        echo "claude: skipped settings merge (invalid JSON in $settings)" >&2
      fi
    '';
}
