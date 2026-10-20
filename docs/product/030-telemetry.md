---
title: Состав телеметрии
---

# Состав телеметрии

Время журналов 1С - местное время сервера, в OpenTelemetry оно передается в UTC
по часовому поясу из настройки `otel.onec-logs.timezone`.

## Технологический журнал

### Логи

Каждое событие - запись лога (область инструментирования `opentelemetry-onec-logs.techlog`).

| Поле | Значение |
|------|----------|
| Время | время окончания события |
| Тело | исходный текст события |
| Серьезность | `ERROR` для `EXCP`; `WARN` для `ATTN`, `TDEADLOCK`, `TTIMEOUT`; иначе `INFO` |
| `onec.techlog.event.name` | имя события (`CALL`, `DBMSSQL`...) |
| `onec.techlog.duration` | длительность, мкс |
| `onec.techlog.depth` | уровень вложенности |
| `onec.techlog.<свойство>` | свойства события как есть: `onec.techlog.Usr`, `onec.techlog.t:clientID`, `onec.techlog.Sql`...; повторяющиеся свойства - массивом |
| `onec.infobase.name` | имя базы из свойства `p:processName` |
| `process.executable.name`, `process.pid` | процесс и PID из имени каталога или файла |
| `log.file.path` | путь к файлу журнала |

### Метрики

| Метрика | Тип | Атрибуты |
|---------|-----|----------|
| `onec.techlog.event.duration`, с | гистограмма | `onec.techlog.event.name`, `process.executable.name`, `onec.infobase.name` |

### Трассы

Корень трассы - событие вызова (`CALL`, `SCALL`, настройка `otel.onec-logs.traces.root-events`).
Платформа пишет событие по окончании, поэтому вложенные события появляются в журнале раньше вызова:
они ждут его в буфере потока (процесс + `OSThread`). При появлении вызова в трассу попадают события
того же потока, интервал которых `[окончание - длительность, окончание]` лежит внутри интервала вызова.
Родитель события - ближайшее охватывающее событие с меньшим уровнем вложенности.

| Событие | Спан |
|---------|------|
| `CALL` | вид `SERVER` |
| `DBMSSQL`, `DBPOSTGRS`, `DBORACLE`, `DB2` | вид `CLIENT`, `db.system.name` |
| `EXCP` | не спан, а событие `exception` родительского спана (`exception.type`, `exception.message`) |
| остальные | вид `INTERNAL` |

Атрибуты спанов - те же, что у записей лога. Запись лога корневого события содержит
`trace_id` и `span_id` своей трассы: из Loki можно перейти в трассу в Tempo и обратно.
Записи вложенных событий отправляются в Loki до появления вызова и с трассой не связаны.

Трассы собираются в памяти: вложенные события вызова, который не закончился к остановке
приложения, в трассу не попадут (в логах они будут).

## Журнал регистрации

### Логи

Каждая запись - запись лога (область инструментирования `opentelemetry-onec-logs.eventlog`).
Пустые поля не передаются.

| Поле | Значение |
|------|----------|
| Время | время записи |
| Тело | комментарий; если он пуст - идентификатор события |
| Серьезность | `E` - `ERROR`, `W` - `WARN`, `I` - `INFO`, `N` (примечание) - `DEBUG` |
| `onec.eventlog.event` | идентификатор события (`_$Session$_.Start`, `_$Data$_.Post`...) |
| `onec.infobase.name` | имя базы из настройки `infobase` |
| `user.name`, `user.id` | имя и идентификатор пользователя |
| `onec.eventlog.computer`, `onec.eventlog.application` | компьютер и приложение |
| `onec.eventlog.connection`, `onec.eventlog.session` | соединение и сеанс |
| `onec.eventlog.transaction.status` | `committed`, `rolled_back`, `unfinished` |
| `onec.eventlog.transaction.id` | номер транзакции |
| `onec.eventlog.metadata`, `onec.eventlog.metadata.uuid` | объект метаданных |
| `onec.eventlog.data`, `onec.eventlog.data.presentation` | данные и их представление |
| `onec.eventlog.server`, `onec.eventlog.port`, `onec.eventlog.sync_port` | рабочий сервер и порты |
| `onec.eventlog.data_separation.<разделитель>` | значения разделителей сеанса |
| `log.file.path` | путь к файлу журнала |

### Метрики

| Метрика | Тип | Атрибуты |
|---------|-----|----------|
| `onec.eventlog.records` | счетчик | `onec.eventlog.event`, `onec.eventlog.severity`, `onec.infobase.name`, `onec.eventlog.application` |
