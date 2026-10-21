#native

// Представления системных событий журнала регистрации - как в просмотре журнала 1С.
//
// Соответствие снято с платформы 8.3.27 функцией ПолучитьЗначенияОтбораЖурналаРегистрации("Событие")
// на русском и английском языке интерфейса. Строится один раз для языка из настройки
// otel.v8-logs.language. Для событий без представления (события пользователя, события
// других версий платформы) возвращается сам идентификатор.

Перем Представления; // Соответствие: идентификатор события -> представление на выбранном языке
Перем ЯзыкПредставлений; // Строка - ru или en

#Область ПрограммныйИнтерфейс

// Представление события журнала регистрации.
//
// Параметры:
//   Событие - Строка - идентификатор события (_$Data$_.Post, otel.test...)
//
// Возвращаемое значение:
//   Строка - представление на языке из настроек; без представления - идентификатор события
//
Функция Представление(Знач Событие) Экспорт
	Значение = Представления[Событие];
	Возврат ?(Значение = Неопределено, Событие, Значение);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура Добавить(Событие, Русское, Английское)
	Если ЯзыкПредставлений = "ru" Тогда
		Представления.Вставить(Событие, Русское);
	ИначеЕсли ЯзыкПредставлений = "en" Тогда
		Представления.Вставить(Событие, Английское);
	Иначе
		// Для других языков представлений нет: возвращается идентификатор события
		Возврат;
	КонецЕсли;
КонецПроцедуры

