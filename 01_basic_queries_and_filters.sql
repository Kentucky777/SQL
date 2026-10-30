/*
Задание 1 
В авиапарк компании поступает новый региональный самолет. 
Напишите запрос для добавления в таблицу airplane записи со следующими характеристиками: 
ID — 1113, бренд — «Sukhoi», модель — «Superjet 100-95B», дальность полета — 3050 км, класс — «Ближнемагистральный».
*/
INSERT INTO airplane (airplane_id, brand, model, range_km, airplane_class) VALUES 
(1113, 'Sukhoi', 'Superjet 100-95B', 3050, 'Ближнемагистральный');
/*
Задание 2
Выведите из таблицы городов (city) названия всех городов присутствия, 
которые находятся в России (country_id = 1), за исключением Новосибирска.
*/
select city_name from city
where country_id = 1 and city_name <> 'Новосибирск';
/*
Задание 3
Выведите из таблицы пассажиров (passenger) список всех мужчин (gender = 'М'), 
которые относятся к категории «Взрослый».
*/
select full_name from passenger
where gender = 'М' and category_name = 'Взрослый';
/*
Задание 4
Выведите бренды и модели самолетов из таблицы airplane, 
у которых класс обслуживания заявлен как «Среднемагистральный», 
но при этом максимальная дальность полета составляет менее 6000 км.
*/
select brand, model from airplane
where airplane_class = 'Среднемагистральный' and range_km < 6000;
/*
Задание 5
На основе таблицы билетов (ticket) выведите ID билета, 
базовый тариф (actual_rate), 
процент скидки (discount_percent) и вычисляемое поле ruble_discount, 
отражающее абсолютную величину скидки в рублях.
*/

select ticket_id, actual_rate, discount_percent, (actual_rate * discount_percent / 100) as ruble_discount from ticket;

/*
Задание 6
Выведите из таблицы билетов (ticket) идентификатор билета, 
а также вычисляемое поле price_excess_ratio, 
отражающее коэффициент превышения реальной стоимости билета над базовой.
*/

select ticket_id, (price / early_rate) as price_excess_ratio from ticket;

/*
Задание 7
Напишите запрос к таблице бронирований (booking), 
который сортирует все записи по стоимости (total_amount) от самых дорогих к самым дешевым, 
пропускает первые 5 записей и возвращает следующие 3.
*/

select * from booking
order by total_amount desc
limit 3
offset 5;

/*
Задание 8
Выведите из таблицы маршрутов (route) номера рейсов (route_no), 
дистанцию (distance_km) и длительность полета. 
В выборку должны попасть только те маршруты, 
у которых идентификатор аэропорта вылета (departure_airport_id) 
соответствует кодам 111 (Домодедово), 112 (Шереметьево) или 131 (Пулково). 
Для фильтрации пула этих аэропортов обязательно используйте оператор IN.
*/

select route_no, distance_km, duration_min from route
where departure_airport_id in (111,112,131);

/*
Задание 9
Найдите в таблице вылетов (flight) все рейсы, запланированные на период с 1 по 31 августа 2026 года включительно. 
Для фильтрации дат обязательно примените оператор BETWEEN.
*/

select * from flight
where scheduled_departure between '2026-08-01' and '2026-08-31';

/*
Задание 10
Выведите из таблицы маршрутов (route) номера рейсов (route_no), 
дистанцию и маску расписания для тех маршрутов, 
которые выполняются по субботам (цифра 6 в поле schedule_pattern). 
Для фильтрации обязательно используйте оператор LIKE.
*/

select route_no, distance_km, schedule_pattern from route
where schedule_pattern like '%6%';
/*
Задание 11
Выведите из таблицы бронирований (booking) ID бронирования и общую сумму чека (total_amount). 
Явно преобразуйте поле total_amount к текстовому типу данных и добавьте к нему справа обозначение валюты: « RUB». 
Включите в отчет только те бронирования, которые были совершены в июне 2026 года.
*/

set lc_monetary to 'ru_RU.utf8';

select booking_id, total_amount, cast(total_amount as money) as total_amount_rub from booking
where booking_date between '2026-06-01' and '2026-06-30';
/*
Задание 12
Напишите запрос, который выводит ID билета (ticket_id) и стоимость багажа (baggage_price) из таблицы ticket. 
Вместо неопределенных значений (NULL) для пассажиров без багажа в отчете должен выводиться ноль (0.00). 
Для замены значений обязательно используйте функцию COALESCE.
*/

select ticket_id, coalesce(baggage_price, 0.00) as baggage_price from ticket;

/*
Задание 13
Напишите запрос к таблице мест (seat), который выведет номера кресел для самолета с ID 1111. 
С помощью конструкции CASE создайте вычисляемое поле meal_type: 
если класс обслуживания (fare_conditions) равен «Бизнес», должно выводиться значение «Горячий люкс-обед», 
а если «Эконом» — «Сэндвич и напиток».
*/

select seat_no,
	case fare_conditions
		when 'Бизнес' then 'Горячий люкс-обед'
		when 'Эконом' then 'Сэндвич и напиток'
	end as meal_type
from seat
where airplane_id = 1111;

/*
Задание 14
Из таблицы пассажиров (passenger) выведите категорию (category_name). 
Вместо полного имени сформируйте строку в формате «Фамилия И.О.» (на основе поля full_name). 
Поле паспорта (passport_no) преобразуйте так, чтобы в нем были скрыты знаками «X» две последние цифры серии 
и две первые цифры номера (например, вместо «5014-101101» должно получиться «50XX-XX1101»).
*/

select category_name, split_part(full_name, ' ', 1) || ' ' 
|| left(split_part(full_name,' ', 2), 1) || '.'
|| left(split_part(full_name,' ',3),1) || '.' as initials,
(replace(passport_no, substring(passport_no from 3 for 5), 'XX-XX')) as secret
from passenger;

/*
Задание 15
Из таблицы пассажиров (passenger) выведите полное имя (full_name) и дату рождения (birth_date). 
Извлеките из даты рождения отдельно день, номер месяца и год в виде трех самостоятельных числовых столбцов. 
В отдельном вычисляемом поле рассчитайте возраст пассажира в полных годах 
относительно текущей даты (даты выполнения запроса).
*/
select full_name, birth_date,
extract(day from birth_date) as day,
extract(month from birth_date) as month,
extract(year from birth_date) as year,
(extract(year from age(current_date, birth_date))) as age
from passenger;
