# Выгрузка Data журнала регистрации

Эталон `ключ=значение` через `ВыгрузитьЖурналРегистрации` для сверки с `*.lgp`
(карта bit/позиция → имя). Сборка и запуск — **vanessa-runner**.

## Состав

| Путь | Назначение |
|------|------------|
| `src/ВыгрузкаДанныхЖурналаРегистрации/` | XML-исходники внешней обработки |
| `build/ВыгрузкаДанныхЖурналаРегистрации.epf` | собранная обработка (после `epf compile`) |

## Сборка

```sh
# пустая ИБ один раз
vrunner infobase init --ibconnection "/F./tools/eventlog-data-dump/.ib" --v8version 8.3.27

vrunner epf compile \
  --ibconnection "/F./tools/eventlog-data-dump/.ib" \
  --v8version 8.3.27 \
  --out ./tools/eventlog-data-dump/build \
  ./tools/eventlog-data-dump/src/ВыгрузкаДанныхЖурналаРегистрации
```

## Запуск

```sh
vrunner run enterprise \
  --ibconnection "/F<path-to-ib>" \
  --v8version 8.3.27 \
  --execute ./tools/eventlog-data-dump/build/ВыгрузкаДанныхЖурналаРегистрации.epf \
  --command "DumpPath=C:/path/eventlog-data-dump.jsonl;ЗавершитьРаботуСистемы"
```

Для otel-test укажите `--ibconnection` на эту базу (нужны права на Data админских событий).

Опционально `SeedTestEvents` — пишет пару пользовательских событий (у них Data в выгрузке
может быть пустым; системные вроде `_$Session$_.Authentication` заполняются).

## Формат JSONL

`n`, `date`, `event`, `level`, `session`, `connection`, `user`, `comment`,
`data` (дерево), `data_flat` (`Путь=значение`), `data_presentation`.

Ключи в `data` — **как вернула платформа** (на RU-интерфейсе часто русские имена свойств).
