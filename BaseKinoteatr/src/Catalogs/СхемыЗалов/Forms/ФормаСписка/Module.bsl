
&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	ВыводСхемыЗала();
КонецПроцедуры

&НаСервере
Процедура ВыводСхемыЗала()
	//очистка поля табличного документа "СхемаКинозала"
	СхемаЗала.Очистить();
	//определяем текущую строку в справочнике "СхемыЗалов"
	текСхема = Элементы.Список.ТекущаяСтрока;
	Если текСхема <> Неопределено Тогда
		//получаем схему из ХранилищаЗначений, если она определена
		СхемаЗалаМакет = текСхема.Схема.Получить();
	КонецЕсли;
	Если СхемаЗалаМакет <> Неопределено Тогда 
		//выводим схему, полученную из ХранилищаЗначений
		СхемаЗала.Вывести(СхемаЗалаМакет);	
	КонецЕсли;
КонецПроцедуры
