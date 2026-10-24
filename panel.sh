
#!/bin/bash
# ====================================================
#      PTERODACTYL INSTALL / USER / UPDATE / REMOVE
# ====================================================

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m"

# ================== INSTALL FUNCTION ==================
install_ptero() {
    clear
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────────────┐"
    echo "          🚀 𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗜𝗻𝘀𝘁𝗮𝗹𝗹𝗮𝘁𝗶𝗼𝗻"
    echo "└──────────────────────────────────────────────┘${NC}"

    bash <(curl -fsSL "https://raw.githubusercontent.com/dragongamer432/pteropanel/refs/heads/main/pterodactyl.sh")

    echo -e "${GREEN}✔ Installation Complete${NC}"
    read -r -p "Press Enter to return..."
}

# ================== PREMIUM INSTALL FUNCTION ==================
install_ptero_premium() {
    clear
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────────────┐"
    echo "          ⭐ 𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗣𝗿𝗲𝗺𝗶𝘂𝗺"
    echo "└──────────────────────────────────────────────┘${NC}"

    bash <(curl -fsSL "https://raw.githubusercontent.com/dragongamer432/pteropanel/refs/heads/main/pteropremium./pterop.sh")

    echo -e "${GREEN}✔ Premium Installer Finished${NC}"
    read -r -p "Press Enter to return..."
}

# ================== CREATE USER ==================
create_user() {
    clear
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────────────┐"
    echo "         👤 𝗖𝗿𝗲𝗮𝘁𝗲 𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗨𝘀𝗲𝗿"
    echo "└──────────────────────────────────────────────┘${NC}"

    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "${RED}❌ Panel not installed!${NC}"
        read -r -p "Press Enter to return..."
        return
    fi

    cd /var/www/pterodactyl || return
    php artisan p:user:make

    echo -e "${GREEN}✔ User creation command completed.${NC}"
    read -r -p "Press Enter to return..."
}

# ================= PANEL UNINSTALL =================
uninstall_panel() {
    echo ">>> Stopping Panel service..."
    systemctl stop pteroq.service 2>/dev/null || true
    systemctl disable pteroq.service 2>/dev/null || true
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload

    echo ">>> Removing cronjob..."
    crontab -l 2>/dev/null |
        grep -v 'php /var/www/pterodactyl/artisan schedule:run' |
        crontab - || true

    echo ">>> Removing files..."
    rm -rf /var/www/pterodactyl

    echo ">>> Dropping database..."
    mysql -u root -e "DROP DATABASE IF EXISTS panel;"
    mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    echo ">>> Cleaning nginx..."
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    systemctl reload nginx || true

    echo "✅ Panel removed."
}

uninstall_ptero() {
    clear
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────────────┐"
    echo "         🧹 𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗨𝗻𝗶𝗻𝘀𝘁𝗮𝗹𝗹𝗮𝘁𝗶𝗼𝗻"
    echo "└──────────────────────────────────────────────┘${NC}"

    echo -e "${RED}WARNING: This deletes panel files and the panel database.${NC}"
    read -r -p "Are you sure? Type YES: " confirm

    if [ "$confirm" != "YES" ]; then
        echo "Cancelled."
        read -r -p "Press Enter to return..."
        return
    fi

    uninstall_panel
    echo -e "${GREEN}✔ Panel Uninstalled (Wings untouched)${NC}"
    read -r -p "Press Enter to return..."
}

# ================= UPDATE FUNCTION =================
update_panel() {
    clear
    echo -e "${YELLOW}"
    echo "═══════════════════════════════════════════════"
    echo "           ⚡ 𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗣𝗮𝗻𝗲𝗹 𝗨𝗽𝗱𝗮𝘁𝗲"
    echo "═══════════════════════════════════════════════${NC}"

    cd /var/www/pterodactyl || {
        echo -e "${RED}❌ Panel not found!${NC}"
        read -r -p "Press Enter to return..."
        return
    }

    php artisan down || return

    if ! curl -fL "https://github.com/pterodactyl/panel/releases/download/v1.12.1/panel.tar.gz" |
        tar -xz; then
        echo -e "${RED}❌ Update download or extraction failed.${NC}"
        read -r -p "Press Enter to return..."
        return 1
    fi

    if ! chmod -R 755 storage/* bootstrap/cache ||
       ! composer install --no-dev --optimize-autoloader ||
       ! php artisan view:clear ||
       ! php artisan config:clear ||
       ! php artisan migrate --seed --force; then
        echo -e "${RED}❌ Update failed. Check the panel before bringing it online.${NC}"
        read -r -p "Press Enter to return..."
        return 1
    fi

    chown -R www-data:www-data /var/www/pterodactyl/*
    php artisan queue:restart
    php artisan up

    echo -e "${GREEN}🎉 Panel Updated Successfully${NC}"
    read -r -p "Press Enter to return..."
}

# ===================== MENU =====================
while true; do
    clear
    echo -e "${YELLOW}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║          𝗣𝘁𝗲𝗿𝗼𝗱𝗮𝗰𝘁𝘆𝗹 𝗖𝗼𝗻𝘁𝗿𝗼𝗹 𝗖𝗲𝗻𝘁𝗲𝗿"
    echo "╠═══════════════════════════════════════════════╣"
    echo -e "║ ${GREEN}1) Install Panel${NC}"
    echo -e "║ ${CYAN}2) Create Panel User${NC}"
    echo -e "║ ${YELLOW}3) Update Panel${NC}"
    echo -e "║ ${RED}4) Uninstall Panel${NC}"
    echo -e "║ ${CYAN}5) Install Premium Panel${NC}"
    echo -e "║ 6) Exit${NC}"
    echo "╚═══════════════════════════════════════════════╝"

    echo -ne "${CYAN}Select Option → ${NC}"
    read -r choice

    case "$choice" in
        1) install_ptero ;;
        2) create_user ;;
        3) update_panel ;;
        4) uninstall_ptero ;;
        5) install_ptero_premium ;;
        6) clear; exit 0 ;;
        *) echo -e "${RED}Invalid option...${NC}"; sleep 1 ;;
    esac
done
