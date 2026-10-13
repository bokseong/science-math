# 인쇄용 실제 좌표 성도

이 폴더의 12개 SVG는 A4 비율 인쇄용입니다. 생일 별자리(황도 12궁)의 별자리 선, 항성, 메시에 천체와 밝은 딥스카이를 J2000 적경·적위 좌표로 배치했습니다. 희미한 카탈로그 천체를 모두 넣으면 읽기 어려워지므로, 딥스카이는 메시에 목록과 밝은 대표 대상 중 시야 안에서 겉보기등급이 밝은 순서의 최대 12개만 표시합니다.

- 항성 위치: XHIP Extended Hipparcos Compilation (VizieR V/137D)
- 딥스카이: Messier catalog 및 Saguaro Astronomy Club Database 8.1의 밝은 대표 대상
- 별자리 선·투영용 GeoJSON: [d3-celestial](https://github.com/ofrohn/d3-celestial), BSD-3-Clause

`../tools/generate-zodiac-posters.ps1`는 원본 d3-celestial의 `data` 폴더를 `-DataRoot`로 받아 SVG를 다시 생성합니다.

별자리 선은 하늘의 물리적 연결이 아니라, 서양 천문 문화에서 사용하는 도식입니다. 성도에 나타나는 위치는 실제 좌표 기반이지만, 관측 시의 방향·고도는 관측 날짜·시간·장소에 따라 달라집니다.
