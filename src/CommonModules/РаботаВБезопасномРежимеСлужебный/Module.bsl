////////////////////////////////////////////////////////////////////////////////
// Подсистема "Базовая функциональность".
// Серверные процедуры и функции общего назначения:
// - Поддержка профилей безопасности.
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Создает запрос на создание профиля безопасности для внешнего модуля.
// Только для внутреннего использования.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросСозданияПрофиляБезопасности(Знач ПрограммныйМодуль) Экспорт
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	Операция = Перечисления.ОперацииАдминистрированияПрофилейБезопасности.Создание;
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеСозданияПрофиляБезопасности");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		
		Обработчик.Модуль.ПриЗапросеСозданияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
		
		Если Не СтандартнаяОбработка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если СтандартнаяОбработка Тогда
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеСозданияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросАдминистрированияРазрешений(
			ПрограммныйМодуль, Операция);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Внешние модули
//

// Возвращает режим подключения внешнего модуля.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка, ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    режим подключения.
//
// Возвращаемое значение: Строка - имя профиля безопасности, который должен использоваться для подключения
//  внешнего модуля. Если для внешнего модуля не зарегистрирован режим подключения - возвращается Неопределено.
//
Функция РежимПодключенияВнешнегоМодуля(Знач ВнешнийМодуль) Экспорт
	
	Возврат РегистрыСведений.РежимыПодключенияВнешнихМодулей.РежимПодключенияВнешнегоМодуля(ВнешнийМодуль);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

// Возвращает URI пространства имен XDTO-пакета, который используется для описания разрешений
// в профилях безопасности.
//
// Возвращаемое значение: Строка, URI пространства имен XDTO-пакета.
//
Функция Пакет() Экспорт
	
	Возврат Метаданные.ПакетыXDTO.ApplicationPermissions_1_0_0_2.ПространствоИмен;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Создание запросов разрешений.
//

// Создает запросы на использование внешних ресурсов для внешнего модуля.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются разрешения,
//  НовыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    запрашиваемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*().
//    При запросе разрешений для внешних модулей добавление разрешений всегда выполняется в режиме замещения.
//
// Возвращаемое значение - Массив(УникальныйИдентификатор) - идентификаторы созданных запросов.
//
Функция ЗапросРазрешенийДляВнешнегоМодуля(Знач ПрограммныйМодуль, Знач НовыеРазрешения = Неопределено) Экспорт
	
	Результат = Новый Массив();
	
	Если НовыеРазрешения = Неопределено Тогда
		НовыеРазрешения = Новый Массив();
	КонецЕсли;
	
	Если НовыеРазрешения.Количество() > 0 Тогда
		
		// Если профиля безопасности еще нет - его требуется создать.
		Если РежимПодключенияВнешнегоМодуля(ПрограммныйМодуль) = Неопределено Тогда
			Результат.Добавить(ЗапросСозданияПрофиляБезопасности(ПрограммныйМодуль));
		КонецЕсли;
		
		Результат.Добавить(
			ЗапросИзмененияРазрешений(
				ПрограммныйМодуль, Истина, НовыеРазрешения, Неопределено, ПрограммныйМодуль));
		
	Иначе
		
		// Если профиль безопасности есть - его требуется удалить.
		Если РежимПодключенияВнешнегоМодуля(ПрограммныйМодуль) <> Неопределено Тогда
			Результат.Добавить(ЗапросУдаленияПрофиляБезопасности(ПрограммныйМодуль));
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

// Проверяет возможность использования профилей безопасности для текущей информационной базы.
//
// Возвращаемое значение: Булево.
//
Функция ВозможноИспользованиеПрофилейБезопасности() Экспорт
	
	Если ОбщегоНазначения.ИнформационнаяБазаФайловая(СтрокаСоединенияИнформационнойБазы()) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Отказ = Ложь;
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриПроверкеВозможностиИспользованияПрофилейБезопасности");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		Обработчик.Модуль.ПриПроверкеВозможностиИспользованияПрофилейБезопасности(Отказ);
		Если Отказ Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	РаботаВБезопасномРежимеПереопределяемый.ПриПроверкеВозможностиИспользованияПрофилейБезопасности(Отказ);
	
	Возврат Не Отказ;
	
