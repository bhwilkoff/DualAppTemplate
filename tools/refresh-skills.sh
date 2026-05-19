#!/usr/bin/env bash
# refresh-skills.sh — re-sync vendored skills/commands from upstream
# sources, so this template stays current.
#
# Marketplace skills get pulled from their git origins; user-authored
# skills get re-copied from ~/.claude/ in case you've edited them
# globally and want to update the bundled copy.
#
# Safe to re-run. Reports what changed.

set -euo pipefail

TEMPLATE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$TEMPLATE_ROOT/.claude/skills"
COMMANDS_DIR="$TEMPLATE_ROOT/.claude/commands"

USER_CLAUDE="$HOME/.claude"
MARKETPLACES="$USER_CLAUDE/plugins/marketplaces"
PLUGIN_CACHE="$USER_CLAUDE/plugins/cache"

# Marketplace skills — sourced from your installed plugin marketplaces
SWIFT_IOS_SKILLS_SRC="$MARKETPLACES/swift-ios-skills/skills"
UI_UX_PRO_MAX_SRC="$MARKETPLACES/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max"
FRONTEND_DESIGN_SRC="$PLUGIN_CACHE/claude-plugins-official/frontend-design/unknown/skills/frontend-design"

# User-authored — live in ~/.claude/, refreshed alongside marketplace pulls
USER_SKILLS_SRC="$USER_CLAUDE/skills"
USER_KUI_SRC="$USER_CLAUDE/commands/KUI"

say()   { printf "\033[1;34m▸\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m!\033[0m %s\n" "$*" >&2; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
fail()  { printf "\033[1;31m✗\033[0m %s\n" "$*" >&2; exit 1; }

# 1. Pull marketplace updates ------------------------------------------------
say "Pulling marketplace updates..."

for repo in \
  "$MARKETPLACES/swift-ios-skills" \
  "$MARKETPLACES/ui-ux-pro-max-skill"
do
  if [ -d "$repo/.git" ]; then
    name=$(basename "$repo")
    before=$(git -C "$repo" rev-parse --short HEAD)
    git -C "$repo" pull --ff-only --quiet 2>/dev/null || warn "could not pull $name (uncommitted changes? offline?)"
    after=$(git -C "$repo" rev-parse --short HEAD)
    if [ "$before" != "$after" ]; then
      ok "$name updated: $before → $after"
    else
      ok "$name up to date ($before)"
    fi
  else
    warn "$(basename "$repo") is not a git checkout — skipping pull"
  fi
done

# claude-plugins-official is a meta-marketplace; frontend-design comes
# from its plugin cache rather than a top-level git checkout. Updates
# arrive via Claude Code's plugin refresh, not git.

# 2. Sync marketplace skills into vendored copy ------------------------------
say "Syncing marketplace skills into $SKILLS_DIR ..."

sync_marketplace_skill() {
  local src="$1"
  local label="$2"
  if [ ! -d "$src" ]; then
    warn "$label source missing at $src — skipping"
    return
  fi
  # Per-skill copy so we don't blow away user-authored siblings
  local count=0
  if [ -f "$src/SKILL.md" ]; then
    # single-skill source (e.g. ui-ux-pro-max, frontend-design)
    local name=$(basename "$src")
    rsync -a --delete "$src/" "$SKILLS_DIR/$name/"
    count=1
  else
    # multi-skill source (e.g. swift-ios-skills/skills/)
    for skill in "$src"/*/; do
      [ -d "$skill" ] || continue
      local name=$(basename "$skill")
      rsync -a --delete "$skill" "$SKILLS_DIR/$name/"
      count=$((count + 1))
    done
  fi
  ok "$label: $count skill(s) synced"
}

sync_marketplace_skill "$SWIFT_IOS_SKILLS_SRC" "swift-ios-skills"
sync_marketplace_skill "$UI_UX_PRO_MAX_SRC"    "ui-ux-pro-max"
sync_marketplace_skill "$FRONTEND_DESIGN_SRC"  "frontend-design"

# 3. Sync user-authored skills ----------------------------------------------
# These are the ones you wrote yourself in ~/.claude/skills/. They're not
# in any marketplace, so they only update when you edit them globally and
# re-run this script.
say "Syncing user-authored skills..."

if [ -d "$USER_SKILLS_SRC" ]; then
  count=0
  for skill in "$USER_SKILLS_SRC"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    rsync -a --delete "$skill" "$SKILLS_DIR/$name/"
    count=$((count + 1))
  done
  ok "user skills: $count synced from ~/.claude/skills/"
else
  warn "$USER_SKILLS_SRC not found — no user-authored skills to sync"
fi

# 4. Sync KUI slash commands ------------------------------------------------
say "Syncing KUI commands..."

if [ -d "$USER_KUI_SRC" ]; then
  mkdir -p "$COMMANDS_DIR/KUI"
  rsync -a --delete "$USER_KUI_SRC/" "$COMMANDS_DIR/KUI/"
  count=$(ls "$COMMANDS_DIR/KUI/"*.md 2>/dev/null | wc -l | tr -d ' ')
  ok "KUI commands: $count synced from ~/.claude/commands/KUI/"
else
  warn "$USER_KUI_SRC not found — no KUI commands to sync"
fi

# 5. Summary ----------------------------------------------------------------
total_skills=$(ls "$SKILLS_DIR" | wc -l | tr -d ' ')
total_commands=$(ls "$COMMANDS_DIR" | wc -l | tr -d ' ')
total_size=$(du -sh "$TEMPLATE_ROOT/.claude" | cut -f1)

echo
ok "Refresh complete."
echo "   Skills: $total_skills    Commands: $total_commands    Bundle size: $total_size"
echo
echo "Next: review with 'git diff', commit, push."
