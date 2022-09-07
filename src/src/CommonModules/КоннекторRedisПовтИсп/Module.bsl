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

#Область ПрограммныйИнтерфейс

// Клиент redis.
// 
// Возвращаемое значение:
//  РазрешеннаяВнешняяКомпонента
Функция КлиентRedis() Экспорт
	
	Если Не КоннекторRedisПовтИсп.Используется() Тогда
		ВызватьИсключение "Использование Redis отключено в функцональных опциях";
	КонецЕсли;
	
	Если Не ПодключитьВнешнююКомпоненту("ОбщийМакет.RedisClient", "Redis", ТипВнешнейКомпоненты.Native) Тогда
		ВызватьИсключение "Не удалось подключить компоненту";
	КонецЕсли;
	
 	Компонента = Новый("AddIn.Redis.RedisClient");
	Если Компонента = Неопределено Тогда
		ВызватьИсключение "Не удалось создать экземпляр компоненты";
	КонецЕсли;             
	
	Если КешRedisПовтИсп.СравнитьВерсии(Компонента.ВерсияКомпоненты, "1.0.0.1") < 0 Тогда
		ВызватьИсключение "Используется версия компоненты ниже поддерживаемой";
	КонецЕсли;
	Компонента.Connect(АдресСервераRedis());   
	
	Возврат Компонента;
	
КонецФункции

Функция АдресСервераRedis() Экспорт
	УстановитьПривилегированныйРежим(Истина);
	Возврат Константы.RedisURI.Получить();
КонецФункции

Функция Используется() Экспорт
	Возврат ПолучитьФункциональнуюОпцию("ИспользоватьRedis");
КонецФункции

#КонецОбласти