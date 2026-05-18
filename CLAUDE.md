# [APP NAME] — Claude Code Project Context

## Why we build

Every feature in this app is built in service of human learning and
growth — not to replace thinking, but to deepen it. At each decision
point, ask: does this design invite the user to engage more fully,
think more critically, or connect more meaningfully? If a feature
makes a person more passive, reconsider it. If it opens a door to
curiosity or collaboration, prioritize it. The goal is never a slick
product — it is a tool that makes someone more human.

**Before implementing any feature**, invoke the
`learning-orientation-design` skill — the four-question test that
operationalizes this paragraph.

---

## How we build

This project follows a methodology that lives in **global skills**
(`~/.claude/skills/`). Don't re-derive these patterns; invoke the
skill when its trigger matches.

| When | Skill |
|---|---|
| Starting any feature change | `feature-shipping-discipline` |
| Proposing UI / IA work | `binding-design-doc-discipline` |
| Designing any view | `mobile-first-density-design` + `native-platform-first` |
| Adding a list / grid / sheet | `universal-feature-states` |
| Logging an architecture decision | `architectural-decision-log` |
| Debugging a 3D / video / RealityKit feature | `3d-feature-sim-validation` + `realitykit-3d-card-rendering` |
| User pushback after 3+ iterations of "still broken" | `3d-feature-debug-loop` |

iOS-specific skills live under `all-ios-skills:<name>` (40+ skills:
swiftui-patterns, swiftui-navigation, swiftdata, ios-networking,
swiftui-liquid-glass, etc.). Design skills live under `KUI:<name>`.
Invoke by name as needed.

---

## Debugging philosophy

**Do not iterate blindly on behavior you cannot observe.** When a
feature does not work correctly and the root cause is not immediately
clear from reading the code, the first move is diagnostics — not
another implementation attempt.

1. Add observability before trying another implementation
2. Design diagnostics to answer a specific question — write down what
   you expect to see vs. what would indicate the bug
3. Isolate layers — verify each independently before changing any
4. For visual / 3D bugs you cannot directly observe, build an offline
   sim that renders the output to PNG (see `3d-feature-sim-validation`)
5. Remove diagnostics before declaring a fix complete

If user pushback returns after 3+ iterations of "still broken,"
that's the signal to invoke `3d-feature-debug-loop` and reset to
research-agent + sim-validation discipline.

---

## What this app does

<!-- FILL IN: One paragraph on what your app does and who it's for -->

Available as both a **web app** and a **native iOS app**, developed
separately but maintaining feature parity. When adding to one
platform, note the equivalent work in SCRATCHPAD.md.

---

## Web app

**Stack**: Vanilla HTML/JS — no framework, no build step. Custom CSS,
mobile-first. <!-- FILL IN: API / auth / hosting choices -->. GitHub
Pages static hosting, branch `main`, root `/`.

**Key directories**:
- `/` — root: index.html, CLAUDE.md, SCRATCHPAD.md, DECISIONS.md
- `/css/styles.css` — single main stylesheet
- `/js/api.js`, `/js/app.js` — API abstraction + view system
- `/assets/` — static assets

**Run locally**: `python3 -m http.server 8080` → visit
http://localhost:8080. Deploy: push to `main`; GitHub Pages serves
automatically.

**Conventions** (the load-bearing ones — see skills for the rest):
- All API calls through `js/api.js` — never `fetch` directly elsewhere
- CSS custom properties in `:root` in `styles.css`
- Mobile-first; all media queries use `min-width`
- No inline styles
- Error states must be user-visible (not just console logs)

**Safari layout pitfall** (from previous projects):
`body { height: 100dvh; display: flex; flex-direction: column;
overflow: hidden; }` with `main { flex: 1; overflow-y: auto;
min-height: 0; }`. NO `viewport-fit=cover`. NO `position: fixed`
overlays — they break Safari's compositor at the Dynamic Island.

---

## iOS app

**Stack**: Swift 6, SwiftUI (`@Observable`, iOS 17+), SwiftData for
local persistence, Keychain for credential storage, URLSession
direct to API (no third-party packages).

