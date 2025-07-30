# Kindle LitClock

This repository contains a very small Kindle extension that displays an Urdu literary clock on Kindle e-ink devices. The clock shows an image with a literary quote for the current time and overlays the digital time text using [`fbink`](https://github.com/NiLuJe/FBInk).

## Repository contents

- `literaryclock.sh` – main shell script that runs the clock. It chooses an image from `images/` based on the current hour and quarter, displays it via fbink and writes a log to `clock.log`.
- `menu.json` – definition for the extension's menu with **Start Clock** and **Stop Clock** actions.
- `config.xml` – Kindle extension configuration file that references the dynamic menu.
- `offset.conf` – optional hour offset used by the script for timezone adjustment.

An `images/` directory is expected next to the script containing files named `quote_H_Q.png` where `H` is the hour in 24‑hour format and `Q` is the quarter index (0–3).

## Running on a Kindle

Copy the repository to `/mnt/us/extensions/kindle_litclock` on the Kindle and ensure `fbink` is installed at `/mnt/us/extensions/bin/fbink`. The extension can then be launched from the Kindle "Extensions" menu or by running:

```sh
sh literaryclock.sh
```

Stop the clock by terminating the script (for example using `pkill -f literaryclock.sh`).

## Notes

The project only contains the launcher script and configuration files. Quote images are not provided.
