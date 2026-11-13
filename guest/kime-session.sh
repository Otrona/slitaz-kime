#!/bin/sh
# Set up kime for the desktop session. Run as root after installing the
# kime package. Optional argument: the desktop user (default: tux).
U=${1:-tux}

# Environment for every program started in the session
printf 'export GTK_IM_MODULE=kime\nexport XMODIFIERS=@im=kime\n' > /etc/profile.d/kime.sh

# Start kime with the Openbox session
A=/home/$U/.config/openbox/autostart.sh
mkdir -p "$(dirname "$A")"
grep -q '^kime' "$A" 2>/dev/null || echo 'kime &' >> "$A"
chown -R "$U" "/home/$U/.config/openbox"

# Register the GTK3 input module (the package does this too)
gtk-query-immodules-3.0 --update-cache

echo "kime is set up for $U."
echo "Log out and back in, then press Right Alt to switch to Hangul."