**Project structure** — Xcode Cloud compatible:

```
/                          ← repo root
├── AppName.xcodeproj/     ← at root (Xcode Cloud requirement)
├── AppName/
│   ├── App/               ← entry point
│   ├── Models/            ← data models
│   ├── Views/             ← SwiftUI views (one folder per feature)
│   ├── Components/        ← reusable UI
│   ├── Networking/        ← API client (singleton)
│   ├── Store/             ← @Observable global state
│   └── Resources/Fonts/
├── AppVersion.xcconfig    ← shared version numbers
├── ci_scripts/            ← Xcode Cloud build scripts
├── index.html             ← Web app
├── css/                   ← Web stylesheets
└── js/                    ← Web JavaScript
```

**Critical conventions** (from past production lessons — see
`all-ios-skills:*` for skill-level depth):

- **All API calls through a shared singleton** — never URLSession
  directly from views
- **Auth state owned by one manager** — views read via `@Environment`
- **Global nav state in `@Observable` store** with `NavigationPath`
- **Version numbers via `AppVersion.xcconfig` only** — never edit
  through Xcode identity panel (creates per-target overrides)
- **iOS 17+ minimum** — keychain for credentials, never UserDefaults
- **No third-party Swift packages** — Apple frameworks only

For SwiftUI patterns, navigation, animation, gestures, performance,
etc., invoke `all-ios-skills:<name>`. For Liquid Glass (iOS 26+) see
`all-ios-skills:swiftui-liquid-glass`. For 3D / RealityKit work, see
the three `*-3d-*` skills.

---

## Shared design system

**Design tokens** (both platforms):

<!-- FILL IN your palette. Two systems, kept distinct:
     - Brand (UI chrome only): primary CTA, accent, background, surface
     - Semantic (content only): success / warning / error + domain-specific

     The split is binding — never use a brand color for content meaning,
     never use a semantic color for chrome. -->

```css
:root {
  --color-primary:    #FF5C35;  /* CTAs, active states */
  --color-accent:     #0047FF;  /* links, interactive */
  --color-bg:         #FFFFFF;
  --color-surface:    #F7F7F7;
  --color-text:       #0A0A0A;
  --color-border:     #E0E0E0;
}
```

**Typography hierarchy**: three weights × two sizes = six levels.
Refuse a seventh; refactor instead. See `mobile-first-density-design`
for the discipline.

**Density rule**: density comes from removing chrome, not adding
decoration. Test at 375px before 1440px. The `mobile-first-density-design`
skill operationalizes this.

---

## When to create a binding design doc

If your project grows past ~5 views, consider adding `DESIGN.md`
(iOS) and/or `WEB-DESIGN.md` (web) as **binding design docs** that
govern every UI/IA decision. The `binding-design-doc-discipline`
skill defines the workflow: quote the rule before proposing UI work;
fix the doc, then fix the feature.

A binding design doc typically captures:
- Six core principles (native first, one verb per tab, depth ≤ 2,
  search-first, density from removal, glass = navigation only)
- Anti-patterns the project rejects (with concrete examples)
- Per-tab IA recipes
- Universal states (loading / empty / error / offline) + teaching
  surfaces (EmptyState / ErrorBanner / HintBanner / Walkthrough)

Don't create these on day 1 — wait until the project's UI complexity
warrants the doc. Once created, treat as binding.

---

## Standing instructions

- **Read the relevant skill before re-deriving a pattern.** The
  global skills exist because the patterns came from real iteration.
- **Commit messages quote the user's request verbatim** when
  applicable. See `feature-shipping-discipline`.
- **DECISIONS.md leads with WHY, not WHAT.** See
  `architectural-decision-log`.
- **Don't add features beyond what's requested.** Fix only the bug.
- **Don't refactor surrounding code.** Scoped diffs.
- **Default to writing no comments.** Only add one when the WHY is
  non-obvious — a hidden constraint, a subtle invariant, a workaround
  for a specific bug.
- **No emojis in code or commits** unless explicitly requested.

---

## Current state

See `SCRATCHPAD.md` for active milestone + feature parity status.
See `DECISIONS.md` for architecture decisions.
