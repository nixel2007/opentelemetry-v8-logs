// EN-имена полей Data системных событий журнала регистрации.
//
// Порядок и способ кодирования — как в *.lgp (хранение), не как список в
// UnloadEventLog СП. Имена EN — ключи OTLP/метрик.
//
// {P,{Маска, Значение…}} — бит N → поле; значения по возрастанию установленных битов.
// {P,{Значение…}} или плотный ряд после маски (User.*) — ИменаПолей по позиции.
// События без проверенной раскладки: состав из СП как Последовательность (черновик).
// Одинаковый состав — ПоОбразцу.

Перем РаскладкиПоСобытию; // Соответствие: событие -> подтвержденные формы разбора
Перем Поля; // Соответствие: событие -> Массив EN (порядок хранения)
Перем БитыПоСобытию; // Соответствие: событие -> Соответствие(НомерБита -> Имя)
Перем СпособПоСобытию; // Соответствие: событие -> "Маска" | "Последовательность"

#Область ПрограммныйИнтерфейс

// Способ кодирования Data в файле журнала.
//
// Параметры:
//   Событие - Строка - идентификатор события (_$Session$_.Authentication…)
//
// Возвращаемое значение:
//   Строка, Неопределено - "Маска", "Последовательность"; без состава - Неопределено
//
Функция Способ(Знач Событие) Экспорт
	Возврат СпособПоСобытию[Событие];
КонецФункции

// EN-имена полей Data в порядке хранения значений (после маски или без неё).
// Для способа Маска — Неопределено (см. ИмяПоБиту / Биты).
//
// Параметры:
//   Событие - Строка - идентификатор события (_$User$_.Update…)
//
// Возвращаемое значение:
//   Массив из Строка, Неопределено - имена полей; без состава или Маска - Неопределено
//
Функция ИменаПолей(Знач Событие) Экспорт
	Возврат Поля[Событие];
КонецФункции

// Карта бит (0-based) → EN-имя для способа Маска.
//
// Параметры:
//   Событие - Строка - идентификатор события (_$Session$_.Authentication…)
//
// Возвращаемое значение:
//   Соответствие, Неопределено - ключ Число (номер бита), значение Строка; иначе Неопределено
//
Функция Биты(Знач Событие) Экспорт
	Возврат БитыПоСобытию[Событие];
КонецФункции

// Имя поля по номеру бита (0-based), если способ — Маска.
//
// Параметры:
//   Событие - Строка - идентификатор события
//   НомерБита - Число - номер бита в маске присутствия
//
// Возвращаемое значение:
//   Строка, Неопределено - EN-имя поля; нет раскладки или бита - Неопределено
//
Функция ИмяПоБиту(Знач Событие, Знач НомерБита) Экспорт
	Карта = БитыПоСобытию[Событие];
	Если Карта = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	Возврат Карта[НомерБита];
КонецФункции

// Подтвержденные раскладки Data для декодера. Черновики из СП сюда не попадают.
// Маска задается явно: наличие известных битов не разрешает новые сочетания.
// Имена сохраняют текущий JSON-контракт, в том числе AuthenticationMethod и Vendor.
//
// Параметры:
//   Событие - Строка - исходный код события
//
// Возвращаемое значение:
//   Массив из Структура, Неопределено - подтвержденные формы или Неопределено:
//     * Имена - Массив из Строка - имена полей JSON в порядке хранения
//     * Типы - Строка - ожидаемые типы по позициям
//     * Маска - Строка - точный литерал маски; пустая строка для формы без маски
//     * Смещение - Число - количество служебных элементов перед значениями
//     * Обработка - Строка - способ преобразования значений и представления JSON
//
Функция Раскладки(Знач Событие) Экспорт
	Возврат РаскладкиПоСобытию[Событие];
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура Добавить(Событие, Имена)
	СпособПоСобытию.Вставить(Событие, "Последовательность");
	Поля.Вставить(Событие, СтрРазделить(Имена, ",", Ложь));
КонецПроцедуры

Процедура Маска(Событие, ОписаниеБитов)
	СпособПоСобытию.Вставить(Событие, "Маска");
	Карта = Новый Соответствие;
	Для Каждого Пара Из СтрРазделить(ОписаниеБитов, ",", Ложь) Цикл
		Части = СтрРазделить(СокрЛП(Пара), "=", Ложь);
		Карта.Вставить(Число(Части[0]), Части[1]);
	КонецЦикла;
	БитыПоСобытию.Вставить(Событие, Карта);
