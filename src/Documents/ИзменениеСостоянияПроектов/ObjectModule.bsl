//////////////////////////////////////////////////////////////////////////////////
//// РАЗДЕЛ ПРОЦЕДУР И ФУНКЦИЙ

// Обработка проведения.
// ................................................................................
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// очищаем все движеня
	Движения.ВремяВыполненияПроектов.Очистить();
	Движения.ВремяВыполненияПроектов.Записать();
	Движения.СостоянияПроектов.Очистить();
	Движения.СостоянияПроектов.Записать();
	Движения.СтоимостьПроектов.Очистить();
	Движения.СтоимостьПроектов.Записать();
	Движения.УП_ВремяВыполнениеПроектов_План.Очистить();
	Движения.УП_ВремяВыполнениеПроектов_План.Записать();
	Движения.УП_СостоянияПроектов.Очистить();
	Движения.УП_СостоянияПроектов.Записать();
	Движения.УП_СтоимостьПроектов.Очистить();
	Движения.УП_СтоимостьПроектов.Записать();
	
	Если ВидИзменения = Перечисления.ВидыИзмененийСостоянийПроектов.ЭтапВыполнения Тогда
		// регистр СостоянияПроектов
		// (устарело, но используется)
		Движения.СостоянияПроектов.Записывать = Истина;
		// регистр УП_СостоянияПроектов
		Движения.УП_СостоянияПроектов.Записывать = Истина;
		Для Каждого ТекСтрокаПроекты Из Проекты Цикл
			Движение            = Движения.СостоянияПроектов.Добавить();
			Движение.Период     = Дата;
			Движение.Контрагент = Контрагент;
			Движение.Проект     = ТекСтрокаПроекты.Проект;
			Движение.Состояние  = ТекСтрокаПроекты.СостояниеПроекта;
			
			ПараметрыАналитики = Новый Структура();
			ПараметрыАналитики.Вставить("Контрагент", Контрагент);
			ПараметрыАналитики.Вставить("Клиент"    , ТекСтрокаПроекты.Клиент);
			ПараметрыАналитики.Вставить("Проект"    , ТекСтрокаПроекты.Проект);
			Движение                              = Движения.УП_СостоянияПроектов.Добавить();
			Движение.Период                       = Дата;
			Движение.АналитикаУчетаПоКонтрагентам = УП_РаботаСДокументамиСервер.ЗначениеКлючаАналитики(ПараметрыАналитики);
			Движение.Состояние                    = ТекСтрокаПроекты.СостояниеПроекта;
		КонецЦикла;
	ИначеЕсли ВидИзменения = Перечисления.ВидыИзмененийСостоянийПроектов.ВремяВыполнения Тогда
		// регистр ВремяВыполненияПроектов
		// (устарело, но используется)
		Движения.ВремяВыполненияПроектов.Записывать = Истина;
		// регистр СтоимостьПроектов
		// (устарело, но используется)
		Движения.СтоимостьПроектов.Записывать = Истина;
		
		// регистр УП_СтоимостьПроектов
		Движения.УП_СтоимостьПроектов.Записывать = Истина;
		// регистр УП_ВремяВыполнениеПроектов_План
		Движения.УП_ВремяВыполнениеПроектов_План.Записывать = Истина;
		Для Каждого ТекСтрокаПроекты Из Проекты Цикл
			Движение                      = Движения.ВремяВыполненияПроектов.Добавить();
			Движение.РегистраторСсылка    = Ссылка;
			Движение.Контрагент           = Контрагент;
			Движение.Проект               = ТекСтрокаПроекты.Проект;
			Движение.ВремяВыполнения_План = УП_ОбщегоНазначения_Сервер.ПреобразоватьВремя(ТекСтрокаПроекты.ВремяВыполнения);
			Движение.ВремяВыполнения_Факт = 0;
			
			Движение                          = Движения.СтоимостьПроектов.Добавить();
			Движение.Период                   = Дата;
			Движение.Контрагент               = Контрагент;
			Движение.ВалютаПроекта            = ТекСтрокаПроекты.Валюта;
			Движение.ВалютаУчета              = Константы.ВалютаУчета.Получить();
			Движение.Проект                   = ТекСтрокаПроекты.Проект;
			Движение.СуммаПроекта             = ТекСтрокаПроекты.Сумма;
			Движение.СуммаПроектаВВалютеУчета = ТекСтрокаПроекты.Сумма*УП_ОбщегоНазначения_Сервер.ПолучитьАктуальныйКурсВалюты(Дата, ТекСтрокаПроекты.Валюта);
			
			
			ПараметрыАналитики = Новый Структура();
			ПараметрыАналитики.Вставить("Контрагент", Контрагент);
			ПараметрыАналитики.Вставить("Клиент"    , ТекСтрокаПроекты.Клиент);
			ПараметрыАналитики.Вставить("Проект"    , ТекСтрокаПроекты.Проект);
			АналитикаУчетаПоКонтрагентам = УП_РаботаСДокументамиСервер.ЗначениеКлючаАналитики(ПараметрыАналитики);
			
			Движение                              = Движения.УП_СтоимостьПроектов.Добавить();
			Движение.Период                       = Дата;
			Движение.АналитикаУчетаПоКонтрагентам = АналитикаУчетаПоКонтрагентам;
			Движение.Валюта                       = ТекСтрокаПроекты.Валюта;
			Движение.Сумма                        = УП_РаботаСДокументамиСервер.ПолучитьПлановуюТекущуюСтоимостьПроекта(Дата - 1, АналитикаУчетаПоКонтрагентам) + ТекСтрокаПроекты.Сумма;
			
			Движение                              = Движения.УП_ВремяВыполнениеПроектов_План.Добавить();
			Движение.Период                       = Дата;
			Движение.АналитикаУчетаПоКонтрагентам = АналитикаУчетаПоКонтрагентам;
			ТекущееВремяВыполнения    = УП_РаботаСДокументамиСервер.ПолучитьТекущееВремяВыполнения(Дата - 1, АналитикаУчетаПоКонтрагентам);
			ИзмененноеВремяВыполнения = УП_ОбщегоНазначения_Сервер.ПреобразоватьВремя(ТекСтрокаПроекты.ВремяВыполнения);
			Движение.ВремяВыполнения              = ТекущееВремяВыполнения + ИзмененноеВремяВыполнения;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры