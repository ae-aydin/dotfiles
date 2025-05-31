#!/usr/bin/env python3

import os
import shutil
from pathlib import Path
from datetime import datetime

DOTFILES_DIR = Path(__file__).parent.resolve()  # Assumes script is in dotfiles root
MANIFEST_FILE = DOTFILES_DIR / "MANIFEST"
BACKUP_DIR_BASE = Path.home() / "dotfiles_backup"

def main():
    print("\n--- Dotfiles Linker ---")
    print(f"Source Dir: {DOTFILES_DIR}")
    print(f"Manifest: {MANIFEST_FILE}")

    if not MANIFEST_FILE.is_file():
        print(f"ERROR: Manifest file not found: {MANIFEST_FILE}")
        return

    # Backup file creation
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = BACKUP_DIR_BASE.parent / f"{BACKUP_DIR_BASE.name}_{timestamp}"
    try:
        backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"Backup Dir: {backup_dir}")
    except OSError as e:
        print(f"ERROR: Could not create backup directory {backup_dir}: {e}")
        return

    # Read MANIFEST file for symlink creation
    with open(MANIFEST_FILE, "r") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()

            if not line or line.startswith("#"):
                continue

            try:
                source_relative_str, target_tilde_str = line.split(":", 1)
            except ValueError:
                print(f"WARNING: Skipping malformed line {line_num} in manifest: '{line}' (missing ':')")
                continue

            # SOURCE: Path within dotfiles, should be fully resolved
            source_path = (DOTFILES_DIR / source_relative_str).resolve()

            # TARGET: Path in home directory where symlink will live. Expand ~ but do not resolve
            target_link_location = Path(target_tilde_str).expanduser()

            print(f"\nProcessing: '{source_path}' -> '{target_link_location}'")

            if not source_path.exists():
                print(f"WARNING: Source '{source_path}' does not exist. Skipping.")
                continue

            # Ensure parent directory for the symlink target_link_location exists
            try:
                target_link_location.parent.mkdir(parents=True, exist_ok=True)
            except OSError as e:
                print(f"ERROR: Could not create parent for '{target_link_location.parent}': {e}")
                continue

            # Check what's currently at the target_link_location
            if target_link_location.is_symlink():
                try:
                    if target_link_location.readlink().resolve(strict=False) == source_path:
                        print(f"SUCCESS: Symlink '{target_link_location}' already correctly points to '{source_path}'.")
                        continue
                    else:
                        print(f"Replacing incorrect symlink at '{target_link_location}'.")
                        target_link_location.unlink()
                except OSError as e:
                    print(f"Removing problematic symlink at '{target_link_location}' (Error reading it: {e}).")
                    try:
                        target_link_location.unlink()
                    except OSError as e_unlink:
                        print(f"ERROR: Failed to remove problematic symlink '{target_link_location}': {e_unlink}")
                        continue
            elif target_link_location.exists():
                backup_destination = backup_dir / target_link_location.name
                print(f"Backing up existing file/directory: '{target_link_location}' to '{backup_destination}'")
                try:
                    shutil.move(str(target_link_location), str(backup_destination))
                except OSError as e:
                    print(f"ERROR: Could not back up '{target_link_location}': {e}")
                    continue

            print(f"Creating symlink: '{target_link_location}' -> '{source_path}'")
            try:
                target_link_location.symlink_to(source_path, target_is_directory=source_path.is_dir())
                print("SUCCESS: Linked.")
            except OSError as e:
                print(f"ERROR: Failed to create symlink for '{target_link_location}': {e}")
            except Exception as e:
                print(f"ERROR: An unexpected error occurred during symlinking for '{target_link_location}': {e}")

    print("\n--- Process Complete ---")

if __name__ == "__main__":
    main()