КонецПроцедуры

Процедура ПоОбразцу(Событие, Образец)
	СпособПоСобытию.Вставить(Событие, СпособПоСобытию[Образец]);
	Если СпособПоСобытию[Образец] = "Маска" Тогда
		БитыПоСобытию.Вставить(Событие, БитыПоСобытию[Образец]);
	Иначе
		Поля.Вставить(Событие, Поля[Образец]);
	КонецЕсли;
КонецПроцедуры

// BSLLS:DuplicateStringLiteral-off
// Имена и проверки типа каждой подтвержденной формы хранятся вместе.
Процедура ДобавитьФорму(События, Имена, Типы, Маска = "", Смещение = 0, Обработка = "Поля")
	Если ТипЗнч(Имена) = Тип("Строка") Тогда
		Имена = СтрРазделить(Имена, ",");
	КонецЕсли;
	Если Имена.Количество() <> СтрДлина(Типы) Тогда
		ВызватьИсключение "Число типов не соответствует полям раскладки " + События;
	КонецЕсли;
	Описание = Новый Структура("Имена, Типы, Маска, Смещение, Обработка", Имена, Типы, Маска, Смещение, Обработка);
	Для Каждого Событие Из СтрРазделить(События, ",") Цикл
		Если РаскладкиПоСобытию[Событие] = Неопределено Тогда
			РаскладкиПоСобытию.Вставить(Событие, Новый Массив);
		КонецЕсли;
		РаскладкиПоСобытию[Событие].Добавить(Описание);
	КонецЦикла;
КонецПроцедуры

// Состав берем из общей карты битов; допускаются только перечисленные ниже маски.
Процедура ДобавитьФормуМаски(События, Типы, Маска)
	Для Каждого Событие Из СтрРазделить(События, ",") Цикл
		Имена = Новый Массив;
		Остаток = Число(Маска);
		Бит = 0;
		Пока Остаток > 0 Цикл
			Если Остаток % 2 = 1 Тогда
				Имя = ИмяПоБиту(Событие, Бит);
				Если Имя = Неопределено Тогда
					ВызватьИсключение "Неизвестный бит подтвержденной раскладки " + Событие;
				КонецЕсли;
				Если Имя = "AuthenticationMode" Тогда
					// Имя в сохраненной выгрузке 8.3.27 и текущем JSON.
					Имя = "AuthenticationMethod";
				КонецЕсли;
				Имена.Добавить(Имя);
			КонецЕсли;
			Остаток = Цел(Остаток / 2);
			Бит = Бит + 1;
		КонецЦикла;
		ДобавитьФорму(Событие, Имена, Типы, Маска, 1);
	КонецЦикла;
КонецПроцедуры

