&НаСервере
//Функция возвращает значение проверки условия
//_Значение = значение которое проверяем
//_ВидСравнения(строка) - Вид сравнения условия 
//_ЧтоПроверить = значение что проверить 
//------------
функция ПолучитьЗначениеУсловия(_Значение, _ВидСравнения, _ЧтоПроверить)
	возвр = ложь;
	попытка
		если _ВидСравнения = "Равно" тогда
			возвр = ?(_значение = _ЧтоПроверить, истина, ложь);
		иначеесли _ВидСравнения = "Не Равно" тогда
			возвр = ?(_значение <> _ЧтоПроверить, истина, ложь);	
			
		иначеесли _ВидСравнения = "Содержит" тогда
			ОТ = новый описаниетипов("Строка");
			если От.СодержитТип(ТипЗнч(_ЧтоПроверить)) тогда
				возвр = ?(найти(_чтоПроверить, _значение) > 0, истина, ложь);		
			конецесли;
		иначеесли _ВидСравнения = "Больше" тогда	
			возвр = ?(_ЧтоПроверить > _значение , истина, ложь);	
			
		иначеесли _ВидСравнения = "Меньше" тогда	
			возвр = ?(_ЧтоПроверить < _значение , истина, ложь);	
		конецесли;
	исключение
	конецпопытки;
	
	возврат возвр;
	
конецфункции

&НаСервере 
//Функция возвращает общую проверку по строке по всем условиям
//_Стр_МД = Строка метаданных из ТЗ найденных функцией НайтиССылки()
//_ТЗ_Усл - тз условий из формы
//возвращает истина или ложь
//------------------------------
функция ПроверитьУсловие(_Стр_МД ,_ТЗ_Усл)
	Нач = истина;
	ТУсловие = "";//переменная где копятся результаты условий с условными операторами
	//пример "истина и истина или ложь" для подстановки в запрос
	попытка
		_Ссылка = _Стр_МД[1];
		ТипОбъекта = _Стр_МД[2].полноеимя();
	исключение
		возврат ложь;
	конецпопытки;
	
	для каждого стр из _ТЗ_Усл цикл
		//если стр.Включено тогда
			//Проверим проверку
			ТП = стр.ТипОбъекта;
			ЗНЧ = стр.Значение;
			Реквизит = стр.РеквизитТекст;
			ВСравнения = стр.ВидСравнения;
			проверка = ложь;
			если ТП = "[Документы]" тогда
				//Проверим значение
				если лев(ТипОбъекта, 8) = "Документ" тогда
					//подходит
					
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, истина);
				конецесли;
				
			иначеесли 	ТП = "[Документы.Проведенные]" тогда
				если лев(ТипОбъекта, 8) = "Документ" тогда
					//подходит
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, _ссылка.проведен);
				конецесли;
			иначеесли 	ТП = "[Документы.ПометкаУдаления]" тогда
				если лев(ТипОбъекта, 8) = "Документ" тогда
					//подходит
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, _ссылка.пометкаУдаления);
				конецесли;
			иначеесли 	ТП = "[Справочники]" тогда
				если лев(ТипОбъекта, 10) = "Справочник" тогда
					//подходит
					
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, истина);
				конецесли;
			иначеесли 	ТП = "[Справочники.ПометкаУдаления]" тогда
				если лев(ТипОбъекта, 10) = "Справочник" тогда
					//подходит
					
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, _Ссылка.пометкаУдаления);
				конецесли;
			иначе
				если ТипОбъекта = ТП тогда
					проверка = ПолучитьЗначениеУсловия(Знч, ВСравнения, _Ссылка[Реквизит]);
				конецесли;
				
			конецесли;
			
			если не Нач тогда
				ТУсловие = ТУсловие + " " + стр.ТипУсловия;
			иначе
				Нач = ложь; // Уже прошли первое условие	
			конецесли;
			ТУсловие = ТУсловие + " " + ?(проверка, "истина", "ложь");
			старСтр = стр;
		//конецесли;
		
	конеццикла;
	если ТУсловие = "" тогда
		возврат ложь;
	конецесли;
	
	//Так как выполнить непозволяет проверить возхврат будем делать через запрос
	запрос = новый запрос;
	запрос.Текст = "ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА [УСЛОВИЕ]
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК Усл";
	запрос.текст = стрзаменить(запрос.текст, "[УСЛОВИЕ]", ТУсловие);
	Рез = запрос.Выполнить().Выбрать();
	Рез.Следующий();
	возврат Рез.Усл;
	
