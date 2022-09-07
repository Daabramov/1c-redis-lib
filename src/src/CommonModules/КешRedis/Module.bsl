//   Redis 1C-NativeAddin wrapper
//   Copyright (C) 2022  Dmitry Abramov
// 
//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU Affero General Public License as
//   published by the Free Software Foundation, either version 3 of the
//   License, or (at your option) any later version.
// 
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU Affero General Public License for more details.
// 
//   You should have received a copy of the GNU Affero General Public License
//   along with this program.  If not, see <https://www.gnu.org/licenses/>.


// @strict-types

#Область ПрограммныйИнтерфейс

// Новые параметры.
// 
// Параметры:
//  ИмяМетода - Строка - Имя метода
//  Ключ - Строка - Ключ, может быть не указан, тогда подсистема попытаеся сформировать ключ автоматически.
// 
// Возвращаемое значение:
//  Структура - Новые параметры:
// * ИмяМетода - Строка - Имя выполняемой функции конфигурации
// * Ключ - Строка - Ключ значения в redis
// * Параметры - Массив из Произвольный - Параметры метода в порядке следования
// * Поле - Неопределено, Строка - Имя поля для использования HSET и HGET
// * ВремяЖизни - Число - Время жизни значения в кеше в секундах, если равно 0, то бессрочно.
//   Если поле "Поле" заполнено, то не учитывается
Функция НовыеПараметры(ИмяМетода = "", Ключ = "") Экспорт
	Параметры = Новый Структура();
	Параметры.Вставить("Ключ", Ключ);
	Параметры.Вставить("ИмяМетода", ИмяМетода);
	Параметры.Вставить("Параметры", Новый Массив());
	Параметры.Вставить("Поле", Неопределено);
	Параметры.Вставить("ВремяЖизни", 0);
	Возврат Параметры;
КонецФункции

// Получает закешированные значение в редис по указанному ключу.
// Если значение не найдено, то будет выполнена переданная функция, а ее результат помещен в кеш
// ВНИМАНИЕ!
// 1) Тип результата возвращаемый указанной функции должен быть сериализуемым, в тч и вложенные типы.
// 2) Не поддерживается тип Неопределено
// Параметры:
//  Параметры - см. НовыеПараметры
// 
// Возвращаемое значение:
//  Произвольный
Функция Значение(Параметры) Экспорт
	
	Если Не КоннекторRedisПовтИсп.Используется() Тогда
		Возврат ВызватьФункциюКонфигурации(Параметры.ИмяМетода, Параметры.Параметры);
	КонецЕсли;
	
	Ключ = ?(
		ЗначениеЗаполнено(Параметры.Ключ),
		Параметры.Ключ,
		КонтрольнаяСуммаПараметров(Параметры.ИмяМетода, Параметры.Параметры)
	);
	
	Если ЗначениеЗаполнено(Параметры.Поле) Тогда
		ЗначениеИзРедис = КоннекторRedis.HGET(Ключ, Параметры.Поле);
	Иначе
		ЗначениеИзРедис = КоннекторRedis.GET(Ключ);
	КонецЕсли;
	
	Если ЗначениеИзРедис <> Неопределено Тогда
		Возврат Десериализовать(ЗначениеИзРедис);
	КонецЕсли;	
	
	РезультатВыполнения = ВызватьФункциюКонфигурации(Параметры.ИмяМетода, Параметры.Параметры);
	
	Если ЗначениеЗаполнено(Параметры.Поле) Тогда
		КоннекторRedis.HSET(Ключ, Параметры.Поле, Сериализовать(РезультатВыполнения));
	Иначе
		КоннекторRedis.SET(Ключ, Сериализовать(РезультатВыполнения), Параметры.ВремяЖизни);
	КонецЕсли;
	
	Возврат РезультатВыполнения;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Контрольная сумма параметров.
