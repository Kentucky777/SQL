/*
Задание 1
Для автоматизации работы стойки регистрации требуется сопоставить выданные посадочные талоны 
с персональными сведениями улетающих клиентов. 
На основе таблиц посадочных талонов (boarding) и пассажиров (passenger) выведите ФИО пассажира, 
серию и номер его паспорта, а также идентификатор назначенного ему места (seat_id). 
В отчёт должны попасть только те люди, по которым фактически сформирован посадочный талон.
Примечание: Для реализации этого запроса обязательно использовать неявное соединение таблиц.
*/

select p.full_name, p.passport_no, b.seat_id from passenger p, boarding b, ticket t
where p.passenger_id = t.passenger_id and t.ticket_id = b.ticket_id;

/*
Задание 2
Служба кейтеринга в базовом аэропорту составляет график подготовки 
пассажирских салонов перед отправкой рейсов. Сотрудникам необходимо заранее знать структуру и 
компоновку посадочных мест для конкретных физических вылетов. 
На основе таблиц вылетов (flight) и 
мест в салоне (seat) выведите идентификатор вылета (flight_id), плановые дату и время отправления, 
а также номер кресла (seat_no) и класс его обслуживания. Ограничьте отчет только теми вылетами, 
которые запланированы на сентябрь 2026 года.
Примечание: Для реализации этого запроса обязательно используйте неявное соединение таблиц.
*/

select f.flight_id, f.scheduled_departure, s.seat_no, s.fare_conditions from flight f, seat s
where f.airplane_id = s.airplane_id and 
f.scheduled_departure between '2026-09-01 00:00:00' and '2026-09-30 23:59:59';

/*
Задание 3
Аналитический отдел готовит отчет для совета директоров по развитию маршрутной сети и оценке присутствия авиакомпании на зарубежных рынках.
Для подготовки презентации руководству требуется выгрузить полную географическую цепочку по каждому действующему авиаузлу, 
расположенному за пределами домашнего региона. 
Используя таблицы стран (country), 
городов (city) и аэропортов (airport), сформируйте единый список, содержащий название страны, 
название города и официальное наименование расположенного в нём аэропорта. 
Исключите из анализа Российскую Федерацию. Отсортируйте полученный результат по названию страны,
а внутри неё – по названию города.
*/

select co.country_name, c.city_name, a.airport_name 
from country co
join city c on c.country_id = co.country_id 
join airport a on a.city_id = c.city_id
where co.country_name <> 'Россия'
order by co.country_name, c.city_name;

/*
Задание 4
Службе диспетчеризации авиакомпании требуется детальный оперативный план полетов с 
расшифровкой географических точек. 
На основе таблиц вылетов (flight) и маршрутов (route) сформируйте отчет, 
содержащий идентификатор физического рейса (flight_id), плановые дату и время вылета, 
номер рейса по расписанию, 
а также официальные названия аэропорта вылета и аэропорта прилета.
*/

select f.flight_id, f.scheduled_departure, r.route_no, 
dep.airport_name as departure_airport, arr.airport_name
from flight f
join route r on r.route_id = f.route_id
join airport dep on dep.airport_id = r.departure_airport_id
join airport arr on arr.airport_id = r.arrival_airport_id;

/*
Задание 5
Коммерческий департамент анализирует ценовую политику и динамику продаж билетов на дальние расстояния 
для оценки эффективности эксплуатации различных типов воздушных судов. 
На основе таблиц билетов (ticket) и самолетов (airplane) выведите идентификатор билета, 
итоговую финальную стоимость его продажи (price), бренд и модель назначенного на рейс самолета,
а также класс его магистральности. Отфильтруйте итоговый отчет так, 
чтобы в нем остались только продажи на рейсы, 
выполняемые на дальномагистральных лайнерах.
*/

select t.ticket_id, t.price, a.brand, a.model, a.airplane_class from ticket t 
join flight f on f.flight_id = t.flight_id
join airplane a on a.airplane_id = f.airplane_id
where a.airplane_class = 'Дальномагистральный';

