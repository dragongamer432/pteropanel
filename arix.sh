#!/usr/bin/env bash
# ==================================================
#                ARIX THEME MANAGER
# ==================================================

set -e

REPO="https://github.com/dragongamer432/arix-theme.git"
PANEL_PATH="/var/www/pterodactyl"
TMP_DIR="/tmp/arix_theme"
BACKUP_PATH="/var/www/pterodactyl_arix_backup"

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

clear
echo -e "${CYAN}"
echo "=========================================="
echo "           ARIX THEME MANAGER"
echo "=========================================="
echo -e "${RESET}"

# Root check
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root.${RESET}"
  exit 1
fi

# Panel check
if [ ! -d "$PANEL_PATH" ]; then
  echo -e "${RED}Pterodactyl panel not found at $PANEL_PATH${RESET}"
  exit 1
fi

install_theme() {
    echo -e "${YELLOW}Backing up panel...${RESET}"
    rm -rf $BACKUP_PATH
    cp -r $PANEL_PATH $BACKUP_PATH

    echo -e "${YELLOW}Cloning ARIX repository...${RESET}"
    rm -rf $TMP_DIR
    git clone $REPO $TMP_DIR

    echo -e "${YELLOW}Copying command files...${RESET}"
    cp -r $TMP_DIR/app/Console/Commands/* $PANEL_PATH/app/Console/Commands/

    echo -e "${YELLOW}Merging ARIX files...${RESET}"
    cp -r $TMP_DIR/arix/v1.3.1/* $PANEL_PATH/

    echo -e "${YELLOW}Installing node modules...${RESET}"
    cd $PANEL_PATH
    yarn install

    echo -e "${YELLOW}Building assets...${RESET}"
    yarn build:production || yarn build || npm run build

    echo -e "${YELLOW}Running ARIX artisan command...${RESET}"
    php artisan arix || php artisan arix:install || true

    echo -e "${YELLOW}Clearing cache...${RESET}"
    php artisan view:clear
    php artisan config:clear
    php artisan cache:clear
    php artisan queue:restart

    chown -R www-data:www-data $PANEL_PATH
    chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

    echo -e "${GREEN}ARIX Theme Installed Successfully!${RESET}"
}

uninstall_theme() {
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}No backup found! Cannot uninstall.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Restoring backup...${RESET}"
    rm -rf $PANEL_PATH
    mv $BACKUP_PATH $PANEL_PATH

    chown -R www-data:www-data $PANEL_PATH
    chmod -R 755 $PANEL_PATH/storage $PANEL_PATH/bootstrap/cache

    echo -e "${GREEN}ARIX Theme Uninstalled Successfully!${RESET}"
}

update_theme() {
    echo -e "${YELLOW}Updating ARIX Theme...${RESET}"
    install_theme
    echo -e "${GREEN}ARIX Theme Updated Successfully!${RESET}"
}

echo "1) Install ARIX Theme"
echo "2) Uninstall ARIX Theme"
echo "3) Update ARIX Theme"
echo "4) Exit"
echo ""
read -p "Select an option [1-4]: " OPTION

case $OPTION in
    1) install_theme ;;
    2) uninstall_theme ;;
    3) update_theme ;;
    4) exit ;;
    *) echo -e "${RED}Invalid option.${RESET}" ;;
esac