КонецФункции

// Проверяет возможность настройки профилей безопасности из текущей информационной базы.
//
// Возвращаемое значение: Булево.
//
Функция ДоступнаНастройкаПрофилейБезопасности() Экспорт
	
	Если ВозможноИспользованиеПрофилейБезопасности() Тогда
		
		Отказ = Ложь;
		
		ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
			"СтандартныеПодсистемы.БазоваяФункциональность\ПриПроверкеВозможностиНастройкиПрофилейБезопасности");
		
		Для Каждого Обработчик Из ОбработчикиСобытия Цикл
			Обработчик.Модуль.ПриПроверкеВозможностиНастройкиПрофилейБезопасности(Отказ);
			Если Отказ Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если Не Отказ Тогда
			РаботаВБезопасномРежимеПереопределяемый.ПриПроверкеВозможностиНастройкиПрофилейБезопасности(Отказ);
		КонецЕсли;
		
		Возврат Не Отказ;
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

// Выполняет дополнительные (определенные бизнес-логикой) действия при включении
//  использования профилей безопасности.
//
Процедура ПриВключенииИспользованияПрофилейБезопасности() Экспорт
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриВключенииИспользованияПрофилейБезопасности");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		Обработчик.Модуль.ПриВключенииИспользованияПрофилейБезопасности();
	КонецЦикла;
	
	РаботаВБезопасномРежимеПереопределяемый.ПриВключенииИспользованияПрофилейБезопасности();
	
КонецПроцедуры

