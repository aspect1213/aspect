Функция ПроверитьНеобходимостьОбновленияРабочегоСтола() Экспорт
	УстановитьПривилегированныйРежим(Истина);
	НомерСеанса = НомерСеансаИнформационнойБазы();
	НужноОбновление = Ложь;
	Для Каждого Стр из ПолучитьСоединенияИнформационнойБазы()Цикл		
		Если Стр.НомерСеанса = НомерСеанса тогда
			Рег = РегистрыСведений.ОбновлениеРабочегоСтола.Получить(Новый Структура("НомерСоединения",Стр.НомерСоединения));
			НужноОбновление = Рег.ВыполнитьОбновление;
			Если НужноОбновление тогда
				НаборЗаписей = РегистрыСведений.ОбновлениеРабочегоСтола.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.НомерСоединения.Установить(Стр.НомерСоединения);	
				НаборЗаписей.Прочитать();
				НаборЗаписей.Удалить(НаборЗаписей[0]);			
				НаборЗаписей.Записать(Истина);
			КонецЕсли;	
			УстановитьПривилегированныйРежим(Ложь);
			Возврат НужноОбновление;		
		КонецЕсли;
	КонецЦикла;
	УстановитьПривилегированныйРежим(Ложь);
	Возврат НужноОбновление;		
	
КонецФункции

Процедура ЗапуститьОбновлениеРабочегоСтолаНаКлиентах() Экспорт
	УстановитьПривилегированныйРежим(Истина);
	НомерСеанса = НомерСеансаИнформационнойБазы();
	Для Каждого Стр из ПолучитьСоединенияИнформационнойБазы()Цикл		
		Если Стр.НомерСеанса = НомерСеанса тогда
			Продолжить;
		КонецЕсли;
		Если Лев(Стр.ИмяПриложения,4) = "1CV8" тогда
			 Мен = РегистрыСведений.ОбновлениеРабочегоСтола.СоздатьМенеджерЗаписи();
			 Мен.ВыполнитьОбновление = Истина;
			 Мен.НомерСоединения = Стр.НомерСоединения;
			 Мен.Записать(Истина);
		КонецЕсли;
	КонецЦикла;
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры


Процедура ПриНачалеРаботыСистемы() Экспорт
	НомерВерсии = Константы.НомерВерсии.Получить();
	Если НЕ ЗначениеЗаполнено(НомерВерсии) тогда // первый запуск
		Спр = Справочники.Исполнители.ОсновнойИсполнитель.ПолучитьОбъект();
		Спр.РежимОтправкиУведомлений = Перечисления.РежимыОтправкиУведомлений.Никогда;
		Спр.ПоУмолчанию = Истина;
		Спр.Записать();
		
		Константы.НомерВерсии.Установить(Метаданные.Версия);
	КонецЕсли;
КонецПроцедуры

