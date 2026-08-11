# Guitarix Preset Downloader (`gxDL-er.sh`)

This Bash script provides a robust and user-friendly way to batch-download Guitarix preset banks (`.gx` / `.gxb`) directly into your Guitarix configuration directory (`~/.config/guitarix/banks`). It supports single URLs, space-separated lists, and text files containing lists of links. The script features a retro ASCII art intro banner, real-time progress updates, color-coded output, comprehensive logging, and user confirmation prompts.

---

![screenshot](example.jpeg)

---

## Features

* **ASCII Art Intro Banner:** Features a custom ASCII banner upon launching the script.
* **Automatic Redirect Handling:** Uses `curl -L` to follow HTTP 301/302 redirects (commonly triggered by repositories like Musical Artifacts).
* **Dynamic File Naming:** Automatically extracts and uses the remote filename (`-O`) without requiring manual output naming.
* **Flexible Input Methods:** Accepts direct single URLs, multiple space-separated URLs, or paths to `.txt` files containing link lists.
* **Text File Sanitization:** Ignores empty lines, trims Windows carriage returns (`\r`), and skips comment lines starting with `#` in `.txt` files.
* **Real-time Progress:** Displays a live counter showing how many files have been processed out of the total.
* **Color-Coded Output:** Provides clear, color-coded messages for downloading, success, errors, warnings, and banners.
* **Comprehensive Logging:** Records all download attempts (successful or failed) with timestamps to `guitarix_preset_download.log`.
* **User Confirmation:** Includes a confirmation prompt before initiating batch downloads to prevent accidental bandwidth usage.
* **Graceful Exit:** Catches `Ctrl+C` interruptions to exit cleanly.

---

## Requirements

Before running the script, make sure you have the following installed on your system:

* **Bash, Zsh, or Ksh:** Designed for modern POSIX-compliant shells utilizing arrays, strict mode execution, and standard regex evaluation.
* **`curl` Utility:** Required to perform HTTP requests, follow redirects, and save output files.
* **`tr`, `xargs`, and `basename` Utilities:** Standard command-line tools for text sanitization and path resolution, usually pre-installed on Linux/macOS.

### Installation Instructions for `curl`

* **Debian / Linux Mint / Ubuntu:**
    ```bash
    sudo apt update
    sudo apt install curl
    ```

* **Fedora:**
    ```bash
    sudo dnf install curl
    ```

* **Arch Linux:**
    ```bash
    sudo pacman -S curl
    ```

* **macOS (using Homebrew):**
    ```bash
    brew install curl
    ```

---

## How to Use

1. **Save the Script:**
   Save the script content into a file named `gxDL-er.sh`.

2. **Make it Executable:**
   Open your terminal, navigate to the directory where you saved the script, and run:
   ```bash
   chmod +x gxDL-er.sh
   ```

3. **Run the Script:**
   You can pass direct URLs, multiple space-separated URLs, or text files to the script.

   **Single URL Example:**
   ```bash
   ./gxDL-er.sh "https://bucket.musical-artifacts.com/uploads/stored_file/file/5473/musiclab-MarkKnopfler.gx"
   ```

   **Multiple Space-Separated URLs:**
   ```bash
   ./gxDL-er.sh "https://bucket.musical-artifacts.com/uploads/stored_file/file/5473/musiclab-MarkKnopfler.gx" "https://bucket.musical-artifacts.com/uploads/stored_file/file/5527/musiclab-PaulGilbert.gx"
   ```

   **Using a Text File (list.txt):**
   Create a text file containing preset links line by line, then execute the script pointing to your text file:
   ```bash
   ./gxDL-er.sh list.txt
   ```

### What to Expect When Running the Script:

* **ASCII Intro Banner:** Displays the custom script logo upon launch.
* **Queue Scanning:** Scans all arguments, parses `.txt` files, strips whitespace/comments, and counts valid target URLs.
* **User Confirmation:** Asks for confirmation (y/N) before downloading begins.
* **Download Progress:** Displays real-time progress for each item.
* **Summary & Reload Reminders:** Reports total completed downloads, error logs, and reminds you to refresh presets inside Guitarix (`Ctrl+P` -> Refresh).

---

## Customization

You can customize the target directory or log filename by editing the Configuration section at the top of `gxDL-er.sh`:

```bash
# --- Configuration ---
TARGET_DIR="$HOME/.config/guitarix/banks"
LOG_FILE="guitarix_preset_download.log"
```

---

## Troubleshooting

* **"Error: 'curl' is not installed...":** Install curl using your Linux distribution's package manager.

* **Presets do not show up in Guitarix immediately:** Inside Guitarix, press `Ctrl + P` to open the Scratchpad / Bank Manager, then click **Refresh** at the bottom of the window.

* **HTTP 302 Redirect Error:** The script uses `curl -L`, which automatically handles HTTP 302/301 redirects. Ensure you are using the provided script version without modifying the curl flags.

---

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or encounter bugs.

---

## License

This project is open-source and available under the MIT License.