// Возвращает контрольные суммы файлов комплекта внешней компоненты, поставляемого в макете конфигурации.
//
// Параметры:
//  ИмяМакета - Строка - имя макета конфигурации, в составе которого поставляется комплект внешней компоненты.
//
// Возвращаемое значение - ФиксированноеСоответствие:
//                         * Ключ - Строка - имя файла,
//                         * Значение - Строка - контрольная сумма.
//
Функция КонтрольныеСуммыФайловКомплектаВнешнейКомпоненты(Знач ИмяМакета) Экспорт
	
	Результат = Новый Соответствие();
	
	СтруктураИмени = СтрРазделить(ИмяМакета, ".");
	
	Если СтруктураИмени.Количество() = 2 Тогда
		
		// Это общий макет
		Макет = ПолучитьОбщийМакет(СтруктураИмени[1]);
		
	ИначеЕсли СтруктураИмени.Количество() = 4 Тогда
		
		// Это макет объекта метаданных.
		МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(СтруктураИмени[0] + "." + СтруктураИмени[1]);
		Макет = МенеджерОбъекта.ПолучитьМакет(СтруктураИмени[3]);
		
	Иначе
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
				  |некорректное имя макета %1!'"), ИмяМакета);
	КонецЕсли;
	
	Если Макет = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
				  |поставляемой в макете %1: макет %1 не обнаружден в составе конфигурации!'"), ИмяМакета);
	КонецЕсли;
	
	Если Метаданные.НайтиПоПолномуИмени(ИмяМакета).ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты:
				  |макет %1 не содержит двоичных данных!'"), ИмяМакета);
	КонецЕсли;
	
	ВременныйФайл = ПолучитьИмяВременногоФайла("zip");
	Макет.Записать(ВременныйФайл);
	
	Архиватор = Новый ЧтениеZipФайла(ВременныйФайл);
	КаталогРаспаковки = ПолучитьИмяВременногоФайла() + "\";
	СоздатьКаталог(КаталогРаспаковки);
	
	ФайлМанифеста = "";
	Для Каждого ЭлементАрхива Из Архиватор.Элементы Цикл
		Если ВРег(ЭлементАрхива.Имя) = "MANIFEST.XML" Тогда
			ФайлМанифеста = КаталогРаспаковки + ЭлементАрхива.Имя;
			Архиватор.Извлечь(ЭлементАрхива, КаталогРаспаковки);
		КонецЕсли;
	КонецЦикла;
	
	Если ПустаяСтрока(ФайлМанифеста) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось сформировать разрешение на использование внешней компоненты,
				  |поставляемой в макете %1: в архиве не обнаружен файл MANIFEST.XML!'"), ИмяМакета);
	КонецЕсли;
	
	ПотокЧтения = Новый ЧтениеXML();
	ПотокЧтения.ОткрытьФайл(ФайлМанифеста);
	ОписаниеКомплекта = ФабрикаXDTO.ПрочитатьXML(ПотокЧтения, ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/addin/bundle", "bundle"));
	Для Каждого ОписаниеКомпоненты Из ОписаниеКомплекта.component Цикл
		
		Если ОписаниеКомпоненты.type = "native" ИЛИ ОписаниеКомпоненты.type = "com" Тогда
			
			ФайлКомпоненты = КаталогРаспаковки + ОписаниеКомпоненты.path;
			
			Архиватор.Извлечь(Архиватор.Элементы.Найти(ОписаниеКомпоненты.path), КаталогРаспаковки);
			
			Хэширование = Новый ХешированиеДанных(ХешФункция.SHA1);
			Хэширование.ДобавитьФайл(ФайлКомпоненты);
			
			ХэшСумма = Хэширование.ХешСумма;
			ХэшСуммаПреобразованнаяКСтрокеBase64 = Base64Строка(ХэшСумма);
			
			Результат.Вставить(ОписаниеКомпоненты.path, ХэшСуммаПреобразованнаяКСтрокеBase64);
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПотокЧтения.Закрыть();
	Архиватор.Закрыть();
	
	Попытка
		УдалитьФайлы(КаталогРаспаковки);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Работа в безопасном режиме.Не удалось удалить временный файл'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), 
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Попытка
		УдалитьФайлы(ВременныйФайл);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Работа в безопасном режиме.Не удалось удалить временный файл'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), 
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Преобразование ссылок к виду Тип+Идентификатор для хранения в регистрах
// разрешений.
//
// Используется нестандартный способ хранения ссылок т.к. для регистров разрешений не
// требуется обеспечение ссылочной целостности, и не требуется удаление записей из
// регистров вместе с удалением объекта.
//

// Формирует параметры для хранения ссылки в регистрах разрешений.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка.
//
// Возвращаемое значение: Структура:
//                        * Тип - СправочникСсылка.ИдентификаторыОбъектовМетаданных,
//                        * Идентификатор - УникальныйИдентификатор - уникальный
//                           идентификатор ссылки.
//
Функция СвойстваДляРегистраРазрешений(Знач Ссылка) Экспорт
	
	Результат = Новый Структура("Тип,Идентификатор");
	
	Если Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка() Тогда
		
		Результат.Тип = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
		Результат.Идентификатор = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
		
	Иначе
		
		Результат.Тип = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Ссылка.Метаданные());
		Результат.Идентификатор = Ссылка.УникальныйИдентификатор();
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Формирует ссылку из данных, хранящихся в регистрах разрешений.
//
// Параметры:
//  Тип - СправочникСсылка.ИдентификаторОбъектаМетаданных,
//  Идентификатор - УникальныйИдентификатор - уникальный идентификатор ссылки.
//
// Возвращаемое значение: ЛюбаяСсылка.
//
Функция СсылкаИзРегистраРазрешений(Знач Тип, Знач Идентификатор) Экспорт
	
	Если Тип = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка() Тогда
		Возврат Тип;
	Иначе
		
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(Тип);
		Менеджер = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ОбъектМетаданных.ПолноеИмя());
		
		Если ПустаяСтрока(Идентификатор) Тогда
			Возврат Менеджер.ПустаяСсылка();
		Иначе
			Возврат Менеджер.ПолучитьСсылку(Идентификатор);
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Создание запросов разрешений.
//

