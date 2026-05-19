# Dual App Template — Web + iOS with Claude Code

Project template for building web and iOS apps in parallel with full
feature parity. Designed for Claude Code, GitHub Pages, and Xcode
Cloud. Skill-aware: the methodology lives in global skills, so this
template stays lean.

## What's in the template

```
/
├── CLAUDE.md              Project identity + skill-aware standing instructions (~150 lines)
├── SCRATCHPAD.md          Active milestone + feature parity (~70 lines)
├── DECISIONS.md           Decision log — leads with WHY (~70 lines)
├── README.md              This file
├── .claude/               Slash commands + session-start hook
├── index.html             Web app entry point
├── css/styles.css         Mobile-first CSS with custom properties
├── js/app.js, js/api.js   Web app logic + API abstraction
├── manifest.json          PWA manifest
├── assets/                Static assets
├── ios/                   iOS Swift starter (moves into Xcode project on setup)
├── AppVersion.xcconfig    Shared version numbers
├── ci_scripts/            Xcode Cloud build scripts
└── .gitignore             Build artifacts + Xcode user data
```

## Setup — 7 steps

1. **Use as template** on GitHub (or clone + re-init git)
2. **Fill in CLAUDE.md** — project name, what the app does, design
   tokens. Leave the methodology sections; they point at skills.
3. **Fill in SCRATCHPAD.md** — M1, M2 milestones with
   learning-orientation-design checks
4. **Create the Xcode project**:
   - Xcode → File → New → Project → iOS → App
   - Product Name: `AppName` (NO spaces — Xcode Cloud requirement)
   - Save to **repo root** (not a subdirectory)
   - Move `ios/` Swift files into the Xcode-created `AppName/` group,
     then delete the `ios/` directory
   - Add `AppVersion.xcconfig` to both Debug + Release configs
5. **Push to GitHub** + enable GitHub Pages (Settings → Pages → main)
6. **Xcode Cloud** (optional) — workflow in App Store Connect.
   `.xcodeproj` at root means Xcode Cloud finds it automatically.
7. **Start building** — Claude Code loads context via the
   session-start hook

## How sessions work

- Session-start hook injects CLAUDE.md + current state from
  SCRATCHPAD.md
- Slash commands: `/status`, `/milestone`, `/decision`
- Global skills (`~/.claude/skills/`) provide the methodology — see
  CLAUDE.md "How we build" for the trigger table

## Methodology — skill-aware

This template doesn't repeat the methodology that's in the global
skills. Invoke skills by name when their trigger matches:

**Workflow**:
- `binding-design-doc-discipline` — when DESIGN.md exists, quote the
  rule before proposing UI work
- `architectural-decision-log` — when adding to DECISIONS.md
- `feature-shipping-discipline` — 7-step end-to-end ship sequence

**Design**:
- `learning-orientation-design` — four-question test for new features
- `mobile-first-density-design` — density from removing chrome
- `native-platform-first` — exhaust native APIs before custom
- `universal-feature-states` — loading/empty/error/offline +
  5 teaching surfaces

**3D / RealityKit**:
- `realitykit-3d-card-rendering`, `3d-feature-sim-validation`,
  `3d-feature-debug-loop`

**iOS framework depth**: `all-ios-skills:<name>` (40+ skills covering
SwiftUI, SwiftData, networking, security, Liquid Glass, etc.).

**Design system depth**: `KUI:<name>` (system, brand, screen, review,
code, a11y, darkmode, trends, figma).

**App Store**: `app-store-screenshots` for marketing assets,
`all-ios-skills:app-store-review` for rejection prevention.

## Skills bundled with the template

Skills and slash commands are vendored directly into `.claude/` so
anyone who clones this repo has everything available immediately —
no `~/.claude/` configuration, no marketplace installs, no second
repository to track.

**What's bundled** (in `.claude/skills/` and `.claude/commands/KUI/`):

| Source | What | Update path |
|---|---|---|
| `swift-ios-skills` marketplace | 80+ Apple framework skills (SwiftUI, SwiftData, networking, Liquid Glass, App Intents, …) | refresh from upstream |
| `ui-ux-pro-max-skill` marketplace | `ui-ux-pro-max` design intelligence skill | refresh from upstream |
| `claude-plugins-official` | `frontend-design` skill | refresh from upstream |
| [ParthJadhav/app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) | `app-store-screenshots` | refresh from upstream (GitHub-tracked, cloned to `~/.claude/sources/`) |
| Template maintainer | 12 methodology + design skills (`learning-orientation-design`, `feature-shipping-discipline`, `architectural-decision-log`, `binding-design-doc-discipline`, `mobile-first-density-design`, `native-platform-first`, `universal-feature-states`, `3d-feature-*`, `realitykit-3d-card-rendering`, `tvos-platform-patterns`, `killer-ui`) | hand-edited |
| Template maintainer | `KUI:*` slash commands (a11y / brand / code / darkmode / figma / review / screen / system / trends) | hand-edited |

**Refreshing marketplace skills**: maintainer runs
`tools/refresh-skills.sh`. The script pulls latest commits from the
marketplace git checkouts in `~/.claude/plugins/marketplaces/`,
rsyncs them into `.claude/skills/`, and also re-syncs user-authored
skills from `~/.claude/skills/` and `~/.claude/commands/KUI/`. Safe
to re-run; reports diffs. Commit the changes to publish refreshed
skills to template users.

## What this template encodes

**From previous production builds**:
- Web: vanilla HTML/CSS/JS, single-page view system, API abstraction
- iOS: SwiftUI + @Observable + SwiftData, no third-party packages
- Shared: feature parity tracking, design-token alignment, dual-
  platform decision records
- Version management via xcconfig (not Xcode UI)
- Safari mobile layout pitfall (body flex column, no
  viewport-fit=cover) — see CLAUDE.md
- Xcode Cloud project-at-root requirement — see DECISIONS.md #002

**What the template intentionally doesn't bake in**:
- Specific iOS bugs from past projects (VideoPlayer crash patterns,
  share sheet quirks, etc.) — these live in skills, not the template
- DESIGN.md / WEB-DESIGN.md content — create those per-project when
  the project's UI complexity warrants it (see CLAUDE.md "When to
  create a binding design doc")

## Learning orientation

Every feature is evaluated against the four-question test before
implementation. See the `learning-orientation-design` skill:

1. Does it deepen understanding?
2. Does it invite participation?
3. Does it support human agency?
4. Clarity over cleverness?

A "no" to any is a redesign signal at proposal stage, not after
shipping.
