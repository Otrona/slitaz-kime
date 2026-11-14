#!/bin/sh
# Set up kime system-wide on SliTaz 5.1. Run as root after installing the
# kime and fonts-kr packages.
#
# - kime starts by itself: its package installs /etc/xdg/autostart/kime.desktop,
#   which the LXTaz session runs.
# - Environment files (/etc/profile.d) are not read by the LXTaz session, and
#   GTK3 apps pick kime's module without GTK_IM_MODULE anyway.
# - kime looks for "Noto Sans CJK KR" (fallback D2Coding) for its XIM preedit
#   and Hanja candidate windows; fonts-kr installs "Noto Sans KR", so point
#   kime at it. Settings left out keep their defaults (Right Alt toggle etc).

mkdir -p /etc/xdg/kime
cat > /etc/xdg/kime/config.yaml << 'YAML'
engine:
  xim_preedit_font: [Noto Sans KR, 15.0]
  candidate_font: Noto Sans KR
YAML

# Register the GTK3 input module (the kime package does this too)
gtk-query-immodules-3.0 --update-cache

echo "kime is set up. Log out and back in, then press Right Alt to switch to Hangul."
