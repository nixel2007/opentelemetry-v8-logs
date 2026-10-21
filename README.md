# opentelemetry-v8-logs

[![Тестирование](https://github.com/nixel2007/opentelemetry-v8-logs/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/nixel2007/opentelemetry-v8-logs/actions/workflows/test.yml)
[![Telegram](https://img.shields.io/badge/Telegram-чат-blue?logo=telegram)](https://t.me/autumn_winow)

Экспорт технологического журнала (ТЖ) и журнала регистрации (ЖР) 1С:Предприятия в OpenTelemetry по OTLP:
логи в Loki, метрики в Prometheus/Mimir, трассы вызовов в Tempo - весь стек LGTM.

Приложение на OneScript и [Autumn](https://github.com/autumn-library/autumn), телеметрия отправляется
через [OpenTelemetry SDK для OneScript](https://github.com/nixel2007/opentelemetry).

## Возможности

- Технологический журнал в текстовом формате и в формате JSON (8.3.25+), размещение файлов
  по каталогам процессов и плоское, многострочные значения, формат 8.2.
- Журнал регистрации в формате lgf/lgp, включая разделение данных сеанса.
- Дочитывание файлов с сохраненной байтовой позиции: незавершенные события и записи
  дочитываются при следующем проходе, позиции хранятся в базе через
  [autumn-data](https://github.com/autumn-library/autumn-data) (SQLite, JSON и другие коннекторы entity).
- Доставка «хотя бы один раз»: позиции фиксируются только после успешной отправки телеметрии.
  Логи и спаны при повторе могут продублироваться; метрики - только после успешного сброса.
- Трассы вызовов: CALL со вложенными событиями (DBMSSQL, SDBL, TLOCK, EXCP...) в одну трассу,
  потоковая отправка спанов без накопления событий, каждая запись лога связана со своим спаном.

## Быстрый старт

```sh
opm install opentelemetry-v8-logs

# стек LGTM для проверки
docker compose -f demo/docker-compose.yml up -d

# настройки - в autumn-properties.json текущего каталога, пример в demo/
cp demo/autumn-properties.json .
opentelemetry-v8-logs
```

Grafana будет доступна на http://localhost:3000: логи в Explore → Loki
(`{service_name="1c-cluster"}` - технологический журнал, `{service_name="erp"}` - журнал регистрации,
`{service_name="opentelemetry-v8-logs"}` - логи самого коллектора), трассы в Explore → Tempo, метрики `v8_techlog_event_duration_*`
и `v8_eventlog_records_total` в Prometheus.

Подробнее - в [документации](docs/product/010-index.md): [настройка](docs/product/020-configuration.md),
[состав телеметрии](docs/product/030-telemetry.md).

## Разработка

```sh
opm install -l --dev
oneunit e
```

Тесты пишутся до кода. Классы разбора и чтения компилируются в режиме `#native`.

Код - желуди [autumn](https://github.com/autumn-library/autumn) в каталогах подсистем `src/<подсистема>/Классы`
(`Чтение`, `ТехнологическийЖурнал`, `ЖурналРегистрации`, `Экспорт`, `Конвейер`, `Коллектор`, `Запуск`),
которые подключаются по соглашению о структуре каталогов: класс подключает каталоги подсистем, от которых
зависит, точка входа `src/main.os` - `Запуск` (команды [autumn-cli](https://github.com/autumn-library/autumn-cli)). Классы без состояния источника (чтение файлов, парсеры, время) -
синглтоны, классы с параметрами источника журнала (читатели, экспортеры, сборщик трасс, позиции) -
компанейские желуди: параметры передаются блестяшками, а желуди достаются из `&Табакерка`. Тестовые наборы
oneunit - тоже желуди и получают классы так же.

## Лицензия

MIT License. Подробности в файле [LICENSE.md](LICENSE.md).