/*
Задание 6
Финансово-экономическая служба рассчитывает средние затраты различных социальных групп пассажиров 
на перелеты. На основе таблиц пассажиров (passenger) и билетов (ticket) 
выведите название возрастной/социальной категории клиентов (category_name) и 
среднюю итоговую стоимость (price) приобретенных ими авиабилетов. 
Сгруппируйте данные по категориям пассажиров и оставьте в финальном отчете только те группы, 
у которых средняя стоимость билета превышает 15 000 рублей.
*/

select p.category_name, avg(t.price) as avg_price from ticket t
join passenger p on p.passenger_id = t.passenger_id
group by category_name
having avg(t.price) > 15000;

/*
Задание 7
Отдел аудита проверяет качество работы онлайн-системы бронирования и 
хочет выявить случаи «брошенных корзин» – когда под заказ был зарезервирован идентификатор брони, 
но клиент по какой-то причине не завершил покупку и на эту бронь 
не было выписано ни одного персональногобилета. 
На основе таблиц бронирований (booking) и билетов (ticket) выведите идентификатор брони, 
дату ее создания и полную сумму заказа. В отчет должны попасть только те бронирования, 
для которых отсутствуют выписанные билеты
*/

select b.booking_id, b.booking_date, b.total_amount from booking b 
left join ticket t on t.booking_id = b.booking_id
where t.ticket_id is null;

/*
Задание 8
Департамент аудита проводит проверку клиентской базы и финансовых поступлений. 
Руководству требуется сопоставить полный список зарегистрированных в системе пассажиров 
с реестром оформленных бронирований, чтобы получить исчерпывающую картину коммерческой активности. 
На основе таблиц пассажиров (passenger) , билетов (ticket) и бронирований (booking) сформируйте отчет,
содержащий ФИО пассажира, его возрастную/социальную категорию (category_name),
идентификатор бронирования (booking_id) и общую сумму чека (total_amount). 
Настройте связь таблиц так, чтобы в итоговый список попали абсолютно все пассажиры 
(включая тех, у кого нет оформленных заказов) и 
абсолютно все бронирования (включая те, под которые в системе не зарегистрированы пассажиры).
*/

select p.full_name, p.category_name, b.booking_id, b.total_amount from passenger p
full join ticket t on t.passenger_id = p.passenger_id
full join booking b on b.booking_id = t.booking_id;

/*
Задание 9
Коммерческий департамент оценивает востребованность авиамаршрутов компании. 
На основе таблиц маршрутов (route), городов (city), вылетов (flight) и билетов (ticket) сформируйте отчет,
содержащий номер рейса (route_no), названия городов вылета и прилета, 
а также общую сумму, вырученную с продажи билетов. Настройте связь таблиц так, 
чтобы в отчет попали абсолютно все маршруты из расписания, даже если по ним еще 
не было рейсов и продаж (для таких направлений выручка должна быть выведена как ноль). 
Оставьте в итоговом документе только те маршруты, 
у которых суммарная выручка составила менее 50 000 рублей.
*/

SELECT r.route_no, dep_city.city_name AS departure_city, arr_city.city_name AS arrival_city, 
COALESCE(SUM(t.price), 0) AS sum_t
FROM route r
JOIN airport dep_airport ON dep_airport.airport_id = r.departure_airport_id
JOIN city dep_city ON dep_city.city_id = dep_airport.city_id
JOIN airport arr_airport ON arr_airport.airport_id = r.arrival_airport_id
JOIN city arr_city ON arr_city.city_id = arr_airport.city_id
LEFT JOIN flight f ON f.route_id = r.route_id
LEFT JOIN ticket t ON t.flight_id = f.flight_id
GROUP BY r.route_no, dep_city.city_name, arr_city.city_name
HAVING COALESCE(SUM(t.price), 0) < 50000;


/*
Задание 10
Служба организации перевозок анализирует заполняемость пассажирских мест на авиарейсах. 
На основе таблиц вылетов (flight), самолетов (airplane), мест (seat) и 
посадочных талонов (boarding) сформируйте отчет, 
содержащий идентификатор вылета (flight_id), дату вылета, бренд и модель самолета. 
Для каждого вылета рассчитайте:
Общее количество мест в самолете.
Количество фактически зарегистрированных пассажиров.
Долю заполняемости салона в процентах (округлите до одного знака после запятой).
Отсортируйте полученный список по доле заполняемости салона от меньшей к большей.
*/

