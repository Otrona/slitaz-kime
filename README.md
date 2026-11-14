# kime Korean input for SliTaz 5.1 (x86_64)

**English** | [한국어](README.ko.md)

Korean (Hangul) input on [SliTaz](https://www.slitaz.org) 5.1 with
[kime](https://github.com/Riey/kime) 3.2.0, plus a Korean font package,
LibreOffice 7.6, and two ready-to-boot live ISOs.

SliTaz 5.1 has no Rust, only an old meson and no libclang, so kime cannot be
cooked out of the box. This repo has the receipts, fixes and ISO flavors that
make it work, tested on the SliTaz 5.1 x86_64 cooking of November 2026.

## What works

| | |
|---|---|
| GTK3 apps (Firefox ESR, TazTerm, text editor, LXTaz tools) | yes, through kime's GTK3 module |
| LibreOffice 7.6 | yes, through XIM (its launcher sets it up) |
| Other X11-only apps (e.g. xterm) | no: XIM needs `XMODIFIERS=@im=kime`, which the LXTaz session does not set |
| Qt5 / Qt6 apps (e.g. qBittorrent) | no: the Qt modules are not built; type elsewhere and paste |
| Telegram Desktop (official binary) | no: it bundles its own Qt; use Telegram Web in Firefox instead (not tested) |
| Wayland | no (SliTaz 5.1 uses Xorg) |
| Hangul / Hanja / emoji | Hangul tested; Hanja and emoji use kime's candidate window (not tested) |
| kime tray icon (한/A) | no: see [Known issues](#known-issues) |

## Tested setup

| | |
|---|---|
| SliTaz | 5.1 cooking x86_64 (November 2026): installed to disk, and the live ISOs below |
| Kernel | 6.12.115-slitaz |
| Toolchain | GCC 6.3.0, glibc 2.20, GLib 2.56.4, GTK3 3.22.30, Python 3.8.3 |
| Virtual machine | QEMU/KVM, 6 cores, 8 GB RAM (see [slitaz-qemu-clipboard](https://github.com/Otrona/slitaz-qemu-clipboard)) |
| Real hardware | ThinkPad E14 Gen 3 (Realtek RTL8852AE Wi-Fi), booted from Ventoy (UEFI, normal mode) |

## Repository layout

```
wok/meson/receipt           meson 1.5.2 (kime needs >= 1.1; SliTaz has 0.62.2)
wok/rust/receipt            Rust 1.99.1, official x86_64 binaries
wok/kime/receipt            kime 3.2.0: XIM + GTK3 module
wok/fonts-kr/receipt        Noto Sans KR, Noto Serif KR, NanumSquare
wok/libreoffice/receipt     LibreOffice 7.6.7.2, official x86-64 binaries
flavors/kime-x86_64         metier flavor: firefox desktop + kime + fonts
flavors/kime-office-x86_64  metier flavor: the above + LibreOffice
host/get-fonts-kr           collects the font files (run on a machine with internet)
guest/fix-cook-conf.sh      fixes the i486 values in cook.conf on x86_64
guest/kime-session.sh       kime's system-wide font settings
```

---

## Option A: live ISOs (ready to boot)

Unofficial ISOs built from the SliTaz 5.1 cooking `firefox-x86_64` flavor,
hybrid BIOS + UEFI, for a USB key (`dd`, Rufus in DD mode, or Ventoy):

| ISO | Contents | RAM | SHA-256 |
|---|---|---|---|
| `slitaz-kime-x86_64-cooking.iso` (177 MB) | Firefox + kime + Korean fonts | 2 GB+ | `d7e4c3541156d07a1e742be597b4b3f199412fde45045a5caf49b29720c0e2f2` |
| `slitaz-kime-office-x86_64-cooking.iso` (367 MB) | the above + LibreOffice 7.6 | 4 GB+ | `0f9508bd042108498b808317e2b98e5f5e74eddb0707bdbbc6d79182d393c700` |

Download (MYBOX): [kime ISO](https://naver.me/5LQ6gQ8k) · [office ISO](https://naver.me/G6RmxRRB)

The live system runs entirely from RAM. kime starts by itself: press
**Right Alt** to switch to Hangul. Both ISOs also include the firmware for
Realtek Wi-Fi 6/6E/7 cards (rtw89), which the official firefox ISO lacks.

## Option B: install the packages

On an existing SliTaz 5.1 x86_64 system, download from the
[v3.2.0-1 release](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1)
`kime-3.2.0-x86_64.tazpkg` and `fonts-kr-1.0-any.tazpkg` (and
`libreoffice-7.6.7.2-x86_64.tazpkg` if you want it), then as root:

```sh
tazpkg install fonts-kr-1.0-any.tazpkg
tazpkg install kime-3.2.0-x86_64.tazpkg
tazpkg install libreoffice-7.6.7.2-x86_64.tazpkg     # optional
sh guest/kime-session.sh
```

Log out and back in, then press **Right Alt**. SliTaz cooking is a rolling
release: these packages keep working after system updates as long as the
libraries they use stay compatible. If an update breaks them, cook them again
from the receipts (Option C). tazpkg fetches the runtime dependencies (gtk+3,
dbus, fontconfig, freetype, libxcb; libcups, nss, nspr for LibreOffice) from
the mirror.

## Option C: cook from source

### 1. Prerequisites (root)

```sh
# Mirror: on an installed 5.1 system, busybox wget gets
# "Connection reset by peer" from the HTTPS mirror. Use plain HTTP:
echo http://mirror.slitaz.org/x86_64/cooking/packages/ > /var/lib/tazpkg/mirror
tazpkg recharge

# cookutils is not installed by the installer
tazpkg get-install cookutils
cook setup

# cook.conf has i486 values on x86_64: fix it (after every `cook setup`)
sh guest/fix-cook-conf.sh

tazpkg get-install python3
```

Free resources: about **8 GB RAM** and **6 GB disk** for the Rust and kime
builds.

### 2. Cook meson, Rust and kime (root)

To skip cooking meson and Rust (about 7 minutes and 1.8 GB), install the
prebuilt packages from [slitaz-rust-meson](https://github.com/Otrona/slitaz-rust-meson/releases/latest) instead.

```sh
cp -r wok/meson wok/rust wok/kime /home/slitaz/wok/

cook meson
tazpkg install /home/slitaz/packages/meson-1.5.2*.tazpkg
meson --version                          # 1.5.2

cook rust
tazpkg install /home/slitaz/packages/rust-1.99.1*.tazpkg
rustc --version && cargo --version
rm -rf /home/slitaz/wok/rust/source /home/slitaz/wok/rust/install /home/slitaz/wok/rust/taz

cook kime                                # about 5 minutes on 6 cores
tazpkg install /home/slitaz/packages/kime-3.2.0*.tazpkg
```

Install **your** meson and rust packages before `cook kime`; otherwise cook
pulls the repository's meson 0.62.2.

### 3. Fonts

On a machine with internet (the font files are not in this repo):

```sh
./host/get-fonts-kr                      # ~27 MB into ~/tmp/fonts-kr
```

Copy that folder to SliTaz as `/home/slitaz/wok/fonts-kr/stuff/fonts`, then:

```sh
cp -r wok/fonts-kr /home/slitaz/wok/     # the receipt (keep stuff/fonts)
cook fonts-kr
tazpkg install /home/slitaz/packages/fonts-kr-1.0*.tazpkg
fc-list :lang=ko family                  # lists the three families
```

### 4. LibreOffice (optional)

```sh
cp -r wok/libreoffice /home/slitaz/wok/
cook libreoffice                         # downloads ~230 MB
tazpkg install /home/slitaz/packages/libreoffice-7.6.7.2*.tazpkg
```

### 5. Session setup

```sh
sh guest/kime-session.sh                 # root
```

kime then starts with every session (its package installs an XDG autostart
entry). Programs started before the font install keep their old font list:
restart them.

## Option D: build the ISOs yourself

The ISOs are built with SliTaz's ISO builder **metier** from the flavors in
`flavors/`. As root, on SliTaz 5.1 x86_64 with the packages above cooked:

```sh
tazpkg get-install metier
tazpkg get-install mercurial
hg clone http://hg.slitaz.org/flavors /home/slitaz/repos/flavors
cp -r flavors/kime-x86_64 flavors/kime-office-x86_64 /home/slitaz/repos/flavors/

# metier takes local packages from here first, the rest from the mirror
mkdir -p /home/slitaz/x86_64/packages
cp /home/slitaz/packages/kime-*.tazpkg /home/slitaz/packages/fonts-kr-*.tazpkg \
   /home/slitaz/packages/libreoffice-*.tazpkg /home/slitaz/x86_64/packages/

metier check kime-x86_64
metier build kime-x86_64                 # -> /home/slitaz/iso/
metier build kime-office-x86_64
```

The flavors are copies of the official `firefox-x86_64` flavor with:

- `kime`, `fonts-kr` (and `libreoffice`) added to `packages.list`;
- the five `firmware-rtw89-*` packages added (Realtek Wi-Fi 6/6E/7);
- `addfiles/etc/xdg/kime/config.yaml` (kime's fonts, as in `kime-session.sh`);
- `COMPRESSION="xz"` instead of lzma (see Ventoy below).

Notes:

- metier gives each download **120 seconds**. On a slow connection the
  ~100 MB Firefox package times out and is reported as "not on the mirror".
  Download it yourself into metier's cache, then run `metier check` again:
  `wget -O /home/slitaz/x86_64/cache/cooking/<file> http://mirror.slitaz.org/x86_64/cooking/packages/<file>`.
- `tazlito writeiso` does not work on x86_64 (it needs isolinux, which
  x86_64 SliTaz does not have); metier builds GRUB2 hybrid ISOs instead.
- The office build stopped without a clear error twice; running
  `metier build` again worked both times. Check that the ISO's date changed.

---

## Why the receipts look like this

| | kime 3.2.0 needs | SliTaz 5.1 x86_64 has | Solution |
|---|---|---|---|
| Rust | stable, edition 2021 | no package | official 1.99.1 binaries; they need only glibc ≥ 2.17 |
| meson | ≥ 1.1 | 0.62.2 | meson 1.5.2, the last release that runs on Python 3.8 |
| libclang | listed for `bindgen` | no package | `bindgen` is declared but unused (`build.rs` only calls cbindgen): the receipt deletes it |
| C++20 | kime's default `cpp_std` | GCC 6.3 can't | `-Dcpp_std=none`: only the Qt modules are C++, and they are disabled |
| GTK3 | `gtk+-3.0` | 3.22.30 | OK |

Rust receipt details:

- It uses the **`.tar.gz`** tarball: busybox `unxz` reports "corrupted data"
  on Rust's `.tar.xz`.
- Cook's **strip** step damages `librustc_driver` (158 MB → 136 MB) and
  `rustc` then segfaults. The receipt sets `COOKOPTS="!strip"`, which
  keeps the file at ~158 MB (verified). If `rustc` still
  segfaults, unpack the tarball from `/home/slitaz/src` and run its
  `./install.sh --prefix=/usr --without=rust-docs --disable-ldconfig`.

kime's fonts: kime looks for **"Noto Sans CJK KR"** (fallback D2Coding) for
its XIM preedit and Hanja candidate windows. fonts-kr installs "Noto Sans KR",
a different family name, so `/etc/xdg/kime/config.yaml` points kime at it.
Without it, kime-xim logs `Failed to load xim preedit font ... InvalidFont`.
The settings must sit under `engine:`.

LibreOffice receipt details:

- **7.6** is the last release that runs on glibc 2.17; 24.2 and newer need
  2.27 ([system requirements](https://www.libreoffice.org/get-help/system-requirements)).
  7.6 no longer gets security updates.
- SliTaz's `get-LibreOffice` script fetches the 32-bit build, so it does not
  help on x86_64. The receipt unpacks the official x86-64 RPMs instead.
- LibreOffice's **GTK3 plugin crashes** on SliTaz 5.1 ("Unspecified
  Application Error"), so the receipt leaves it out (the `gnome-integration`
  RPM) and uses the X11 plugin. That plugin only takes input over XIM, and
  the LXTaz session sets no `XMODIFIERS`, so the receipt adds
  `SAL_USE_VCLPLUGIN=gen` and `XMODIFIERS=@im=kime` to the `soffice`
  launcher (only when not already set).

The Qt5 module would need the Qt5 development files, a C++17/20 compiler
(`gcc83` exists in the repository) and kime's `system_engine` option; it is
not attempted here.

## Known issues

- **No kime tray icon.** kime-indicator uses the StatusNotifierItem (D-Bus)
  tray protocol; the LXTaz panel only shows XEmbed tray icons. Typing is not
  affected. A bridge such as `snixembed` might help (not tried).
- **The session sets no input-method variables.** `lxtaz-dm` reads only the
  locale from `/etc/locale.conf`, and the session reads no profile files, so
  `/etc/profile.d` has no effect. GTK3 apps choose kime anyway; X11-only apps
  (xterm) get no Hangul.
- **Slow screen in virtual machines.** SliTaz 5.1 has no driver for QEMU's
  virtual graphics cards (virtio-gpu, qxl, bochs), so X falls back to fbdev.
  Real hardware is fine.

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `CPU you selected does not support x86-64` | i486 values in `cook.conf` | `guest/fix-cook-conf.sh` |
| `Command 'cook' not found` | cookutils not installed | `tazpkg get-install cookutils` |
| tazpkg: `Recharging failed`, `Connection reset by peer` | busybox wget vs. the HTTPS mirror | use the `http://` mirror |
| `meson_version >= 1.1` | the repository's meson 0.62.2 was used | install `wok/meson` first |
| rust: `unxz: corrupted data` | busybox unxz vs. `.tar.xz` | use the `.tar.gz` (the receipt does) |
| `rustc` segfaults, `cargo` works | cook stripped `librustc_driver` | see the Rust notes above |
| Hangul shows as boxes | no Korean font, or the app was started before the install | install fonts-kr, restart the app |
| kime-xim: `InvalidFont` | kime's default font name is not installed | `guest/kime-session.sh` |
| Right Alt does nothing | kime not running | `pgrep -a kime`; start it with `kime &` |
| LibreOffice closes at start, or keeps asking to recover a document | GTK3 plugin crash | use this receipt; move `~/.config/libreoffice` away once |
| Ventoy: `rootfs image is not initramfs (LZMA data is corrupt)`, login fails | Ventoy appends its initramfs; lzma has no end marker | build with `COMPRESSION="xz"` (the flavors do) |
| metier: package "not on the mirror" | 120 s download limit | download it into the cache with `wget` |
| No Wi-Fi with a Realtek Wi-Fi 6 card | `firmware-rtw89-*` missing | install it (the ISOs include it) |

Build logs are in `/home/slitaz/log/<package>.log`.

## Licenses

The scripts, receipts and flavors in this repository are licensed under
GPL-3.0 (see [LICENSE](LICENSE)).

kime is GPL-3.0-or-later. LibreOffice is MPL-2.0. Noto CJK and NanumSquare
are under the SIL Open Font License 1.1. Rust is MIT/Apache-2.0, meson
Apache-2.0. The ISOs contain SliTaz packages under their own licenses,
including non-free firmware.

Issues and reports from other setups are welcome.
