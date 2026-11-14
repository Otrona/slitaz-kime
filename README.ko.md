# SliTaz 5.1 (x86_64)용 kime 한글 입력기

[English](README.md) | **한국어**

[SliTaz](https://www.slitaz.org) 5.1에서 [kime](https://github.com/Riey/kime)
3.2.0으로 한글을 입력하기 위한 receipt와 설정 모음입니다. 한글 글꼴 패키지,
LibreOffice 7.6, 바로 부팅할 수 있는 Live ISO 두 가지도 함께 제공합니다.

SliTaz 5.1에는 Rust가 없고, meson은 오래된 버전이며, libclang도 없어서
kime를 그대로는 빌드(cook)할 수 없습니다. 이 저장소에는 이를 해결하는
receipt, 수정 사항, ISO flavor가 들어 있으며, 2026년 11월 SliTaz 5.1 x86_64
cooking에서 테스트했습니다.

## 동작 범위

| | |
|---|---|
| GTK3 프로그램 (Firefox ESR, TazTerm, 텍스트 편집기, LXTaz 도구) | 됨 (kime GTK3 모듈) |
| LibreOffice 7.6 | 됨 (XIM, 실행 스크립트에서 설정) |
| 그 밖의 X11 전용 프로그램 (예: xterm) | 안 됨: XIM에는 `XMODIFIERS=@im=kime`가 필요한데 LXTaz 세션이 설정하지 않음 |
| Qt5 / Qt6 프로그램 (예: qBittorrent) | 안 됨: Qt 모듈은 빌드하지 않음. 다른 곳에서 입력한 뒤 붙여넣기 |
| Telegram Desktop (공식 바이너리) | 안 됨: 자체 Qt를 내장. 대신 Firefox에서 Telegram Web 사용 (테스트 안 함) |
| Wayland | 안 됨 (SliTaz 5.1은 Xorg 사용) |
| 한글 / 한자 / 이모지 | 한글은 테스트 완료. 한자와 이모지는 kime 후보 창을 사용 (테스트 안 함) |
| kime 상태 아이콘 (한/A) | 안 됨: [알려진 문제](#알려진-문제) 참고 |

## 테스트 환경

| | |
|---|---|
| SliTaz | 5.1 cooking x86_64 (2026년 11월): 디스크 설치판과 아래 Live ISO |
| 커널 | 6.12.115-slitaz |
| 툴체인 | GCC 6.3.0, glibc 2.20, GLib 2.56.4, GTK3 3.22.30, Python 3.8.3 |
| 가상 머신 | QEMU/KVM, 6코어, RAM 8 GB ([slitaz-qemu-clipboard](https://github.com/Otrona/slitaz-qemu-clipboard) 참고) |
| 실제 PC | ThinkPad E14 Gen 3 (Realtek RTL8852AE 무선랜), Ventoy로 부팅 (UEFI, 일반 모드) |

## 저장소 구성

```
wok/meson/receipt           meson 1.5.2 (kime는 1.1 이상 필요, SliTaz에는 0.62.2)
wok/rust/receipt            Rust 1.99.1, 공식 x86_64 바이너리
wok/kime/receipt            kime 3.2.0: XIM + GTK3 모듈
wok/fonts-kr/receipt        Noto Sans KR, Noto Serif KR, 나눔스퀘어
wok/libreoffice/receipt     LibreOffice 7.6.7.2, 공식 x86-64 바이너리
flavors/kime-x86_64         metier flavor: Firefox 데스크톱 + kime + 글꼴
flavors/kime-office-x86_64  metier flavor: 위 + LibreOffice
host/get-fonts-kr           글꼴 파일 수집 (인터넷이 되는 컴퓨터에서 실행)
guest/fix-cook-conf.sh      x86_64에서 cook.conf의 i486 설정을 고침
guest/kime-session.sh       kime 시스템 전체 글꼴 설정
```

---

## 방법 A: Live ISO (바로 부팅)

SliTaz 5.1 cooking의 `firefox-x86_64` flavor를 바탕으로 만든 비공식 ISO입니다.
BIOS와 UEFI를 모두 지원하며, USB에 굽거나(`dd`, Rufus DD 모드) Ventoy로 부팅할
수 있습니다.

| ISO | 내용 | RAM | SHA-256 |
|---|---|---|---|
| `slitaz-kime-x86_64-cooking.iso` (177 MB) | Firefox + kime + 한글 글꼴 | 2 GB 이상 | `d7e4c3541156d07a1e742be597b4b3f199412fde45045a5caf49b29720c0e2f2` |
| `slitaz-kime-office-x86_64-cooking.iso` (367 MB) | 위 + LibreOffice 7.6 | 4 GB 이상 | `0f9508bd042108498b808317e2b98e5f5e74eddb0707bdbbc6d79182d393c700` |

다운로드 (MYBOX): [kime판](https://naver.me/5LQ6gQ8k) · [오피스판](https://naver.me/G6RmxRRB)

Live 시스템은 전체가 RAM에서 실행됩니다. kime는 자동으로 실행되며
**오른쪽 Alt**로 한글로 전환합니다. 공식 firefox ISO에는 없는 Realtek
Wi-Fi 6/6E/7 무선랜 펌웨어(rtw89)도 두 ISO에 들어 있습니다.

## 방법 B: 패키지 설치

이미 SliTaz 5.1 x86_64를 쓰고 있다면,
[v3.2.0-1 릴리스](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1)에서
`kime-3.2.0-x86_64.tazpkg`, `fonts-kr-1.0-any.tazpkg`(필요하면
`libreoffice-7.6.7.2-x86_64.tazpkg`도)를 내려받은 뒤, root로 실행합니다:

```sh
tazpkg install fonts-kr-1.0-any.tazpkg
tazpkg install kime-3.2.0-x86_64.tazpkg
tazpkg install libreoffice-7.6.7.2-x86_64.tazpkg     # 선택
sh guest/kime-session.sh
```

로그아웃했다가 다시 로그인한 뒤 **오른쪽 Alt**를 누르면 됩니다. SliTaz
cooking은 계속 업데이트되는 롤링 버전입니다. 시스템을 업데이트해도 사용하는
라이브러리가 호환되는 한 이 패키지를 계속 쓸 수 있습니다. 업데이트 후 동작하지
않으면 receipt로 다시 빌드하세요 (방법 C). 실행에 필요한 패키지(gtk+3, dbus,
fontconfig, freetype, libxcb, LibreOffice는 libcups, nss, nspr)는 tazpkg가
미러에서 받아 옵니다.

## 방법 C: 소스에서 빌드

### 1. 준비 (root)

```sh
# 미러: 설치된 5.1 시스템에서는 busybox wget이 HTTPS 미러에 접속할 때
# "Connection reset by peer" 오류가 납니다. HTTP를 사용하세요:
echo http://mirror.slitaz.org/x86_64/cooking/packages/ > /var/lib/tazpkg/mirror
tazpkg recharge

# 설치 프로그램은 cookutils를 설치하지 않습니다
tazpkg get-install cookutils
cook setup

# x86_64인데 cook.conf가 i486 설정으로 되어 있으므로 고칩니다
# (cook setup을 실행할 때마다 다시 실행)
sh guest/fix-cook-conf.sh

tazpkg get-install python3
```

Rust와 kime 빌드에는 **RAM 약 8 GB**, **디스크 여유 공간 약 6 GB**가
필요합니다.

### 2. meson, Rust, kime 빌드 (root)

meson과 Rust를 직접 빌드하지 않으려면(약 7분, 1.8 GB 필요)
[slitaz-rust-meson](https://github.com/Otrona/slitaz-rust-meson/releases/latest)의 미리 빌드된 패키지를 설치하면 됩니다.

```sh
cp -r wok/meson wok/rust wok/kime /home/slitaz/wok/

cook meson
tazpkg install /home/slitaz/packages/meson-1.5.2*.tazpkg
meson --version                          # 1.5.2

cook rust
tazpkg install /home/slitaz/packages/rust-1.99.1*.tazpkg
rustc --version && cargo --version
rm -rf /home/slitaz/wok/rust/source /home/slitaz/wok/rust/install /home/slitaz/wok/rust/taz

cook kime                                # 6코어 기준 약 5분
tazpkg install /home/slitaz/packages/kime-3.2.0*.tazpkg
```

`cook kime` 전에 반드시 **직접 빌드한** meson과 rust 패키지를 설치하세요.
그렇지 않으면 cook이 저장소의 meson 0.62.2를 설치합니다.

### 3. 글꼴

인터넷이 되는 컴퓨터에서 (글꼴 파일은 이 저장소에 포함되어 있지 않습니다):

```sh
./host/get-fonts-kr                      # 약 27 MB, ~/tmp/fonts-kr에 저장
```

이 폴더를 SliTaz의 `/home/slitaz/wok/fonts-kr/stuff/fonts`로 복사한 뒤:

```sh
cp -r wok/fonts-kr /home/slitaz/wok/     # receipt 복사 (stuff/fonts는 그대로)
cook fonts-kr
tazpkg install /home/slitaz/packages/fonts-kr-1.0*.tazpkg
fc-list :lang=ko family                  # 세 가지 글꼴이 표시되면 성공
```

### 4. LibreOffice (선택)

```sh
cp -r wok/libreoffice /home/slitaz/wok/
cook libreoffice                         # 약 230 MB 다운로드
tazpkg install /home/slitaz/packages/libreoffice-7.6.7.2*.tazpkg
```

### 5. 세션 설정

```sh
sh guest/kime-session.sh                 # root
```

이후 kime는 로그인할 때마다 자동으로 실행됩니다 (패키지가 XDG 자동 시작 항목을
설치함). 글꼴을 설치하기 전에 실행한 프로그램은 예전 글꼴 목록을 쓰므로 다시
실행하세요.

## 방법 D: ISO 직접 만들기

ISO는 SliTaz의 ISO 빌더 **metier**로 `flavors/`의 flavor에서 만듭니다. 위
패키지를 빌드한 SliTaz 5.1 x86_64에서 root로:

```sh
tazpkg get-install metier
tazpkg get-install mercurial
hg clone http://hg.slitaz.org/flavors /home/slitaz/repos/flavors
cp -r flavors/kime-x86_64 flavors/kime-office-x86_64 /home/slitaz/repos/flavors/

# metier는 이 폴더의 패키지를 먼저 쓰고, 나머지는 미러에서 받습니다
mkdir -p /home/slitaz/x86_64/packages
cp /home/slitaz/packages/kime-*.tazpkg /home/slitaz/packages/fonts-kr-*.tazpkg \
   /home/slitaz/packages/libreoffice-*.tazpkg /home/slitaz/x86_64/packages/

metier check kime-x86_64
metier build kime-x86_64                 # -> /home/slitaz/iso/
metier build kime-office-x86_64
```

두 flavor는 공식 `firefox-x86_64` flavor를 복사해서 다음을 바꾼 것입니다:

- `packages.list`에 `kime`, `fonts-kr`(와 `libreoffice`) 추가
- `firmware-rtw89-*` 다섯 개 추가 (Realtek Wi-Fi 6/6E/7)
- `addfiles/etc/xdg/kime/config.yaml` (kime 글꼴 설정, `kime-session.sh`와 같음)
- 압축을 lzma 대신 `COMPRESSION="xz"`로 변경 (아래 Ventoy 참고)

참고:

- metier는 다운로드마다 **120초** 제한이 있습니다. 느린 네트워크에서는 약
  100 MB인 Firefox 패키지가 시간 초과로 "미러에 없음"으로 표시됩니다. metier
  캐시에 직접 내려받은 뒤 `metier check`를 다시 실행하세요:
  `wget -O /home/slitaz/x86_64/cache/cooking/<파일> http://mirror.slitaz.org/x86_64/cooking/packages/<파일>`
- `tazlito writeiso`는 x86_64에서 동작하지 않습니다 (x86_64 SliTaz에는 없는
  isolinux가 필요). metier는 GRUB2 하이브리드 ISO를 만듭니다.
- 오피스판 빌드가 뚜렷한 오류 없이 두 번 멈췄는데, 다시 실행하면 두 번 모두
  성공했습니다. ISO 파일의 날짜가 바뀌었는지 확인하세요.

---

## receipt를 이렇게 만든 이유

| | kime 3.2.0 요구 사항 | SliTaz 5.1 x86_64 | 해결 방법 |
|---|---|---|---|
| Rust | stable, edition 2021 | 패키지 없음 | 공식 1.99.1 바이너리 (glibc 2.17 이상이면 동작) |
| meson | 1.1 이상 | 0.62.2 | Python 3.8에서 동작하는 마지막 버전인 meson 1.5.2 |
| libclang | `bindgen` 때문에 필요 | 패키지 없음 | `bindgen`은 선언만 되어 있고 실제로는 쓰이지 않음 (`build.rs`는 cbindgen만 사용). receipt에서 해당 줄을 삭제 |
| C++20 | kime 기본 `cpp_std` | GCC 6.3은 지원 안 함 | `-Dcpp_std=none`: C++ 코드는 비활성화한 Qt 모듈뿐 |
| GTK3 | `gtk+-3.0` | 3.22.30 | 문제없음 |

Rust receipt 참고 사항:

- **`.tar.gz`** 파일을 사용합니다. busybox `unxz`는 Rust의 `.tar.xz`에서
  "corrupted data" 오류를 냅니다.
- cook의 **strip** 단계가 `librustc_driver`를 손상시켜(158 MB → 136 MB)
  `rustc`가 segfault로 종료됩니다. receipt에 `COOKOPTS="!strip"`을
  넣어 파일 크기가 약 158 MB로 유지되는 것을 확인했습니다.
  그래도 `rustc`가 segfault로 끝나면 `/home/slitaz/src`의 tarball을
  풀고 `./install.sh --prefix=/usr --without=rust-docs --disable-ldconfig`
  를 실행하면 됩니다.

kime 글꼴: kime는 XIM 조합 창과 한자 후보 창에 **"Noto Sans CJK KR"**(대체
글꼴 D2Coding)을 찾습니다. fonts-kr이 설치하는 "Noto Sans KR"은 글꼴 이름이
달라서, `/etc/xdg/kime/config.yaml`로 이 글꼴을 쓰도록 지정합니다. 이 설정이
없으면 kime-xim이 `Failed to load xim preedit font ... InvalidFont`를
출력합니다. 설정은 반드시 `engine:` 아래에 넣어야 합니다.

LibreOffice receipt 참고 사항:

- **7.6**은 glibc 2.17에서 동작하는 마지막 버전입니다. 24.2 이후는 2.27이
  필요합니다 ([시스템 요구 사항](https://www.libreoffice.org/get-help/system-requirements)).
  7.6은 더 이상 보안 업데이트가 없습니다.
- SliTaz의 `get-LibreOffice` 스크립트는 32비트판을 받아서 x86_64에서는 쓸 수
  없습니다. 이 receipt는 공식 x86-64 RPM을 풀어서 씁니다.
- LibreOffice의 **GTK3 플러그인은 SliTaz 5.1에서 비정상 종료**합니다
  ("Unspecified Application Error"). 그래서 이 플러그인(`gnome-integration`
  RPM)은 빼고 X11 플러그인을 씁니다. X11 플러그인은 XIM으로만 입력을 받는데
  LXTaz 세션이 `XMODIFIERS`를 설정하지 않으므로, receipt가 `soffice` 실행
  스크립트에 `SAL_USE_VCLPLUGIN=gen`과 `XMODIFIERS=@im=kime`를 넣습니다
  (이미 설정되어 있으면 그대로 둠).

Qt5 모듈은 Qt5 개발 파일, C++17/20 컴파일러(저장소에 `gcc83` 있음),
kime의 `system_engine` 옵션이 필요해서 여기서는 시도하지 않았습니다.

## 알려진 문제

- **kime 상태 아이콘이 패널에 나타나지 않습니다.** kime-indicator는
  StatusNotifierItem(D-Bus) 방식을 쓰는데, LXTaz 패널은 XEmbed 방식의 아이콘만
  표시합니다. 한글 입력에는 지장이 없습니다. `snixembed` 같은 중계 프로그램으로
  해결될 수도 있습니다 (시도 안 함).
- **세션이 입력기 환경 변수를 설정하지 않습니다.** `lxtaz-dm`은
  `/etc/locale.conf`에서 로캘만 읽고, 세션은 profile 파일을 읽지 않으므로
  `/etc/profile.d`는 효과가 없습니다. GTK3 프로그램은 그래도 kime를 쓰지만,
  X11 전용 프로그램(xterm)에서는 한글이 입력되지 않습니다.
- **가상 머신에서는 화면이 느립니다.** SliTaz 5.1에는 QEMU 가상 그래픽
  카드용 드라이버(virtio-gpu, qxl, bochs)가 없어서 X가 fbdev를 씁니다. 실제
  PC에서는 정상입니다.

## 문제 해결

| 증상 | 원인 | 해결 |
|---|---|---|
| `CPU you selected does not support x86-64` | `cook.conf`의 i486 설정 | `guest/fix-cook-conf.sh` |
| `Command 'cook' not found` | cookutils 미설치 | `tazpkg get-install cookutils` |
| tazpkg: `Recharging failed`, `Connection reset by peer` | busybox wget과 HTTPS 미러 문제 | `http://` 미러 사용 |
| `meson_version >= 1.1` | 저장소의 meson 0.62.2가 쓰임 | `wok/meson`을 먼저 설치 |
| rust: `unxz: corrupted data` | busybox unxz와 `.tar.xz` 문제 | `.tar.gz` 사용 (receipt에 반영됨) |
| `rustc`는 segfault, `cargo`는 동작 | cook이 `librustc_driver`를 strip함 | 위 Rust 참고 사항 |
| 한글이 네모로 표시됨 | 한글 글꼴이 없거나, 글꼴 설치 전에 실행한 프로그램 | fonts-kr 설치 후 프로그램 재실행 |
| kime-xim: `InvalidFont` | kime 기본 글꼴 이름이 설치되어 있지 않음 | `guest/kime-session.sh` |
| 오른쪽 Alt가 반응 없음 | kime가 실행되지 않음 | `pgrep -a kime` 확인, `kime &`로 실행 |
| LibreOffice가 시작하자마자 닫히거나 문서 복구를 계속 요청 | GTK3 플러그인 비정상 종료 | 이 receipt 사용, `~/.config/libreoffice`를 한 번 다른 이름으로 옮김 |
| Ventoy: `rootfs image is not initramfs (LZMA data is corrupt)`, 로그인 실패 | Ventoy가 initramfs를 덧붙이는데 lzma에는 끝 표시가 없음 | `COMPRESSION="xz"`로 빌드 (flavor에 반영됨) |
| metier: 패키지가 "미러에 없음" | 다운로드 120초 제한 | `wget`으로 캐시에 직접 내려받기 |
| Realtek Wi-Fi 6 무선랜이 안 잡힘 | `firmware-rtw89-*` 없음 | 설치 (ISO에는 포함됨) |

빌드 로그는 `/home/slitaz/log/<패키지>.log`에 있습니다.

## 라이선스

이 저장소의 스크립트, receipt, flavor는 GPL-3.0 라이선스를 따릅니다
([LICENSE](LICENSE) 참고).

kime는 GPL-3.0-or-later, LibreOffice는 MPL-2.0, Noto CJK와 나눔스퀘어는 SIL
Open Font License 1.1, Rust는 MIT/Apache-2.0, meson은 Apache-2.0입니다. ISO에
들어 있는 SliTaz 패키지는 각자의 라이선스를 따르며, 비자유 펌웨어도 포함되어
있습니다.

다른 환경에서의 사용 후기나 이슈 등록을 환영합니다.
