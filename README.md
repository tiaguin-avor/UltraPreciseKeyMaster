# UltraPreciseKeyMaster.ahk

**Version:** 1.0  
**Author:** SIGMAT3CH  
**License:** GNU General Public License v3.0

## Overview

**UltraPreciseKeyMaster** is a high-precision AutoHotkey script designed for ultra-accurate keypress simulation. It uses advanced timing calibration, statistical filtering, and spinlock sleeping to achieve reliable, low-latency key holds, particularly useful for tasks that demand consistent input timing such as gaming, automation, or testing.

---

## Features

- **Realtime Process Priority** – Ensures the script runs with maximum CPU priority.
- **Advanced Calibration System** – Measures system overhead using statistical filtering and outlier rejection.
- **Dynamic Timing Adjustment** – Adjusts key hold duration based on real-world timing deviations.
- **Timing Diagnostics** – Visual feedback for timing accuracy and adjustments.
- **Customizable Hold Time** – Modify key hold duration live via hotkeys or precise input.
- **Auto Recalibration** – Periodically recalibrates to maintain accuracy during long runtimes.
-  **Spinlock Precision Sleep** – Avoids delays from standard sleep methods with tight timing loops.

---

## Default Hotkeys

| Hotkey           | Description                              |
|------------------|------------------------------------------|
| `F1`             | Toggle the script on/off                 |
| `e`              | Press & hold the key precisely           |
| `Ctrl + ↑ / ↓`   | Increase/decrease hold time by 0.01 ms   |
| `Ctrl + Shift + ↑ / ↓` | Adjust hold time by 0.1 ms         |
| `Ctrl + E`       | Input a specific hold time (in ms)       |
| `Alt + T`        | Toggle timing diagnostics on/off         |
| `Ctrl + Esc`     | Exit and clean up the script             |

> **Note:** The key being simulated by default is `e`. You can change this in the `CustomE` section.

---

## How It Works

- **Calibration:** On startup and at regular intervals, the script measures how long it takes to send a keystroke and adjusts timing based on system overhead.
- **Spinlock Sleep:** Instead of using `Sleep`, which is coarse, it uses high-frequency performance counters to wait with sub-millisecond accuracy.
- **Diagnostics:** When enabled, timing differences are displayed in real-time so you can see how accurately the script is performing.

---

## Installation

1. Install [AutoHotkey v1.1](https://www.autohotkey.com/).
2. Save the script as `UltraPreciseKeyMaster.ahk`.
3. Run the script by double-clicking it or placing it in your startup folder for automatic launch.
4. Press `F1` to activate.

---

## Customization

To change the key being simulated (default: `e`), edit these lines:

`Hotkey, *e, CustomE, On Hotkey, *e Up, CustomE_Up, On`

And replace all instances of:
`SendInput, {e down}...SendInput, {e up}` With your desired key, such as `{a down} / {a up}`.

## License

This project is licensed under the GNU General Public License v3.0.
See [LICENSE](https://github.com/SIGMAT3CH/UltraPreciseKeyMaster/blob/main/LICENSE) for more information.

## Disclaimer

This script is provided as-is, with no warranty. While designed for maximum accuracy, results may vary depending on your hardware, OS version, and background processes.

## Support

For questions or improvements, feel free to contribute or open an issue.

Happy scripting!
— SIGMAT3CH
