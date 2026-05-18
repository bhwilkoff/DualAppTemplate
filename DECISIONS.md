# [APP NAME] — Architecture & Technology Decisions

Entries capture the *why* behind choices — not the *what* (the code
already shows that). Each entry should answer: **"what would the next
developer get wrong if they didn't know this?"** Lead with the rule,
follow with `**Why:**` and `**How to apply:**`. Append-only.

Invoke the `architectural-decision-log` skill when adding a new entry.

---

## 001 — Vanilla HTML/CSS/JS for Web
*Date: YYYY-MM-DD*

No framework, no build step. GitHub Pages serves static files
directly. Framework abstractions cost more than they save at this
scale; adding one would require a build pipeline, a CI step, and a
mental model every future contributor has to carry.

**Principle**: reach for complexity only when simplicity has actually
failed, not when it might someday fail.

**How to apply**: revisit if component count exceeds ~20 OR a feature
genuinely needs reactive state across many components. Until then,
plain DOM + ES2022 + Supabase SDK via CDN.

---

## 002 — Xcode Project at Repository Root
*Date: YYYY-MM-DD*

`.xcodeproj` lives at repo root, no subdirectory, no spaces in
project name.

**Why**: Xcode Cloud requires `.xcodeproj` at the repo root for
auto-discovery. Spaces in paths cause shell-script and CI issues.
Past project (`BskyDreams-iOS/Bsky Dreams/Bsky Dreams.xcodeproj`,
two levels deep + spaces) cost hours debugging "Project does not
exist at root."

**How to apply**: when creating the Xcode project, save to repo
root. Product name has no spaces. Move scaffolded `ios/` source
files into the Xcode-created group, then delete the `ios/` directory.

---

## 003 — Shared Version Config via xcconfig
*Date: YYYY-MM-DD*

`AppVersion.xcconfig` at repo root defines `MARKETING_VERSION` and
`CURRENT_PROJECT_VERSION`. All targets reference it.

**Why**: editing version numbers via Xcode's identity panel creates
per-target overrides in `project.pbxproj` that shadow the xcconfig,
causing targets to drift silently.

**How to apply**: ALWAYS edit `AppVersion.xcconfig` directly. Never
use Xcode UI for version numbers. Bump on every ship as part of the
`feature-shipping-discipline` 7-step sequence.

---

## 004 — SwiftUI + @Observable + SwiftData (iOS)
*Date: YYYY-MM-DD*

SwiftUI for all UI. `@Observable` (iOS 17 macro) for state. SwiftData
for local persistence. UIKit only where SwiftUI lacks a native
equivalent.

**Why**: modern Apple stack, minimal boilerplate, no third-party
dependencies. iOS 17+ minimum is acceptable given current device
share.

**How to apply**: when navigating SwiftUI patterns, invoke
`all-ios-skills:swiftui-patterns`. When UIKit interop is needed (camera,
maps, AVKit), use `all-ios-skills:swiftui-uikit-interop`.

---

## 005 — Dual-Platform Feature Parity
*Date: YYYY-MM-DD*

Both platforms implement the same core feature set. Platform-specific
implementation is acceptable (Keychain vs localStorage); platform-
exclusive features are the exception, not the rule.

**Why**: users expect the same capabilities regardless of platform.
Implementation details can differ to leverage each platform's
strengths.

**How to apply**: track parity in SCRATCHPAD.md feature table. When
adding to one platform, note the equivalent work needed on the other.
Shared design tokens + API contracts mitigate the "built twice" cost.