Процедура ЗаполнитьРаскладки() // BSLLS:MethodSize-off
	ДобавитьФормуМаски("_$Session$_.Authentication,_$Session$_.AuthenticationError", "SSN", "518");
	ДобавитьФормуМаски("_$Session$_.Authentication,_$Session$_.AuthenticationError", "SN", "514");
	ДобавитьФормуМаски("_$Session$_.Authentication,_$Session$_.AuthenticationError", "SN", "513");
	ДобавитьФорму("_$InfoBase$_.ConfigUpdate,_$InfoBase$_.DBConfigUpdate,_$InfoBase$_.ConfigUpdateError,_$InfoBase$_.DBConfigUpdateError", "Vendor,Version", "SS");
	ДобавитьФормуМаски("_$InfoBase$_.ExclusiveModeChange,_$InfoBase$_.ExclusiveModeChangeError", "B", "2");
	ДобавитьФорму("_$Access$_.AccessDenied", "Right", "S", "1", 1);
	ДобавитьФорму("_$Access$_.AccessDenied", "Action,Data", "SU", "6", 1);
	ДобавитьФорму("_$Session$_.ConfigExtensionApplyError,_$InfoBase$_.UserPasswordPolicyDelete,_$InfoBase$_.UserPasswordPolicyDeleteError,_$User$_.Delete,_$User$_.DeleteError", "Name", "S");
	ДобавитьФорму("_$InfoBase$_.EventLogSettingsUpdate,_$InfoBase$_.EventLogSettingsUpdateError", "EventName,EventIsLogged", "SB", "24", 1);
	ДобавитьФорму("_$InfoBase$_.EventLogReduce,_$InfoBase$_.EventLogReduceError", "Date", "D");
	ДобавитьФорму("_$InfoBase$_.RegionalSettingsChange", "LocaleCode,UseCurrentSessionSettings,NumbersDecimalSeparator,NumbersDigitGroupSeparator,NumbersDigitGroupFormat,NegativeNumberPresentation,BooleanFalsePresentation,BooleanTruePresentation,DatePresentationFormat,TimePresentationFormat,FirstDayOfWeek", "SBSSSNSSSSN");
	ДобавитьФорму("_$Session$_.ExternalDataProcessorConnect,_$Session$_.ExternalDataProcessorConnectError,_$Session$_.ExternalReportConnect,_$Session$_.ExternalReportConnectError", "Path,Name,SafeMode,SecurityProfile,UnsafeOperationProtection,LanguageCode", "SSBSBS");
	ДобавитьФорму("_$Session$_.AddInAttach,_$Session$_.AddInAttachError", "Name,Location,Type,AttachmentType", "SSUU");
	ДобавитьФорму("_$InfoBase$_.SessionLockChange,_$InfoBase$_.SessionLockChangeError", "Use,Begin,End,Message,KeyCode,Parameter", "BDDSSS");
	ДобавитьФорму("_$InfoBase$_.ConfigExtensionUpdate,_$InfoBase$_.DBConfigExtensionInsert,_$InfoBase$_.DBConfigExtensionInsertError,_$InfoBase$_.DBConfigExtensionDeleteError,_$InfoBase$_.DBConfigExtensionUpdate,_$InfoBase$_.DBConfigExtensionUpdateError,_$InfoBase$_.DBConfigExtensionDelete", "Name,Version,Vendor,UUID,HashSum,Synonym,SafeMode,SecurityProfile,Active,UnsafeOperationProtection,Purpose,UsedInDistributedInfoBase,Scope,DefaultRoles,UseDefaultRolesForAllUsers", "SSSSSSBSBBSBSAB");
	// Пользователь 65534 использует общий список апстрима; 65535 добавляет интерфейс.
	Пользователь = ИменаПолей("_$User$_.Update");
	ИменаСИнтерфейсом = Новый Массив;
	Для Каждого Имя Из Пользователь Цикл
		ИменаСИнтерфейсом.Добавить(Имя);
	КонецЦикла;
	ИменаСИнтерфейсом.Вставить(12, "DefaultInterface");
	СобытияПользователя = "_$User$_.New,_$User$_.Update,_$User$_.NewError,_$User$_.UpdateError";
	ДобавитьФорму(СобытияПользователя, Пользователь, "BBBSOBBBSSSABBTSBSBBTSDSBBB", "65534", 1, "Пользователь");
	ДобавитьФорму(СобытияПользователя, ИменаСИнтерфейсом, "BBBSOBBBSSSAOBBTSBSBBTSDSBBB", "65535", 1, "Пользователь");
	ДобавитьФорму("_$InfoBase$_.UserPasswordPolicyNew,_$InfoBase$_.UserPasswordPolicyNewError,_$InfoBase$_.UserPasswordPolicyUpdate",
		"Name,PasswordMaxEffectivePeriod,PasswordMinEffectivePeriod,PasswordMinLength,PasswordReuseLimit,PasswordStrengthCheck,PasswordExpirationNotificationPeriod,PasswordCompromiseCheck,ActionOnPasswordRequirementsViolationOnAuthenticationCode",
		"SNNNNBNBN", "255", 1, "Позиционная");
	СобытияПараметров = "_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError";
	ДобавитьФорму(СобытияПараметров, "MaxUnsuccessfulAttemptsCount,LockDuration,UserNameAdditionCodes", "NNS", "448", 1, "Позиционная");
	ДобавитьФорму(СобытияПараметров, "MaxUnsuccessfulAttemptsCount,LockDuration", "NN", "192", 1, "Позиционная");
	ДобавитьФорму(СобытияПараметров, "MaxUnsuccessfulAttemptsCount,UserNameAdditionCodes", "NS", "320", 1, "Позиционная");
	ДобавитьФорму(СобытияПараметров, "LockDuration,UserNameAdditionCodes", "NS", "384", 1, "Позиционная");
	ДобавитьФорму(СобытияПараметров, "UserPasswordStrengthCheck", "N", "4", 1, "ПроверкаПароля");
	ДобавитьФорму(СобытияПараметров, "ActionOnUserPasswordRequirementsViolationOnAuthentication", "N", "32768", 1, "НарушениеПароля");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "VerificationCodeLength,Header,ShowHelpHyperlink", "NSB", "2564", 1);

	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoveryMethod", "N", "1", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoveryURL", "S", "2", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "VerificationCodeLength", "N", "4", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "MaxUnsuccessfulVerificationCodeValidationAttemptsCount", "N", "8", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "SMTPServerAddress", "S", "16", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "SMTPUser", "S", "32", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "SMTPPasswordChanged", "B", "64", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "SMTPPort", "N", "128", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "SenderName", "S", "256", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "Header", "S", "512", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "HTMLMessageText", "S", "1024", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "ShowHelpHyperlink", "B", "2048", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "HelpURL", "S", "4096", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "VerificationCodeRefreshRequestLockDuration", "N", "8192", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "UseSSL", "B", "16384", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "AllowAutoSaveAuthentication", "B", "32768", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "AutoSaveAuthenticationByDefault", "B", "65536", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "AutoSavedAuthenticationLifeTime", "N", "131072", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "UseStandardPasswordCompromiseCheckList", "B", "262144", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "UseSpecifiedPasswordCompromiseCheckList", "B", "524288", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "UsePasswordCompromiseCheckService", "B", "1048576", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordCompromiseCheckServiceURL", "S", "2097152", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordCompromiseCheckServiceRequestTimeout", "N", "4194304", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "IgnorePasswordCompromiseCheckServiceErrors", "B", "8388608", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "VerificationCodeEffectivePeriod", "N", "16777216", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationMethod", "N", "33554432", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationVerificationCodeLength", "N", "67108864", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationMaxUnsuccessfulVerificationCodeValidationAttemptsCount", "N", "134217728", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationSMTPServerAddress", "S", "268435456", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationSMTPUser", "S", "536870912", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationSMTPPasswordChanged", "B", "1073741824", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationSMTPPort", "N", "2147483648", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationSenderName", "S", "4294967296", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationHeader", "S", "8589934592", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationHTMLMessageText", "S", "17179869184", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationVerificationCodeRefreshRequestLockDuration", "N", "34359738368", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationUseSSLWhenSendingVerificationCode", "B", "68719476736", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationVerificationCodeEffectivePeriod", "N", "137438953472", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoverySMTPSecureAuthenticationOnly", "B", "549755813888", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoveryTokenAuthenticationWhenSendingVerificationCode", "N", "1099511627776", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoveryAccessTokenChanged", "B", "2199023255552", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationTokenAuthenticationWhenSendingVerificationCode", "N", "8796093022208", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationAccessTokenChanged", "B", "17592186044416", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "PasswordRecoveryFrom", "S", "35184372088832", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate", "EmailAuthenticationFrom", "S", "70368744177664", 1, "НастройкаАутентификации");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "LockWaitTime", "N", "1", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordMinLength", "N", "2", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "PassiveSessionHibernateTime", "N", "8", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "HibernateSessionTerminateTime", "N", "16", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "MaxUnsuccessfulAttemptsCount", "N", "64", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "LockDuration", "N", "128", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserNameAdditionCodes", "S", "256", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordMinEffectivePeriod", "N", "512", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordMaxEffectivePeriod", "N", "1024", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordReuseLimit", "N", "2048", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordExpirationNotificationPeriod", "N", "4096", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordHashAlgorithmType", "S", "8192", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "UserPasswordCompromiseCheck", "B", "16384", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "InactivityTimeForTerminateSessionNotification", "N", "65536", 1, "Позиционная");
	ДобавитьФорму("_$InfoBase$_.ParametersUpdate,_$InfoBase$_.ParametersUpdateError", "InactivityTimeForTerminateSession", "N", "131072", 1, "Позиционная");
