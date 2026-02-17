# Dolphin URL Handler (`dolphin:///`)

A lightweight URL scheme handler that opens `dolphin:///...` links directly in **Dolphin** (KDE’s file manager).

This is useful when you want a local HTML “projects dashboard” where each link opens a folder in Dolphin with one click—without relying on `.desktop` launchers or insecure browser settings. In many browsers, `file:///...` links are shown inside the browser (directory listing) instead of launching the system file manager; this handler avoids that.

---

## What it does

When you click a link like:

- `dolphin:///home/you/Projects/MyProject/`

the system routes the URL to this handler, which:
- sanitizes and validates the URL
- extracts the filesystem path
- launches Dolphin on that path (default: `dolphin --new-window <path>`)

---

## Requirements

- Linux desktop with **Dolphin** installed
- `xdg-mime` (typically installed on most distributions)
- Optional: `update-desktop-database` (nice-to-have)

---

## Installation

Clone the repository and run the installer:

```bash
git clone <YOUR_GIT_URL> dolphin-url-handler
cd dolphin-url-handler
./install.sh
```

The installer typically:
- installs the script to ~/.local/bin/open-in-dolphin.sh
- installs a desktop entry to ~/.local/share/applications/dolphin-handler.desktop
- registers the handler via:

```bash
xdg-mime default dolphin-handler.desktop x-scheme-handler/dolphin
```

## Verification

### Check the default handler

```bash
xdg-mime query default x-scheme-handler/dolphin
```

Expected output:

```plaintext
dolphin-handler.desktop
```

If it’s different, re-register:

```bash
xdg-mime default dolphin-handler.desktop x-scheme-handler/dolphin
```

### Open a test URL via the system

```bash
xdg-open "dolphin:///home/$USER/"
```

This should open Dolphin to your home directory.

### Test from a local HTML file (Firefox recommended)

Create projects.html:

```html
<!doctype html>
<html>
  <body>
    <ul>
      <li><a href="dolphin:///home/your_user/">Open Home in Dolphin</a></li>
      <li><a href="dolphin:///home/your_user/Projects/">Open Projects</a></li>
    </ul>
  </body>
</html>
```

Open it in Firefox and click a link. The first time, Firefox should prompt you to allow opening external links with the registered handler. You can usually tick “Remember” to avoid repeated prompts.

## Configuration

The script supports optional environment variables:

- DEBUG=true
  Enables debug logging. Default: false.

- LOGFILE=/path/to/file.log
  Sets a custom log file path. Default: ~/.cache/dolphin-handler.log.

- DOLPHIN_BIN=/full/path/to/dolphin
  Forces the Dolphin binary used by the handler (useful if the handler runs with a minimal PATH).

Examples:

```bash
DEBUG=true xdg-open "dolphin:///home/$USER/"
```

```bash
DEBUG=true LOGFILE="$HOME/.cache/dolphin-handler.log" xdg-open "dolphin:///home/$USER/"
```

```bash
DOLPHIN_BIN="/usr/bin/dolphin" xdg-open "dolphin:///home/$USER/"
```

## Debug

### Confirm the desktop entry points to the right script

```bash
grep -n '^Exec=' ~/.local/share/applications/dolphin-handler.desktop
```

It should reference your installed script, for example:

```ini
Exec=/home/<you>/.local/bin/open-in-dolphin.sh %u
```

If the Exec= path is wrong, reinstall (or fix it manually and re-run xdg-mime).

### Inspect the log (when DEBUG=true)

Default log file:

```plaintext
~/.cache/dolphin-handler.log
```

View the last lines:

```bash
tail -n 50 ~/.cache/dolphin-handler.log
```

### Common issues

- Browser shows the “open with handler” prompt but nothing happens
  - Run the “Direct terminal test” section below to verify the script itself works.
  - Ensure Exec= in the .desktop file points to the correct script location.

- dolphin not found
  - Set DOLPHIN_BIN=/usr/bin/dolphin (or your distro’s actual location).

- Paths with special characters
  - The script may implement minimal percent-decoding (e.g. %20 for spaces). If you need full decoding, extend it carefully (keep changes auditable and simple).

## Direct terminal test (script-only)

This bypasses the browser and xdg-open, and runs the script directly. It is the fastest way to isolate problems.

```bash
DEBUG=true ~/.local/bin/open-in-dolphin.sh "dolphin:///home/$USER/"
echo "exit=$?"
tail -n 50 ~/.cache/dolphin-handler.log
```

If this opens Dolphin correctly, the script is fine; any remaining issue is likely in the browser/portal layer or in handler registration.

## Uninstallation

Run:

```bash
./uninstall.sh
```

This removes:

- ~/.local/bin/open-in-dolphin.sh
- ~/.local/share/applications/dolphin-handler.desktop

Note: It does not automatically restore a previous handler for x-scheme-handler/dolphin. If needed, set a different default handler manually:

```bash
xdg-mime default <other.desktop> x-scheme-handler/dolphin
```

## Security notes

This handler is designed to be conservative:

- only accepts URLs starting with dolphin:///
- strips ?query and #fragment
- requires absolute paths
- blocks trivial traversal patterns (/../ and /./)
- sanitizes CR/LF/TAB characters defensively

If you want additional hardening, consider adding an allowlist of allowed path prefixes (e.g. only under ~/Projects).
