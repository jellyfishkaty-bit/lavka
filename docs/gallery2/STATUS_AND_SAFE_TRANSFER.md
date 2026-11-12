# Gallery №2 — 8/8 утверждённых изображений и 8/8 Flutter CI

**Актуальный статус на 12.11.2026:** художественная приёмка **8/8**, восемь подготовленных RGBA-текстур загружены в GitHub и проверены, настоящие Flutter-скриншоты **8/8 успешно созданы** в отдельной пробной ветке. **Это ещё не production APK и не merge.**

## Проверяемые доказательства

- Владелец утвердила все позиции: https://github.com/jellyfishkaty-bit/lavka/issues/5#issuecomment-6810620536
- Исходный код пробной ветки: https://github.com/jellyfishkaty-bit/lavka/pull/8
- **Защищённый CI, SUCCESS, Flutter 3.47.9:** https://github.com/jellyfishkaty-bit/lavka/actions/runs/43158618687
- **Восемь оригинальных Flutter PNG:** https://github.com/jellyfishkaty-bit/lavka/actions/runs/43158618687/artifacts/13916399541
- Запуск: `flutter pub get --enforce-lockfile`, `flutter analyze` — no issues, `flutter test test/gallery2_preview_test.dart` — **8 passed**.
- Сцена: 393×493 логических px, экспорт `toImage(pixelRatio: 3)` создаёт 1179×1479 PNG на каждый вид изделия.
- Каталог восьми реально загруженных PNG: `art_experiments/2b/first_batch/original/trial_source/assets/images/gallery2/`.
- Контроль: у каждого PNG Git blob SHA-1 совпал с локальным утверждённым бинарным файлом, SHA-256 и PNG RGBA/dimensions совпали с `gallery2_manifest.json`; GitHub Actions офлайн-проверка: **8/8 accepted**.

## Художественные позиции

- Свитер, носки, плед: +20 px относительно исходной композиции первой тройки.
- Мишка: без изменения.
- Шаль: +20 px; шарф, недовязанное полотно и ранний палантин: +25 px относительно исходной композиции пятёрки.

Изолированные позиции и размеры в `lib/gallery2_preview.dart`, контрольные суммы в `gallery2_manifest.json`. Исходные макеты `Lavka_gallery2_items_lowered_20px_mockup.png` и `Lavka_gallery2_three_more_down_5px_review.png` одобрены владельцем. Не путать ранний палантин Gallery №2 с отдельно утверждённым концептом B.

## Безопасность и ограничения

Предыдущая попытка запустить Flutter в облаке Work была остановлена после неожиданного обращения к `169.254.169.254`; причину обращения в той среде не установили и запуск там **не повторяли**.

В новом workflow `.github/workflows/gallery2-isolated-preview-ci.yml` первый обязательный шаг **до checkout** установил запрет выходящих соединений к IPv4 link-local 169.254.0.0/16, 100.100.100.200 и IPv6 metadata/link-local диапазонам, подтвердил правила iptables/ip6tables. Повторная проверка после установки Flutter также прошла. Неподтверждённая изоляция вызывает прекращение job до рендера. Используются `permissions: contents: read` и `persist-credentials: false`. Никаких обращений к metadata endpoint при проверке не выполняли.

## Следующий этап

Просмотреть восемь настоящих экранов, подтвердить, что посадка в реальной пробной комнате соответствует одобренным позициям, затем отдельно разработать интеграцию предметов в production в контролируемой ветке и собрать APK. **Не менять main, PR #4, исторические PNG, SQLite/keys/signing, не выполнять merge без отдельного решения владельца.**
