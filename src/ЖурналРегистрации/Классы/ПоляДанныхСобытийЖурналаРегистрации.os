// EN-имена полей Data системных событий журнала регистрации.
//
// Порядок и способ кодирования — как в *.lgp (хранение), не как список в
// UnloadEventLog СП. Имена EN — ключи OTLP/метрик.
//
// {P,{Маска, Значение…}} — бит N → поле; значения по возрастанию установленных битов.
// {P,{Значение…}} или плотный ряд после маски (User.*) — ИменаПолей по позиции.
// События без проверенной раскладки: состав из СП как Последовательность (черновик).
// Одинаковый состав — ПоОбразцу.

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
КонецПроцедуры
