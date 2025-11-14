## Cél
Növelni az elérhető eszközök számát az alkalmazásban és frissíteni az app verzióját `1.0.77`-re, majd a módosításokat gitre pusholni.

## Változások köre
1. Eszközadatok bővítése a meglévő kategóriákban (Phones, Macs, iPads, AirPods, Watches, Laptops, Tablets, Headphones).
2. Verziófrissítés: `pubspec.yaml:19` → `version: 1.0.77`.
3. Git commit és push az aktuális ágra.

## Konkrét fájlmódosítások
- `lib/data/phones_data.dart`: új modellek az Apple/Samsung/Xiaomi/Google/OnePlus listákban; az `allPhones` aggregátor automatikusan felveszi őket.
- `lib/data/macs_data.dart`: új MacBook/iMac/Studio variánsok.
- `lib/data/ipads_data.dart`: új iPad Air/Pro/Basic variánsok az `alliPads` listában.
- `lib/data/airpods_data.dart`, `lib/data/watches_data.dart`, `lib/data/laptops_data.dart`, `lib/data/tablets_data.dart`, `lib/data/headphones_data.dart`: kategóriánként 2–4 új eszköz.
- `pubspec.yaml:19`: verzió `1.0.77`.

## Telefonom márkafilter kompatibilitás
- A brand chip-ek a következőkre korlátozottak: `All, iPhone, Samsung, Xiaomi, Google, OnePlus` (`lib/screens/home_screen.dart:900–911`).
- Csak ezekhez a márkákhoz adunk új telefonokat, így nem szükséges a UI brand lista bővítése.

## Példák az új elemekre
- Phones: `Galaxy S24 Ultra`, `Pixel 9 Pro`, `OnePlus 12`, további iPhone 16/15 variánsok.
- Macs: `MacBook Air 15" (M3)`, `MacBook Pro 14" (M3 Pro)` variánsok.
- iPads: `iPad Air M2` variánsok, `iPad Pro M4` további konfigurációk.
- Headphones: `Sony WH-1000XM5`, `AirPods Pro (USB‑C)`.
- Watches: `Apple Watch Series 10`, `Watch SE (2024)`.
- Laptops/Tablets: 2–3 népszerű modell kategóriánként, a meglévő model struktúrával.

## Ellenőrzés
- `flutter analyze` futtatása és hibák javítása.
- Build/preview lokálisan: ellenőrizni, hogy az új eszközök megjelennek és szűrhetők.
- Egyszerű tesztek (adatlisták nem üresek, szűrés működik) frissítése/futtatása.

## Git lépések
1. Változtatások staged → `git add .`.
2. Commit → `git commit -m "feat(data): több eszköz hozzáadva; version 1.0.77"`.
3. Push → `git push` (az aktuális origin/branch-re).

Jóváhagyás után elvégzem a fenti módosításokat, frissítem a verziót és pusholom a változásokat.