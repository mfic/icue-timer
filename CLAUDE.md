# CLAUDE.md — icue-timer

Vanilla HTML/CSS/JS widget for Corsair iCUE LCD displays. No build step, no framework, no Node.js inside the widget. The renderer is **QtWebEngine 6.9.3 (Chromium 130)** — standard web APIs work; `localStorage` is available and persistent.

## Project layout

```
icue-timer/
├── src/
│   ├── index.html          # All widget logic (HTML + inline JS)
│   ├── manifest.json       # iCUE metadata, device support, version
│   ├── styles/widget.css   # All styles
│   └── resources/icon.svg  # Widget icon
├── .github/workflows/
│   └── release.yml         # Tag v*.*.* → build + GitHub Release
├── justfile                # dev / package / install recipes
└── docker-compose.yml      # nginx dev server on :8888
```

## Architecture

Everything lives in `src/index.html`. There are no modules, no imports, no bundler.

### Views

Three full-screen views toggled by adding/removing the `hidden` class:

| ID | Purpose |
|---|---|
| `view-main` | Timer card list |
| `view-edit` | Add / edit timer form |
| `view-presets` | Preset library |

### Data model

Two arrays in memory, each persisted to `localStorage` on every mutation:

```js
// Timer
{ id, name, durationSec, startedAt, stoppedAt, elapsed, color, loop, warnAt }

// Preset (same shape minus runtime fields)
{ id, name, durationSec, color, loop, warnAt }
```

**Time tracking invariants** — critical, do not change without understanding:
- `elapsed` (float, seconds) accumulates across pause/resume cycles. It is updated in `pauseTimer()` and never touched by `startTimer()`.
- `timerRemaining` when **paused** (`stoppedAt` set): `durationSec - elapsed` — uses only `elapsed`, never `stoppedAt - startedAt`.
- `timerRemaining` when **running**: `durationSec - (elapsed + (Date.now() - startedAt) / 1000)`.
- `timerIsExpired` uses `<= 0`, not `=== 0`, to handle float rounding at the end of the countdown.
- `resetTimer()` must be the single point that clears `loopTimeouts` and `warnBeeps` for a timer id.

### State that lives outside timers[]

```js
const alerted      = new Set();   // ids that have fired the expiry beep this cycle
const warnBeeps    = new Map();   // id → Set of thresholds (60/30/10/5) already beeped
const loopTimeouts = new Map();   // id → setTimeout handle for auto-restart
```

All three are cleared by `resetTimer()`. `removeTimer()` calls `resetTimer()` before splicing the array.

### iCUE integration

```js
// Global assignment — required by iCUE runtime, not a mistake
icueEvents = {
  onDataUpdated:     onIcueDataUpdated,   // fires when widget properties change
  onICUEInitialized: onIcueInitialized    // fires on first load inside iCUE
};
```

Widget properties are declared as `<meta name="x-icue-property">` tags in the `<head>`. Current properties: `accentColor`, `backgroundColor`, `transparency`, `enableSound`.

The startup branch at the bottom of the script:
```js
if (typeof iCUE_initialized === 'undefined' || !iCUE_initialized) {
  init(); // dev / standalone preview only
}
// iCUE host fires onICUEInitialized → onIcueInitialized() → init()
```

### Rendering

`renderTimers()` is called every 500 ms by `setInterval` (via `startTick()`), and also synchronously after any mutation. It does a keyed incremental update — existing cards are reused, stale ones removed, new ones appended. `card.innerHTML` is always fully rewritten each tick.

Card state classes: `running` | `warn` | `expired` (mutually exclusive, set on the card element).

`--card-color` is set as an inline CSS custom property on each card element, defaulting to the first palette color. The CSS uses `var(--card-color)` for border, progress fill, and expired flash — never `var(--accent-color)` inside card rules.

### Audio

Web Audio API, lazily initialised on first use. Two functions:
- `beep()` — three ascending sine tones (expiry alert)
- `beepWarn()` — single short sine tone (countdown intervals)

Gated by `getIcueProperty('enableSound') !== 0`.

### String safety

All user-supplied content (timer names, preset names) must go through `esc()` before being interpolated into `innerHTML`. Template literals that build card HTML already do this for every name field.

**Never use smart/curly quotes (`'` U+2018, `'` U+2019) as JS string delimiters** — they are not recognised by the JS parser and will silently break the entire script. Use straight quotes `'` (U+0027) or double quotes `"`.

## Dev workflow

```sh
# Start nginx dev server (serves src/ at http://localhost:8888)
just dev

# Stop
just stop

# Package → dist/timer.icuewidget (requires icue-packager Docker image)
just package

# Package + open in iCUE
just install
```

The packager image lives in `../icue-widgetbuilder`. Build it once with:
```sh
cd ../icue-widgetbuilder && just build-packager
```

## Release workflow

Releases are automated via `.github/workflows/release.yml`. The workflow triggers on any tag matching `v*.*.*`:

1. Stamps the tag version into `src/manifest.json`
2. Zips `src/` into `dist/timer.icuewidget`
3. Creates a GitHub Release with the file attached

To cut a release:
```sh
git tag v1.2.0
git push origin v1.2.0
```

## Known limitations / future work

- Card insertion uses `appendChild` for new cards; order is correct for append-only usage but will mismatch if a timer is inserted in the middle of an existing list (currently not possible via the UI, only if `timers[]` is manually reordered).
- Only `dashboard_lcd` device type is declared in the manifest. Pump LCD and keyboard LCD are different aspect ratios and would need layout adjustments.
- The `warnAt` stepper steps in 5-second increments. Very short timers (< 5 s) can't have a meaningful warn threshold.