конецфункции


//Процедура находит ссылки 
//Заполняет на форме Табличное Поле
&НаСервере
Процедура СсылкиНаСервере(МассивЗаменяемых, знач ТЗ_Условий)
	ТабСсылки = НайтиПоСсылкам(МассивЗаменяемых);
	
	//Удалим из таблиц условий то что выключено
	М_УД_ТЗ_Условий = ТЗ_Условий.найтиСтроки(новый структура("Включено", ложь));
	для каждого стр из М_УД_ТЗ_Условий цикл
		ТЗ_Условий.удалить(стр);
	конеццикла;
	
	//Теперь проверим ссылки которые мы нашли на условие
	
	если ТЗ_Условий.количество() > 0 тогда
		М_Уд = новый массив;
		для каждого стр из ТабСсылки цикл
			если не ПроверитьУсловие(стр, ТЗ_Условий) тогда
				М_УД.Добавить(стр);
			конецесли;
		конеццикла;
		
		для каждого стр из М_Уд цикл
			ТабСсылки.Удалить(стр);
		конеццикла;
		
	конецесли;
	
	
	
	
	НайденныеСсылки.Загрузить(ТабСсылки);
КонецПроцедуры

&НаСервереБезКонтекста
// Возвращает объект ОписаниеТипов, содержащий указанный тип.
//
// Параметры:
//  ЗначениеТипа - строка с именем типа или значение типа Тип.
//  
// Возвращаемое значение:
//  ОписаниеТипов
//
Функция вОписаниеТипа(ЗначениеТипа)
	
	МассивТипов = Новый Массив;
	Если ТипЗнч(ЗначениеТипа) = Тип("Строка") Тогда
		МассивТипов.Добавить(Тип(ЗначениеТипа));
	Иначе
		МассивТипов.Добавить(ЗначениеТипа);
	КонецЕсли; 
	ОписаниеТипов	= Новый ОписаниеТипов(МассивТипов);
	
	Возврат ОписаниеТипов;
	
КонецФункции // вОписаниеТипа()

&НаКлиенте
Процедура КоманднаяПанельЗаменяемыеЗначенияНайтиСсылки(Команда)
	
	МассивЗаменяемых = Новый Массив;
	Для каждого Стр Из ЗаменяемыеЗначения Цикл
		Если Стр.Пометка Тогда
			МассивЗаменяемых.Добавить(Стр.ЧтоЗаменять);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивЗаменяемых.Количество() = 0 Тогда
		Предупреждение("Не выбрано ни одного значения для поиска!");
		Возврат;
	КонецЕсли;
	
	
	СсылкиНаСервере(МассивЗаменяемых, ФильтрПоиска);
	
	КоманднаяПанельНайденныеСсылкиВключитьВсе("");
КонецПроцедуры

&НаКлиенте
Процедура КоманднаяПанельНайденныеСсылкиВключитьВсе(Команда)
	Для Каждого Стр Из НайденныеСсылки Цикл
		Стр.Включено = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КоманднаяПанельНайденныеСсылкиВыключитьВсе(Команда)
	Для Каждого Стр Из НайденныеСсылки Цикл
		Стр.Включено = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗаменуЗначений(Команда)
	ТекстСообщения = "";
	ВыполнитьЗаменуЗначенийНаСервере();
	Если Не ПустаяСтрока(ТекстСообщения) Тогда
		Сообщить(ТекстСообщения);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СообщитьОбОшибкеПриЗаписи(Информация)
	
	Причина = ?(Информация.Причина = Неопределено, Информация, Информация.Причина);
	ТекстСообщения = ТекстСообщения + Причина.Описание + Символы.ВК + Символы.ПС;
	
КонецПроцедуры

