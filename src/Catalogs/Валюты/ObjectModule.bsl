#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РасчетПоФормуле Тогда
		ТекстЗапроса =
		"ВЫБРАТЬ
		|	Валюты.Наименование КАК СимвольныйКод
		|ИЗ
		|	Справочник.Валюты КАК Валюты
		|ГДЕ
		|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Валюты.Наименование
		|ИЗ
		|	Справочник.Валюты КАК Валюты
		|ГДЕ
		|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.РасчетПоФормуле)";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		ЗависимыеВалюты = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("СимвольныйКод");
		
		Для Каждого Валюта Из ЗависимыеВалюты Цикл
			Если СтрНайти(ФормулаРасчетаКурса, Валюта) > 0 Тогда
				Отказ = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОсновнаяВалюта.ОсновнаяВалюта) Тогда
		Отказ = Истина;
	КонецЕсли;
	
	Если Отказ Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Курс валюты можно связать только с курсом независимой валюты.'"));
	КонецЕсли;
	
	Если СпособУстановкиКурса <> Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты Тогда
		ИсключаемыеРеквизиты = Новый Массив;
		ИсключаемыеРеквизиты.Добавить("ОсновнаяВалюта");
		ИсключаемыеРеквизиты.Добавить("Наценка");
		ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, ИсключаемыеРеквизиты);
	КонецЕсли;
	
	Если СпособУстановкиКурса <> Перечисления.СпособыУстановкиКурсаВалюты.РасчетПоФормуле Тогда
		ИсключаемыеРеквизиты = Новый Массив;
		ИсключаемыеРеквизиты.Добавить("ФормулаРасчетаКурса");
		ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, ИсключаемыеРеквизиты);
	КонецЕсли;
	
	Если Не ЭтоНовый()
		И СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты
		И РаботаСКурсамиВалют.СписокЗависимыхВалют(Ссылка).Количество() > 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru = 'Валюта не может быть подчиненной, так как она является основной для других валют.'"));
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	РаботаСКурсамиВалют.ПроверитьКорректностьКурсаНа01_01_1980(Ссылка);
	
	Если ДополнительныеСвойства.Свойство("ОбновитьКурсы") Тогда
		ПараметрыВалюты = Новый Структура;
		ПараметрыВалюты.Вставить("ОсновнаяВалюта");
		ПараметрыВалюты.Вставить("Ссылка");
		ПараметрыВалюты.Вставить("Наценка");
		ПараметрыВалюты.Вставить("ДополнительныеСвойства");
		ПараметрыВалюты.Вставить("ФормулаРасчетаКурса");
		ЗаполнитьЗначенияСвойств(ПараметрыВалюты, ЭтотОбъект);
		
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ПодчиненнаяВалюта", ПараметрыВалюты);
		ПараметрыЗадания.Вставить("СпособУстановкиКурса", СпособУстановкиКурса);
		
		ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(Новый УникальныйИдентификатор());
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Валюты");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Ссылка);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		Результат = ДлительныеОперации.ВыполнитьВФоне("РаботаСКурсамиВалют.ОбновитьКурсВалюты", ПараметрыЗадания, ПараметрыВыполнения);
		Если Результат.Статус = "Ошибка" Тогда
			ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
		КонецЕсли;
		Если ОбщегоНазначенияПовтИсп.РазделениеВключено() Тогда
			РаботаСКурсамиВалют.ПриОбновленииКурсовВалютВМоделиСервиса(ЭтотОбъект);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		ДополнительныеСвойства.Вставить("ОбновитьКурсы");
		ДополнительныеСвойства.Вставить("ЭтоНовый");
	Иначе
		ПредыдущиеЗначения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "Код,СпособУстановкиКурса,ОсновнаяВалюта,Наценка,ФормулаРасчетаКурса");
		Если (ПредыдущиеЗначения.СпособУстановкиКурса <> СпособУстановкиКурса)
			Или (СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета 
				И ПредыдущиеЗначения.Код <> Код)
			Или (СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты
				И (ПредыдущиеЗначения.ОсновнаяВалюта <> ОсновнаяВалюта Или ПредыдущиеЗначения.Наценка <> Наценка))
			Или (СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РасчетПоФормуле
				И ПредыдущиеЗначения.ФормулаРасчетаКурса <> ФормулаРасчетаКурса) Тогда
			ДополнительныеСвойства.Вставить("ОбновитьКурсы");
		КонецЕсли;
	КонецЕсли;
	
	Если СпособУстановкиКурса <> Перечисления.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты Тогда
		ОсновнаяВалюта = Справочники.Валюты.ПустаяСсылка();
		Наценка = 0;
	КонецЕсли;
	
	Если СпособУстановкиКурса <> Перечисления.СпособыУстановкиКурсаВалюты.РасчетПоФормуле Тогда
		ФормулаРасчетаКурса = "";
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
