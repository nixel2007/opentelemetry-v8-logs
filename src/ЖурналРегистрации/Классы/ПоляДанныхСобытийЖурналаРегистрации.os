// EN-имена полей структуры Data (Данные) системных событий журнала регистрации.
//
// Состав и порядок - из синтакс-помощника UnloadEventLog / ВыгрузитьЖурналРегистрации,
// параметр <Отбор>.Событие (платформа 8.5.1.1343). Только английские имена: ключи атрибутов
// OTLP/метрик. События с одинаковым составом в СП — ПоОбразцу. Без описания состава
// ИменаПолей возвращает Неопределено.

Перем Поля; // Соответствие: идентификатор события -> Массив из Строка (EN)

#Область ПрограммныйИнтерфейс

// EN-имена полей Data события в порядке синтакс-помощника.
//
// Параметры:
//   Событие - Строка - идентификатор события (_$User$_.Update...)
//
// Возвращаемое значение:
//   Массив из Строка, Неопределено - имена полей; без состава - Неопределено
//
Функция ИменаПолей(Знач Событие) Экспорт
	Возврат Поля[Событие];
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура Добавить(Событие, Имена)
	Поля.Вставить(Событие, СтрРазделить(Имена, ",", Ложь));
КонецПроцедуры

Процедура ПоОбразцу(Событие, Образец)
	Поля.Вставить(Событие, Поля[Образец]);
КонецПроцедуры

// Таблица полей: по вызову на событие. У событий с одинаковым составом в СП - ПоОбразцу.
// BSLLS:DuplicateStringLiteral-off
Процедура ЗаполнитьПоля() // BSLLS:MethodSize-off

	Добавить("_$Access$_.Access", "Data");
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
	Добавить("_$InfoBase$_.ConfigUpdate", "HashSum,Version");
	Добавить("_$InfoBase$_.DBConfigUpdate", "Vendor,Version");
	ПоОбразцу("_$InfoBase$_.ConfigUpdateError", "_$InfoBase$_.DBConfigUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigBackgroundUpdateError", "_$InfoBase$_.DBConfigUpdate");
	ПоОбразцу("_$InfoBase$_.DBConfigUpdateError", "_$InfoBase$_.DBConfigUpdate");
	Добавить("_$InfoBase$_.EventLogSettingsUpdateError", "Levels,SplitPeriod,EventLogFormat,EventName,EventIsLogged");
	Добавить("_$InfoBase$_.ExclusiveModeChange", "ExclusiveMode,Parameters,Message");
	ПоОбразцу("_$InfoBase$_.ExclusiveModeChangeError", "_$InfoBase$_.ExclusiveModeChange");
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
	Добавить("_$Session$_.Authentication",
		"OSUser,Name,CurrentOSUser,UserNameAdditionCode,AuthenticationMode,"
		+ "SavedAuthentication,OpenIDProviderURL,OpenIDProviderUserID,"
		+ "AccessTokenIssuer,AccessTokenID,EmailAddress");
	ПоОбразцу("_$Session$_.AuthenticationError", "_$Session$_.Authentication");
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
	Добавить("_$User$_.New",
		"OSAuthentication,StandardAuthentication,AccessTokenAuthentication,"
		+ "OpenIDAuthentication,OpenIDConnectAuthentication,"
		+ "QRCodeAuthentication,PasswordSettingDate,UnsafeOperationProtection,"
		+ "CannotChangePassword,Name,PasswordPolicyName,UserMatchingKeys,"
		+ "DefaultInterface,PasswordChanged,PasswordDoesNotSatisfyRequirements,"
		+ "PasswordIsSet,ShowInList,FullName,OSUser,RunMode,Roles,"
		+ "UserPasswordHashAlgorithmType,Language");
	ПоОбразцу("_$User$_.NewError", "_$User$_.New");
	ПоОбразцу("_$User$_.Update", "_$User$_.New");
	ПоОбразцу("_$User$_.UpdateError", "_$User$_.Update");
	Добавить("_$User$_.PermissionChange",
		"Rights,AccessDisabled,Restrictions,Updated,Removed,Added,"
		+ "TemplateText,Description");
КонецПроцедуры
// BSLLS:DuplicateStringLiteral-on

#КонецОбласти

&Желудь
Процедура ПриСозданииОбъекта()
	Поля = Новый Соответствие;
	ЗаполнитьПоля();
КонецПроцедуры
