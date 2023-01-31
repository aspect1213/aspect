#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("НазваниеРегионаДляЗагрузки") Тогда
		Элементы.Надпись.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Элементы.Надпись.Заголовок, Параметры.НазваниеРегионаДляЗагрузки);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Загрузить(Команда)
	УстановитьФлагНапоминанияОЗагрузкеКлассификатора();
	Закрыть(КодВозвратаДиалога.Да);
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	УстановитьФлагНапоминанияОЗагрузкеКлассификатора();
	Закрыть(КодВозвратаДиалога.Нет);
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьФлагНапоминанияОЗагрузкеКлассификатора()
	Если НеНапоминатьОЗагрузке Тогда
		ПараметрыПриложения.Вставить("АдресныйКлассификатор.НеЗагружатьКлассификатор", Истина);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти




