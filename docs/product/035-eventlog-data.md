---
title: Содержимое Data журнала регистрации
---

# Содержимое Data журнала регистрации

Сложное содержимое поля `Data` дополнительно передается JSON-строкой в атрибуте
`v8.eventlog.data.json`. Прежние `v8.eventlog.data`, `v8.eventlog.data.presentation`,
текст тела лога, ресурсы и метрики сохраняются. Включать настройку не требуется.
У обычных скаляров дополнительного атрибута нет.

Правила разбора разработаны в [форке OneSTools.EventLog](https://github.com/APonkratov/OneSTools.EventLog/tree/015d838)
и проверен на искусственных примерах, сопоставленных с выгрузкой платформы 8.3.27.2325.
Имена из синтакс-помощника используются после подтверждения реального расположения полей:
порядок перечисления в справке не совпадает с порядком значений LGP.
Наличие события в таблице ниже не означает распознавание всех его вариантов.
Проверяются код события, маска, количество и типы элементов.

Раскладки хранятся в общем классе `ПоляДанныхСобытийЖурналаРегистрации`:
метод `Раскладки(Событие)` возвращает подтвержденные имена JSON, типы, точную маску
и смещение значений. Декодер проверяет структуру и преобразует значения.
Справочные `ИменаПолей`, `Биты`, `Способ` сохранены; черновики из синтакс-помощника
не разрешают позиционный разбор. Для совместимости JSON использует
`AuthenticationMethod` и `Vendor` у `ConfigUpdate`, как в проверенной выгрузке 8.3.27.

## Подтвержденные формы

| События (суффиксы после системной группы) | Содержимое |
|---|---|
| `User.AuthenticationLock`, `AuthenticationUnlock`, `AuthenticationUnlockError`; `Session.PasswordRequirementsViolationOnAuthentication` | `Name`, включая пустую строку |
| `Session.Authentication`, `AuthenticationError` | формы 513, 514, 518: `OSUser` / `Name`, `CurrentOSUser`, `AuthenticationMethod` |
| `User.New`, `Update`, `NewError`, `UpdateError` | формы 65535 и 65534: свойства пользователя, ссылки на язык/интерфейс, `RolesCount`, настройки второго фактора и политики паролей |
| `User.Delete`, `DeleteError`; `Session.ConfigExtensionApplyError` | `Name` |
| `InfoBase.UserPasswordPolicyNew`, `UserPasswordPolicyNewError`, `UserPasswordPolicyUpdate` | форма 255: девять свойств политики, включая проверку компрометации и действие при нарушении требований |
| `InfoBase.UserPasswordPolicyDelete`, `UserPasswordPolicyDeleteError` | `Name` |
| `InfoBase.ParametersUpdate`, `ParametersUpdateError` | подтвержденные маски параметров базы: пароли, блокировка аутентификации, ожидание блокировки и завершение неактивных сеансов |
| `InfoBase.AdditionalAuthenticationSettingsUpdate` | 45 отдельных масок параметров и форма 2564; методы восстановления и отправки кодов, SMTP, интервалы и проверки компрометации |
| `InfoBase.ConfigUpdate`, `DBConfigUpdate`, `ConfigUpdateError`, `DBConfigUpdateError` | `Vendor`, `Version` |
| `InfoBase.ExclusiveModeChange`, `ExclusiveModeChangeError` | `ExclusiveMode` |
| `Access.Access`, `AccessDenied` | таблица `Data`, либо `Right`, либо `Action` и незаданные `Data` |
| `InfoBase.SecondAuthenticationFactorTemplateNew`, `SecondAuthenticationFactorTemplateUpdate`, `SecondAuthenticationFactorTemplateDelete` | `Name` |
| `InfoBase.EventLogSettingsUpdate`, `EventLogSettingsUpdateError` | `Levels` либо `EventName`, `EventIsLogged` |
| `InfoBase.EventLogReduce`, `EventLogReduceError` | `Date` |
| `InfoBase.RegionalSettingsChange` | 11 свойств региональных установок |
| `Session.ExternalDataProcessorConnect`, `ExternalDataProcessorConnectError`, `ExternalReportConnect`, `ExternalReportConnectError` | путь, имя, безопасный режим, профиль безопасности, защита от опасных действий и язык |
| `Session.AddInAttach`, `AddInAttachError` | `Name`, `Location`, незаданные `Type`, `AttachmentType` |
| `InfoBase.SessionLockChange`, `SessionLockChangeError` | `Use`, `Begin`, `End`, `Message`, `KeyCode`, `Parameter` |
| `InfoBase.ConfigExtensionUpdate`, `DBConfigExtensionInsert`, `DBConfigExtensionInsertError`, `DBConfigExtensionDelete`, `DBConfigExtensionDeleteError`, `DBConfigExtensionUpdate`, `DBConfigExtensionUpdateError` | 15 свойств расширения: имя, версия, поставщик, UUID, хэш, синоним, режимы, профиль, назначение, область и роли |
| `Data.DataHistorySettingsUpdate`, `PredefinedDataInitialization`, `UpdatePredefinedData`; `InfoBase.PredefinedDataUpdate` | таблица `Data` в подтвержденной именованной форме |

Всего специальные правила охватывают 56 кодов событий. Для остальных возможен общий разбор
именованных пар; неподтвержденные формы сохраняются целиком.

## Представление значений

Числа и булевы значения в JSON представлены строками (`"0"`, `"false"`), как в исходном
декодере. Это сохраняет точность длинных чисел и единый контракт. Даты — локальные значения 1С
`yyyy-MM-ddTHH:mm:ss`, без добавления часового пояса. Пустая дата сохраняется как
`0001-01-01T00:00:00`. Пустые строки не удаляются. `null` означает незаданное поле подтвержденной
формы; в общем разборе `U` сохраняется явно как `{"$type":"U"}`.

Например, блокировка аутентификации: `{"Name":"FixtureUser"}`.

Для подтвержденных форм `User.New`, `Update`, `NewError`, `UpdateError` свойства
пользователя находятся прямо в корне JSON, без `$format`, `values` и `nodes`.
Состав ролей пользователя намеренно не экспортируется; вместо списка UUID
сохраняется `RolesCount`. Точный состав ролей из телеметрии восстановить нельзя.
`DefaultRoles` расширения остается отдельным полем.

Для остальных позиционных форм используется конверт `1c-positional-data-v1`:
`layout`, `values`, `unnamedFields`, `nodes`. Для общих именованных пар —
`1c-named-data-v1`: `values`, `nodes`. Ссылки сохраняют идентификаторы, без попытки
прочитать объект из информационной базы. Для неизвестных форм расположение
ролей не угадывается: сохраняется исходное дерево.
Если маска, число или типы полей неизвестны, возвращается
`{"$format":"1c-brackets-v1","nodes":[...]}`. `nodes` сохраняет дерево и исходный текст
листьев, включая удвоенные кавычки. Переход на новую платформу не приводит к угадыванию полей.

## Поиск в Loki

Loki нормализует имя атрибута в `v8_eventlog_data_json`. Например:

```logql
{service_name="erp"} | v8_eventlog_data_json != ""
  | line_format "{{.v8_eventlog_data_json}}" | json
```

Подставьте `service.name` своего источника и период журнала. Поля `Data` следует оставлять
атрибутами логов, не добавляя их в индексные метки Loki или в разрезы метрик.