//Заменяет значения 
//Не изменена
&НаСервере
Процедура ВыполнитьЗаменуЗначенийНаСервере()
	СписокТипов = Новый СписокЗначений;
	
	Заменяемые = Новый Соответствие;
	Для каждого Стр Из ЗаменяемыеЗначения Цикл
		Если Стр.Пометка Тогда
			Заменяемые.Вставить(Стр.ЧтоЗаменять, Стр.НаЧтоЗаменять);
			СписокТипов.Добавить(ТипЗнч(Стр.ЧтоЗаменять));
		КонецЕсли;
	КонецЦикла;
	
	ТабРегистрКлюч = Новый ТаблицаЗначений;
	ТабРегистрКлюч.Колонки.Добавить("ИмяРегистра", Новый ОписаниеТипов("Строка"));
	ТабРегистрКлюч.Колонки.Добавить("ТипКлючаЗаписи");	//, Новый ОписаниеТипов("Произвольный"));
	
	Для Каждого Регистр Из Метаданные.РегистрыСведений Цикл
		Для Каждого Измерение Из Регистр.Измерения Цикл
			Для Каждого Элемент Из СписокТипов Цикл
				Если Измерение.Тип.СодержитТип(Элемент.Значение) Тогда
					НовСтр = ТабРегистрКлюч.Добавить();
					НовСтр.ИмяРегистра = Регистр.Имя;
					НовСтр.ТипКлючаЗаписи = Тип("РегистрСведенийКлючЗаписи." + Регистр.Имя);
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		Для Каждого Ресурс Из Регистр.Ресурсы Цикл
			Для Каждого Элемент Из СписокТипов Цикл
				Если Ресурс.Тип.СодержитТип(Элемент.Значение) Тогда
					НовСтр = ТабРегистрКлюч.Добавить();
					НовСтр.ИмяРегистра = Регистр.Имя;
					НовСтр.ТипКлючаЗаписи = Тип("РегистрСведенийКлючЗаписи." + Регистр.Имя);
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		Для Каждого Реквизит Из Регистр.Реквизиты Цикл
			Для Каждого Элемент Из СписокТипов Цикл
				Если Реквизит.Тип.СодержитТип(Элемент.Значение) Тогда
					НовСтр = ТабРегистрКлюч.Добавить();
					НовСтр.ИмяРегистра = Регистр.Имя;
					НовСтр.ТипКлючаЗаписи = Тип("РегистрСведенийКлючЗаписи." + Регистр.Имя);
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	БылиИсключения = Ложь;
	Если ВыполнятьВТранзакции Тогда
		НачатьТранзакцию();
	КонецЕсли;
	ОбрабатываемаяСсылка = Неопределено;
	
	Параметры1 = Новый Структура;
	
	Для Каждого РегистрБухгалтерии ИЗ Метаданные.РегистрыБухгалтерии Цикл
		Параметры1.Вставить(РегистрБухгалтерии.Имя+"Субконто", РегистрБухгалтерии.ПланСчетов.МаксКоличествоСубконто);
		Параметры1.Вставить(РегистрБухгалтерии.Имя+"Корреспонденция", РегистрБухгалтерии.Корреспонденция);		
	КонецЦикла;
	
	Параметры1.Вставить("Объект", Неопределено);	
	
	Для Каждого СтрокаТаблицы Из НайденныеСсылки Цикл
		Если Не СтрокаТаблицы.Включено Тогда
			Продолжить;
		КонецЕсли;
		ПравильныйЭлемент = Заменяемые[СтрокаТаблицы.Ссылка];
		
		Ссылка = СтрокаТаблицы.Ссылка;
		
		Если ОбрабатываемаяСсылка <> СтрокаТаблицы.Данные Тогда
			Если ОбрабатываемаяСсылка <> Неопределено и Параметры1.Объект <> Неопределено Тогда
				
				Если ОтключатьКонтрольЗаписи Тогда
					Параметры1.Объект.ОбменДанными.Загрузка = Истина;
				КонецЕсли;
				
				Попытка
					Параметры1.Объект.Записать();
				Исключение
					СообщитьОбОшибкеПриЗаписи(ИнформацияОбОшибке());
					БылиИсключения = Истина;
					Если ВыполнятьВТранзакции Тогда
						Перейти ~ОТКАТ;
					КонецЕсли;
				КонецПопытки;
				Параметры1.Объект = Неопределено;
			КонецЕсли;
			ОбрабатываемаяСсылка = СтрокаТаблицы.Данные;
			
		КонецЕсли;
		
		// Если тип данных "Регистр сведений ключ записи", то метод Метаданные() отсутствует
		СтрРегистра = ТабРегистрКлюч.Найти(ТипЗнч(СтрокаТаблицы.Данные), "ТипКлючаЗаписи");
		Если СтрРегистра = Неопределено Тогда
			ТекущиеМетаданные = СтрокаТаблицы.Данные.Метаданные();
		Иначе
			ТекущиеМетаданные = Метаданные.РегистрыСведений[СокрЛП(СтрРегистра.ИмяРегистра)];
		КонецЕсли;
		Если Метаданные.Документы.Содержит(ТекущиеМетаданные) Тогда
			
			Если Параметры1.Объект = Неопределено Тогда
				Параметры1.Объект = СтрокаТаблицы.Данные.ПолучитьОбъект();
			КонецЕсли;
			
			Для Каждого Реквизит Из ТекущиеМетаданные.Реквизиты Цикл
				Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) И Параметры1.Объект[Реквизит.Имя] = Ссылка Тогда
					Параметры1.Объект[Реквизит.Имя] = ПравильныйЭлемент;
				КонецЕсли;
			КонецЦикла;
			
			Для Каждого ТЧ ИЗ ТекущиеМетаданные.ТабличныеЧасти Цикл
				Для Каждого Реквизит Из ТЧ.Реквизиты Цикл
					Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
						СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						Пока СтрокаТабЧасти <> Неопределено Цикл
							СтрокаТабЧасти[Реквизит.Имя] = ПравильныйЭлемент;
							СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			
			Для Каждого Движение ИЗ ТекущиеМетаданные.Движения Цикл
				
				ЭтоДвижениеРегистраБухгалтерии = Метаданные.РегистрыБухгалтерии.Содержит(Движение);
				ЕстьКорреспонденция = ЭтоДвижениеРегистраБухгалтерии и Параметры1[Движение.Имя + "Корреспонденция"];
				
				НаборЗаписей  = Параметры1.Объект.Движения[Движение.Имя];
				НаборЗаписей.Прочитать();
				НадоЗаписывать = Ложь;
				ТаблицаНабора = НаборЗаписей.Выгрузить();
				
				Если ТаблицаНабора.Количество() = 0 Тогда
					Продолжить;
				КонецЕсли;
				
				масИменКолонок = Новый Массив;
				
				// Получим имена измерений, которые могут содержать ссылку
				Для Каждого Измерение ИЗ Движение.Измерения Цикл
					
					Если Измерение.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
						
						Если ЭтоДвижениеРегистраБухгалтерии Тогда
							
							Если Измерение.ПризнакУчета <> Неопределено Тогда
								
								масИменКолонок.Добавить(Измерение.Имя + "Дт");
								масИменКолонок.Добавить(Измерение.Имя + "Кт");
								
							Иначе
								масИменКолонок.Добавить(Измерение.Имя);
							КонецЕсли;
							
						Иначе
							масИменКолонок.Добавить(Измерение.Имя);
						КонецЕсли;
						
					КонецЕсли;
					
				КонецЦикла;
				
				// Получим имена ресурсов, которые могут содержать ссылку
				Если Метаданные.РегистрыСведений.Содержит(Движение) Тогда
					Для Каждого Ресурс ИЗ Движение.Ресурсы Цикл
						Если Ресурс.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
							масИменКолонок.Добавить(Ресурс.Имя);
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
				
				// Получим имена ресурсов, которые могут содержать ссылку
				Для Каждого Реквизит ИЗ Движение.Реквизиты Цикл
					Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
						масИменКолонок.Добавить(Реквизит.Имя);
					КонецЕсли;
				КонецЦикла;
				
				// Произведем замены в таблице
				Для Каждого ИмяКолонки Из масИменКолонок Цикл
					СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, ИмяКолонки);
					Пока СтрокаТабЧасти <> Неопределено Цикл
						СтрокаТабЧасти[ИмяКолонки] = ПравильныйЭлемент;
						НадоЗаписывать = Истина;
						СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, ИмяКолонки);
					КонецЦикла;
				КонецЦикла;
				
				Если Метаданные.РегистрыБухгалтерии.Содержит(Движение) Тогда
					
					Для ИндексСубконто = 1 по Параметры1[Движение.Имя + "Субконто"] Цикл
						Если ЕстьКорреспонденция Тогда
							СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "СубконтоДт"+ИндексСубконто);
							Пока СтрокаТабЧасти <> Неопределено Цикл
								СтрокаТабЧасти["СубконтоДт"+ИндексСубконто] = ПравильныйЭлемент;
								НадоЗаписывать = Истина;
								СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "СубконтоДт"+ИндексСубконто);
							КонецЦикла;
							СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "СубконтоКт"+ИндексСубконто);
							Пока СтрокаТабЧасти <> Неопределено Цикл
								СтрокаТабЧасти["СубконтоКт"+ИндексСубконто] = ПравильныйЭлемент;
								НадоЗаписывать = Истина;
								СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "СубконтоКт"+ИндексСубконто);
							КонецЦикла;								
						Иначе							
							СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "Субконто"+ИндексСубконто);
							Пока СтрокаТабЧасти <> Неопределено Цикл
								СтрокаТабЧасти["Субконто"+ИндексСубконто] = ПравильныйЭлемент;
								НадоЗаписывать = Истина;
								СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "Субконто"+ИндексСубконто);
							КонецЦикла;							
						КонецЕсли;						
					КонецЦикла;
					
					Если Ссылка.Метаданные() = Движение.ПланСчетов Тогда
						Для Каждого СтрокаТабЧасти Из ТаблицаНабора Цикл
							Если ЕстьКорреспонденция Тогда
								Если СтрокаТабЧасти.СчетДт = Ссылка Тогда
									СтрокаТабЧасти.СчетДт = ПравильныйЭлемент;
									НадоЗаписывать = Истина;
								КонецЕсли;
								Если СтрокаТабЧасти.СчетКт = Ссылка Тогда
									СтрокаТабЧасти.СчетКт = ПравильныйЭлемент;
									НадоЗаписывать = Истина;
								КонецЕсли;
							Иначе
								Если СтрокаТабЧасти.Счет = Ссылка Тогда
									СтрокаТабЧасти.Счет = ПравильныйЭлемент;
									НадоЗаписывать = Истина;
								КонецЕсли;
							КонецЕсли;
						КонецЦикла;
					КонецЕсли;
				КонецЕсли;
				
				Если Метаданные.РегистрыРасчета.Содержит(Движение) Тогда
					СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "ВидРасчета");
					Пока СтрокаТабЧасти <> Неопределено Цикл
						СтрокаТабЧасти["ВидРасчета"] = ПравильныйЭлемент;
						НадоЗаписывать = Истина;
						СтрокаТабЧасти = ТаблицаНабора.Найти(Ссылка, "ВидРасчета");
					КонецЦикла;
				КонецЕсли;
				
				Если НадоЗаписывать Тогда
					НаборЗаписей.Загрузить(ТаблицаНабора);
					Если ОтключатьКонтрольЗаписи Тогда
						НаборЗаписей.ОбменДанными.Загрузка = Истина;
					КонецЕсли;
					Попытка
						НаборЗаписей.Записать();
					Исключение
						СообщитьОбОшибкеПриЗаписи(ИнформацияОбОшибке());
						БылиИсключения = Истина;
						Если ВыполнятьВТранзакции Тогда
							Перейти ~ОТКАТ;
						КонецЕсли;
					КонецПопытки;
				КонецЕсли;
			КонецЦикла;
			
			
			Для Каждого Последовательность ИЗ Метаданные.Последовательности Цикл
				Если Последовательность.Документы.Содержит(ТекущиеМетаданные) Тогда
					НадоЗаписывать = Ложь;
					НаборЗаписи = Последовательности[Последовательность.Имя].СоздатьНаборЗаписей();
					НаборЗаписи.Отбор.Регистратор.Установить(СтрокаТаблицы.Данные);
					НаборЗаписи.Прочитать();
					
					Если НаборЗаписи.Количество() > 0 Тогда
						Для Каждого Измерение ИЗ Последовательность.Измерения Цикл
							Если Измерение.Тип.СодержитТип(ТипЗнч(Ссылка)) И НаборЗаписи[0][Измерение.Имя]=Ссылка Тогда
								НаборЗаписи[0][Измерение.Имя] = ПравильныйЭлемент;
								НадоЗаписывать = Истина;
							КонецЕсли;
						КонецЦикла;					
						Если НадоЗаписывать Тогда
							Если ОтключатьКонтрольЗаписи Тогда
								НаборЗаписи.ОбменДанными.Загрузка = Истина;
							КонецЕсли;
							Попытка
								НаборЗаписи.Записать();
							Исключение
								СообщитьОбОшибкеПриЗаписи(ИнформацияОбОшибке());
								БылиИсключения = Истина;
								Если ВыполнятьВТранзакции Тогда
									Перейти ~ОТКАТ;
								КонецЕсли;
							КонецПопытки;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			
			
			
		ИначеЕсли Метаданные.Справочники.Содержит(ТекущиеМетаданные) Тогда
			
			Если Параметры1.Объект = Неопределено Тогда
				Параметры1.Объект = СтрокаТаблицы.Данные.ПолучитьОбъект();
			КонецЕсли;
			
			Если ТекущиеМетаданные.Владельцы.Содержит(Ссылка.Метаданные()) И Параметры1.Объект.Владелец = Ссылка Тогда
				Параметры1.Объект.Владелец = ПравильныйЭлемент;
			КонецЕсли;
			
			Если ТекущиеМетаданные.Иерархический И Параметры1.Объект.Родитель = Ссылка Тогда
				Параметры1.Объект.Родитель = ПравильныйЭлемент;
			КонецЕсли;
			
			Для Каждого Реквизит Из ТекущиеМетаданные.Реквизиты Цикл
				Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) И Параметры1.Объект[Реквизит.Имя] = Ссылка Тогда
					Параметры1.Объект[Реквизит.Имя] = ПравильныйЭлемент;
				КонецЕсли;
			КонецЦикла;
			
			Для Каждого ТЧ ИЗ ТекущиеМетаданные.ТабличныеЧасти Цикл
				Для Каждого Реквизит Из ТЧ.Реквизиты Цикл
					Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
						СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						Пока СтрокаТабЧасти <> Неопределено Цикл
							СтрокаТабЧасти[Реквизит.Имя] = ПравильныйЭлемент;
							СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			
		ИначеЕсли Метаданные.ПланыВидовХарактеристик.Содержит(ТекущиеМетаданные)
			ИЛИ Метаданные.ПланыСчетов.Содержит(ТекущиеМетаданные)
			ИЛИ Метаданные.ПланыВидовРасчета.Содержит(ТекущиеМетаданные)
			ИЛИ Метаданные.Задачи.Содержит(ТекущиеМетаданные)
			ИЛИ Метаданные.БизнесПроцессы.Содержит(ТекущиеМетаданные) Тогда
			
			Если Параметры1.Объект = Неопределено Тогда
				Параметры1.Объект = СтрокаТаблицы.Данные.ПолучитьОбъект();
			КонецЕсли;
			
			Для Каждого Реквизит Из ТекущиеМетаданные.Реквизиты Цикл
				Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) И Параметры1.Объект[Реквизит.Имя] = Ссылка Тогда
					Параметры1.Объект[Реквизит.Имя] = ПравильныйЭлемент;
				КонецЕсли;
			КонецЦикла;
			
			Для Каждого ТЧ ИЗ ТекущиеМетаданные.ТабличныеЧасти Цикл
				Для Каждого Реквизит Из ТЧ.Реквизиты Цикл
					Если Реквизит.Тип.СодержитТип(ТипЗнч(Ссылка)) Тогда
						СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						Пока СтрокаТабЧасти <> Неопределено Цикл
							СтрокаТабЧасти[Реквизит.Имя] = ПравильныйЭлемент;
							СтрокаТабЧасти = Параметры1.Объект[ТЧ.Имя].Найти(Ссылка, Реквизит.Имя);
						КонецЦикла;							
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;	
			
		ИначеЕсли Метаданные.Константы.Содержит(ТекущиеМетаданные) Тогда
			
			Константы[ТекущиеМетаданные.Имя].Установить(ПравильныйЭлемент);
			
			
		ИначеЕсли Метаданные.РегистрыСведений.Содержит(ТекущиеМетаданные) Тогда	
			
			СтруктураИзмерений = Новый Структура;
			НаборЗаписей = РегистрыСведений[ТекущиеМетаданные.Имя].СоздатьНаборЗаписей();
			Для Каждого Измерение ИЗ ТекущиеМетаданные.Измерения Цикл
				НаборЗаписей.Отбор[Измерение.Имя].Установить(СтрокаТаблицы.Данные[Измерение.Имя]);
				СтруктураИзмерений.Вставить(Измерение.Имя);
			КонецЦикла;
			Если ТекущиеМетаданные.ПериодичностьРегистраСведений <> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический Тогда
				НаборЗаписей.Отбор["Период"].Установить(СтрокаТаблицы.Данные.Период);
			КонецЕсли;
			НаборЗаписей.Прочитать();
			
			Если НаборЗаписей.Количество() = 0 Тогда
				Продолжить;
			КонецЕсли;
			
			ТаблицаНабора = НаборЗаписей.Выгрузить();
			НаборЗаписей.Очистить();
			
			Если ОтключатьКонтрольЗаписи Тогда
				НаборЗаписей.ОбменДанными.Загрузка = Истина;
			КонецЕсли;
			
			
			Если Не ВыполнятьВТранзакции Тогда
				НачатьТранзакцию();
			КонецЕсли;
			
			Попытка
				
				НаборЗаписей.Записать();
				
				Для Каждого Колонка ИЗ ТаблицаНабора.Колонки Цикл
					Если ТаблицаНабора[0][Колонка.Имя] = Ссылка Тогда
						ТаблицаНабора[0][Колонка.Имя] = ПравильныйЭлемент;
						Если СтруктураИзмерений.Свойство(Колонка.Имя) Тогда
							НаборЗаписей.Отбор[Колонка.Имя].Установить(ПравильныйЭлемент);
						КонецЕсли;
						
					КонецЕсли;
				КонецЦикла;
				
				НаборЗаписей.Загрузить(ТаблицаНабора);
				
				НаборЗаписей.Записать();
				
				Если Не ВыполнятьВТранзакции Тогда
					ЗафиксироватьТранзакцию();
				КонецЕсли; 
				
			Исключение
				
				СообщитьОбОшибкеПриЗаписи(ИнформацияОбОшибке());
				
				Если ВыполнятьВТранзакции Тогда
					БылиИсключения = Истина;
					Перейти ~ОТКАТ;
				Иначе
					ОтменитьТранзакцию();
				КонецЕсли;
				
			КонецПопытки;
			
		Иначе
			Сообщить("Ссылки типа "+ТекущиеМетаданные+" не заменяются!!");
		КонецЕсли;
		//***//ОбработкаПрерыванияПользователя();
	КонецЦикла;
	
	Если Параметры1.Объект <> Неопределено Тогда
		Если ОтключатьКонтрольЗаписи Тогда
			Параметры1.Объект.ОбменДанными.Загрузка = Истина;
		КонецЕсли;
		Попытка
			Параметры1.Объект.Записать();
		Исключение
			СообщитьОбОшибкеПриЗаписи(ИнформацияОбОшибке());
			БылиИсключения = Истина;
			Если ВыполнятьВТранзакции Тогда
				Перейти ~ОТКАТ;
			КонецЕсли;
		КонецПопытки;
	КонецЕсли;
	
	~ОТКАТ:
	Если ВыполнятьВТранзакции Тогда
		Если БылиИсключения Тогда
			ОтменитьТранзакцию();
		Иначе
			ЗафиксироватьТранзакцию();
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаменяемыеЗначенияЧтоЗаменятьПриИзменении(Элемент)
	Элементы.ЗаменяемыеЗначения.ТекущиеДанные.Пометка = Истина;
