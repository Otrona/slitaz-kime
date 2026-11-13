# kime 3.2.0 for SliTaz 5.1 x86_64

[English](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1) | **한국어**

**SliTaz 5.1 x86_64**용 **kime 3.2.0** 한글 입력기와 한글 글꼴 패키지입니다.
(2026년 11월 10일자 cooking ISO에서 테스트)

파일은 [릴리스 페이지](https://github.com/Otrona/slitaz-kime/releases/tag/v3.2.0-1)에서 내려받을 수 있습니다.

| 파일 | 내용 |
|---|---|
| `kime-3.2.0-x86_64.tazpkg` | kime 3.2.0 (XIM, GTK3 모듈) |
| `fonts-kr-1.0-any.tazpkg` | Noto Sans KR, Noto Serif KR, 나눔스퀘어 (Regular, Bold) |
| `SHA256SUMS` | 체크섬 |

## 설치

내려받은 파일이 있는 폴더에서 root로 실행합니다:

```sh
sha256sum -c SHA256SUMS
tazpkg install fonts-kr-1.0-any.tazpkg
tazpkg install kime-3.2.0-x86_64.tazpkg
sh guest/kime-session.sh
```

`guest/kime-session.sh`는 이 저장소에 있습니다. 로그아웃 후 다시
로그인하고 **오른쪽 Alt**를 누르면 한글로 전환됩니다.

## 참고

- GTK3 프로그램(Firefox ESR, TazTerm)과 XIM을 쓰는 X11 프로그램에서 동작합니다. Qt5/Qt6 프로그램은 지원하지 않습니다.
- 실행에는 Rust나 meson이 필요 없습니다. 부족한 패키지는 미러에서 자동으로 설치되며, HTTPS 미러 오류가 나면 [README](../README.ko.md)를 참고하세요.
- 라이선스: kime GPL-3.0-or-later, 글꼴 SIL OFL 1.1.