// 
// Параметры:
//  ИмяМетода - Строка
//  Параметры - Массив из Произвольный
// 
// Возвращаемое значение:
//  Строка - Контрольная сумма
Функция КонтрольнаяСуммаПараметров(ИмяМетода, Параметры)
	
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешированиеДанных.Добавить(ИмяМетода);
	
	Для Каждого Параметр Из Параметры Цикл
		Если ТипЗнч(Параметр) <> Тип("Строка") И ТипЗнч(Параметр) <> Тип("ДвоичныеДанные") Тогда
			ХешированиеДанных.Добавить(Сериализовать(Параметр));
		Иначе
			ХешированиеДанных.Добавить(Параметр);
		КонецЕсли;

	КонецЦикла;
	
	ХешСуммаСтрокой = Строка(ХешированиеДанных.ХешСумма); 
	Результат = СтрЗаменить(ХешСуммаСтрокой, " ", "");
	
	Возврат Результат;
	
КонецФункции

// Сериализовать значение
// 
// Параметры:
//  Значение - Произвольный - Любое сериализумое значение
// 
// Возвращаемое значение:
// 	Строка
Функция Сериализовать(Значение)
	Если КешRedisПовтИсп.ПрименятьОптимизациюСериализации() Тогда
		Данные = СериализацияFIS(Значение);
		Возврат XMLСтрока(Данные);
	Иначе
		Возврат СериализацияJson(Значение);
	КонецЕсли;
КонецФункции

// Десериализовать данные
// 
// Параметры:
//  СериализованныеДанные - Строка - Сериализованные данные
// 
// Возвращаемое значение:
// Произвольный 
Функция Десериализовать(СериализованныеДанные)
	Если КешRedisПовтИсп.ПрименятьОптимизациюСериализации() Тогда
		ДД = XMLЗначение(Тип("ДвоичныеДанные"), СериализованныеДанные);
		Возврат ДесериализацияFIS(ДД);
	Иначе
		Возврат ДесериализацияJson(СериализованныеДанные);
	КонецЕсли;
КонецФункции

Функция СериализацияJson(Значение)
	
	Запись = Новый ЗаписьJSON();
	Запись.УстановитьСтроку();	
	СериализаторXDTO.ЗаписатьJSON(Запись, Значение, НазначениеТипаXML.Явное);	
	Возврат Запись.Закрыть();   
	
КонецФункции

Функция СериализацияFIS(Значение)
	
	ЗаписьXML = Новый ЗаписьFastInfoset;
	ЗаписьXML.УстановитьДвоичныеДанные();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Значение, НазначениеТипаXML.Явное);
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

Функция ДесериализацияJson(СериализованныеДанные)
	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(СериализованныеДанные);	
	ПрочитанныеДанные = СериализаторXDTO.ПрочитатьJSON(Чтение);	
	Чтение.Закрыть();
	Возврат ПрочитанныеДанные;
КонецФункции

Функция ДесериализацияFIS(СериализованныеДанные)
	Чтение = Новый ЧтениеFastInfoset;
	Чтение.УстановитьДвоичныеДанные(СериализованныеДанные);  
	ПрочитанныеДанные = СериализаторXDTO.ПрочитатьXML(Чтение);
	Чтение.Закрыть();	
	Возврат ПрочитанныеДанные;
КонецФункции

// Copyright (c) 2022, ООО 1С-Софт
Функция ВызватьФункциюКонфигурации(Знач ИмяМетода, Знач Параметры = Неопределено)
	
	ИмяПроцедурыВалидно = КешRedisПовтИсп.ПроверитьИмяПроцедурыКонфигурации(ИмяМетода);
	
	Если Не ИмяПроцедурыВалидно Тогда
		ВызватьИсключение "Имя указанного метода конфигурации не валидно."
	КонецЕсли;

	ПараметрыСтрока = "";
	Если Параметры <> Неопределено И Параметры.Количество() > 0 Тогда
		Для Индекс = 0 По Параметры.ВГраница() Цикл 
			ПараметрыСтрока = ПараметрыСтрока + "Параметры[" + XMLСтрока(Индекс) + "],";
		КонецЦикла;
		ПараметрыСтрока = Сред(ПараметрыСтрока, 1, СтрДлина(ПараметрыСтрока) - 1);
	КонецЕсли;
	
	//@skip-check server-execution-safe-mode
	Возврат Вычислить(ИмяМетода + "(" + ПараметрыСтрока + ")");
	
КонецФункции

#КонецОбласти