КонецПроцедуры

//Заполнить список для поля типОбъекта
&НаСервере 
функция ЗаполнитьТипыОбъектов(_Список)
	//глТипыОбъектов = этотобъект.Параметры.ТипыОбъектов;
	//глТипыОбъектов = новый СписокЗначений;
	_Список.Добавить("[Документы]", "Только документы");
	_Список.Добавить("[Документы.Проведенные]", "Только Проведенные документы");
	_Список.Добавить("[Документы.ПометкаУдаления]", "Только Помеченные на удаления документы");
	_Список.Добавить("[Справочники]", "Только Справочники");
	_Список.Добавить("[Справочники.ПометкаУдаления]", "Только Помеченные на удаления справочники");
	
	//Теперь получим документы
	для каждого стр из метаданные.Документы цикл
		_Список.Добавить("Документ." + стр.имя, "Документ " + стр.Синоним);
	конеццикла;
	
	//Теперь получим справочники
	для каждого стр из метаданные.Справочники цикл
		_Список.Добавить("Справочник." + стр.имя, "Справоник " + стр.Синоним);
	конеццикла;
КонецФункции

//Полкучить МетаданныеОбъекта для реквизитов
&НаСервере
Функция ПолучитьМД(_Объект)
	если лев(_Объект, 1) = "[" тогда 
		возвр = Неопределено;
		//Служебный тип
	иначе
		//Это объекты или справочник или документ
		если Лев(_Объект, 8) =  "Документ" тогда
			Об = прав(_Объект, СтрДлина(_Объект) - 9);
			Возвр = метаданные.Документы[Об];
		иначе
			Об = прав(_Объект, СтрДлина(_Объект) - 11);
			Возвр = метаданные.Справочники[Об];
		конецесли;
		
	конецесли;
	возврат Возвр; 
