# Game Timers — iCUE Widget

Multiple named countdown timers for the **Corsair XENEON EDGE** and other iCUE LCD displays. Designed for gaming: track respawns, buffs, boss timers, cooldowns — anything with a countdown.

## Download & Install

1. Go to [**Releases**](https://github.com/mfic/icue-timer/releases) and download `timer.icuewidget` from the latest release.
2. Double-click the file — iCUE opens and installs it automatically.
3. Add it to your LCD layout from the iCUE widget library.

> Requires **iCUE 5+** and a supported LCD device (XENEON EDGE, iCUE LINK AIO pump head, or VANGUARD keyboard LCD).

## Features

| Feature | Description |
|---|---|
| **Multiple timers** | Add as many timers as you need, side-by-side on the display |
| **Named timers** | Each timer has a custom name (up to 24 characters) |
| **Color tags** | Pick one of 8 colors per timer for instant visual identification |
| **Loop mode** | Timer auto-restarts 2 seconds after expiry — great for recurring events |
| **Warning threshold** | Card turns amber when remaining time falls below a configurable threshold |
| **Expiry alert** | Card flashes red + triple ascending beep when time is up |
| **Countdown beeps** | Single beep at 60 s, 30 s, 10 s, and 5 s remaining |
| **Presets** | Save frequently used timer configs and spawn them in one tap |
| **Persistent** | Timers survive iCUE restarts — state is stored locally |

## Using the Widget

### Adding a timer

Tap **+ Timer** in the header to open the editor:

- **Name** — what this timer is for
- **Duration** — use the `−` / `+` steppers for Hours / Min / Sec
- **Color** — choose from 8 color swatches
- **Loop** — toggle on to auto-restart after expiry
- **Warn at** — set a warning threshold in seconds (steps of 5); card turns amber when remaining time hits this value
- Tap **Save & Start** — the timer starts immediately

Tap **★ Preset** before saving to store the config for reuse. Access presets via **★ Presets** in the header.

### Timer card controls

| Button | Action |
|---|---|
| **▶ Start** | Start or resume the timer |
| **⏸ Pause** | Pause without resetting |
| **⏹ Stop** | Stop and reset to full duration |
| ↺ | Reset to full duration (visible when paused) |
| ✎ | Edit name, duration, color, loop and warn settings |
| ✕ | Delete the timer |
| *Tap expired card* | Reset a "TIME'S UP" card with one tap |

### Global controls (header)

| Button | Action |
|---|---|
| **▶ All** | Start / resume all non-expired timers |
| **⏸ All** | Pause all running timers |
| **⏹ All** | Stop and reset all timers |
| **↺ All** | Reset all timers to full duration |

### iCUE settings

Open the widget settings panel in iCUE to adjust:

| Setting | Default | Description |
|---|---|---|
| Alert Color | Red `#e94560` | Color for the expiry flash and notification banner |
| Background | Dark `#0f0f1a` | Widget background color |
| Transparency | 100 % | Background opacity |
| Sound Alerts | On | Disable to silence all beeps |

## Build from source

Requires [just](https://github.com/casey/just) and Docker Desktop.

```sh
# Build the shared packager image (once)
cd ../icue-widgetbuilder
just build-packager

# Dev server at http://localhost:8888
cd ../icue-timer
just dev

# Build timer.icuewidget → dist/timer.icuewidget
just package

# Build and open in iCUE
just install
```

## Releasing a new version

Tag the commit — GitHub Actions builds and publishes the release automatically:

```sh
git tag v1.2.0
git push origin v1.2.0
```

The workflow stamps the version into `manifest.json`, zips `src/` into `timer.icuewidget`, and attaches it to a GitHub Release.

## Device support

| Device | Type |
|---|---|
| XENEON EDGE 14.5" | `dashboard_lcd` |

The widget is built for the wide dashboard slot. Pump LCD and keyboard LCD support can be added by extending `supported_devices` in `manifest.json`.

## License

MIT
