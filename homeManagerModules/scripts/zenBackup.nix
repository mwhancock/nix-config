# -----------------------------------------------------------------------------
# MODULE: ZEN BROWSER BACKUP SCRIPTS
# Description: Automated profile backup/restore to Nextcloud.
# -----------------------------------------------------------------------------
{ pkgs, ... }:
{
  home.packages = [
    # BACKUP SCRIPT
    (pkgs.writeShellScriptBin "zen-backup" ''
      PROFILE_DIR="$HOME/.config/zen/kzzbegky.Default Profile"
      BACKUP_DIR="$HOME/Nextcloud/Documents/ZenBrowser"

      mkdir -p "$BACKUP_DIR"
      TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
      BACKUP_FILE="$BACKUP_DIR/zen-profile-$TIMESTAMP.tar.gz"

      if [ ! -d "$PROFILE_DIR" ]; then
        echo "❌ Error: Profile directory not found at $PROFILE_DIR"
        exit 1
      fi

      echo "📦 Backing up Zen Profile..."
      tar -czf "$BACKUP_FILE" -C "$HOME/.config/zen" "$(basename "$PROFILE_DIR")"
      
      if [ $? -eq 0 ]; then
        echo "✅ Backup successful: $BACKUP_FILE"
        # Keep only the last 5 backups
        ls -t "$BACKUP_DIR"/zen-profile-*.tar.gz | tail -n +6 | xargs -r rm
        echo "🧹 Old backups cleaned up."
      else
        echo "❌ Backup failed!"
      fi
    '')

    # RESTORE SCRIPT
    (pkgs.writeShellScriptBin "zen-restore" ''
      BACKUP_DIR="$HOME/Nextcloud/Documents/ZenBrowser"
      
      if [ ! -d "$BACKUP_DIR" ]; then
        echo "❌ No backup directory found in Nextcloud."
        exit 1
      fi

      echo "Available backups:"
      ls -1 "$BACKUP_DIR"/zen-profile-*.tar.gz | cat -n

      read -p "Enter backup number to restore: " CHOICE
      
      # Correctly escape the variable for Nix/Bash compatibility
      BACKUP_FILE=$(ls -1 "$BACKUP_DIR"/zen-profile-*.tar.gz | sed -n "''${CHOICE}p")

      if [ -z "$BACKUP_FILE" ]; then
        echo "❌ Invalid choice."
        exit 1
      fi

      echo "⚠️  This will overwrite your current Zen profile. Continue? (y/n)"
      read -r CONFIRM
      if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "📂 Restoring from: $BACKUP_FILE"
        tar -xzf "$BACKUP_FILE" -C "$HOME/.config/zen"
        echo "✅ Restore complete!"
      else
        echo "Aborted."
      fi
    '')
  ];
}
