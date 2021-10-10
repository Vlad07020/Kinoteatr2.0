
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Ключ.Пустая() Тогда
		Объект.КоличествоРядов = 1;
		Объект.КоличествоМестНаРяд = 1;
	КонецЕсли;
	
	Элементы.ДобавитьМесто.Доступность = Объект.ВсегоМест > 0;
	Элементы.УдалитьМесто.Доступность = Объект.ВсегоМест > 0;

	ВывестиСхемуЗала(Объект.Ссылка.Схема);
КонецПроцедуры

&НаСервере
Процедура ВывестиСхемуЗала(СхемаХранилище)
	//получаем схему из ХранилищаЗначений, если она определена
	Схема = СхемаХранилище.Получить();
    Если Схема <> Неопределено Тогда    
	   //выводим полученную схему из Хранилища Значений
		СхемаЗала.Вывести(Схема);
	КонецЕсли;
КонецПроцедуры


//&НаСервере
//Процедура УстановитьСхему(Схема)
//КонецПроцедуры

&НаКлиенте
Процедура ВыборСхемыЗала(Команда)
	ФормаВыбора = ПолучитьФорму("Справочник.СхемыЗалов.ФормаВыбора");
	выбрСхема = ФормаВыбора.ОткрытьМодально();
	Если выбрСхема <> Неопределено Тогда
		ВыборСхемыНаСервере(выбрСхема);
	КонецЕсли;
КонецПроцедуры

Процедура ВыборСхемыНаСервере(выбрСхема)
	//записываем табличный документ (Макет) в ХранилищеЗначений
	СхемаЗала.Очистить();
	ВывестиСхемуЗала(Новый ХранилищеЗначения(выбрСхема.Схема.Получить()));

	Объект.КоличествоМестНаРяд =  выбрСхема.КоличествоМестНаРяд;
	объект.КоличествоРядов = выбрСхема.КоличествоРядов;
	Объект.ВсегоМест = выбрСхема.ВсегоМест;
	Элементы.ДобавитьМесто.Доступность = Объект.ВсегоМест > 0;
	Элементы.УдалитьМесто.Доступность = Объект.ВсегоМест > 0;
КонецПроцедуры

&НаКлиенте
Процедура СформироватьЗал(Команда)
	СформироватьШаблонЗала();
	Объект.ВсегоМест = Объект.КоличествоРядов * Объект.КоличествоМестНаРяд;
	Элементы.ДобавитьМесто.Доступность = Истина;
	Элементы.УдалитьМесто.Доступность = Истина;
	Модифицированность = Истина;
КонецПроцедуры