конецфункции


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//Заполнис список типов
	ЗаполнитьТипыОбъектов(Элементы.гПараметрыПоиска.ПодчиненныеЭлементы.ФильтрПоиска.ПодчиненныеЭлементы.ФильтрПоискаТипОбъекта.СписокВыбора);
КонецПроцедуры


//Заполним список реквизитов в зависимости от типа объекта
&НаСервере
функция ПолучитьРеквизитыОбъекта(_Объект, _Список)
	//_список = новый СписокЗначений;
	_список.Очистить();
	если лев(_Объект, 1) = "[" тогда 
		//Это служебный
		_список.Добавить("[<--]", "<--");
	иначе
		
		МД = ПолучитьМД(_Объект);
		МД_Реквизиты = МД.Реквизиты;
		//МД_Реквизиты = метаданные.Документы.АвансовыйОтчет.Реквизиты;
		для каждого стр из МД_Реквизиты цикл
			_список.Добавить(стр.имя, стр.синоним);
		конеццикла;
		МД_Реквизиты = МД.стандартныеРеквизиты;
		для каждого стр из МД_Реквизиты цикл
			
			_список.Добавить(стр.имя, стр.синоним);
		конеццикла;
		
		
	конецесли
конецфункции

&НаКлиенте
Процедура ФильтрПоискаРеквизитТекстНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	тс = элементы.ФильтрПоиска.ТекущаяСтрока;
	если тс <> Неопределено тогда
		стр = ФильтрПоиска.НайтиПоИдентификатору(тс);
		//Загрузим список реквизитов
		_список = новый СписокЗначений;
		
		ПолучитьРеквизитыОбъекта(стр.ТипОбъекта, _список);
		Элементы.ФильтрПоискаРеквизитТекст.списокВыбора.ЗагрузитьЗначения(_список.ВыгрузитьЗначения());
		
		если _список.Количество() = 0 тогда
			стр.РеквизитТекст = "";
		конецесли;
		
	конецесли;
