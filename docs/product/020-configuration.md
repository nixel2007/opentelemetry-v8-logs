---
title: Настройка
---

# Настройка

Настройки читаются из `autumn-properties.json` в текущем каталоге (или в каталоге профиля пользователя).
Секция `otel` - настройки [OpenTelemetry SDK](https://github.com/nixel2007/opentelemetry) и самого
приложения (`otel.v8-logs`), секция `data` - база для позиций чтения, секция `logos` - логи коллектора.

Телеметрия коллектора и данные журналов отправляются под разными `service.name`:

- собственные логи и метрики коллектора - под `otel.service.name`, с атрибутами хоста и процесса коллектора;
- данные журналов - под `otel.v8-logs.service.name` (или `service-name` источника), с атрибутами
  из `otel.v8-logs.resource.attributes` и атрибутами SDK `telemetry.sdk.*`, без атрибутов хоста и
  процесса коллектора.

```json
{
  "otel": {
    "enabled": true,
    "service": { "name": "opentelemetry-v8-logs" },
    "entity": { "enabled": false },
    "exporter": { "otlp": { "endpoint": "http://localhost:4318", "protocol": "http/json" } },
    "traces": { "exporter": "otlp" },
    "metrics": { "exporter": "otlp" },
    "logs": { "exporter": "otlp" },
    "v8-logs": {
      "service": { "name": "1c-cluster" },
      "resource": { "attributes": "deployment.environment.name=production" },
      "timezone": "Europe/Moscow",
      "techlog": [
        { "path": "/var/log/1c/techlog" }
      ],
      "eventlog": [
        { "path": "/home/usr1cv8/.1cv8/1C/1cv8/reg_1541/<GUID базы>/1Cv8Log", "infobase": "erp", "service-name": "erp" }
      ]
    }
  },
  "logos": {
    "logger": { "rootLogger": { "level": "INFO", "appenders": ["otel", "console"] } },
    "appender": {
      "otel": { "type": "ОтелАппендерLogos", "level": "INFO" },
      "console": { "type": "ВыводЛогаВКонсоль", "level": "INFO" }
    }
  },
  "data": {
    "ИсточникиДанных": {
      "ТипКоннектора": "КоннекторSQLite",
      "СтрокаСоединения": "Data Source=opentelemetry-v8-logs.db"
    }
  }
}
```

Если каталога из `path` нет, коллектор ничего из него не читает и не сообщает об этом.

`otel.enabled` нужен только для отправки собственных логов коллектора через `ОтелАппендерLogos`
(autumn-opentelemetry). Вместе с ним по умолчанию включается инструментирование autumn-data, и каждый
запрос к базе позиций стал бы спаном - поэтому в примере `otel.entity.enabled` выключен.

## otel.v8-logs

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `service.name` | `1c` | `service.name` данных журналов. Должен отличаться от `otel.service.name` коллектора. |
| `resource.attributes` | - | Атрибуты ресурса данных журналов в формате `OTEL_RESOURCE_ATTRIBUTES`: `ключ=значение` через запятую. `otel.resource.attributes` к данным не применяется. |
| `techlog` | - | Массив каталогов технологического журнала (`location` в `logcfg.xml`). Элемент: `path`, необязательные `service-name`, `infobase` (база для событий с пустым `p:processName`, например у файловой базы), `timezone`, `start-from-end`, `traces-mode`. |
| `eventlog` | - | Массив каталогов журнала регистрации (`1Cv8Log`). Элемент: `path`, `infobase` (имя базы; по умолчанию имя родительского каталога, то есть GUID базы), необязательные `service-name`, `timezone`, `start-from-end`. |
| `timezone` | часовой пояс машины | Часовой пояс серверов 1С. Журналы пишутся в местном времени сервера, в OpenTelemetry время передается в UTC. Принимаются имена IANA (`Europe/Moscow`), Windows и `GMT+03:00`. |
| `start-from-end` | `false` | При первом запуске пропустить уже накопленные данные. Файлы, появившиеся позже, читаются с начала. |
| `language` | `ru` | Язык представлений событий журнала регистрации в теле записи и атрибуте `v8.eventlog.event.presentation`: `ru` или `en`. При другом значении используется идентификатор события. |
| `interval` | `5` | Пауза между проходами без новых данных, секунд. Пока журналы отстают, проходы идут без пауз. |
| `batch-size` | `1000` | Сколько записей передавать в SDK между сбросами буферов. Не больше размера очереди пакетного процессора (`otel.blrp.max.queue.size`, по умолчанию 2048). |
| `traces.enabled` | `true` | Собирать трассы вызовов из технологического журнала. |
| `traces.root-events` | `CALL` | События - корни трасс. Корневое событие закрывает трассу потока, поэтому событие, которое в вашем журнале бывает вложено в `CALL` того же потока, корнем делать нельзя: оно разорвет трассу вызова. |
| `traces.mode` | `auto` | Режим сборки трасс: `streaming` - спаны отправляются сразу, `buffered` - события копятся до верхнеуровневого (для файловой базы), `auto` - накопление для процессов `1cv8` и `1cv8c`, потоковый для остальных. См. [состав телеметрии](./telemetry.md). |

## OpenTelemetry SDK

Все параметры SDK - в его [документации](https://github.com/nixel2007/opentelemetry). Основные:

| Параметр | Описание |
|----------|----------|
| `otel.service.name` | Имя сервиса самого коллектора. |
| `otel.resource.attributes` | Дополнительные атрибуты ресурса коллектора. |
| `otel.metric.export.interval` | Интервал экспорта метрик, мс; действует и для метрик данных. Для метрик данных используются настройки транспорта OTLP коллектора, а временная агрегация всегда кумулятивная. |
| `otel.exporter.otlp.endpoint` | Адрес приемника OTLP. |
| `otel.exporter.otlp.protocol` | Протокол: рекомендуется `http/json`, см. раздел о производительности. |

Параметры можно задавать и переменными окружения (`OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT`...).

## Позиции чтения

Позиции хранятся в таблице `ПозицииЧтения` источника данных из секции `data`
([autumn-data](https://github.com/autumn-library/autumn-data)): подойдет файл SQLite или любой
другой коннектор entity. Ключ позиции - полный путь к файлу журнала. Позиции удаленных файлов
удаляются автоматически. Чтобы перечитать журналы заново, удалите базу позиций.

## Настройка технологического журнала

Для трасс в ТЖ нужны события вызовов (`CALL`) и вложенные события (`DBMSSQL`,
`DBPOSTGRS`, `SDBL`, `TLOCK`, `EXCP`...) со свойством `OSThread`, а для имен корневых вызовов -
`Context` (в файловой базе код пользователя пишется без `CALL`, трассы строятся накоплением,
см. [состав телеметрии](./telemetry.md)). Пример - `demo/logcfg.xml`.
