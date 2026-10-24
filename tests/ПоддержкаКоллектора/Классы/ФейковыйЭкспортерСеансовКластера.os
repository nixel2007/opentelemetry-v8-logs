// BSLLS:MissingVariablesDescription-off
// BSLLS:PublicMethodsDescription-off
// BSLLS:MissingParameterDescription-off
// BSLLS:MissingReturnedValueDescription-off
// Фейк экспортера сеансов кластера: копит снимки из вызовов Записать.

Перем Снимки; // Массив из Структура - снимки кластера

Процедура Записать(Снимок) Экспорт
	Снимки.Добавить(Снимок);
КонецПроцедуры

Функция ЗаписанныеСнимки() Экспорт
	Возврат Снимки;
КонецФункции

Снимки = Новый Массив;
