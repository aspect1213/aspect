&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтаФорма.АвтоОтображениеСостояния = РежимАвтоОтображенияСостояния.НеОтображать;
	ЭтотОбъект.СкомпоноватьРезультат();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьОтчет(Команда)
	
	ЭтаФорма.АвтоОтображениеСостояния = РежимАвтоОтображенияСостояния.НеОтображать;
	ЭтотОбъект.СкомпоноватьРезультат();
	
КонецПроцедуры