&НаСервере
Процедура СформироватьШаблонЗала()
	СхемаЗала.Очистить();
	Макет = Справочники.СхемыЗалов.ПолучитьМакет("СхемаУниверсал");
	
	ОбластьРяд = Макет.ПолучитьОбласть("РядПусто|МестоПусто");
	СхемаЗала.Вывести(ОбластьРяд);
	ОбластьРяд = Макет.ПолучитьОбласть("РядПусто|МестоПусто");
	СхемаЗала.Вывести(ОбластьРяд);
	Для Место = 1 По Объект.КоличествоМестНаРяд Цикл
		ОбластьМесто = Макет.ПолучитьОбласть("РядПусто|Место");
		ОбластьМесто.Параметры.Значение = "М " + Место;
		СхемаЗала.Присоединить(ОбластьМесто);
	КонецЦикла;
	Для Ряд = 1  По Объект.КоличествоРядов Цикл
		ОбластьРяд = Макет.ПолучитьОбласть("Ряд|МестоПусто");
		ОбластьРяд.Параметры.Значение = "Р " + Ряд;
		СхемаЗала.Вывести(ОбластьРяд);
		Для Место = 1 По Объект.КоличествоМестНаРяд Цикл
			ОбластьМесто = Макет.ПолучитьОбласть("Ряд|Место");
			ОбластьМесто.Параметры.Значение = Место;
			ОбластьМесто.ТекущаяОбласть.ЦветФона = Новый Цвет(153, 204, 255);
			СхемаЗала.Присоединить(ОбластьМесто);
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьМесто(Команда)
	ТекущаяОбласть = Элементы.СхемаЗала.ТекущаяОбласть;
	Если Найти(ТекущаяОбласть.Имя,":") > 0 Тогда
		Сообщить("Обработка группы мест не поддерживается");
		Возврат;
	КонецЕсли;
	Если Найти(СхемаЗала.Область(2,ТекущаяОбласть.Лево).Текст, "М") = 0 ИЛИ Найти(СхемаЗала.Область(ТекущаяОбласть.Низ,1).Текст, "Р") = 0 Тогда
		Сообщить("Укажите область в пределах сетки Ряд / Место");
		Возврат;
	КонецЕсли;
	Если ТекущаяОбласть.ЦветФона = WebЦвета.Белый Тогда
		ТекущаяОбласть.ЦветФона = Новый Цвет(153, 204, 255);
		ТекущаяОбласть.Текст = Строка(ТекущаяОбласть.Лево - 1);
		Объект.ВсегоМест = Объект.ВсегоМест + 1;
	КонецЕсли;
	УстановитьВидимостьОбозначений(ТекущаяОбласть);
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура УдалитьМесто(Команда)
	ТекущаяОбласть = Элементы.СхемаЗала.ТекущаяОбласть;
	Если Найти(ТекущаяОбласть.Имя,":") > 0 Тогда
		Сообщить("Обработка группы мест не поддерживается");
		Возврат;
	КонецЕсли;
	Если Найти(СхемаЗала.Область(2,ТекущаяОбласть.Лево).Текст, "М") = 0 ИЛИ Найти(СхемаЗала.Область(ТекущаяОбласть.Низ,1).Текст, "Р") = 0 Тогда
		Сообщить("Укажите область в пределах сетки Ряд / Место");
		Возврат;
	КонецЕсли;
	Если ТекущаяОбласть.ЦветФона = Новый Цвет(153, 204, 255) Тогда
		ТекущаяОбласть.ЦветФона = WebЦвета.Белый;
		ТекущаяОбласть.Текст = "";
		Объект.ВсегоМест = Объект.ВсегоМест - 1;
	КонецЕсли;
	УстановитьВидимостьОбозначений(ТекущаяОбласть);
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимостьОбозначений(ТекущаяОбласть)
	ЕстьРядГ = Ложь;
	ЕстьРядВ = Ложь;
	
	Для Ном = 3 По Объект.КоличествоРядов + 3 Цикл
		Если СхемаЗала.Область(Ном,ТекущаяОбласть.Лево).ЦветФона = Новый Цвет(153, 204, 255) Тогда
			ЕстьРядВ = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Для Ном = 2 По Объект.КоличествоМестНаРяд + 2 Цикл
		Если СхемаЗала.Область(ТекущаяОбласть.Низ,Ном).ЦветФона = Новый Цвет(153, 204, 255) Тогда
			ЕстьРядГ = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ЕстьРядВ Тогда
		СхемаЗала.Область(2,ТекущаяОбласть.Лево).ЦветТекста = WebЦвета.Черный;
		СхемаЗала.Область(2,ТекущаяОбласть.Лево).ЦветФона = WebЦвета.СеребристоСерый;
	Иначе
		СхемаЗала.Область(2,ТекущаяОбласть.Лево).ЦветТекста = WebЦвета.Белый;
		СхемаЗала.Область(2,ТекущаяОбласть.Лево).ЦветФона = WebЦвета.Белый;
	КонецЕсли;
	
	Если ЕстьРядГ Тогда
		СхемаЗала.Область(ТекущаяОбласть.Низ,1).ЦветТекста = WebЦвета.Черный;
		СхемаЗала.Область(ТекущаяОбласть.Низ,1).ЦветФона = WebЦвета.СеребристоСерый;
	Иначе
		СхемаЗала.Область(ТекущаяОбласть.Низ,1).ЦветТекста = WebЦвета.Белый;
		СхемаЗала.Область(ТекущаяОбласть.Низ,1).ЦветФона = WebЦвета.Белый;
	КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	ТекущийОбъект.Схема = Новый ХранилищеЗначения(СхемаЗала);
КонецПроцедуры
