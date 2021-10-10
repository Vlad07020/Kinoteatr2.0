
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ПродажиПродукции 
	Движения.ПродажиПродукции.Записывать = Истина;
	Для Каждого ТекСтрокаПродукция Из Продукция Цикл
		Движение = Движения.ПродажиПродукции.Добавить();
		Движение.Период = Дата;
		Движение.Продукция = ТекСтрокаПродукция.Товар;
		Движение.Кинотеатр = Кинотеатр;
		Движение.СтоимостьПродаж = ТекСтрокаПродукция.Итого;
		Движение.Количество = ТекСтрокаПродукция.Количество;
	КонецЦикла;	
	
	Если НЕ ЗначениеЗаполнено(ДокументОснование) Тогда
		Движения.ОстаткиПродукции.Записывать = Истина;
		
		// сгрупировать поля в табличной части документа по номенклатуре
		Запрос = Новый Запрос;
		Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПродажаПродукцииПродукция.Товар КАК Товар,
		|	СУММА(ПродажаПродукцииПродукция.Количество) КАК Количество
		|ПОМЕСТИТЬ ДокТЧ
		|ИЗ
		|	Документ.ПродажаПродукции.Продукция КАК ПродажаПродукцииПродукция
		|ГДЕ
		|	ПродажаПродукцииПродукция.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПродажаПродукцииПродукция.Товар
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДокТЧ.Товар КАК Товар,
		|	ДокТЧ.Количество КАК Количество
		|ИЗ
		|	ДокТЧ КАК ДокТЧ";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Движение = Движения.ОстаткиПродукции.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Товар = ВыборкаДетальныеЗаписи.Товар;
			Движение.Кинотеатр = Кинотеатр;
			Движение.Количество = ВыборкаДетальныеЗаписи.Количество;
		КонецЦикла;
		
		Движения.ОстаткиПродукции.БлокироватьДляИзменения = Истина;
		
		Движения.Записать();
		
		
		// запрос к остаткам - контроль остатков
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОстаткиПродукцииОстатки.Товар КАК Товар,
		|	ОстаткиПродукцииОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ОстаткиПродукции.Остатки(
		|			&МоментВремени,
		|			Кинотеатр = &Кинотеатр
		|				И Товар В
		|					(ВЫБРАТЬ
		|						ДокТЧ.Товар КАК Товар
		|					ИЗ
		|						ДокТЧ КАК ДокТЧ)) КАК ОстаткиПродукцииОстатки
		|ГДЕ
		|	ОстаткиПродукцииОстатки.КоличествоОстаток < 0";
		
		Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
		
		
		Запрос.УстановитьПараметр("Кинотеатр", Кинотеатр);
		Запрос.УстановитьПараметр("МоментВремени", Граница);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если Не РезультатЗапроса.Пустой() Тогда
			Отказ=Истина;
			
			// порционно выдает данные
			Выборка = РезультатЗапроса.Выбрать();
			
			Пока Выборка.Следующий() Цикл
				Сообщить("Мало продукции " + Выборка.Товар + ", нужно еще " + (-Выборка.КоличествоОстаток));
			КонецЦикла;
			
		КонецЕсли;
		
		
	КонецЕсли;
	
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	// Обходим строки и проверяем заполнение реквизита
	
	Для Индекс = 0 по Продукция.Количество()-1 Цикл
		СтрокаТовар = Продукция.Получить(Индекс);
		Если Не ЗначениеЗаполнено(СтрокаТовар.Товар) Тогда
			Сообщение = Новый СообщениеПользователю();
			Строка = Индекс + 1;
			Сообщение.Текст = "В строке " + Строка + " не заполнено значение товара";
			Сообщение.Поле = "Товары[" + Индекс + "].Товар";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Сообщить();
			Отказ = Истина;
			
		ИначеЕсли Не ЗначениеЗаполнено(СтрокаТовар.Количество) Тогда
			Сообщение = Новый СообщениеПользователю();
			Строка = Индекс + 1;
			Сообщение.Текст = "В строке " + Строка + " не заполнено значение количества товара";
			Сообщение.Поле = "Товары[" + Индекс + "].Товар";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Сообщить();
			Отказ = Истина;
			
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры


Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)

	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПродукции") Тогда
		// Заполнение шапки
		ИтогоКОплате = ДанныеЗаполнения.ИтогоКОплате;
		Кинотеатр = ДанныеЗаполнения.Кинотеатр;
		ДокументОснование = ДанныеЗаполнения.Ссылка;
		Для Каждого ТекСтрокаПродукция Из ДанныеЗаполнения.Продукция Цикл
			НоваяСтрока = Продукция.Добавить();
			НоваяСтрока.Итого = ТекСтрокаПродукция.Итого;
			НоваяСтрока.Количество = ТекСтрокаПродукция.Количество;
			НоваяСтрока.Товар = ТекСтрокаПродукция.Товар;
			НоваяСтрока.Цена = ТекСтрокаПродукция.Цена;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