КонецПроцедуры

Процедура ЗаполнитьПоля() // BSLLS:MethodSize-off

	// --- проверено по .lgp + ВыгрузитьЖурналРегистрации (8.3.27) ---

	Маска("_$Access$_.Access", "0=Data");
	Маска("_$InfoBase$_.PredefinedDataUpdate", "0=Data");
	Маска("_$InfoBase$_.ExclusiveModeChange", "1=ExclusiveMode");
	ПоОбразцу("_$InfoBase$_.ExclusiveModeChangeError", "_$InfoBase$_.ExclusiveModeChange");

	Добавить("_$InfoBase$_.ConfigUpdate", "HashSum,Version");
	Добавить("_$InfoBase$_.DBConfigUpdate", "Vendor,Version");
	ПоОбразцу("_$InfoBase$_.ConfigUpdateError", "_$InfoBase$_.DBConfigUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigBackgroundUpdateError", "_$InfoBase$_.DBConfigUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigUpdateError", "_$InfoBase$_.DBConfigUpdate");

	Маска("_$Session$_.Authentication",
		"0=OSUser,1=Name,2=CurrentOSUser,9=AuthenticationMode");
	ПоОбразцу("_$Session$_.AuthenticationError", "_$Session$_.Authentication");

	// P/65534: 27 позиций (без DefaultInterface). P/65535: +DefaultInterface после Roles.
	// Имена — как в OneSTools.EventLog docs/events.md (проверено 8.3.27).
	Добавить("_$User$_.Update",
		"OSAuthentication,StandardAuthentication,CannotChangePassword,Name,Language,"
		+ "PasswordChanged,PasswordIsSet,ShowInList,FullName,OSUser,RunMode,Roles,"
		+ "OpenIDAuthentication,UnsafeOperationProtection,SecondAuthenticationFactorSettings,"
		+ "SecondAuthenticationFactorSettingsProcessing,CannotRecoveryPassword,Email,"
		+ "OpenIDConnectAuthentication,AccessTokenAuthentication,UserMatchingKeys,"
		+ "PasswordPolicyName,PasswordSettingDate,PasswordHashAlgorithmType,"
		+ "QRCodeAuthentication,PasswordDoesNotSatisfyRequirements,EmailAuthentication");
	ПоОбразцу("_$User$_.New", "_$User$_.Update");
	ПоОбразцу("_$User$_.NewError", "_$User$_.Update");
	ПоОбразцу("_$User$_.UpdateError", "_$User$_.Update");

	// --- черновик из СП UnloadEventLog (порядок хранения не сверен) ---

	Добавить("_$Access$_.AccessDenied", "Right,Action,Data");
	Добавить("_$InfoBase$_.AdditionalAuthenticationSettingsUpdate",
		"PasswordRecoveryMethod,PasswordRecoveryURL,HelpURL,ShowHelpHyperlink,"
		+ "VerificationCodeLength,"
		+ "MaxUnsuccessfulVerificationCodeValidationAttemptsCount,"
		+ "VerificationCodeRefreshRequestLockDuration,SMTPServerAddress,"
		+ "SMTPUser,SMTPPasswordChanged,SMTPPort,PasswordRecoveryFrom,"
		+ "SenderName,Header,HTMLMailText,SMTPPassword,UseSSL,"
		+ "VerificationCodeEffectivePeriod,"
		+ "PasswordRecoverySMTPSecureAuthenticationOnly,"
		+ "PasswordRecoveryTokenAuthenticationWhenSendingVerificationCode,"
		+ "PasswordRecoveryAccessTokenChanged,"
		+ "AllowSaveAuthenticationForReauthentication,"
		+ "SaveAuthenticationForReauthenticationByDefault,"
		+ "SavedAuthenticationLifeTime,AllowAutoSaveAuthentication,"
		+ "AutoSaveAuthenticationByDefault,AutoSavedAuthenticationLifeTime,"
		+ "UseStandardPasswordCompromiseCheckList,"
		+ "UseSetPasswordCompromiseCheckList,UsePasswordCompromiseCheckService,"
		+ "PasswordCompromiseCheckServiceURL,"
		+ "PasswordCompromiseCheckServiceRequestTimeout,"
		+ "IgnorePasswordCompromiseCheckServiceErrors,EmailAuthenticationMethod,"
		+ "EmailAuthenticationVerificationCodeLength,"
		+ "EmailAuthenticationMaxUnsuccessfulVerificationCodeValidationAttemptsCount,"
		+ "EmailAuthenticationVerificationCodeRefreshRequestLockDuration,"
		+ "EmailAuthenticationSMTPServerAddress,EmailAuthenticationSMTPUser,"
		+ "EmailAuthenticationSMTPPasswordChanged,EmailAuthenticationSMTPPort,"
		+ "EmailAuthenticationFrom,EmailAuthenticationSenderName,"
		+ "EmailAuthenticationHeader,EmailAuthenticationHTMLMessageText,"
		+ "EmailAuthenticationUseSSLWhenSendingVerificationCode,"
		+ "EmailAuthenticationVerificationCodeEffectivePeriod,"
		+ "EmailAuthenticationVerificationCodeAlphabet,"
		+ "EmailAuthenticationSMTPSecureAuthenticationOnly,"
		+ "EmailAuthenticationTokenAuthenticationWhenSendingVerificationCode,"
		+ "PasswordRecoveryAccessTokenChanged");
	Добавить("_$InfoBase$_.AdministrationParametersChange",
		"LockScheduledJobs,SessionsLockEnabled,LockBeginTime,LockEndTime,"
		+ "ConfigurationUnloadDelayByWorkingProcessWithoutActiveUsers,"
		+ "DisableLocalSpeechToText,InfoBaseID,Name,DataBaseName,"
		+ "SessionStartPermissionCode,LanguageCode,"
		+ "MaxScheduledJobsStartShiftWithoutActiveUsers,"
		+ "MinScheduledJobsStartPeriodWithoutActiveUsers,"
		+ "ExternalSessionManagementRequired,Description,LockParameter,"
		+ "DatabaseUser,SecurityProfile,SafeModeSecurityProfile,"
		+ "AllowLicenseDistribution,ReserveWorkingProcesses,DataBaseServer,"
		+ "DateOffset,LockMessage,ExternalSessionManagementConnectionString,"
		+ "DBMS,ConnectionsSecurityLevel");
	Добавить("_$InfoBase$_.ConfigExtensionUpdate",
		"Name,Vendor,Active,SafeMode,SecurityProfile,Version,"
		+ "UnsafeActionProtection,UseDefaultRolesForAllUsers,"
		+ "UsedInDistributedInfoBase,Purpose,Scope,DefaultRoles,Synonym,UUID,"
		+ "HashSum");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionDelete", "_$InfoBase$_.ConfigExtensionUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionDeleteError", "_$InfoBase$_.ConfigExtensionUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionInsert", "_$InfoBase$_.ConfigExtensionUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionInsertError", "_$InfoBase$_.ConfigExtensionUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionUpdate", "_$InfoBase$_.ConfigExtensionUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigExtensionUpdateError", "_$InfoBase$_.ConfigExtensionUpdate");
	Добавить("_$InfoBase$_.EventLogSettingsUpdateError", "Levels,SplitPeriod,EventLogFormat,EventName,EventIsLogged");
	Добавить("_$InfoBase$_.PasswordCompromiseCheckListUpdate", "ValuesCountAfterUpdate");
	Добавить("_$InfoBase$_.RegionalSettingsChange",
		"UseCurrentSessionSettings,LocaleCode,FirstDayOfWeek,"
		+ "BooleanTruePresentation,BooleanFalsePresentation,"
		+ "NegativeNumberPresentation,NumbersDigitGroupSeparator,"
		+ "NumbersDecimalSeparator,NumbersDigitGroupFormat,"
		+ "TimePresentationFormat,DatePresentationFormat");
	ПоОбразцу("_$InfoBase$_.RegionalSettingsChangeError", "_$InfoBase$_.RegionalSettingsChange");
	Добавить("_$InfoBase$_.RoleUpdate",
		"Rights,AccessDisabled,Restrictions,Updated,Removed,Added,"
		+ "TemplateText,SetRightsForNewObjects,"
		+ "SetRightsForAttributesAndTabularSectionsByDefault,"
		+ "SubordinateObjectsHaveIndependentRights");
	Добавить("_$InfoBase$_.SecondAuthenticationFactorTemplateDelete", "Name");
	ПоОбразцу("_$InfoBase$_.SecondAuthenticationFactorTemplateNew", "_$InfoBase$_.SecondAuthenticationFactorTemplateDelete");
	ПоОбразцу("_$InfoBase$_.SecondAuthenticationFactorTemplateUpdate", "_$InfoBase$_.SecondAuthenticationFactorTemplateDelete");
	Добавить("_$InfoBase$_.SecurityProfileChange",
		"ClusterAdministrator,SecurityProfile,ModulesAvailableForExtension,"
		+ "Name,ModulesNotAvailableForExtension,Description,COMObjectFullAccess,"
		+ "AddInFullAccess,ExternalModuleFullAccess,"
		+ "ExternalApplicationsFullAccess,InternetResourcesFullAccess,"
		+ "FileSystemFullAccess,FullPrivilegedMode,SafeModeProfile,"
		+ "AllowExternalCodeExecutionInUnsafeMode,AllowAccessRightsExtension,"
		+ "AccessRightsExtensionLimitingRoles,"
		+ "AccessRightsExtensionLimitingRoles,AllowedAddIns,"
		+ "AllowedExternalApplications,AllowedCOMClass,AllowedInternetResources,"
		+ "AllowedExternalModules,AllowedVirtualDirectories");
	Добавить("_$InfoBase$_.SessionLockChange", "KeyCode,End,Begin,Parameter,Message,Use");
	ПоОбразцу("_$InfoBase$_.SessionLockChangeError", "_$InfoBase$_.SessionLockChange");
	Добавить("_$InfoBase$_.UserPasswordPolicyDelete",
		"Name,PasswordMaxEffectivePeriod,PasswordMinEffectivePeriod,"
		+ "PasswordMinLength,PasswordReuseLimit,PasswordStrengthCheck,"
		+ "PasswordExpirationNotificationPeriod");
	ПоОбразцу("_$InfoBase$_.UserPasswordPolicyNew", "_$InfoBase$_.UserPasswordPolicyDelete");
	ПоОбразцу("_$InfoBase$_.UserPasswordPolicyUpdate", "_$InfoBase$_.UserPasswordPolicyDelete");
	Добавить("_$OpenIDProvider$_.NegativeAssertion", "RelyingPartyURL");
	Добавить("_$OpenIDProvider$_.PositiveAssertion", "Name,RelyingPartyURL");
	Добавить("_$Session$_.AddInAttach", "Location,Name,Type,AttachmentType");
	ПоОбразцу("_$Session$_.AddInAttachError", "_$Session$_.AddInAttach");
	Добавить("_$Session$_.AuthenticationFirstFactor", "Name,AuthenticationMode,CurrentOSUser");
	Добавить("_$Session$_.ConfigExtensionApplyError", "Name");
	Добавить("_$Session$_.ExternalDataProcessorConnect", "Path,Name,SafeMode,LanguageCode,UnsafeActionProtection,SecurityProfile");
	ПоОбразцу("_$Session$_.ExternalDataProcessorConnectError", "_$Session$_.ExternalDataProcessorConnect");
	ПоОбразцу("_$Session$_.ExternalReportConnect", "_$Session$_.ExternalDataProcessorConnect");
	ПоОбразцу("_$Session$_.ExternalReportConnectError", "_$Session$_.ExternalReportConnect");
	Добавить("_$Session$_.PasswordChangeError", "Name");
	Добавить("_$Session$_.PasswordCompromiseCheckServiceErrorOnAuthentication", "Name");
	Добавить("_$Session$_.PasswordRequirementsViolationOnAuthentication", "Name");
	Добавить("_$User$_.AuthenticationLock", "Name");
	Добавить("_$User$_.AuthenticationUnlock", "Name");
	ПоОбразцу("_$User$_.AuthenticationUnlockError", "_$User$_.AuthenticationUnlock");
	Добавить("_$User$_.Delete", "Name");
	ПоОбразцу("_$User$_.DeleteError", "_$User$_.Delete");
	Добавить("_$User$_.PermissionChange",
		"Rights,AccessDisabled,Restrictions,Updated,Removed,Added,"
		+ "TemplateText,Description");
КонецПроцедуры
// BSLLS:DuplicateStringLiteral-on

#КонецОбласти

&Желудь
Процедура ПриСозданииОбъекта()
	Поля = Новый Соответствие;
	БитыПоСобытию = Новый Соответствие;
	СпособПоСобытию = Новый Соответствие;
	ЗаполнитьПоля();
	РаскладкиПоСобытию = Новый Соответствие;
	ЗаполнитьРаскладки();
КонецПроцедуры
