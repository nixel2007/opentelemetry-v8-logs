---
title: Настройка
---

# Настройка

Настройки читаются из `autumn-properties.json` в текущем каталоге (или в каталоге профиля пользователя).
Секция `otel` - настройки [OpenTelemetry SDK](https://github.com/nixel2007/opentelemetry) и самого
приложения (`otel.onec-logs`), секция `data` - база для позиций чтения, секция `logos` - логи коллектора.

Телеметрия коллектора и данные журналов отправляются под разными `service.name`:

- собственные логи и метрики коллектора - под `otel.service.name`, с атрибутами хоста и процесса коллектора;
- данные журналов - под `otel.onec-logs.service.name` (или `service-name` источника), с атрибутами
  из `otel.onec-logs.resource.attributes` и без атрибутов процесса коллектора.

```json
{
  "otel": {
    "enabled": true,
    "service": { "name": "opentelemetry-onec-logs" },
    "entity": { "enabled": false },
    "exporter": { "otlp": { "endpoint": "http://localhost:4318", "protocol": "http/json" } },
    "traces": { "exporter": "otlp" },
    "metrics": { "exporter": "otlp" },
    "logs": { "exporter": "otlp" },
    "onec-logs": {
      "service": { "name": "1c-cluster" },
      "resource": { "attributes": "deployment.environment.name=prod" },
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
      "СтрокаСоединения": "Data Source=opentelemetry-onec-logs.db"
    }
  }
}
```

`otel.enabled` нужен только для отправки собственных логов коллектора через `ОтелАппендерLogos`
(autumn-opentelemetry). Вместе с ним по умолчанию включается инструментирование autumn-data, и каждый
запрос к базе позиций стал бы спаном - поэтому в примере `otel.entity.enabled` выключен.

## otel.onec-logs

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `service.name` | `1c` | `service.name` данных журналов. Должен отличаться от `otel.service.name` коллектора. |
| `resource.attributes` | - | Атрибуты ресурса данных журналов в формате `OTEL_RESOURCE_ATTRIBUTES`: `ключ=значение` через запятую. `otel.resource.attributes` к данным не применяется. |
| `techlog` | - | Массив каталогов технологического журнала (`location` в `logcfg.xml`). Элемент: `path`, необязательные `service-name`, `infobase` (база для событий с пустым `p:processName`, например у файловой базы), `timezone`, `start-from-end`. |
| `eventlog` | - | Массив каталогов журнала регистрации (`1Cv8Log`). Элемент: `path`, `infobase` (имя базы; по умолчанию имя родительского каталога, то есть GUID базы), необязательные `service-name`, `timezone`, `start-from-end`. |
| `timezone` | часовой пояс машины | Часовой пояс серверов 1С. Журналы пишутся в местном времени сервера, в OpenTelemetry время передается в UTC. Принимаются имена IANA (`Europe/Moscow`), Windows и `GMT+03:00`. |
| `start-from-end` | `false` | При первом запуске пропустить уже накопленные данные. Файлы, появившиеся позже, читаются с начала. |
| `interval` | `5` | Пауза между проходами без новых данных, секунд. Пока журналы отстают, проходы идут без пауз. |
| `batch-size` | `1000` | Сколько записей передавать в SDK между сбросами буферов. Не больше размера очереди пакетного процессора (`otel.blrp.max.queue.size`, по умолчанию 2048). |
| `traces.enabled` | `true` | Собирать трассы вызовов из технологического журнала. |
| `traces.root-events` | `CALL` | События - корни трасс. Корневое событие закрывает трассу потока, поэтому событие, которое в вашем журнале бывает вложено в `CALL` того же потока, корнем делать нельзя: оно разорвет трассу вызова. |

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
`DBPOSTGRS`, `SDBL`, `TLOCK`, `EXCP`...) со свойствами `OSThread` и `t:clientID`.
Пример - `demo/logcfg.xml`.