КонецПроцедуры

&НаКлиенте 
Функция ПолучитьТекущуюСтроку(_Элемент, _ТЧ)
	Тс = _ТЧ.НайтиПоИдентификатору(_Элемент.ТекущаяСтрока);
	
	возврат Тс;
	
	
	
конецфункции

//Проверить соответствует ли значение выбранному типу
&НаСервере 
Функция ЗначениеНеСоответствуетТипу(_Значения, _ОписаниеТипов)
	_ОписаниеТипов = новый ОписаниеТипов;
	
	если _ОписаниеТипов.СодержитТип(ТипЗнч(_Значения)) тогда 
		возвр =  ложь;
	иначе
		возвр = истина;
	конецесли;
	возврат возвр;
	
конецфункции


&НаКлиенте
Процедура ФильтрПоискаРеквизитТекстПриИзменении(Элемент)
	//Получим строку текущую
	Стр = ПолучитьТекущуюСтроку(Элементы.ФильтрПоиска, ФильтрПоиска);
	//Установим тип реквизита
	Стр.РеквизитТип =  ФильтрПоискаРеквизитТекстПриИзмененииНаСервере(Стр.ТипОбъекта, Стр.РеквизитТекст);
	элементы.ФильтрПоиска.ПодчиненныеЭлементы.ФильтрПоискаЗначение.ОграничениеТипа = Стр.РеквизитТип;
	элементы.ФильтрПоиска.ПодчиненныеЭлементы.ФильтрПоискаЗначение.ВыбиратьТип=Истина;
	// Уберем значение если оно было из другого типа
	если ЗначениеНеСоответствуетТипу(стр.Значение, Стр.РеквизитТип) тогда
		стр.Значение = Неопределено;
	конецесли;
	
