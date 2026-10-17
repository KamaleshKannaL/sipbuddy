# Security

## Reporting a problem

Please report security issues privately through GitHub:
**Security → Report a vulnerability** on this repository. Don't open a public
issue for them. You'll get an answer within a week.

## What SipBuddy does on your computer

- **No network access.** SipBuddy never connects to the internet: no
  analytics, no update checks, no accounts. The only network use is a server
  on `127.0.0.1` (your own computer) that shows the character video you picked
  to the app's window.
- **Files it writes:** its settings and your characters in your user config
  folder (`%AppData%\SipBuddy` on Windows, `~/.config/SipBuddy` on Linux), and
  a start-at-login shortcut when you turn that on.
- **Programs it runs:** the `ffmpeg` shipped next to it, to read character
  videos, and the system's text-to-speech when voice is on.

## Checking a download

Every release lists SHA-256 checksums in `SHA256SUMS`. To check a file:

```sh
sha256sum -c SHA256SUMS --ignore-missing                                  # Linux
Get-FileHash SipBuddy-v0.4.4-windows-setup.exe -Algorithm SHA256          # Windows PowerShell
```

The result must match the line for that file in `SHA256SUMS`.
