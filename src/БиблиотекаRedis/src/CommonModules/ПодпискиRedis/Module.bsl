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

#Область СлужебныйПрограммныйИнтерфейс

Процедура ОбработкаКешаRedisПриЗаписи(Источник, Отказ) Экспорт
	// Добавьте свои объекты в состав подписки и очищайте \ обновляйте кеш при записи объекта.
	// ВНИМАНИЕ! 
	// REDIS не обеспечивает транзакционную целостность при отмене транзакции, поэтому рекомендуется очищать кеш, а не перезаполнять его.
КонецПроцедуры

#КонецОбласти


//@skip-check module-region-empty
#Область СлужебныеПроцедурыИФункции

// Код процедур и функций

#КонецОбласти