// Создает запрос на изменение разрешений использования внешних ресурсов.
// Только для внутреннего использования.
//
// Параметры:
//  Владелец - ЛюбаяСсылка - владелец разрешений на использование внешних ресурсов.
//    (Неопределено при запросе разрешений для конфигурации, а не для объектов конфигурации),
//  РежимЗамещения - Булево - режим замещения ранее предоставленных для владельца разрешений,
//  ДобавляемыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    запрашиваемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*(),
//  УдаляемыеРазрешения - Массив(ОбъектXDTO) - массив ОбъектовXDTO, соответствующих внутренним описаниям
//    отменяемых разрешений на доступ к внешним ресурсам. Предполагается, что все ОбъектыXDTO, передаваемые
//    в качестве параметра, сформированы с помощью вызова функций РаботаВБезопасномРежиме.Разрешение*(),
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросИзмененияРазрешений(Знач Владелец, Знач РежимЗамещения, Знач ДобавляемыеРазрешения = Неопределено, Знач УдаляемыеРазрешения = Неопределено, Знач ПрограммныйМодуль = Неопределено) Экспорт
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		
		Обработчик.Модуль.ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения, СтандартнаяОбработка, Результат);
		
		Если Не СтандартнаяОбработка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если СтандартнаяОбработка Тогда
		
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения, СтандартнаяОбработка, Результат);
		
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросИспользованияРазрешений(
			ПрограммныйМодуль, Владелец, РежимЗамещения, ДобавляемыеРазрешения, УдаляемыеРазрешения);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Создает запрос на удаление профиля безопасности для внешнего модуля.
// Только для внутреннего использования.
//
// Параметры:
//  ВнешнийМодуль - ЛюбаяСсылка - ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    разрешения. (Неопределено при запросе разрешений для конфигурации, а не для внешних модулей).
//
// Возвращаемое значение - УникальныйИдентификатор - идентификатор созданного запроса.
//
Функция ЗапросУдаленияПрофиляБезопасности(Знач ПрограммныйМодуль) Экспорт
	
	СтандартнаяОбработка = Истина;
	Результат = Неопределено;
	Операция = Перечисления.ОперацииАдминистрированияПрофилейБезопасности.Удаление;
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеУдаленияПрофиляБезопасности");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		
		Обработчик.Модуль.ПриЗапросеУдаленияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
		
		Если Не СтандартнаяОбработка Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если СтандартнаяОбработка Тогда
		РаботаВБезопасномРежимеПереопределяемый.ПриЗапросеУдаленияПрофиляБезопасности(
			ПрограммныйМодуль, СтандартнаяОбработка, Результат);
	КонецЕсли;
	
	Если СтандартнаяОбработка Тогда
		
		Результат = РегистрыСведений.ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов.ЗапросАдминистрированияРазрешений(
			ПрограммныйМодуль, Операция);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Создает запросы на обновление разрешений конфигурации.
//
// Параметры:
//  ВключаяЗапросСозданияПрофиляИБ - Булево - включать в результат запрос на создание профиля безопасности
//    для текущей информационной базы.
//
// Возвращаемое значение: Массив(УникальныйИдентификатор) - идентификаторы запросов для обновления разрешений
// конфигурации до требуемых в настоящий момент.
//
Функция ЗапросыОбновленияРазрешенийКонфигурации(Знач ВключаяЗапросСозданияПрофиляИБ = Истина) Экспорт
	
	Результат = Новый Массив();
	
	НачатьТранзакцию();
	
	Попытка
		
		Если ВключаяЗапросСозданияПрофиляИБ Тогда
			Результат.Добавить(ЗапросСозданияПрофиляБезопасности(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка()));
		КонецЕсли;
		
		ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
			"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам");
		Для Каждого Обработчик Из ОбработчикиСобытия Цикл
			Обработчик.Модуль.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(Результат);
		КонецЦикла;
		
		РаботаВБезопасномРежимеПереопределяемый.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(Результат);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Применение запросов разрешений на использование внешних ресурсов.
//

