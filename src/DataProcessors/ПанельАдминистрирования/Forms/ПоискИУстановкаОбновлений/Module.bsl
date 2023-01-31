&НаКлиенте
Перем ОбновитьИнтерфейс;

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	// Значения реквизитов формы
	РежимРаботы = ОбщегоНазначенияПовтИсп.РежимРаботыПрограммы();
	РежимРаботы = Новый ФиксированнаяСтруктура(РежимРаботы);
	
	// СтандартныеПодсистемы.ОбновлениеКонфигурации
	Элементы.ГруппаОбработкаОбновлениеКонфигурации.Видимость = РежимРаботы.Локальный И РежимРаботы.ЭтоАдминистраторСистемы И Не РежимРаботы.ЭтоLinuxКлиент;
	Элементы.ГруппаНастройкиОбновленияПрограммы.Видимость = РежимРаботы.Локальный И РежимРаботы.ЭтоАдминистраторСистемы И Не РежимРаботы.ЭтоLinuxКлиент;
	ОбновитьНастройкиОбновленияКонфигурации();
	// Конец СтандартныеПодсистемы.ОбновлениеКонфигурации
	
	// СтандартныеПодсистемы.ОбновлениеВерсииИБ
	Элементы.ГруппаДетализироватьОбновлениеИБВЖурналеРегистрации.Видимость = РежимРаботы.ЭтоАдминистраторСистемы;
	// Конец СтандартныеПодсистемы.ОбновлениеВерсииИБ

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// СтандартныеПодсистемы.ОбновлениеКонфигурации
	Если ИмяСобытия = "ЗакрытаФормаНастройкиОбновленияКонфигурации" Тогда
		ОбновитьНастройкиОбновленияКонфигурации();
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ОбновлениеКонфигурации
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	ОбновитьИнтерфейсПрограммы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

// СтандартныеПодсистемы.ОбновлениеВерсииИБ
&НаКлиенте
Процедура ДетализироватьОбновлениеИБВЖурналеРегистрацииПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ОбновлениеВерсииИБ

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.ОбновлениеВерсииИБ
&НаКлиенте
Процедура ОтложеннаяОбработкаДанных(Команда)
	ПараметрыФормы = Новый Структура("ОткрытиеИзПанелиАдминистрирования", Истина);
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ИндикацияХодаОтложенногоОбновленияИБ", ПараметрыФормы);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ОбновлениеВерсииИБ

// СтандартныеПодсистемы.ОбновлениеКонфигурации
&НаКлиенте
Процедура НастройкаОбновленияПрограммы(Команда)
	
	ОткрытьФорму("Обработка.ПоискИУстановкаОбновлений.Форма.НастройкаРасписания");
	
КонецПроцедуры
// Конец СтандартныеПодсистемы.ОбновлениеКонфигурации

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// СтандартныеПодсистемы.ОбновлениеКонфигурации
&НаСервере
Процедура ОбновитьНастройкиОбновленияКонфигурации()
	
	НастройкиОбновленияКонфигурации = ОбновлениеКонфигурации.ПолучитьСтруктуруНастроекПомощника();
	
	ЗаголовокОбновленияПрограммы = НСтр("ru = 'Автоматическая проверка обновлений отключена.'");
	Если НастройкиОбновленияКонфигурации.ПроверятьНаличиеОбновленияПриЗапуске = 2 Тогда
		ЗаголовокОбновленияПрограммы = НСтр("ru = 'Автоматическая проверка обновлений выполняется при каждом запуске программы.'");
	ИначеЕсли НастройкиОбновленияКонфигурации.ПроверятьНаличиеОбновленияПриЗапуске = 1 Тогда
		ЗаголовокОбновленияПрограммы = НСтр("ru = 'Автоматическая проверка обновлений выполняется по расписанию: %1.'");
		Расписание = ОбщегоНазначенияКлиентСервер.СтруктураВРасписание(НастройкиОбновленияКонфигурации.РасписаниеПроверкиНаличияОбновления);
		ЗаголовокОбновленияПрограммы = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ЗаголовокОбновленияПрограммы, Расписание);
	КонецЕсли;
	
	Элементы.ПояснениеНастройкаОбновленияПрограммы.Заголовок = ЗаголовокОбновленияПрограммы;
	
КонецПроцедуры
// Конец СтандартныеПодсистемы.ОбновлениеКонфигурации

&НаКлиенте
Процедура ОбновитьИнтерфейсПрограммы()
	
	Если ОбновитьИнтерфейс = Истина Тогда
		ОбновитьИнтерфейс = Ложь;
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриИзмененииРеквизита(Элемент, ОбновлятьИнтерфейс = Истина)
	
	КонстантаИмя = ПриИзмененииРеквизитаСервер(Элемент.Имя);
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Если ОбновлятьИнтерфейс Тогда
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
	Если КонстантаИмя <> "" Тогда
		Оповестить("Запись_НаборКонстант", Новый Структура, КонстантаИмя);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПриИзмененииРеквизитаСервер(ИмяЭлемента)
	
	РеквизитПутьКДанным = Элементы[ИмяЭлемента].ПутьКДанным;
	
	КонстантаИмя = СохранитьЗначениеРеквизита(РеквизитПутьКДанным);
	
	ОбновитьПовторноИспользуемыеЗначения();
	
	Возврат КонстантаИмя;
КонецФункции

&НаСервере
Функция СохранитьЗначениеРеквизита(РеквизитПутьКДанным)
	
	// Сохранение значений реквизитов, не связанных с константами напрямую.
	Если РеквизитПутьКДанным = "" Тогда
		Возврат "";
	КонецЕсли;
	
	// Определение имени константы.
	КонстантаИмя = "";
	Если НРег(Лев(РеквизитПутьКДанным, 14)) = НРег("НаборКонстант.") Тогда
		// Если путь к данным реквизита указан через "НаборКонстант".
		КонстантаИмя = Сред(РеквизитПутьКДанным, 15);
	Иначе
		// Определение имени и запись значения реквизита в соответствующей константе из "НаборКонстант".
		// Используется для тех реквизитов формы, которые связаны с константами напрямую (в отношении один-к-одному).
	КонецЕсли;
	
	// Сохранения значения константы.
	Если КонстантаИмя <> "" Тогда
		КонстантаМенеджер = Константы[КонстантаИмя];
		КонстантаЗначение = НаборКонстант[КонстантаИмя];
		
		Если КонстантаМенеджер.Получить() <> КонстантаЗначение Тогда
			КонстантаМенеджер.Установить(КонстантаЗначение);
		КонецЕсли;
	КонецЕсли;
	
	Возврат КонстантаИмя;
	
КонецФункции

#КонецОбласти