---
name: tvos-platform-patterns
description: Use before any tvOS UI / focus / layout / animation / image-pipeline work. Captures the load-bearing patterns that the generic SwiftUI / iOS skills do NOT cover — focus engine API decision tree, sidebar / hero / shelf / detail / search / playback recipes, ten-foot type & color rules, and the gotchas that cost real iteration time (`buttonStyle(.plain)` destroying focus, `@Query` cascading "Cannot find X in scope" errors, defaultFocus vs. onAppear racing). Triggers on tvOS, Apple TV, Siri Remote, focus engine, hero carousel, shelf row, ten-foot UI, "the focus is wrong", focusable, defaultFocus, prefersDefaultFocus, focusSection, hoverEffect, .card button style, Top Shelf, NSUserActivity, AVPlayerViewController, ten-foot, 10ft, dark-first, 29pt.
---

# tvOS Platform Patterns

A compact reference for building tvOS 17+ apps. Captures the rules that don't fit anywhere else — most of the generic `all-ios-skills:*` content applies on tvOS, but **focus, the Siri Remote, ten-foot typography, the image pipeline at 4K, and the sidebar/hero/shelf/detail/search/playback shape** are tvOS-specific and have to be learned the hard way otherwise.

## When to invoke

- Building or debugging any tvOS view
- Focus is wrong: skipping items, trapping, lighting the wrong thing, not landing where you want on appear
- Image render is slow or blurry on Apple TV
- Touching a `Button` and discovering it's not focusable
- Designing a Home / Browse / Detail / Player screen
- Wiring App Intents, NSUserActivity (Up Next), or Top Shelf
- Anything that involves the Siri Remote's directional surface, play/pause, or back

If the question is purely about SwiftUI patterns (state, view composition, environment) and would apply on iOS too, use `all-ios-skills:swiftui-patterns`. For navigation primitives (NavigationStack, NavigationSplitView, sheet, deep linking), `all-ios-skills:swiftui-navigation`. For Liquid Glass (tvOS 26+), `all-ios-skills:swiftui-liquid-glass`. This skill is the **tvOS-only complement** — focus engine, ten-foot rules, and shape recipes.

---

## Five unbreakable rules (the backstops)

When in doubt, check against these:

1. **Dark-first, 29 pt body floor, 90/60 safe area.** Light themes lose; body text under 29 pt is unreadable at 8–12 ft.
2. **Back is sacred — never intercept outside player / modal.** Users learn the Back button's contract from every other app; do not break it.
3. **Reachability contract.** Every focusable element is reachable from every other via directional arrows, in every direction that has content. If you can't reach it, it's broken.
4. **No `.buttonStyle(.plain)` on tvOS.** It destroys focusability silently. Use `.borderless` + custom focus treatment, or `.buttonStyle(.card)`, or a custom `ButtonStyle` that reads `@Environment(\.isFocused)`.
5. **Preserve focus across state changes by stable identifier, not by index.** When data refreshes, focus should follow the *item*, not the slot.

---

## Focus engine — the API surface

The single most-mis-used part of the platform. Every tvOS app lives or dies on its focus engine work.

| API | Role | When to use |
|---|---|---|
| `@FocusState` (Bool) | Single focusable's state | Only one item being programmatically focused |
| `@FocusState` (enum) | Multi-target in one scope | 2+ possible focus targets |
| `.focused($state)` / `.focused($state, equals: .x)` | Bind a view to FocusState | Read and drive focus programmatically |
| `.focusable()` | Make a non-interactive view participate | Custom views — `Button`s are focusable for free |
| `.focusable(_: interactions:)` | Specify activation semantics | `.activate`, `.edit`, or `[.activate, .edit]` |
| `.focusEffect()` / `.focusEffectDisabled()` | Custom focus treatment / suppress system halo | When rendering focus yourself via `@Environment(\.isFocused)` |
| `.focusSection()` | Mark a container as a traversal unit | Sidebar, content pane, each shelf — use for irregular layouts |
| `.focusScope()` + `@Namespace` | Reset-able focus boundary | Modal roots where `defaultFocus` should retarget on re-entry |
| `.defaultFocus($state, .value)` | Declarative initial focus | **Preferred** over imperative `onAppear` (avoids race) |
| `.prefersDefaultFocus(_:in:)` | Specific view prefers default within scope | Older API; `defaultFocus` is cleaner |
| `.onMoveCommand` / `.onExitCommand` / `.onPlayPauseCommand` | Intercept Siri Remote commands | Sparingly — only when the focus engine wouldn't consume them |
| `.hoverEffect(.highlight \| .lift)` | System focus treatment | Stock behavior on posters/buttons — don't stack with custom scale |
| `@Environment(\.isFocused)` | Read current view's focus | In `PrimitiveButtonStyle` / custom styles |

### Decision tree — "I need X focus behavior"

- **One initial focus on appear?** → `.defaultFocus($state, .x)`. Not `onAppear` — that races.
- **Initial focus that does NOT survive — refocus on each re-entry?** → wrap content in `.focusScope($ns)` so `defaultFocus` re-applies.
- **Custom view that needs to be focusable?** → `.focusable()`. Or wrap in a `Button` and style it.
- **Sidebar / sectioned layout where directional traversal feels weird?** → `.focusSection()` on each container.
- **Card needs to render its own focus state?** → `.focusEffectDisabled()` + `@Environment(\.isFocused)` in the style.

---

## Gotchas that cost real iteration time

These are repeated experiences across tvOS projects — fix the symptom *and* know the cause:

- **`.buttonStyle(.plain)` destroys focusability.** Silent. Looks correct on iOS, dead on tvOS. Use `.borderless` or `.card`, or a custom `ButtonStyle`.
- **`@Query` macro in a view can cascade "Cannot find X in scope" errors across other top-level views in the same file** when the macro expansion confuses SourceKit. Symptom: a wall of unrelated resolution errors after touching one `@Query` view. Fix: move data fetching out of that view (use a parent + plain `let`).
- **SourceKit phantom errors are stale index, not real.** Cross-file "Cannot find X in scope" warnings on tvOS often disappear after a clean build. Trust `xcodebuild`, not the editor squiggles.
- **`defaultFocus` race on first appear** if you also set `onAppear` to imperatively focus something. Pick one — `defaultFocus` is preferred.
- **Initial-focus views (heroes, first-tab landings) sometimes don't claim focus** even with `defaultFocus`. Fall back to: store `@FocusState`, set the value in `.task { @MainActor in await Task.yield(); state = .hero }`. The yield matters.
- **`NavigationPath` bleeds across tab switches** unless you reset it when the user leaves the tab via the sidebar. Symptom: tab remembers a stale push-stack from last visit.
- **Pushing `AVPlayerViewController` via SwiftUI `fullScreenCover` is fragile.** Present via UIKit `present(_:animated:)` instead. Create a fresh `AVPlayer` at the resume timecode — don't pass shared players across views.
- **Split-file Home components can confuse SourceKit** on big views. If resolution stays broken, consolidate Home-only components back into `HomeView.swift`.

---

## Shape recipes (the load-bearing screens)

### Sidebar / nav

- 5+ destinations → sidebar (~80 pt collapsed / ~280 pt expanded, auto-expand on focus entry). 3–4 → tab bar.
- Mark sidebar and content pane with `.focusSection()`.
- Reset each tab's `NavigationPath` when the user leaves the tab.

### Hero carousel

- 7–8 second rotation, crossfade, subtle Ken Burns (scale 1.00 → 1.05).
- Pause on focus entry.
- Title + category + year/runtime. **No synopsis** at 10 ft.
- Randomize the pool per launch from top-N-by-popularity.
- **Imperatively claim focus on appear** — `defaultFocus` alone is unreliable for "first thing you see."

### Shelf row

- Card: 200×300 pt portrait or 380×214 pt landscape (match content aspect).
- 30–40 pt between cards.
- Title under card, **on focus only** (Infuse pattern) is cleanest.
- Focus effect: scale 1.08 + soft drop shadow (radius 20 pt, opacity 0.3) + accent glow.

### Detail screen

- **Auto-focus Play on entry** (Plex's miss is the #1 complained-about detail behavior).
- Full-bleed backdrop top ~45–60 %. Poster lower-left, metadata to its right.
- Play button pill, pinned at the seam (~Y = 55 %).
- "More Like This" shelf at the bottom.
- Back = pop. Don't intercept.

### Search

- Use Apple's directional keyboard (`.searchable`) — Siri dictation comes free.
- Live results; don't require submit.
- Never invent a grid keyboard.

### Playback

- `AVPlayerViewController` baseline. Minimal custom chrome.
- Persist timecode (not percent) for resume.
- Info panel: chapters, subtitles, audio, runtime, source attribution.

---

## Ten-foot rules

- **Type**: 29 pt body floor. Header hierarchy: 76 / 57 / 38 / 29 / 23 pt. Never below 23 pt.
- **Safe area**: 90 pt horizontal, 60 pt vertical. Margins beyond that.
- **Color**: dark-first. Reserve brightness for the focused element; surrounding cards should be quiet. Brand accents used sparingly (focus glow, shelf dot).
- **Touch-target → focus-reach.** Stop thinking in points-of-finger; think in arrow presses to traverse.

---

## Image pipeline at 4K

- Match decoded size to displayed size at @2x. A 240×360 pt card needs 480×720 px decoded — not the full 1500×2250 source.
- ImageIO downsample in one pass (`CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceThumbnailMaxPixelSize`).
- Cache the decoded result, not the raw bytes — decode cost dwarfs disk.
- Posters from TMDb: `w500` is 500×750 native; that's already good for a 240×360 pt card.

---

## Remote, App Intents, Top Shelf

- App Intents: declare `AppIntent` + `AppShortcutsProvider` for "Hey Siri, [verb] on [app]" voice launches. Pairs naturally with random / surprise-me features.
- NSUserActivity: declare on Detail to enable "Hey Siri, add this to my Up Next" (Apple TV system watchlist).
- Top Shelf: extension with `.sectioned` style. Read from App Group container the main app refreshes via `BGAppRefreshTask`. Tight memory limits — keep work minimal.
- Custom `.onPlayPauseCommand` is fine on media-context screens. Anywhere else, leave it to the focus engine.

---

## When to bootstrap a project playbook

Once your project has ≥ 3 of {Home / Browse / Detail / Player / Search}, the patterns above start needing project-specific adaptations (shelf taxonomy, hero rotation pool, focus contract per tab). At that point, bootstrap a `docs/tvos-playbook.md` in the project — same structure as this skill but with the project's concrete choices, decision references, and citations. Use this skill as the seed.

Archive Watch's `docs/tvos-playbook.md` (590 lines, source-cited across HIG / WWDC 2020–2025 / shipping apps) is the working reference example.

---

## Sources

- Apple Human Interface Guidelines — Designing for tvOS
- WWDC20 #10049 *Create great designs for tvOS*
- WWDC21 #10046 *Design for the Siri Remote*
- WWDC22 #10032 *Dive into App Intents*
- App Store Review Guidelines 2.5.1, 4.0
- AVPlayerViewController docs
- Field analysis: Apple TV app (17.2+), Channels, UHF, Plex, Infuse
- Production iteration: Archive Watch project (`docs/tvos-playbook.md`, commits `e62601c`, `a8188fe`, `1f789b1`, `f7fe380`)
