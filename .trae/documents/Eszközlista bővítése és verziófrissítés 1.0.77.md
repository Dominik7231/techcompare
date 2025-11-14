## Cél
Bővíteni az alkalmazásban elérhető eszközök számát minden érintett kategóriában, majd frissíteni az app verzióját `1.0.77`-re és előkészíteni a git push-t.

## Változtatások köre
1. Eszközadatok bővítése a meglévő kategóriákban:
   - Phones: új modellek a meglévő márkákhoz (iPhone, Samsung, Xiaomi, Google, OnePlus).
   - Macs: több MacBook Air/Pro, iMac, Studio/Pro variáns.
   - iPads: több iPad Pro/Air/Basic variáns.
   - AirPods, Watches, Laptops, Tablets, Headphones: kategóriánként 2–4 új eszköz.
2. Verziófrissítés: `pubspec.yaml:19` → `version: 1.0.77`.
3. Git commit és push az aktuális ágra.

## Konkrét fájlmódosítások
- `lib/data/phones_data.dart`: új telefonok a meglévő listákban; az `allPhones` aggregátor automatikusan felveszi őket.
- `lib/data/macs_data.dart`: új Mac variánsok az `allMacs` listában.
- `lib/data/ipads_data.dart`: új iPad variánsok az `alliPads` listában.
- `lib/data/airpods_data.dart`, `lib/data/watches_data.dart`, `lib/data/laptops_data.dart`, `lib/data/tablets_data.dart`, `lib/data/headphones_data.dart`: kategóriánként 2–4 új eszköz felvétele az adott lista struktúráját követve.
- `pubspec.yaml:19`: verzió `1.0.77`.

## UI kompatibilitás
- A telefonoknál csak a meglévő brand chip-eket használjuk: `All, iPhone, Samsung, Xiaomi, Google, OnePlus` (`lib/screens/home_screen.dart:900–911`), így a szűrő változatlanul működik.
- Más kategóriákban nincs márka chip, csak lista bővítés szükséges.

## Ellenőrzés
- `flutter analyze` és gyors futtatás: az új eszközök megjelennek, szűrhetők.
- Alap teszt futtatás; szükség esetén egyszerű ellenőrző tesztek (lista nem üres, szűrés működik).

## Git lépések
1. `git add .`
2. `git commit -m "feat(data): több eszköz; version 1.0.77"`
3. `git push`

Jóváhagyás után végrehajtom a módosításokat, frissítem a verziót és pusholom a változásokat.