--1) Вывести названия моделей, их бренды и мощности двигателей, где мощность двигателя
--превышает среднюю мощность всех моделей в базе.

SELECT m."name", b."name", m.horsepower

FROM model m
JOIN brand b ON m.brand_id = b.brand_id
WHERE m.horsepower > (SELECT AVG(horsepower) FROM model);

--2) Вывести список всех машин Джея Лено, указав модель, её год выпуска
--и страну бренда.

SELECT b."name" AS brand, m."name" AS model_name, c.production_year, b.country
FROM car c
JOIN model m ON c.model_id = m.model_id
JOIN brand b ON m.brand_id = b.brand_id
JOIN collector c2 ON c.current_collector_id = c2.collector_id
WHERE c2.first_name = 'Jay' AND c2.last_name = 'Leno';

--3) Посчитать общее количество проданных машин, суммарную выручку, страну бренда,
--сгруппировав их по стране бренда.

SELECT COUNT(al.lot_id), SUM(al.sold_price), b.country

FROM auction_lot al
JOIN car c ON al.car_id = c.car_id
JOIN model m ON c.model_id = m.model_id
JOIN brand b ON m.brand_id = b.brand_id
WHERE al.status = 'Sold'
GROUP BY b.country;

--4) Найти всех итальянских дизайнеров, которые разработали дизайн модели целиком
--и вывести названия этих моделей.

SELECT d."name", m."name"

FROM designer d
JOIN model_designer md ON d.designer_id = md.designer_id
JOIN model m ON md.model_id = m.model_id
WHERE d.country = 'Italy' AND md.design_part = 'full';

--5) Вывести проданные лоты, цена которых максимально отличалась (в процентах)
--максимально ожидаемой, и на сколько именно в процентах и в абсолютных цифрах отсортированное в порядке убывания абсолютной разницы.

SELECT
b."name",
m."name",
al.estimated_price_max - al.sold_price AS abs_diff,
(1 - al.sold_price / al.estimated_price_max) * 100 AS proc_diff
FROM auction_lot al
JOIN car c ON al.car_id = c.car_id
JOIN model m ON c.model_id = m.model_id
JOIN brand b ON m.brand_id = b.brand_id
WHERE al.status = 'Sold'
ORDER BY abs_diff DESC;

--6) Для каждого проданного лота вывести название бренда, модель, цену продажи и среднюю цену продажи всех машин этого бренда и
--разницу между ценой этой машины и средней по бренду.

SELECT
b.name,
m.name,
al.sold_price,
ROUND(AVG(al.sold_price) OVER(PARTITION BY b.brand_id), 2) AS brand_avg_price,
ROUND(al.sold_price - AVG(al.sold_price) OVER(PARTITION BY b.brand_id), 2) AS price_diff
FROM auction_lot al
JOIN car c ON al.car_id = c.car_id
JOIN model m ON c.model_id = m.model_id
JOIN brand b ON m.brand_id = b.brand_id
WHERE al.status = 'Sold'
ORDER BY price_diff DESC;

--7) Найти коллекционеров, которые одновременно являются и продавцами, и покупателями (в успешно закрытых сделках).

SELECT c.first_name, c.last_name
FROM collector c
JOIN auction_lot al ON c.collector_id = al.buyer_id
WHERE c.collector_id IN (
SELECT c2.collector_id
FROM collector c2
JOIN auction_lot al2 ON c2.collector_id = al2.seller_id
WHERE al2.status = 'Sold'
)
AND al.status = 'Sold';

--8) Найти названия брендов, у которых в таблице MODEL есть записи, но ни одна модель этого бренда не
--содержится в истории аукционных лотов.

SELECT b."name"

FROM brand b
JOIN model m ON b.brand_id = m.brand_id
WHERE m.model_id NOT IN (
SELECT m2.model_id
FROM model m2
JOIN car c2 ON m2.model_id = c2.model_id
JOIN auction_lot al2 ON c2.car_id = al2.car_id
);

--9) Рассчитать среднюю стоимость одной лошадиной силы для каждого класса автомобилей.
--Учитывать только успешно проданные лоты и модели с мощностью выше 100 л.с. и расположить в порядке убывания.

SELECT m."class", AVG(al.sold_price / m.horsepower) AS price_per_hp
FROM auction_lot al
JOIN car c ON al.car_id = c.car_id
JOIN model m ON c.model_id = m.model_id
WHERE al.status = 'Sold' AND m.horsepower > 100
GROUP BY m."class"
ORDER BY price_per_hp DESC;

--10) Рассчитать среднюю цену продажи для каждого состояния, считать только для тех моделей, у
--которых в таблице CAR минимум 3 состояния.

WITH mod_cond AS (
SELECT model_id
FROM car
GROUP BY model_id
HAVING COUNT(DISTINCT condition_state) >= 3
)
SELECT c.condition_state, AVG(al.sold_price)
FROM auction_lot al
JOIN car c ON al.car_id = c.car_id
WHERE al.status = 'Sold'
AND c.model_id IN (SELECT model_id FROM mod_cond)
GROUP BY c.condition_state;