КонецПроцедуры

Функция ПолучитьТипОбъекта(_МД, _ИмяРеквизита)
	если ЗначениеЗаполнено(_ИмяРеквизита) тогда 
		попытка
			возвр =  _МД.Реквизиты[_ИмяРеквизита].Тип;
		исключение
			возвр = _МД.СтандартныеРеквизиты[_ИмяРеквизита].Тип;
		конецпопытки
	иначе
		возвр = неопределено;
	конецесли;
	возврат возвр;
	
конецфункции


//Функция получает тип реквизита
//_ТипОбъекта(строка) - Тип объекта
//_РеквизитТекст(строка) - Имя реквизита 
//Возвращает описание типов
&НаСервере
функция ФильтрПоискаРеквизитТекстПриИзмененииНаСервере(_ТипОбъекта, _РеквизитТекст)
	//Теперь пропишем описание типов в колонку
	МД = ПолучитьМД(_ТипОбъекта);
	если МД <> Неопределено тогда
		возвр =  ПолучитьТипОбъекта(МД, _РеквизитТекст);
	иначе
		возвр = новый ОписаниеТипов("Булево");
	конецесли;
	возврат возвр;
Конецфункции

&НаКлиенте
Процедура ФильтрПоискаТипОбъектаПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтроку(Элементы.ФильтрПоиска, ФильтрПоиска);
	Стр.РеквизитТекст = "";
	стр.РеквизитТип = Неопределено;
	стр.Значение = Неопределено;

КонецПроцедуры
