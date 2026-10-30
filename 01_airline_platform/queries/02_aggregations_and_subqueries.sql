/*
Задание 1
Для анализа распределения бронирований по дням выведите из таблицы бронирований (booking) 
дату совершения сделки (booking_date) 
и общее количество оформленных броней в этот день. 
Столбец с результатом назовите bookings_count.
*/
select booking_date, count(booking_id) as bookings_count from booking
group by booking_date;
/*
Задание 2
Для анализа причин сбоев в расписании по дням недели 
на основе таблицы журналов событий рейса (history) извлеките номер дня недели из поля status_time. 
Сгруппируйте данные по этому дню недели и посчитайте количество зафиксированных отклонений, 
отфильтровав только события со статусами 'Задержан' или 'Отменен'.
*/
select extract(dow from status_time) as day_week, count(status_name) as minuses from history
where status_name = 'Задержан' or status_name = 'Отменен' 
group by day_week;
/*
Задание 3
Финансовый отдел анализирует эффективность применения дисконтных программ. 
На основе таблицы билетов (ticket) выведите процент предоставленной скидки (discount_percent), 
общее количество проданных билетов по каждой скидочной ставке, 
а также их среднюю итоговую стоимость (price), округленную до ближайшего целого числа в большую сторону. 
Обратите внимание на обработку билетов, проданных без скидки.
*/
select coalesce(discount_percent, 0) as discount_percent, 
count(ticket_id) as kolvo, 
round(avg(price)) as avg_price
from ticket
group by discount_percent;
/*
Задание 4
Отделу маркетинга необходимо оценить продажи билетов в разрезе глубины бронирования. 
Используя конструкцию CASE, разделите билеты из таблицы билетов (ticket) 
на три категории по значению поля days_before_flight: «В день вылета» (0-1 дней), «Краткосрочно» (от 2 до 10 дней) 
и «Долгосрочно» (более 10 дней). Сгруппируйте данные по этим категориям и для каждой из них найдите 
минимальную и максимальную сумму предоставленной скидки в процентах и рублях.
*/
select case
when days_before_flight between 0 and 1 then 'В день вылета'
when days_before_flight between 2 and 10 then 'Краткосрочно'
when days_before_flight > 10 then 'Долгосрочно'
end as booking_depth,
(min(coalesce(discount_percent, 0)))::integer as min_disc_per,
(max(coalesce(discount_percent, 0)))::integer as max_disc_per,
(min(actual_rate * coalesce(discount_percent, 0) / 100))::integer as min_disc_rub,
(max(actual_rate * coalesce(discount_percent, 0) / 100))::integer as max_disc_rub
from ticket
group by booking_depth;
/*
Задание 5
Коммерческий департамент ищет наиболее крупные категории клиентов для оптимизации тарифной сетки. 
На основе таблицы пассажиров (passenger) сгруппируйте данные по названию категории (category_name) 
и посчитайте количество человек в каждой из них. Выведите в итоговый отчет только те категории, 
численность пассажиров в которых превышает 6 человек.
*/
select category_name, count(passenger_id) as count_pass from passenger
group by category_name
having count(passenger_id) > 6;
/*
Задание 6
Финансовая служба анализирует помесячные объемы поступлений для оценки сезонности спроса 
и подведения промежуточных итогов.
На основе таблицы бронирований (booking) извлеките номер месяца из даты совершения сделки (booking_date) 
и найдите суммарную стоимость оформленных заказов. Выведите в отчет только те месяцы, 
в которых общая сумма продаж превысила 100 000 рублей.
*/
select extract(month from booking_date) as month_date, sum(total_amount) as sum_price from booking
group by month_date
having sum(total_amount) > 100000;
/*
Задание 7
Аналитики изучают востребованность платных услуг на различных рейсах для оценки дополнительных доходов. 
На основе таблицы билетов (ticket) сгруппируйте данные по идентификаторам физических вылетов (flight_id) 
и посчитайте общую сумму, собранную за провоз дополнительного багажа. Выведите только те рейсы, 
где сборы за багаж превысили 1000 рублей. 
Для корректности расчетов замените неопределенные значения (NULL) в поле багажа на ноль.
*/
select flight_id, sum(coalesce(baggage_price,0)) as sum_baggage from ticket
group by flight_id
having sum(coalesce(baggage_price,0)) > 1000;
/*
Задание 8
Отделу закупок необходимо определить самолеты с повышенным количеством мест бизнес-класса, 
чтобы рассчитать объемы закупки дорогих рационов питания. 
На основе таблицы мест в салоне (seat) сгруппируйте данные по идентификаторам самолетов (airplane_id). 
Для каждого самолета посчитайте общее количество кресел, а также вычисляемое поле business_seat_ratio, 
отражающее процентную долю мест бизнес-класса от общей вместимости салона и округленное до 2 знаков после запятой. 
На уровне строк исключите из анализа ближнемагистральные самолеты, чей идентификатор начинается на 1. 
Выведите в отчет только те модели воздушных судов, 
у которых рассчитанная доля мест бизнес-класса превышает 30%.
*/
select airplane_id, count(seat_id), round((
sum(case
when fare_conditions = 'Бизнес' then 1
when fare_conditions = 'Эконом' then 0
end)::numeric / count(seat_id)) * 100,2) 
as business_seat_ratio from seat
where airplane_id::text not like '1%'
group by airplane_id
having (round((
sum(case
when fare_conditions = 'Бизнес' then 1
when fare_conditions = 'Эконом' then 0
end)::numeric / count(seat_id)) * 100,2)) > 30; 
/*
Задание 9
Отдел логистики анализирует закрепление воздушных судов за направлениями для оптимизации технического 
обслуживания в региональных аэропортах. 
На основе таблицы вылетов (flight) сгруппируйте данные по идентификаторам самолетов (airplane_id). 
С помощью функций работы со строками извлеките двухзначный код города прилета из поля route_id (первые 2 цифры кода). 
Выведите в отчет только те модели самолетов, 
которые за все время зафиксированных вылетов летали только в один и тот же город
*/
select airplane_id from flight
group by airplane_id
having count(distinct left(route_id::text, 2)) = 1;
/*
Задание 10
Службе авиационной безопасности необходимо проверить личные данные пассажиров, вылетающих определенным рейсом, 
попавшим в операционную сводку. 
На основе таблицы пассажиров (passenger) выведите полные имена и номера паспортов тех клиентов, 
чей идентификатор (passenger_id) содержится в списке билетов (ticket), 
оформленных на рейс с номером 26072501.
*/
select full_name, passport_no from passenger
where passenger_id in (select passenger_id from ticket where flight_id = 26072501);
/*
Задание 11
Маркетинговая служба анализирует предпочтения пассажиров при выборе авиастроительных брендов 
для проведения совместных промо-акций. 
На основе таблицы бронирований (booking) выведите идентификаторы заказов (booking_id), 
которые были оформлены на рейсы, выполняемые самолетами производителя «Airbus».
*/
select booking_id from booking
where booking_id in (select booking_id from ticket where flight_id in 
(select flight_id from flight where airplane_id in 
(select airplane_id from airplane where brand = 'Airbus')));
/*
Задание 12
Коммерческий департамент изучает границы параметров маршрутной сети для оптимизации расходов на авиатопливо. 
На основе таблицы маршрутов (route) выведите номера рейсов (route_no) и дистанцию для тех направлений, 
у которых расстояние полета (distance_km) 
является максимальным или минимальным среди всех существующих в расписании маршрутов.
*/
select route_no, distance_km from route
where distance_km in ((select max(distance_km) from route), (select min(distance_km) from route));
/*
Задание 13
Финансовый департамент выявляет билеты, проданные по высоким динамическим тарифам в периоды пикового спроса. 
На основе таблицы билетов (ticket) выведите идентификатор билета и его финальную цену (price) для всех билетов, 
чья стоимость превышает среднюю стоимость всех проданных билетов авиакомпании.
*/
select ticket_id, price from ticket
where price > (select avg(price) from ticket);
/*
Задание 14
Финансовая служба формирует отчет по наиболее прибыльным направлениям для оценки коммерческой эффективности расписания. 
На основе таблицы городов (city) выведите названия городов прилета, в которые выполнялись рейсы, 
суммарно принесшие авиакомпании выручку от продажи билетов на сумму более 50 000 рублей.
*/
select c.city_name
from city c
where (select sum(t.price) from ticket t
where t.flight_id in (select f.flight_id from flight f
where f.route_id in (select r.route_id from route r
where r.arrival_airport_id in (select a.airport_id from airport a
where a.city_id = c.city_id
)))) > 50000;
/*
Задание 15
Финансовый департамент анализирует отклонения цен от средних значений внутри каждого рейса 
для оценки работы алгоритмов динамического ценообразования. 
На основе таблицы билетов (ticket) выведите идентификатор билета, номер вылета (flight_id) 
и его финальную цену (price), а также величину отклонения от средней цены на этот рейс. 
В отчет должны попасть только те билеты, стоимость которых превышает среднюю стоимость билетов, 
проданных именно на этот конкретный рейс.
*/
select ticket_id, flight_id, price, price - (select avg(price) from ticket as ticket_sub where ticket_sub.flight_id = ticket.flight_id) as otkl_price from ticket as ticket
where price > (select avg(price) from ticket as ticket_sub where ticket_sub.flight_id = ticket.flight_id);
/*
Задание 16
Аналитики коммерческого департамента выявляют нерентабельные направления, которые не пользуются спросом у пассажиров. 
На основе таблицы маршрутов (route) выведите номера рейсов (route_no) и дистанцию для тех маршрутов, 
на рейсы которых в таблице билетов (ticket) не зафиксировано ни одной продажи. 
Для реализации проверки обязательно используйте конструкцию EXISTS / NOT EXISTS.
*/
select route_no, distance_km from route r
where not exists(select * from flight f where r.route_id = f.route_id and f.flight_id in (select flight_id from ticket));