// Формирует представление разрешений на использование внешних ресурсов по таблицам разрешений.
//
// Параметры:
//  Таблицы - Структура - таблицы разрешений, для которых формируется представление
//    (см. ТаблицыРазрешений()).
//
// Возвращаемое значение: ТабличныйДокумент, представление разрешений на использование внешних ресурсов.
//
Функция ПредставлениеРазрешенийНаИспользованиеВнешнихРесурсов(Знач ТипПрограммногоМодуля, Знач ИдентификаторПрограммногоМодуля, Знач ТипВладельца, Знач ИдентификаторВладельца, Знач Разрешения) Экспорт
	
	НачатьТранзакцию();
	
	Менеджер = Обработки.НастройкаРазрешенийНаИспользованиеВнешнихРесурсов.Создать();
	
	Менеджер.ДобавитьЗапросРазрешенийНаИспользованиеВнешнихРесурсов(
			ТипПрограммногоМодуля,
			ИдентификаторПрограммногоМодуля,
			ТипВладельца,
			ИдентификаторВладельца,
			Истина,
			Разрешения,
			Новый Массив());
	
	Менеджер.РассчитатьПрименениеЗапросов();
	
	ОтменитьТранзакцию();
	
	Возврат Менеджер.Представление(Истина);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Внешние модули
//

// Возвращает программный модуль, выполняющий функции менеджера внешнего модуля.
//
//  ВнешнийМодуль - ЛюбаяСсылка, ссылка, соответствующая внешнему модулю, для которого запрашиваются
//    менеджер.
//
// Возвращаемое значение: ОбщийМодуль.
//
Функция МенеджерВнешнегоМодуля(Знач ВнешнийМодуль) Экспорт
	
	Контейнеры = Новый Массив();
	
	Менеджеры = МенеджерыВнешнихМодулей();
	Для Каждого Менеджер Из Менеджеры Цикл
		КонтейнерыМенеджера = Менеджер.КонтейнерыВнешнихМодулей();
		
		Если ТипЗнч(ВнешнийМодуль) = Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
			ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(ВнешнийМодуль);
		Иначе
			ОбъектМетаданных = ВнешнийМодуль.Метаданные();
		КонецЕсли;
		
		Если КонтейнерыМенеджера.Найти(ОбъектМетаданных) <> Неопределено Тогда
			Возврат Менеджер;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Контроль записи служебных данных.
//

// Процедура должна вызываться при записи любых служебных данных, изменение которых должно быть
// недопустимо при установленном безопасном режиме.
//
Процедура ПриЗаписиСлужебныхДанных(Объект) Экспорт
	
	Если РаботаВБезопасномРежиме.УстановленБезопасныйРежим() Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Запись объекта %1 недоступна: установлен безопасный режим: %2!'"),
			Объект.Метаданные().ПолноеИмя(),
			БезопасныйРежим());
		
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Декларация обработчиков программных событий.
//

// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
//
Процедура ПриДобавленииОбработчиковСлужебныхСобытий(КлиентскиеОбработчики, СерверныеОбработчики) Экспорт
	
	// СЕРВЕРНЫЕ ОБРАБОТЧИКИ.
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда
		СерверныеОбработчики["СтандартныеПодсистемы.ВариантыОтчетов\ПриНастройкеВариантовОтчетов"].Добавить(
			"РаботаВБезопасномРежимеСлужебный");
	КонецЕсли;
	
	// КЛИЕНТСКИЕ ОБРАБОТЧИКИ.
	
	КлиентскиеОбработчики[
		"СтандартныеПодсистемы.БазоваяФункциональность\ПослеНачалаРаботыСистемы"].Добавить(
			"НастройкаРазрешенийНаИспользованиеВнешнихРесурсовКлиент");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики служебных событий.
//

