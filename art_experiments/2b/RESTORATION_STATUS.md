# Партия 2Б: оригиналы и состояние переноса

Все восемь изображений — исторические пробы, не утверждены. Исходник: `Lavka_2B_trial_all.zip`. Манифест всех трёх архивов с SHA-256: [ARCHIVE_MANIFEST.json](ARCHIVE_MANIFEST.json). Сверка манифеста сделана с веткой `art/pixel-workshop-v2` на 5533339, до переноса исходников текущим PR.

| Путь в архиве | Размер, байт | SHA-256 | В GitHub |
|---|---:|---|---|
| `assets/project_scarf_2b.png` | 838371 | `a66b56afc9b0957a7bd07fb4eb9b239b6928449072ece84829e842df676a4724` | отсутствует |
| `assets/project_blanket_2b.png` | 1063388 | `f6b24ac6aa0e4b78da5d97dc3c0243451bfc95eb5b00b91991686090b5f494b8` | отсутствует |
| `assets/project_shawl_2b.png` | 1255772 | `2dedb074f1bc49dd886a13e62e140b3746ff51ea399557769fbd8a47bd7be49e` | отсутствует |
| `assets/project_socks_2b.png` | 1498339 | `e3b0ec27c46b82996c49387eb655051952319b6fc202390b1c501d0598dfdd6c` | отсутствует |
| `assets/project_fabric_2b.png` | 1084284 | `509db08d5de8eac038e7ae9492c9c37dbc577684651d36fd8cd8465b6f48579c` | отсутствует |
| `assets/project_sweater_2b.png` | 1138761 | `a3c7c4f3f326302e9346f1305bdb97c6f2d3e98db43f609f7528c02046d7c2c8` | отсутствует |
| `assets/project_toy_2b.png` | 1160746 | `1ebc663c80864f68ad885b65eb36398e92533935e3a3063829595d12b0dcf1f9` | отсутствует |
| `assets/project_stole_2b.png` | 1267236 | `afe6ddc157179a4ed27b39a406a49bd37528fe86db19e897fe7aeaec1be3c129` | отсутствует |

Девять исходных текстовых файлов сцены перенесены в `first_batch/original/trial_source/` с сохранением структуры. Полноценный запуск невозможен: PNG сцены и проекта ещё не перенесены; Flutter в среде отсутствует. PNG и мобильные превью должны быть загружены из исходного архива без изменений и проверены SHA-256 после загрузки.

Прямой `git push --dry-run` не прошёл: `fatal: could not read Username for https://github.com: terminal prompts disabled` (кавычки опущены). Пакетный Base64 не использован. Исторические 104 скриншота v0.2.2 остаются отдельной, менее приоритетной задачей.
