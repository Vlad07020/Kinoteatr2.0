
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ДатаСеанса = ТекущаяДата();
	ОтобразитьСеансыВПланировщике();
КонецПроцедуры

&НаКлиенте
Процедура ДатаСеансаПриИзменении(Элемент)
	ОтобразитьСеансыВПланировщике()
КонецПроцедуры

&НаКлиенте
Процедура КинотеатрПриИзменении(Элемент)
	ОтобразитьСеансыВПланировщике()
КонецПроцедуры

&НаКлиенте
Процедура ФильмПриИзменении(Элемент)
	ОтобразитьСеансыВПланировщике()
КонецПроцедуры








&НаСервере
Процедура ОтобразитьСеансыВПланировщике()

	РасписаниеСеансов.Элементы.Очистить();
	
	Если Не ЗначениеЗаполнено(ДатаСеанса) Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не заполнено обязательное поле дата сеанса!" + Символы.ПС + "Заполните его пожалуйста!";
		Сообщение.Сообщить(); 
		
		Возврат;
		
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	ТекстЗапроса = 
		"ВЫБРАТЬ
		|	РасписаниеСеансов.Период КАК Период,
		|	РасписаниеСеансов.ВремяСеанса КАК ВремяСеанса,
		|	РасписаниеСеансов.Зал КАК Зал,
		|	РасписаниеСеансов.Кинотеатр КАК Кинотеатр,
		|	РасписаниеСеансов.Фильм КАК Фильм,
		|	РасписаниеСеансов.Стоимость КАК Стоимость,
		|	ДОБАВИТЬКДАТЕ(РасписаниеСеансов.Период, СЕКУНДА, РАЗНОСТЬДАТ(НАЧАЛОПЕРИОДА(РасписаниеСеансов.ВремяСеанса, ДЕНЬ), РасписаниеСеансов.ВремяСеанса, СЕКУНДА)) КАК НачалоСеанса,
		|	ДОБАВИТЬКДАТЕ(ДОБАВИТЬКДАТЕ(РасписаниеСеансов.Период, СЕКУНДА, РАЗНОСТЬДАТ(НАЧАЛОПЕРИОДА(РасписаниеСеансов.ВремяСеанса, ДЕНЬ), РасписаниеСеансов.ВремяСеанса, СЕКУНДА)), СЕКУНДА, ЕСТЬNULL(Фильмы.Длительность, 0) * 60) КАК КонецСеанса
		|ИЗ
		|	РегистрСведений.РасписаниеСеансов КАК РасписаниеСеансов
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Фильмы КАК Фильмы
		|		ПО РасписаниеСеансов.Фильм = Фильмы.Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	НачалоСеанса";
	
	СхемаЗапроса = Новый СхемаЗапроса;
	СхемаЗапроса.УстановитьТекстЗапроса(ТекстЗапроса);
	
	ЗапросВыбора = СхемаЗапроса.ПакетЗапросов[0];
	ОператорВыбора = ЗапросВыбора.Операторы[0];
	
	Если ЗначениеЗаполнено(ДатаСеанса) Тогда
		ОператорВыбора.Отбор.Добавить("РасписаниеСеансов.Период = &Период");
		Запрос.УстановитьПараметр("Период", ДатаСеанса);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Кинотеатр) Тогда
		ОператорВыбора.Отбор.Добавить("РасписаниеСеансов.Кинотеатр = &Кинотеатр");
		Запрос.УстановитьПараметр("Кинотеатр", Кинотеатр);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Фильм) Тогда
		ОператорВыбора.Отбор.Добавить("РасписаниеСеансов.Фильм = &Фильм");
		Запрос.УстановитьПараметр("Фильм", Фильм);
	КонецЕсли;
	
	ТекстЗапроса = СхемаЗапроса.ПолучитьТекстЗапроса();
	
	Запрос.Текст = ТекстЗапроса;
	Выборка = Запрос.Выполнить().Выбрать();
	
	РасписаниеСеансов.ТекущиеПериодыОтображения.Очистить();
	РасписаниеСеансов.ТекущиеПериодыОтображения.Добавить(НачалоДня(ДатаСеанса), КонецДня(ДатаСеанса));
	
	ТекущийЦвет = WebЦвета.ЗеленаяЛужайка;
	ПредыдущийЦвет = WebЦвета.Васильковый;
	ПеременныйЦвет = Неопределено;
	ПредыдущееВремяНачалоСеанса = Дата("00010101");
	ПредыдущееВремяОкончаниеСеанса = Дата("00010101");
	
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.НачалоСеанса >= ПредыдущееВремяНачалоСеанса И Выборка.НачалоСеанса <= ПредыдущееВремяОкончаниеСеанса Тогда
			ПеременныйЦвет = ТекущийЦвет;
			ТекущийЦвет = ПредыдущийЦвет;
			ПредыдущийЦвет = ПеременныйЦвет;
		КонецЕсли; 
		
		ПредыдущееВремяНачалоСеанса = Выборка.НачалоСеанса;
		ПредыдущееВремяОкончаниеСеанса = Выборка.КонецСеанса;
		
		ТекстДляВывода = "";
		
		Если Не ЗначениеЗаполнено(Кинотеатр) Тогда
			
			ТекстДляВывода = ТекстДляВывода + "Кинотеатр: " + Выборка.Кинотеатр + " ";
			
		КонецЕсли; 
		
		Если Не ЗначениеЗаполнено(Фильм) Тогда
			
			ТекстДляВывода = ТекстДляВывода + "Фильм: " + Выборка.Фильм;
			
		КонецЕсли;
		
		НовыйЭлемент = РасписаниеСеансов.Элементы.Добавить(Выборка.НачалоСеанса, Выборка.КонецСеанса);
		
		НовыйЭлемент.Текст = ТекстДляВывода;
		НовыйЭлемент.ЦветФона = ТекущийЦвет;	
		НовыйЭлемент.Значение = ТекстДляВывода;
				
	КонецЦикла;
	
	
	
КонецПроцедуры 





