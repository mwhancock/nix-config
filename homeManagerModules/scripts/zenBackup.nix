{ pkgs, ... }:

{

  home.packages = [
    (pkgs.writeShellScriptBin "zen-backup" ''
      # Your exact profile path
      PROFILE_DIR="$HOME/.config/zen/kzzbegky.Default Profile"
      BACKUP_DIR="$HOME/Nextcloud/Documents/ZenBrowser"

      # Create backup directory if it doesn't exist
      mkdir -p "$BACKUP_DIR"

      # Create timestamp
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      BACKUP_FILE="$BACKUP_DIR/zen-profile-$TIMESTAMP.tar.gz"

      # Check if profile exists
      if [ ! -d "$PROFILE_DIR" ]; then
        echo "Error: Profile directory not found at $PROFILE_DIR"
        exit 1
      fi

      echo "Backing up Zen profile from: $PROFILE_DIR"
      echo "Creating backup in Nextcloud: $BACKUP_FILE"

      # Create the backup
      tar -czf "$BACKUP_FILE" -C "$HOME/.config/zen" "$(basename "$PROFILE_DIR")"

      # Show result
      if [ $? -eq 0 ]; then
        echo "✅ Backup successful!"
        ls -lh "$BACKUP_FILE"

        # keep only last 5 backups
        echo "Cleaning up old backups (keeping last 5)..."
        ls -t "$BACKUP_DIR"/zen-profile-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
      else
        echo "❌ Backup failed"
        exit 1
      fi
    '')

    (pkgs.writeShellScriptBin "zen-restore" ''
      BACKUP_DIR="$HOME/Nextcloud/Documents/ZenBrowser"
      PROFILE_DIR="$HOME/.config/zen/kzzbegky.Default Profile"

      # Check if backup directory exists
      if [ ! -d "$BACKUP_DIR" ]; then
        echo "Backup directory not found at $BACKUP_DIR"
        echo "Creating it now..."
        mkdir -p "$BACKUP_DIR"
        exit 1
      fi

      # List available backups
      echo "Available backups in Nextcloud:"
      ls -1 "$BACKUP_DIR"/zen-profile-*.tar.gz 2>/dev/null | cat -n

      if [ $? -ne 0 ]; then
        echo "No backups found in $BACKUP_DIR"
        exit 1
      fi

      # Ask which backup to restore
      echo ""
      read -p "Enter backup number to restore: " $CHOICE

      BACKUP_FILE=$(ls -1 "$BACKUP_DIR"/zen-profile-*.tar.gz | sed -n "$CHOICE") --strip-components=1

      if [ -z "$BACKUP_FILE" ]; then
        echo "Invalid choice"
        exit 1
      fi

      echo "Restoring from: $BACKUP_FILE"
      echo "This will replace your current profile at: $PROFILE_DIR"
      read -p "Are you sure? (y/N): " CONFIRM

      if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        # Backup current profile just in case
        if [ -d "$PROFILE_DIR" ]; then
          mv "$PROFILE_DIR" "$PROFILE_DIR.bak.$(date +%s)"
          echo "Current profile backed up to: $PROFILE_DIR.bak.$(date +%s)"
        fi

        # Restore
        tar -xzf "$BACKUP_FILE" -C "$HOME/.config/zen"
        echo "✅ Restore complete!"
      else
        echo "Cancelled"
      fi
    '')
  ];
}
