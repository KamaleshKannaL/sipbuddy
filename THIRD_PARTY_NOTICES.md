# Third-party software

SipBuddy is free to use (see `LICENSE`). It is built with, and its downloads
include, the following software under their own licenses.

## Shipped as a separate program

### FFmpeg 7.1.1 — LGPL 2.1 or later

The downloads include a small `ffmpeg` / `ffmpeg.exe` that SipBuddy runs to
read character videos. It is an LGPL build (no GPL or non-free parts):
decoders, scaling and a JPEG encoder only.

- License: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
- Source: https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz
- Exact build recipe: [`ffmpeg/build.sh`](https://github.com/KamaleshKannaL/sipbuddy/blob/main/ffmpeg/build.sh)

You may replace it with any other ffmpeg build: put yours next to SipBuddy
with the same name.

## Compiled into SipBuddy

| Component | License |
|---|---|
| [Wails](https://github.com/wailsapp/wails) | MIT |
| [fyne.io/systray](https://github.com/fyne-io/systray) | Apache 2.0 |
| [go-ole](https://github.com/go-ole/go-ole) | MIT |
| [godbus/dbus](https://github.com/godbus/dbus) | BSD 2-Clause |
| [golang.org/x/sys](https://pkg.go.dev/golang.org/x/sys) | BSD 3-Clause |
| [React](https://react.dev) | MIT |
| [Instrument Sans](https://github.com/Instrument/instrument-sans) (via Fontsource) | SIL Open Font License 1.1 |

## Used at run time, not included

- Windows: Microsoft Edge WebView2 Runtime (part of Windows 10/11; the
  installer can fetch Microsoft's official setup if it is missing).
- Linux: WebKitGTK, GTK 3, speech-dispatcher, from the system.