// Таблица представлений: по вызову на событие. У событий-синонимов платформы
// одинаковые представления.
// BSLLS:DuplicateStringLiteral-off
Процедура ЗаполнитьПредставления() // BSLLS:MethodSize-off

	Добавить("_$Access$_.Access",
		"Доступ. Доступ",
		"Access. Access");
	Добавить("_$Access$_.AccessDenied",
		"Доступ. Отказ в доступе",
		"Access. Access denied");
	Добавить("_$DamagedEntry$_",
		"Повреждение журнала",
		"Journal damage");
	Добавить("_$Data$_.DataHistorySettingsUpdate",
		"Данные. Изменение настроек истории данных",
		"Data. Change data history settings");
	Добавить("_$Data$_.Delete",
		"Данные. Удаление",
		"Data. Delete");
	Добавить("_$Data$_.DeletePredefinedData",
		"Данные. Удаление предопределенных данных",
		"Data. Deleting the predefined data");
	Добавить("_$Data$_.DeleteVersions",
		"Данные. Удаление версий",
		"Data. Delete versions");
	Добавить("_$Data$_.LabelsOfMandatoryAccessControlUpdate",
		"Данные. Изменение меток мандатного разграничения доступа",
		"Data. Change mandatory access control labels");
	Добавить("_$Data$_.LabelsOfMandatoryAccessControlUpdateError",
		"Данные. Ошибка изменения меток мандатного разграничения доступа",
		"Data. An error occurred when changing mandatory access control labels");
	Добавить("_$Data$_.New",
		"Данные. Добавление",
		"Data. Add");
	Добавить("_$Data$_.NewPredefinedData",
		"Данные. Добавление предопределенных данных",
		"Data. Adding the predefined data");
	Добавить("_$Data$_.NewVersion",
		"Данные. Добавление версии",
		"Data. Add version.");
	Добавить("_$Data$_.Post",
		"Данные. Проведение",
		"Data. Posting");
	Добавить("_$Data$_.PredefinedDataInitialization",
		"Данные. Инициализация предопределенных данных",
		"Data. Predefined data initialization");
	Добавить("_$Data$_.PredefinedDataInitializationDataNotFound",
		"Данные. Инициализация предопределенных данных, данные не найдены",
		"Data. Predefined data initialization, data not found");
	Добавить("_$Data$_.SetPredefinedDataInitialization",
		"Данные. Установка инициализации предопределенных данных",
		"Data. Setting the predefined data initialization");
	Добавить("_$Data$_.SetStandardODataInterfaceContent",
		"Данные. Изменение состава стандартного интерфейса OData",
		"Data. Changing the content of the standard OData interface");
	Добавить("_$Data$_.SetVersionComment",
		"Данные. Установка комментария версии",
		"Data. Install the version comment");
	Добавить("_$Data$_.TotalsMaxPeriodUpdate",
		"Данные. Изменение максимального периода рассчитанных итогов",
		"Data. Modification of calculated totals maximum period.");
	Добавить("_$Data$_.TotalsMinPeriodUpdate",
		"Данные. Изменение минимального периода рассчитанных итогов",
		"Data. Modification of calculated totals minimum period.");
	Добавить("_$Data$_.TotalsPeriodUpdate",
		"Данные. Изменение максимального периода рассчитанных итогов",
		"Data. Modification of calculated totals maximum period.");
	Добавить("_$Data$_.Unpost",
		"Данные. Отмена проведения",
		"Data. Undo posting");
	Добавить("_$Data$_.Update",
		"Данные. Изменение",
		"Data. Change");
	Добавить("_$Data$_.UpdatePredefinedData",
		"Данные. Изменение предопределенных данных",
		"Data. Changing the predefined data");
	Добавить("_$Debug$_.DebugTargetAttach",
		"Отладка. Подключение предмета отладки",
		"Debug. Attach debug target");
	Добавить("_$Debug$_.DebugTargetDetach",
		"Отладка. Отключение предмета отладки",
		"Debug. Detach debug target");
	Добавить("_$Debug$_.ExpressionEvaluation",
		"Отладка. Вычисление выражения",
		"Debug. Expression calculation");
	Добавить("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate",
		"Информационная база. Изменение дополнительных настроек аутентификации",
		"Infobase. Changing additional authentication settings");
	Добавить("_$InfoBase$_.AdditionalAuthenticationSettingsUpdateError",
		"Информационная база. Ошибка изменения дополнительных настроек аутентификации",
		"Infobase. An error occurred while changing additional authentication settings");
	Добавить("_$InfoBase$_.AdministrationParametersChange",
		"Информационная база. Изменение административных параметров",
		"Infobase. Changing administrative parameters");
	Добавить("_$InfoBase$_.ConfigExtensionUpdate",
		"Информационная база. Изменение расширения конфигурации",
		"Infobase. Modifying the configuration extension");
	Добавить("_$InfoBase$_.ConfigExtensionUpdateError",
		"Информационная база. Ошибка изменения расширения конфигурации",
		"Infobase. Error changing configuration extension");
	Добавить("_$InfoBase$_.ConfigUpdate",
		"Информационная база. Изменение конфигурации",
		"Infobase. Modifying the configuration");
	Добавить("_$InfoBase$_.ConfigUpdateError",
		"Информационная база. Ошибка изменения конфигурации",
		"Infobase. Error changing configuration");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateCancel",
		"Информационная база. Отмена фонового обновления конфигурации базы данных",
		"Infobase. Cancel of background database configuration update");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateError",
		"Информационная база. Ошибка фонового обновления конфигурации базы данных",
		"Infobase. Background update error of database configuration");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateFinish",
		"Информационная база. Завершение фонового обновления конфигурации базы данных",
		"Infobase. Completion of background database configuration update");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateResume",
		"Информационная база. Продолжение фонового обновления конфигурации базы данных",
		"Infobase. Continue of background database configuration update");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateStart",
		"Информационная база. Запуск фонового обновления конфигурации базы данных",
		"Infobase. Run background database configuration update");
	Добавить("_$InfoBase$_.DBConfigBackgroundUpdateSuspend",
		"Информационная база. Приостановка фонового обновления конфигурации базы данных",
		"Infobase. Pause of background database configuration update");
	Добавить("_$InfoBase$_.DBConfigExtensionDelete",
		"Информационная база. Удаление расширения конфигурации базы данных",
		"Infobase. Deleting database configuration extension");
	Добавить("_$InfoBase$_.DBConfigExtensionDeleteError",
		"Информационная база. Ошибка удаления расширения конфигурации базы данных",
		"Infobase. Error deleting database configuration extension");
	Добавить("_$InfoBase$_.DBConfigExtensionInsert",
		"Информационная база. Добавление расширения конфигурации базы данных",
		"Infobase. Adding database configuration extension");
	Добавить("_$InfoBase$_.DBConfigExtensionInsertError",
		"Информационная база. Ошибка добавления расширения конфигурации базы данных",
		"Infobase. Error adding database configuration extension");
	Добавить("_$InfoBase$_.DBConfigExtensionUpdate",
		"Информационная база. Изменение расширения конфигурации базы данных",
		"Infobase. Modifying the database configuration extension");
	Добавить("_$InfoBase$_.DBConfigExtensionUpdateError",
		"Информационная база. Ошибка изменения расширения конфигурации базы данных",
		"Infobase. Cannot modify the database configuration extension");
	Добавить("_$InfoBase$_.DBConfigUpdate",
		"Информационная база. Изменение конфигурации базы данных",
		"Infobase. Modifying the database configuration");
	Добавить("_$InfoBase$_.DBConfigUpdateError",
		"Информационная база. Ошибка изменения конфигурации базы данных",
		"Infobase. Cannot modify the database configuration.");
	Добавить("_$InfoBase$_.DBConfigUpdateStart",
		"Информационная база. Запуск обновления конфигурации базы данных",
		"Infobase. Run database configuration update");
	Добавить("_$InfoBase$_.DumpError",
		"Информационная база. Ошибка выгрузки в файл",
		"Infobase. Cannot dump to file");
	Добавить("_$InfoBase$_.DumpFinish",
		"Информационная база. Окончание выгрузки в файл",
		"Infobase. End dumping to file");
	Добавить("_$InfoBase$_.DumpStart",
		"Информационная база. Начало выгрузки в файл",
		"Infobase. Start dumping to file");
	Добавить("_$InfoBase$_.EraseData",
		"Информационная база. Удаление данных информационной базы",
		"Infobase. Deleting the infobase data");
	Добавить("_$InfoBase$_.EraseDataError",
		"Информационная база. Ошибка удаление данных информационной базы",
		"Infobase. Error deleting infobase data");
	Добавить("_$InfoBase$_.EventLogReduce",
		"Информационная база. Сокращение журнала регистрации",
		"Infobase. Shrink event log");
	Добавить("_$InfoBase$_.EventLogReduceError",
		"Информационная база. Ошибка сокращения журнала регистрации",
		"Infobase. Cannot shrink the event log");
	Добавить("_$InfoBase$_.EventLogSettingsUpdate",
		"Информационная база. Изменение настроек журнала регистрации",
		"Infobase. Modifying the event log settings");
	Добавить("_$InfoBase$_.EventLogSettingsUpdateError",
		"Информационная база. Ошибка изменения настроек журнала регистрации",
		"Infobase. Cannot modify the event log settings");
	Добавить("_$InfoBase$_.ExclusiveModeChange",
		"Информационная база. Изменение режима монопольного доступа к текущей области",
		"Infobase. Changing exclusive access mode to current area");
	Добавить("_$InfoBase$_.ExclusiveModeChangeError",
		"Информационная база. Ошибка изменения режима монопольного доступа к текущей области",
		"Infobase. Error changing exclusive access mode to current area");
	Добавить("_$InfoBase$_.InfoBaseAdmParamsUpdate",
		"Информационная база. Изменение параметров информационной базы",
		"Infobase. Modifying the infobase parameters");
	Добавить("_$InfoBase$_.InfoBaseAdmParamsUpdateError",
		"Информационная база. Ошибка изменения параметров информационной базы",
		"Infobase. Cannot modify the infobase parameters");
	Добавить("_$InfoBase$_.IntegrationServiceActiveUpdate",
		"Информационная база. Изменение активности сервиса интеграции",
		"Infobase. Modifying integration service activity");
	Добавить("_$InfoBase$_.IntegrationServiceSettingsUpdate",
		"Информационная база. Изменение настроек сервиса интеграции",
		"Infobase. Modifying integration service settings");
	Добавить("_$InfoBase$_.LabelsOfMandatoryAccessControlUpdate",
		"Информационная база. Изменение меток мандатного разграничения доступа",
		"Infobase. Change mandatory access control labels");
	Добавить("_$InfoBase$_.LabelsOfMandatoryAccessControlUpdateError",
		"Информационная база. Ошибка изменения меток мандатного разграничения доступа",
		"Infobase. An error occurred when changing mandatory access control labels");
	Добавить("_$InfoBase$_.MasterNodeUpdate",
		"Информационная база. Изменение главного узла",
		"Infobase. Modifying the master node");
	Добавить("_$InfoBase$_.ParametersUpdate",
		"Информационная база. Изменение параметров информационной базы",
		"Infobase. Modifying the infobase parameters");
	Добавить("_$InfoBase$_.ParametersUpdateError",
		"Информационная база. Ошибка изменения параметров информационной базы",
		"Infobase. Cannot modify the infobase parameters");
	Добавить("_$InfoBase$_.PasswordCompromiseCheckListUpdate",
		"Информационная база. Изменение списка проверки раскрытия пароля",
		"Infobase. Changing list of password compromise check");
	Добавить("_$InfoBase$_.PasswordCompromiseCheckListUpdateError",
		"Информационная база. Ошибка изменения списка проверки раскрытия пароля",
		"Infobase. Error changing list of password compromise check");
	Добавить("_$InfoBase$_.PasswordCompromiseCheckServiceError",
		"Информационная база. Ошибка сервиса проверки раскрытия пароля",
		"Infobase. Error of service for password compromise check");
	Добавить("_$InfoBase$_.PredefinedDataUpdate",
		"Информационная база. Обновление предопределенных данных",
		"Infobase. Update predefined data");
	Добавить("_$InfoBase$_.RegionalSettingsChange",
		"Информационная база. Изменение региональных установок",
		"Infobase. Modifying the regional settings");
	Добавить("_$InfoBase$_.RegionalSettingsChangeError",
		"Информационная база. Ошибка изменения региональных установок",
		"Infobase. Error changing regional settings");
	Добавить("_$InfoBase$_.RegionalSettingsUpdate",
		"Информационная база. Изменение региональных установок",
		"Infobase. Modifying the regional settings");
	Добавить("_$InfoBase$_.RestoreError",
		"Информационная база. Ошибка загрузки из файла",
		"Infobase. Cannot restore from file");
	Добавить("_$InfoBase$_.RestoreFinish",
		"Информационная база. Окончание загрузки из файла",
		"Infobase. End restoring from file");
	Добавить("_$InfoBase$_.RestoreStart",
		"Информационная база. Начало загрузки из файла",
		"Infobase. Start restoring from file");
	Добавить("_$InfoBase$_.RoleUpdate",
		"Информационная база. Изменение роли",
		"Infobase. Changing role");
	Добавить("_$InfoBase$_.SecondAuthenticationFactorTemplateDelete",
		"Информационная база. Удаление шаблона второго фактора аутентификации",
		"Infobase. Deleting the template of the second authentication factor");
	Добавить("_$InfoBase$_.SecondAuthenticationFactorTemplateNew",
		"Информационная база. Добавление шаблона второго фактора аутентификации",
		"Infobase. Adding a template of the second authentication factor");
	Добавить("_$InfoBase$_.SecondAuthenticationFactorTemplateUpdate",
		"Информационная база. Изменение шаблона второго фактора аутентификации",
		"Infobase. Modifying the template of the second authentication factor");
	Добавить("_$InfoBase$_.SecondFactorAuthTemplateDelete",
		"Информационная база. Удаление шаблона второго фактора аутентификации",
		"Infobase. Deleting the template of the second authentication factor");
	Добавить("_$InfoBase$_.SecondFactorAuthTemplateNew",
		"Информационная база. Добавление шаблона второго фактора аутентификации",
		"Infobase. Adding a template of the second authentication factor");
	Добавить("_$InfoBase$_.SecondFactorAuthTemplateUpdate",
		"Информационная база. Изменение шаблона второго фактора аутентификации",
		"Infobase. Modifying the template of the second authentication factor");
	Добавить("_$InfoBase$_.SecurityProfileChange",
		"Информационная база. Изменение профиля безопасности",
		"Infobase. Changing security profile");
	Добавить("_$InfoBase$_.SessionLockChange",
		"Информационная база. Изменение блокировки начала сеансов",
		"Infobase. Changing session start lock");
	Добавить("_$InfoBase$_.SessionLockChangeError",
		"Информационная база. Ошибка изменения блокировки начала сеансов",
		"Infobase. Error changing session start lock");
	Добавить("_$InfoBase$_.SetPredefinedDataUpdate",
		"Информационная база. Установка обновления предопределенных данных",
		"Infobase. Setting the predefined data update");
	Добавить("_$InfoBase$_.TARImportant",
		"Тестирование и исправление. Ошибка",
		"Verify and repair. Error");
	Добавить("_$InfoBase$_.TARInfo",
		"Тестирование и исправление. Сообщение",
		"Verify and repair. Message");
	Добавить("_$InfoBase$_.TARMess",
		"Тестирование и исправление. Предупреждение",
		"Verify and repair. Warning");
	Добавить("_$InfoBase$_.UserPasswordPolicyDelete",
		"Информационная база. Удаление политики паролей пользователей",
		"Infobase. Delete user password policy");
	Добавить("_$InfoBase$_.UserPasswordPolicyDeleteError",
		"Информационная база. Ошибка удаления политики паролей пользователей",
		"Infobase. Error deleting user password policy");
	Добавить("_$InfoBase$_.UserPasswordPolicyNew",
		"Информационная база. Добавление политики паролей пользователей",
		"Infobase. Add user password policy");
	Добавить("_$InfoBase$_.UserPasswordPolicyNewError",
		"Информационная база. Ошибка добавления политики паролей пользователей",
		"Infobase. Error adding user password policy");
	Добавить("_$InfoBase$_.UserPasswordPolicyUpdate",
		"Информационная база. Изменение политики паролей пользователей",
		"Infobase. Change user password policy");
	Добавить("_$InfoBase$_.UserPasswordPolicyUpdateError",
		"Информационная база. Ошибка изменения политики паролей пользователей",
		"Infobase. Error changing user password policy");
	Добавить("_$InfoBase$_.VerifyAndRepairImportant",
		"Тестирование и исправление. Ошибка",
		"Verify and repair. Error");
	Добавить("_$InfoBase$_.VerifyAndRepairInfo",
		"Тестирование и исправление. Сообщение",
		"Verify and repair. Message");
	Добавить("_$InfoBase$_.VerifyAndRepairMessage",
		"Тестирование и исправление. Предупреждение",
		"Verify and repair. Warning");
	Добавить("_$Job$_.Cancel",
		"Фоновое задание. Отмена",
		"Background job. Cancel");
	Добавить("_$Job$_.Error",
		"Фоновое задание. Ошибка выполнения",
		"Background job. Execution error");
	Добавить("_$Job$_.Fail",
		"Фоновое задание. Ошибка выполнения",
		"Background job. Execution error");
	Добавить("_$Job$_.Finish",
		"Фоновое задание. Успешное завершение",
		"Background job. Successful completion");
	Добавить("_$Job$_.Start",
		"Фоновое задание. Запуск",
		"Background job. Start");
	Добавить("_$Job$_.Succeed",
		"Фоновое задание. Успешное завершение",
		"Background job. Successful completion");
	Добавить("_$Job$_.Terminate",
		"Фоновое задание. Принудительное завершение",
		"Background job. Force termination");
	Добавить("_$OpenIDProvider$_.NegativeAssertion",
		"Провайдер OpenID. Отклонено",
		"OpenID provider. Rejected");
	Добавить("_$OpenIDProvider$_.PositiveAssertion",
		"Провайдер OpenID. Подтверждено",
		"OpenID provider. Confirmed");
	Добавить("_$PerformError$_",
		"Ошибка выполнения",
		"Execution error");
	Добавить("_$PredefinedData$_.Initialization",
		"Данные. Инициализация предопределенных данных, данные не найдены",
		"Data. Predefined data initialization, data not found");
	Добавить("_$Session$_.AddInAttach",
		"Сеанс. Подключение внешней компоненты",
		"Session. Attaching add-in");
	Добавить("_$Session$_.AddInAttachError",
		"Сеанс. Ошибка подключения внешней компоненты",
		"Session. Error attaching add-in");
	Добавить("_$Session$_.Authentication",
		"Сеанс. Аутентификация",
		"Session. Authentication");
	Добавить("_$Session$_.AuthenticationError",
		"Сеанс. Ошибка аутентификации",
		"Session. Authentication error");
	Добавить("_$Session$_.AuthenticationFirstFactor",
		"Сеанс. Аутентификация первый фактор",
		"Session. First authentication factor");
	Добавить("_$Session$_.ConfigExtensionApplyError",
		"Сеанс. Ошибка применения расширения конфигурации",
		"Session. Cannot apply configuration extension");
	Добавить("_$Session$_.DataZoneChange",
		"Сеанс. Изменение текущей области",
		"Session. Changing current area");
	Добавить("_$Session$_.DataZoneChangeError",
		"Сеанс. Ошибка изменения текущей области",
		"Session. Error changing current area");
	Добавить("_$Session$_.ExternalDataProcessorConnect",
		"Сеанс. Подключение внешней обработки",
		"Session. Connecting external data processor");
	Добавить("_$Session$_.ExternalDataProcessorConnectError",
		"Сеанс. Ошибка подключения внешней обработки",
		"Session. Error connecting external data processor");
	Добавить("_$Session$_.ExternalReportConnect",
		"Сеанс. Подключение внешнего отчета",
		"Session. Connecting external report");
	Добавить("_$Session$_.ExternalReportConnectError",
		"Сеанс. Ошибка подключения внешнего отчета",
		"Session. Error connecting external report");
	Добавить("_$Session$_.Finish",
		"Сеанс. Завершение",
		"Session. Completion");
	Добавить("_$Session$_.PasswordChangeError",
		"Сеанс. Ошибка смены пароля",
		"Session. Error changing password");
	Добавить("_$Session$_.PasswordCompromiseCheckServiceErrorOnAuthentication",
		"Сеанс. Ошибка сервиса проверки раскрытия пароля при аутентификации",
		"Session. Error of service for password compromise check upon authentication");
	Добавить("_$Session$_.PasswordRecoveryAttempt",
		"Сеанс. Попытка восстановления пароля",
		"Session. Attempting to recover the password");
	Добавить("_$Session$_.PasswordRecoveryAttemptError",
		"Сеанс. Ошибка попытки восстановления пароля",
		"Session. An error occurred while attempting to recover the password");
	Добавить("_$Session$_.PasswordRequirementsViolationOnAuthentication",
		"Сеанс. Несоответствие пароля требованиям при аутентификации",
		"Session. Password violates authentication requirements");
	Добавить("_$Session$_.Start",
		"Сеанс. Начало",
		"Session. Beginning");
	Добавить("_$Transaction$_.Begin",
		"Транзакция. Начало",
		"Transaction. Beginning");
	Добавить("_$Transaction$_.Commit",
		"Транзакция. Фиксация",
		"Transaction. Commit");
	Добавить("_$Transaction$_.Rollback",
		"Транзакция. Отмена",
		"Transaction. Cancel");
	Добавить("_$User$_.AuthenticationLock",
		"Пользователи. Блокировка аутентификации",
		"Users. Authentication lock");
	Добавить("_$User$_.AuthenticationLockError",
		"Пользователи. Ошибка блокировки аутентификации",
		"Users. Authentication lock error");
	Добавить("_$User$_.AuthenticationUnlock",
		"Пользователи. Разблокировка аутентификации",
		"Users. Authentication unlock");
	Добавить("_$User$_.AuthenticationUnlockError",
		"Пользователи. Ошибка разблокировки аутентификации",
		"Users. Authentication unlock error");
	Добавить("_$User$_.Delete",
		"Пользователи. Удаление",
		"Users. Delete");
	Добавить("_$User$_.DeleteError",
		"Пользователи. Ошибка удаления",
		"Users. Deleting error");
	Добавить("_$User$_.New",
		"Пользователи. Добавление",
		"Users. Add");
	Добавить("_$User$_.NewError",
		"Пользователи. Ошибка добавления",
		"Users. Adding error");
	Добавить("_$User$_.PermissionChange",
		"Пользователи. Изменение прав доступа",
		"Users. Changing access rights");
	Добавить("_$User$_.Update",
		"Пользователи. Изменение",
		"Users. Change");
	Добавить("_$User$_.UpdateError",
		"Пользователи. Ошибка изменения",
		"Users. Modifying error");

КонецПроцедуры
// BSLLS:DuplicateStringLiteral-on

#КонецОбласти

// Параметры:
//   Язык - Строка - язык представлений, настройка otel.v8-logs.language: ru или en
//
&Желудь
Процедура ПриСозданииОбъекта(&Деталька(Значение = "otel.v8-logs.language", ЗначениеПоУмолчанию = "ru") Язык)
	ЯзыкПредставлений = НРег(СокрЛП(Язык));
	Представления = Новый Соответствие;
	ЗаполнитьПредставления();
КонецПроцедуры