// Содержит настройки размещения вариантов отчетов в панели отчетов.
//
// Параметры:
//   Настройки - Коллекция - Содержит настройки всех отчетов и вариантов конфигурации.
//       Используется для передачи в параметрах вспомогательных методов.
//
// Описание:
//   См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов().
//
// Вспомогательные методы:
//   1. Функции ОписаниеОтчета и ОписаниеВарианта формируют описание настроек отчета и варианта для последующего изменения:
//       НастройкиОтчета   = ВариантыОтчетов.ОписаниеОтчета(Настройки, Метаданные.Отчеты.<ИмяОтчета>);
//       НастройкиВарианта = ВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "<ИмяВарианта>");
//       Возвращаемые коллекции содержат одинаковый набор свойств.
//       НастройкиОтчета используются как умолчания для вариантов, описания которых еще не получены.
//       Подробнее - см. "свойства для изменения" в комментарии к ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов().
//   2. Процедура УстановитьРежимВыводаВПанеляхОтчетов позволяет настроить режим группировки вариантов в панелях отчетов:
//       ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, НастройкиОтчета, Истина/Ложь);
//       ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, Метаданные.Отчеты.<ИмяОтчета>, Истина/Ложь);
//       ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, Метаданные.Подсистемы.<ИмяПодсистемы>, Истина/Ложь);
//   3. Процедура НастроитьОтчетВМодулеМенеджера позволяет переопределять настройки отчета в его модуле менеджера:
//       ВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.<ИмяОтчета>);
//
Процедура ПриНастройкеВариантовОтчетов(Настройки) Экспорт
	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.ИспользуемыеВнешниеРесурсы);
КонецПроцедуры

