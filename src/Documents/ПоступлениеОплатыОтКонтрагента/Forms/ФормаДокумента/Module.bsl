&НаСервере
Процедура ОбработкаВыбораНаСервере(ВыбранноеЗначение)
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	Для каждого ТекСтрока Из ВыбранноеЗначение.Корзина Цикл
		ПараметрыОтбора = Новый Структура;
		ПараметрыОтбора.Вставить("Клиент", ТекСтрока.Клиент);
		ПараметрыОтбора.Вставить("Проект", ТекСтрока.Проект);
		НайденныеСтроки = ДокументОбъект.Проекты.НайтиСтроки(ПараметрыОтбора);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока        = ДокументОбъект.Проекты.Добавить();
			НоваяСтрока.Клиент = ТекСтрока.Клиент;
			НоваяСтрока.Проект = ТекСтрока.Проект;
			НоваяСтрока.Валюта = Константы.ВалютаУчета.Получить();
			
			ПараметрыАналитики = Новый Структура();
			ПараметрыАналитики.Вставить("Контрагент", Объект.Контрагент);
			ПараметрыАналитики.Вставить("Клиент"    , ТекСтрока.Клиент);
			ПараметрыАналитики.Вставить("Проект"    , ТекСтрока.Проект);
			АналитикаУчетаПоКонтрагентам = УП_РаботаСДокументамиСервер.ЗначениеКлючаАналитики(ПараметрыАналитики);
			НоваяСтрока.Сумма  = УП_РаботаСДокументамиСервер.ПолучитьТекущуюСтоимостьПроекта(Объект.Дата, АналитикаУчетаПоКонтрагентам);
		КонецЕсли;
	КонецЦикла;
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УП_РаботаСДокументамиСервер.Документ_ПриСозданииНаСервере(РеквизитФормыВЗначение("Объект"), ЭтотОбъект.Объект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	СуммаДляРаспределения = Объект.СуммаДокумента;
	Если ЗначениеЗаполнено(Объект.Контрагент) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	УП_РасчетыСКонтрагентамиОстатки.АналитикаУчетаПоКонтрагентам.Клиент КАК Клиент,
		|	УП_РасчетыСКонтрагентамиОстатки.АналитикаУчетаПоКонтрагентам.Проект КАК Проект,
		|	УП_РасчетыСКонтрагентамиОстатки.Валюта,
		|	УП_РасчетыСКонтрагентамиОстатки.СуммаОстаток
		|ИЗ
		|	РегистрНакопления.УП_РасчетыСКонтрагентами.Остатки(&ДатаОстатков, АналитикаУчетаПоКонтрагентам.Контрагент = &Контрагент) КАК УП_РасчетыСКонтрагентамиОстатки
		|ГДЕ
		|	УП_РасчетыСКонтрагентамиОстатки.СуммаОстаток > 0";
		Запрос.УстановитьПараметр("ДатаОстатков", Объект.Дата-1);
		Запрос.УстановитьПараметр("Контрагент"  , Объект.Контрагент);
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		Объект.Проекты.Очистить();
		Пока Выборка.Следующий() И СуммаДляРаспределения > 0 Цикл
			ПолученнаяСумма = Мин(Выборка.СуммаОстаток, СуммаДляРаспределения);
			НоваяСтрока       = Объект.Проекты.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
			НоваяСтрока.Сумма = ПолученнаяСумма;
			СуммаДляРаспределения = СуммаДляРаспределения - ПолученнаяСумма;
		КонецЦикла;
		Если СуммаДляРаспределения > 0 Тогда
			// предоплата. Кидаем на основного клиента.
			НоваяСтрока           = Объект.Проекты.Добавить();
			ЗапросКлиента = Новый Запрос;
			ЗапросКлиента.Текст =
			"ВЫБРАТЬ
			|	Клиенты.Ссылка
			|ИЗ
			|	Справочник.Клиенты КАК Клиенты
			|ГДЕ
			|	Клиенты.Контрагент = &Контрагент
			|	И Клиенты.Основной";
			ЗапросКлиента.УстановитьПараметр("Наименование", Строка(Объект.Контрагент));
			ЗапросКлиента.УстановитьПараметр("Контрагент"  , Объект.Контрагент);
			ВыборкаКлиентов = ЗапросКлиента.Выполнить().Выбрать();
			ВыборкаКлиентов.Следующий();
			НоваяСтрока.Клиент    = ВыборкаКлиентов.Ссылка;
			НоваяСтрока.Валюта    = Константы.ВалютаУчета.Получить();
			НоваяСтрока.Сумма     = СуммаДляРаспределения;
			СуммаДляРаспределения = 0;
		КонецЕсли;
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Перед заполнением необходимо указать контрагента";
		Сообщение.Поле = "Объект.Контрагент";
		Сообщение.УстановитьДанные(Объект);
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	
	//Если СуммуДокументаОтличаетсяНаСервере() Тогда
	ЗаполнитьНаСервере();
	//КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СуммуДокументаОтличаетсяНаСервере()
	
	Если НЕ Объект.Ссылка.СуммаДокумента = Объект.СуммаДокумента Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	ОбработкаВыбораНаСервере(ВыбранноеЗначение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодборПроектов(Команда)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДатаДокумента", Объект.Дата);
	ПараметрыФормы.Вставить("Контрагент"   , Объект.Контрагент);
	
	ПараметрЗаголовок = НСтр("ru = 'Подбор проектов в %Документ%'");
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ПараметрЗаголовок = СтрЗаменить(ПараметрЗаголовок, "%Документ%", Объект.Ссылка);
	Иначе
		ПараметрЗаголовок = СтрЗаменить(ПараметрЗаголовок, "%Документ%", НСтр("ru = 'поступление оплаты от контрагента'"));
	КонецЕсли;
	ПараметрыФормы.Вставить("Заголовок", ПараметрЗаголовок);
	
	ОткрытьФорму("Обработка.ПодборПроектов.Форма", ПараметрыФормы, ЭтаФорма, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УП_РаботаСДокументамиКлиент.Документ_ПриОткрытии(Объект, Элементы);
	
КонецПроцедуры