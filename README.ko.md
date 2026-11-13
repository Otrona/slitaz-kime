# SliTaz 5.1 (x86_64)용 kime 한글 입력기

[English](README.md) | **한국어**

[SliTaz](https://www.slitaz.org) 5.1에서 [kime](https://github.com/Riey/kime)
3.2.0으로 한글을 입력하기 위한 receipt와 설정 모음입니다. 간단한 한글 글꼴
패키지도 함께 들어 있습니다.

SliTaz 5.1에는 Rust가 없고, meson은 오래된 버전이며, libclang도 없어서
kime를 그대로는 빌드(cook)할 수 없습니다. 이 저장소에는 이를 해결하는
receipt와 수정 사항이 들어 있으며, 2026년 11월 10일자 x86_64 cooking ISO에서
테스트했습니다.

## 동작 범위

| | |
|---|---|
| GTK3 프로그램 (Firefox ESR, TazTerm, LXTaz 도구) | 됨 (kime GTK3 모듈) |
| 그 밖의 X11 프로그램 | 됨 (XIM) |
| Qt5 / Qt6 프로그램 (예: qBittorrent) | 안 됨: Qt 모듈은 빌드하지 않음 (아래 참고). 다른 곳에서 입력한 뒤 붙여넣기 |
| Telegram Desktop (공식 바이너리) | 안 됨: 자체 Qt를 내장. 대신 Firefox에서 Telegram Web 사용 (테스트 안 함) |
| Wayland | 안 됨 (SliTaz 5.1은 Xorg 사용) |
| 한글 / 한자 / 이모지 | 한글은 테스트 완료. 한자와 이모지는 kime 후보 창을 사용 (빌드됨, 테스트 안 함) |

## 테스트 환경

| | |
|---|---|
| SliTaz | 5.1 cooking, x86_64 *firefox* ISO (2026-11-10), 디스크에 설치 |
| 커널 | 6.12.115-slitaz |
| 툴체인 | GCC 6.3.0, glibc 2.20, GLib 2.56.4, GTK3 3.22.30, Python 3.8.3 |
| 머신 | QEMU/KVM 게스트, 6코어, RAM 8 GB (VM 설정은 [slitaz-qemu-clipboard](https://github.com/Otrona/slitaz-qemu-clipboard) 참고) |

## 저장소 구성

```
wok/meson/receipt           meson 1.5.2 (kime는 1.1 이상 필요, SliTaz에는 0.62.2)
wok/rust/receipt            Rust 1.99.1, 공식 x86_64 바이너리
wok/kime/receipt            kime 3.2.0: XIM + GTK3 모듈
wok/fonts-kr/receipt        Noto Sans KR, Noto Serif KR, 나눔스퀘어
host/get-fonts-kr           글꼴 파일 수집 (인터넷이 되는 컴퓨터에서 실행)
guest/fix-cook-conf.sh      x86_64에서 cook.conf의 i486 설정을 고침
guest/kime-session.sh       kime 환경 변수와 자동 시작 설정
```

---

## 방법 A: 미리 빌드된 패키지 설치

[v3.2.0-1 릴리스](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1)에서
`kime-3.2.0-x86_64.tazpkg`와 `fonts-kr-1.0-any.tazpkg`를 내려받은 뒤,
root로 실행합니다:

```sh
tazpkg install fonts-kr-1.0-any.tazpkg
tazpkg install kime-3.2.0-x86_64.tazpkg
sh guest/kime-session.sh          # 또는 아래 "세션 설정"의 명령
```

로그아웃했다가 다시 로그인한 뒤 **오른쪽 Alt**를 누르면 한글로 바뀝니다.
kime 패키지는 실행할 때 Rust나 meson이 필요 없습니다. 실행에 필요한 몇 가지
패키지(gtk+3, dbus, fontconfig, freetype, libxcb)는 tazpkg가 미러에서 받아
옵니다.

## 방법 B: 소스에서 빌드

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

## 세션 설정

root로 (또는 `sh guest/kime-session.sh`):

```sh
printf 'export GTK_IM_MODULE=kime\nexport XMODIFIERS=@im=kime\n' > /etc/profile.d/kime.sh
```

데스크톱 사용자로:

```sh
echo 'kime &' >> ~/.config/openbox/autostart.sh
```

로그아웃했다가 다시 로그인합니다. **오른쪽 Alt**로 영어와 한글을 전환합니다.
예를 들어 `dkssud`를 치면 "안녕"이 입력됩니다. 글꼴을 설치하기 전에 실행한
프로그램은 예전 글꼴 목록을 쓰므로 다시 실행하세요.

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

Qt5 모듈은 Qt5 개발 파일, C++17/20 컴파일러(저장소에 `gcc83` 있음),
kime의 `system_engine` 옵션이 필요해서 여기서는 시도하지 않았습니다.

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
| 특정 프로그램에서만 한글 입력 안 됨 | 환경 변수를 못 받음 | `echo $GTK_IM_MODULE`이 `kime`인지 확인, 다시 로그인 |
| 오른쪽 Alt가 반응 없음 | kime가 실행되지 않음 | `pgrep -a kime` 확인, `kime &`로 실행 |

빌드 로그는 `/home/slitaz/log/<패키지>.log`에 있습니다.

## 라이선스

이 저장소의 스크립트와 receipt는 GPL-3.0 라이선스를 따릅니다 ([LICENSE](LICENSE) 참고).

kime는 GPL-3.0-or-later, Noto CJK와 나눔스퀘어는 SIL Open Font License 1.1,
Rust는 MIT/Apache-2.0, meson은 Apache-2.0입니다.

다른 환경에서의 사용 후기나 이슈 등록을 환영합니다.