// Заполняет структуру параметров, необходимых для работы клиентского кода
// при запуске конфигурации. 
//
// Параметры:
//   Параметры   - Структура - структура параметров.
//   ДоОбновленияПараметровРаботыПрограммы   - Булево    - Истина, если параметр запрашивается для работы клиентского кода 
//      до обновления всех параметров работы программы. Например, в подчиненном узле РИБ из формы повторной загрузки сообщения обмена.
//
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры, ДоОбновленияПараметровРаботыПрограммы = Ложь) Экспорт
	
	Если ДоОбновленияПараметровРаботыПрограммы Тогда
		Параметры.Вставить("ОтображатьПомощникНастройкиРазрешений", Ложь);
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Параметры.Вставить("ОтображатьПомощникНастройкиРазрешений", ИспользуетсяИнтерактивныйРежимЗапросаРазрешений());
	Если Не Параметры.ОтображатьПомощникНастройкиРазрешений Тогда
		Возврат;
	КонецЕсли;	
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		Возврат;
	КонецЕсли;	
			
	Проверка = НастройкаРазрешенийНаИспользованиеВнешнихРесурсовВызовСервера.ПроверитьПрименениеРазрешенийНаИспользованиеВнешнихРесурсов();
	Если Проверка.РезультатПроверки Тогда
		Параметры.Вставить("ПроверитьПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Ложь);
	Иначе
		Параметры.Вставить("ПроверитьПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Истина);
		Параметры.Вставить("ПроверкаПримененияРазрешенийНаИспользованиеВнешнихРесурсов", Проверка);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Декларация программных событий.
//

// Объявляет служебные события подсистемы БазоваяФункциональность, предназначенные
//  для поддержки профилей безопасности.
//
// См. описание этой же процедуры в модуле СтандартныеПодсистемыСервер.
Процедура ПриДобавленииСлужебныхСобытий(КлиентскиеСобытия, СерверныеСобытия) Экспорт
	
	// СЕРВЕРНЫЕ СОБЫТИЯ.
	
	// Вызывается при проверке возможности использования профилей безопасности.
	//
	// Параметры:
	//  Отказ - Булево. Если для информационной базы недоступно использование профилей безопасности -
	//    значение данного параметра нужно установить равным Истина.
	//
	// Синтаксис:
	// Процедура ПриПроверкеВозможностиИспользованияПрофилейБезопасности(Отказ) Экспорт
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриПроверкеВозможностиИспользованияПрофилейБезопасности");
	
	// Вызывается при проверке возможности настройки профилей безопасности.
	//
	// Параметры:
	//  Отказ - Булево. Если для информационной базы недоступно использование профилей безопасности -
	//    значение данного параметра нужно установить равным Истина.
	//
	// Синтаксис:
	// Процедура ПриПроверкеВозможностиНастройкиПрофилейБезопасности(Отказ) Экспорт
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриПроверкеВозможностиНастройкиПрофилейБезопасности");
	
	// Вызывается при включении использования для информационной базы профилей безопасности.
	//
	// Синтаксис:
	// Процедура ПриВключенииИспользованияПрофилейБезопасности() Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриВключенииИспользованияПрофилейБезопасности");
	
	// Заполняет перечень запросов внешних разрешений, которые обязательно должны быть предоставлены
	// при создании информационной базы или обновлении программы.
	//
	// Параметры:
	//  ЗапросыРазрешений - Массив - список запросов, возвращаемых функцией.
	//                      ЗапросНаИспользованиеВнешнихРесурсов модуля РаботаВБезопасномРежиме.
	//
	// Синтаксис:
	// Процедура ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(ЗапросыРазрешений) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам");
	
	// Вызывается при создании запроса разрешений на использование внешних ресурсов.
	//
	// Параметры:
	//  ПрограммныйМодуль - ЛюбаяСсылка - ссылка на объект информационной базы, представляющий программный
	//    модуль, для которого выполняется запрос разрешений,
	//  Владелец - ЛюбаяСсылка - ссылка на объект информационной базы, представляющий объект-владелец запрашиваемых
	//    разрешений на использование внешних ресурсов,
	//  РежимЗамещения - Булево - флаг замещения ранее предоставленных разрешений по владельцу,
	//  ДобавляемыеРазрешения - Массив(ОбъектXDTO) - массив добавляемых разрешений,
	//  УдаляемыеРазрешения - Массив(ОбъектXDTO) - массив удаляемых разрешений,
	//  СтандартнаяОбработка - Булево, флаг выполнения стандартной обработки создания запроса на использование
	//    внешних ресурсов.
	//  Результат - УникальныйИдентификатор - идентификатор запроса (в том случае, если внутри обработчика
	//    значение параметра СтандартнаяОбработка установлено в значение Ложь).
	//
	// Синтаксис:
	// Процедура ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов(Знач ПрограммныйМодуль, Знач Владелец, Знач РежимЗамещения, Знач ДобавляемыеРазрешения, Знач УдаляемыеРазрешения, СтандартнаяОбработка, Результат) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеРазрешенийНаИспользованиеВнешнихРесурсов");
	
	// Вызывается при запросе создания профиля безопасности.
	//
	// Параметры:
	//  ПрограммныйМодуль - ЛюбаяСсылка - ссылка на объект информационной базы, представляющий программный
	//    модуль, для которого выполняется запрос разрешений,
	//  СтандартнаяОбработка - Булево, флаг выполнения стандартной обработки,
	//  Результат - УникальныйИдентификатор - идентификатор запроса (в том случае, если внутри обработчика
	//    значение параметра СтандартнаяОбработка установлено в значение Ложь).
	//
	// Синтаксис:
	// Процедура ПриЗапросеСозданияПрофиляБезопасности(Знач ПрограммныйМодуль, СтандартнаяОбработка, Результат) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеСозданияПрофиляБезопасности");
	
	// Вызывается при запросе удаления профиля безопасности.
	//
	// Параметры:
	//  ПрограммныйМодуль - ЛюбаяСсылка - ссылка на объект информационной базы, представляющий программный
	//    модуль, для которого выполняется запрос разрешений,
	//  СтандартнаяОбработка - Булево, флаг выполнения стандартной обработки,
	//  Результат - УникальныйИдентификатор - идентификатор запроса (в том случае, если внутри обработчика
	//    значение параметра СтандартнаяОбработка установлено в значение Ложь).
	//
	// Синтаксис:
	// Процедура ПриЗапросеУдаленияПрофиляБезопасности(Знач ПрограммныйМодуль, СтандартнаяОбработка, Результат) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриЗапросеУдаленияПрофиляБезопасности");
	
	// Вызывается при подключении внешнего модуля. В теле процедуры-обработчика может быть изменен
	// безопасный режим, в котором будет выполняться подключение.
	//
	// Параметры:
	//  ВнешнийМодуль - ЛюбаяСсылка - ссылка на объект информационной базы, представляющий подключаемый
	//    внешний модуль,
	//  БезопасныйРежим - ОпределяемыйТип.БезопасныйРежим - безопасный режим, в котором внешний
	//    модуль будет подключен к информационной базе. Может быть изменен внутри данной процедуры.
	//
	// Синтаксис:
	// Процедура ПриПодключенииВнешнегоМодуля(Знач ВнешнийМодуль, БезопасныйРежим) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриПодключенииВнешнегоМодуля");
	
	// Вызывается при регистрации менеджеров внешних модулей.
	// Только для использования внутри БСП.
	//
	// Параметры:
	//  Менеджеры - Массив(ОбщийМодуль).
	//
	// Синтаксис:
	// Процедура ПриРегистрацииМенеджеровВнешнихМодулей(Менеджеры) Экспорт
	//
	СерверныеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриРегистрацииМенеджеровВнешнихМодулей");
	
	// КЛИЕНТСКИЕ СОБЫТИЯ.
	
	// Вызывается при подтверждении запросов на использование внешних ресурсов.
	// 
	// Параметры:
	//  Идентификаторы - Массив(УникальныйИдентификатор), идентификаторы запросов, которые требуется применить,
	//  ФормаВладелец - УправляемаяФорма, форма, которая должна блокироваться до окончания применения разрешений,
	//  ОповещениеОЗакрытии - ОписаниеОповещения, которое будет вызвано при успешном предоставлении разрешений.
	//  СтандартнаяОбработка - Булево, флаг выполнения стандартной обработки применения разрешений на использование
	//    внешних ресурсов (подключение к агенту сервера через COM-соединение или сервер администрирования с
	//    запросом параметров подключения к кластеру у текущего пользователя). Может быть установлен в значение Ложь
	//    внутри обработчика события, в этом случае стандартная обработка завершения сеанса выполняться не будет.
	//
	// Синтаксис:
	// Процедура ПриПодтвержденииЗапросовНаИспользованиеВнешнихРесурсов(Знач ИдентификаторыЗапросов, ФормаВладелец, ОповещениеОЗакрытии, СтандартнаяОбработка) Экспорт
	//
	КлиентскиеСобытия.Добавить(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриПодтвержденииЗапросовНаИспользованиеВнешнихРесурсов");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Использование профилей безопасности.
//

// Проверяет, требуется ли использовать интерактивный режим запроса разрешений.
//
// Возвращаемое значение: Булево.
//
Функция ИспользуетсяИнтерактивныйРежимЗапросаРазрешений()
	
	Если ВозможноИспользованиеПрофилейБезопасности() Тогда
		
		Возврат ПолучитьФункциональнуюОпцию("ИспользуютсяПрофилиБезопасности") И Константы.АвтоматическиНастраиватьРазрешенияВПрофиляхБезопасности.Получить();
		
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Внешние модули
//

// Возвращает массив менеджеров справочников, которые являются контейнерами внешних модулей.
//
// Возвращаемое значение: Массив(СправочникМенеджер).
//
Функция МенеджерыВнешнихМодулей()
	
	Менеджеры = Новый Массив();
	
	ОбработчикиСобытия = ОбщегоНазначения.ОбработчикиСлужебногоСобытия(
		"СтандартныеПодсистемы.БазоваяФункциональность\ПриРегистрацииМенеджеровВнешнихМодулей");
	Для Каждого Обработчик Из ОбработчикиСобытия Цикл
		Обработчик.Модуль.ПриРегистрацииМенеджеровВнешнихМодулей(Менеджеры);
	КонецЦикла;
	
	Возврат Менеджеры;
	
КонецФункции

#КонецОбласти