select f.flight_id, f.scheduled_departure, a.brand, a.model, 
count(distinct s.seat_id) as sum_seat, 
count(distinct b.boarding_id) as board_seat_sum,
round(100 * count(distinct b.boarding_id) / count(distinct s.seat_id) , 1) as board_percent
from flight f
join airplane a on a.airplane_id = f.airplane_id
join seat s on s.airplane_id = a.airplane_id
left join ticket t on t.flight_id = f.flight_id
left join boarding b on b.ticket_id = t.ticket_id
group by f.flight_id, f.scheduled_departure, a.brand, a.model
order by board_percent asc;

/*
Задание 11 
Коммерческая служба разрабатывает гибкую сетку тарифов и изучает теоретически возможные комбинации 
базовых цен и скидочных программ, заложенных в систему, для прогнозирования потенциальной выручки. 
На основе таблицы билетов (ticket) извлеките все уникальные значения базового тарифа (base_rate), 
а также все уникальные значения процента предоставленной скидки (discount_percent). 
Используя перекрестное соединение (CROSS JOIN), сгенерируйте полную матрицу сочетаний цен и скидок. 
Для каждой пары дополнительно рассчитайте вычисляемое поле expected_revenue, отражающее сумму, 
которую получит авиакомпания 
с продажи билета по данной базовой ставке с учетом применения этого процента скидки.
*/

select br.base_rate, coalesce(dp.discount_percent,0), 
br.base_rate * (1 - coalesce(dp.discount_percent,0)/100) as expected_revenue from 
(select distinct base_rate from ticket ) br
cross join (select distinct discount_percent from ticket) as dp;

/*
Задание 12 
Отдел взаиморасчетов с агентствами корректирует баланс по билетам на отмененный рейс 
для проведения массового возврата средств. Авиакомпания возвращает пассажирам полную стоимость перелета, 
за исключением фиксированного невозвратного сервисного сбора за обработку платежа, 
который составляет 10% от базового тарифа билета. В таблице билетов (ticket) обновите записи, 
изменив итоговую финальную цену билета (price). Рассчитайте её как 10% от значения в поле 
базового тарифа (base_rate). Проведите это обновление только для билетов, 
оформленных на отмененный рейс с идентификатором 26091001.
*/

begin;

update ticket
set price = base_rate * 0.1
where flight_id = 26091001
returning
    ticket_id,
    flight_id,
    base_rate,
    price as updated;

rollback;

/*
Задание 13 
Департамент клиентского сервиса внедряет программу лояльности для пассажиров старшего поколения. 
Для её реализации необходимо централизованно снизить стоимость перелетов для пенсионеров 
на определенные типы рейсов. Модернизируйте таблицу билетов (ticket), 
установив фиксированную стоимость дополнительных услуг (service_price) 
в размере 500 рублей для всех билетов, оформленных на пассажиров из категории «Пенсионер», 
но только на те рейсы, 
которые выполняются на воздушных судах бренда «Boeing». 
*/

begin;

update ticket t
set service_price = 500
from passenger p, flight f, airplane a
where t.passenger_id = p.passenger_id
and t.flight_id = f.flight_id
and f.airplane_id = a.airplane_id
and p.category_name = 'Пенсионер'
and a.brand = 'Boeing'
returning
    t.ticket_id,
    p.full_name,
    a.brand,
    a.model,
    t.service_price;

rollback;

/*
Задание 15 
Служба безопасности аннулирует учетные карточки клиентов, 
которые были внесены в систему ошибочно или в ходе тестирования интерфейса, 
и при этом не совершили ни одного действия. Необходимо очистить таблицу пассажиров (passenger), 
удалив из нее профили людей, 
на которых в системе не выписано ни одного персонального билета.
*/

begin;

delete from passenger p
where not exists(select 1 from ticket where ticket.passenger_id = p.passenger_id)
returning
    p.passenger_id,
    p.full_name,
    p.passport_no,
    p.category_name;

rollback;