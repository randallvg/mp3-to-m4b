# `abook` – Audiobook Merger Script

`abook` is a Bash script function that automates the process of merging multiple `.mp3` files in the current directory into a single `.m4b` audiobook file. It uses `ffmpeg` and temporary file management for a streamlined experience.

## 📦 Features

- Automatically combines all `.mp3` files in the current directory
- Outputs a `.m4b` file named after the current folder
- Temporary files are automatically cleaned up
- Simple help menu with `-h` or `--help` option

## 🛠 Requirements

- `bash`
- `ffmpeg`
- `gmktemp` (GNU `mktemp` or equivalent for temporary files)

## 📂 Usage

### Step 1: Load the function in your shell

You can source the script or add the function to your `.bashrc`/`.bash_profile`:

```bash
source /path/to/abook.sh
```

### Step 2: Run the command

Navigate to a folder containing MP3 files:

```bash
cd /path/to/mp3/files
abook
```

This will create a file called `foldername.m4b` in the same directory.

### Help

```bash
abook -h
```

Displays usage instructions.

## 🧹 Cleanup

The script automatically deletes all temporary files it creates when it finishes or exits unexpectedly.

## 🧪 Example

Suppose you have a directory `/audiobooks/MyBook` with:

```
01_intro.mp3
02_chapter1.mp3
03_chapter2.mp3
```

Running `abook` in that directory creates:

```
MyBook.m4b
```

## 📜 License

This project is licensed under the terms of the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html).
