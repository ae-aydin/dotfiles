#!/usr/bin/env python3

import shutil
from pathlib import Path
from datetime import datetime

DOTFILES_DIR = Path(__file__).parent.resolve()  
MANIFEST_FILE = DOTFILES_DIR / "MANIFEST"
BACKUP_DIR_BASE = Path.home() / "dotfiles_backup"

def main():
    print("--- Dotfiles Linker (Python) ---")
    print(f"Source: {DOTFILES_DIR}")
    print(f"Manifest: {MANIFEST_FILE}")

    if not MANIFEST_FILE.is_file():
        print(f"ERROR: Manifest file not found: {MANIFEST_FILE}")
        return

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = BACKUP_DIR_BASE.parent / f"{BACKUP_DIR_BASE.name}_{timestamp}"
    try:
        backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"Backup: {backup_dir}")
    except OSError as e:
        print(f"ERROR: Could not create backup directory {backup_dir}: {e}")
        return

    with open(MANIFEST_FILE, "r") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            
            if not line or line.startswith("#"):
                continue

            try:
                source_relative_str, target_absolute_tilde_str = line.split(":", 1)
            except ValueError:
                print(f"WARNING: Skipping malformed line {line_num} in manifest: '{line}' (missing ':')")
                continue

            source_full_path = (DOTFILES_DIR / source_relative_str).resolve()
            target_full_path = Path(target_absolute_tilde_str).expanduser().resolve()

            print(f"\nProcessing: '{source_relative_str}' -> '{target_full_path}'")

            if not source_full_path.exists():
                print(f"WARNING: Source '{source_full_path}' does not exist. Skipping.")
                continue

            try:
                target_full_path.parent.mkdir(parents=True, exist_ok=True)
            except OSError as e:
                print(f"ERROR: Could not create parent directory {target_full_path.parent}: {e}")
                continue

            if target_full_path.is_symlink():
                print(f"Removing existing symlink: {target_full_path}")
                try:
                    target_full_path.unlink()
                except OSError as e:
                    print(f"ERROR: Could not remove symlink {target_full_path}: {e}")
                    continue
            elif target_full_path.exists():
                backup_destination = backup_dir / target_full_path.name
                print(f"Backing up existing file/directory: {target_full_path} to {backup_destination}")
                try:
                    shutil.move(str(target_full_path), str(backup_destination))
                except OSError as e:
                    print(f"ERROR: Could not back up {target_full_path}: {e}")
                    continue

            print(f"Creating symlink: {target_full_path} -> {source_full_path}")
            try:
                target_full_path.symlink_to(source_full_path, target_is_directory=source_full_path.is_dir())
                print("SUCCESS: Linked.")
            except OSError as e:
                print(f"ERROR: Failed to create symlink: {e}")
            except Exception as e:
                print(f"ERROR: An unexpected error occurred during symlinking: {e}")

    print("\n--- Process Complete ---")

if __name__ == "__main__":
    main()