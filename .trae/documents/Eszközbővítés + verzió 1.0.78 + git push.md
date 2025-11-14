## Célok
1. Több eszköz felvétele az alkalmazásba (Phones, Macs, iPads, AirPods, Watches, Laptops, Tablets, Headphones).
2. Verzió frissítése `1.0.78`-ra.
3. Változások commitálása és pusholása gitre.

## Változtatások áttekintése
- Adatbővítés a `lib/data/*.dart` fájlokban: kategóriánként 2–4 új modell.
- A jelenlegi telefonnavigáció és brand-szűrők változatlanul működnek (Phones: iPhone, Samsung, Xiaomi, Google, OnePlus).
- `pubspec.yaml` verzió: `1.0.78`.

## Konkrét fájlok és szerkesztések
- `lib/data/phones_data.dart`
  - Új telefonok a meglévő márkákhoz, pl.: `iPhone 16e`, `Galaxy S24 Ultra`, `Xiaomi 14 Pro`, `Pixel 9 Pro`, `OnePlus 12`.
  - Csak a meglévő márkákhoz adunk, hogy a brand chip-ek kompatibilisek maradjanak.
- `lib/data/macs_data.dart`
  - Új modellek: `MacBook Air 15" (M3, 2024)`, `MacBook Pro 14" (M3 Pro, 2023)` variánsok.
- `lib/data/ipads_data.dart`
  - Új modellek: `iPad Air 11" (M2, 2024)`, további `iPad Pro (M4)` konfigurációk.
- `lib/data/airpods_data.dart`
  - Új modellek: `AirPods Pro (USB‑C)`, `AirPods Max`.
- `lib/data/watches_data.dart`
  - Új modellek: `Apple Watch Series 10`, `Apple Watch SE (2024)`.
- `lib/data/laptops_data.dart`, `lib/data/tablets_data.dart`, `lib/data/headphones_data.dart`
  - Kategóriánként 2–3 népszerű modell felvétele a meglévő struktúrát követve.
- `pubspec.yaml`
  - `version: 1.0.78`.

## Validáció
- `flutter analyze` futtatása és hibák javítása.
- Gyors kézi ellenőrzés: az új eszközök megjelennek, szűrés/rendezés működik.
- (Opcionális) egyszerű tesztek az adatlistákra és a szűrés logikára.

## Git lépések
1. `git add .`
2. `git commit -m "feat(data): több eszköz hozzáadva; version 1.0.78"`
3. `git push` (aktuális origin/branch).

Jóváhagyás után végrehajtom a fenti módosításokat, frissítem a verziót, és pusholom a változásokat.