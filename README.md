# kime Korean input for SliTaz 5.1 (x86_64)

**English** | [한국어](README.ko.md)

Korean (Hangul) input on [SliTaz](https://www.slitaz.org) 5.1 with
[kime](https://github.com/Riey/kime) 3.2.0, plus a small Korean font package.

SliTaz 5.1 has no Rust, only an old meson and no libclang, so kime cannot be
cooked out of the box. This repo has the receipts and fixes that make it
work, tested on the x86_64 cooking ISO of 10 November 2026.

## What works

| | |
|---|---|
| GTK3 apps (Firefox ESR, TazTerm, the LXTaz tools) | yes, through kime's GTK3 module |
| Other X11 apps | yes, through XIM |
| Qt5 / Qt6 apps (e.g. qBittorrent) | no: the Qt modules are not built (see below); type elsewhere and paste |
| Telegram Desktop (official binary) | no: it bundles its own Qt; use Telegram Web in Firefox instead (not tested) |
| Wayland | no (SliTaz 5.1 uses Xorg) |
| Hangul / Hanja / emoji | Hangul tested; Hanja and emoji use kime's candidate window (built, not tested) |

## Tested setup

| | |
|---|---|
| SliTaz | 5.1 cooking, x86_64 *firefox* ISO (10 Nov 2026), installed to disk |
| Kernel | 6.12.115-slitaz |
| Toolchain | GCC 6.3.0, glibc 2.20, GLib 2.56.4, GTK3 3.22.30, Python 3.8.3 |
| Machine | QEMU/KVM guest, 6 cores, 8 GB RAM (see [slitaz-qemu-clipboard](https://github.com/Otrona/slitaz-qemu-clipboard) for the VM setup) |

## Repository layout

```
wok/meson/receipt           meson 1.5.2 (kime needs >= 1.1; SliTaz has 0.62.2)
wok/rust/receipt            Rust 1.99.1, official x86_64 binaries
wok/kime/receipt            kime 3.2.0: XIM + GTK3 module
wok/fonts-kr/receipt        Noto Sans KR, Noto Serif KR, NanumSquare
host/get-fonts-kr           collects the font files (run on a machine with internet)
guest/fix-cook-conf.sh      fixes the i486 values in cook.conf on x86_64
guest/kime-session.sh       sets up the environment and autostart for kime
```

---

## Option A: install prebuilt packages

Download from the [v3.2.0-1 release](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1)
`kime-3.2.0-x86_64.tazpkg` and `fonts-kr-1.0-any.tazpkg`, then as root:

```sh
tazpkg install fonts-kr-1.0-any.tazpkg
tazpkg install kime-3.2.0-x86_64.tazpkg
sh guest/kime-session.sh          # or the commands in "Session setup" below
```

Log out and back in, then press **Right Alt** to switch to Hangul. The kime
package needs no Rust or meson at run time; tazpkg fetches its few runtime
dependencies (gtk+3, dbus, fontconfig, freetype, libxcb) from the mirror.

## Option B: cook from source

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

## Session setup

As root (or `sh guest/kime-session.sh`):

```sh
printf 'export GTK_IM_MODULE=kime\nexport XMODIFIERS=@im=kime\n' > /etc/profile.d/kime.sh
```

As the desktop user:

```sh
echo 'kime &' >> ~/.config/openbox/autostart.sh
```

Log out and back in. Press **Right Alt** to switch between English and
Hangul; for example `dkssud` types 안녕. Programs started before the font
install keep their old font list: restart them.

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
  `rustc` then segfaults. The receipt sets `COOKOPTS="!strip"` (**not yet
  verified**: after cooking, check the file is still ~158 MB). If `rustc`
  segfaults, unpack the tarball from `/home/slitaz/src` and run its
  `./install.sh --prefix=/usr --without=rust-docs --disable-ldconfig`.

The Qt5 module would need the Qt5 development files, a C++17/20 compiler
(`gcc83` exists in the repository) and kime's `system_engine` option; it is
not attempted here.

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
| No Hangul in one app | it does not see the environment | `echo $GTK_IM_MODULE` should print `kime`; log out and in |
| Right Alt does nothing | kime not running | `pgrep -a kime`; start it with `kime &` |

Build logs are in `/home/slitaz/log/<package>.log`.

## Licenses

The scripts and receipts in this repository are licensed under GPL-3.0 (see [LICENSE](LICENSE)).

kime is GPL-3.0-or-later. Noto CJK and NanumSquare are under the SIL Open
Font License 1.1. Rust is MIT/Apache-2.0, meson Apache-2.0.

Issues and reports from other setups are welcome.
