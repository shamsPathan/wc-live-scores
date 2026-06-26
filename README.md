# ⚽ wc-live-scores

A lightweight, over-engineered Bash script designed for developers who want to stay updated on live World Cup matches and upcoming fixtures without leaving their terminal or switching browser tabs. 

It fetches real-time scores using a free sports API and pushes persistent notifications to the **top-right corner** of your screen using `notify-send` and the **Mako** notification daemon on **Sway WM**.

---

## ✨ Features

- **🔴 Live Score Tracking**: Displays the match, live score, and running match minute (e.g., `74'`).
- **📅 Upcoming Fixtures**: Shows upcoming matches scheduled for the day with localized kickoff times.
- **⏱️ Smart Persistent Window**: Notifications stay on screen for exactly 1 minute (`60000ms`) so you don't miss a thing while typing.
- **🛡️ Rate-Limit Safe**: Runs a 60-second polling cycle to stay perfectly under the free-tier limitation of **10 calls per minute**.
- **🐧 Wayland/Sway Native**: Built explicitly to integrate with your customized tiling window manager layout.

---

## 🛠️ Prerequisites

Before running the script, ensure you have the required packages installed on your Linux system:

```bash
# On Debian/Ubuntu/Arch/Fedora (Install jq, curl, and notify-send tools)
sudo apt install jq curl libnotify-bin   # Debian/Ubuntu
sudo pacman -S jq curl libnotify         # Arch Linux
```

### 1. Notification Daemon Setup (Mako)
To guarantee that notifications snap perfectly to the **top-right corner** and stay on screen for a full minute, add these rules to your Mako configuration:

```ini
# Edit ~/.config/mako/config
anchor=top-right
default-timeout=60000

# Custom theme layer specifically for the World Cup alerts
[summary~=".*MATCH LIVE.*|.*UPCOMING FIXTURE.*"]
border-color=#4CAF50
border-size=2
background-color=#1E1E1E
text-color=#FFFFFF
```
*After updating the file, reload Mako using:* `makoctl reload`

### 2. Get a Free API Key
1. Go to [Football-Data.org](https://football-data.org) and register for a free account.
2. Copy your unique API Token from your account dashboard.

---

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd wc-live-scores
   ```

2. **Configure the script:**
   Open the script file and insert your API Token:
   ```bash
   nano wc-live-scores.sh
   ```
   Find the config section at the top and update it:
   ```bash
   API_TOKEN="your_actual_token_here"
   ```

3. **Make it executable:**
   ```bash
   chmod +x wc-live-scores.sh
   ```

4. **Run it:**
   ```bash
   ./wc-live-scores.sh
   ```

---

## ⚙️ Automated Startup (Optional)

If you want the script to launch automatically in the background when you log into your **Sway** session, add this execution line directly to your Sway environment configuration file (`~/.config/sway/config`):

```sway
exec --no-startup-id /path/to/your/wc-live-scores.sh > /dev/null 2>&1 &
```

---

## 🤝 Contributing

Contributions, bug reports, and optimizations (like custom filtering for specific national leagues or team groups) are highly welcome! Feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - feel free to use it to save your coding sanity during tournament season!

