&НаКлиенте
Процедура ИзменениеФлажкаПоказатьЗаверешенные()
	
	Для каждого ТекСтрока Из Список.Отбор.Элементы Цикл
		Если ТекСтрока.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Состояние") Тогда
			ТекСтрока.Использование = НЕ ПоказыватьЗавершенные;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПоказыватьЗавершенные = Ложь;
	ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("Состояние");
	ЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
	ЭлементОтбора.ПравоеЗначение = ПолучитьСостояниеПроектов();
	ЭлементОтбора.Использование  = Ложь;
	ИзменениеФлажкаПоказатьЗаверешенные();
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьЗавершенныеПриИзменении(Элемент)
	
	ИзменениеФлажкаПоказатьЗаверешенные();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСостояниеПроектов()
	
	СписокЗначений = Новый СписокЗначений;
	СписокЗначений.Добавить(Перечисления.СостоянияПроектов.Согласован);
	СписокЗначений.Добавить(Перечисления.СостоянияПроектов.ПустаяСсылка());
	Возврат СписокЗначений;
	
КонецФункции

#КонецОбласти