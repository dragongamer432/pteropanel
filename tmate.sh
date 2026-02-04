clear && echo -e "DragonCloud Tmate Installer V2
echo -e "\n🔧 Updating VPS...\n" && sudo apt update && \
echo -e "\n📦 Installing tmate...\n" && sudo apt install tmate -y && \
echo -e "\n🚀 Starting tmate session...\n" && tmate -F
