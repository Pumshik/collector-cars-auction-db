# 1) Вывести названия моделей, их бренды и мощности двигателей, где мощность двигателя
превышает среднюю мощность всех моделей в базе.

select m."name", b."name", m.horsepower  from model m join brand b on m.brand_id = b.brand_id 
where m.horsepower > (select avg(horsepower) from model)


# 2) Вывести список всех машин Джея Лено, указав модель, её год выпуска
и страну бренда.

select b."name" as brand , m."name" as model_name, c.production_year, b.country 
from car c join model m on c.model_id = m.model_id
join brand b on m.brand_id = b.brand_id 
join collector c2 on c.current_collector_id = c2.collector_id
where c2.first_name = 'Jay' and c2.last_name = 'Leno'


# 3) Посчитать общее количество проданных машин, суммарную выручку, страну бренда,
сгруппировав их по стране бренда.

select count(al.lot_id ), sum (al.sold_price), b.country  from auction_lot al
join car c on al.car_id = c.car_id
join model m on c.model_id = m.model_id 
join brand b on m.brand_id = b.brand_id where al.status = 'Sold'
group by b.country 


# 4) Найти всех итальянских дизайнеров, которые разработали дизайн модели целиком
и вывести названия этих моделей.

select d."name", m."name"  from designer d join model_designer md on d.designer_id = md.designer_id
join model m on md.model_id = m.model_id where d.country = 'Italy' and md.design_part = 'full'


# 5) Вывести проданные лоты, цена которых максимально отличалась (в процентах) 
максимально ожидаемой, и на сколько именно в процентах и в абсолютных цифрах отсортированное в порядке убывания абсолютной разницы.

select b."name", m."name" , al.estimated_price_max - al.sold_price as abs_diff, 
(1 - al.sold_price/al.estimated_price_max)* 100  as proc_diff from auction_lot al join car c on al.car_id = c.car_id
join model m on c.model_id = m.model_id 
join brand b on m.brand_id = b.brand_id where al.status = 'Sold' order by abs_diff desc


# 6) Для каждого проданного лота вывести название бренда, модель, цену продажи и среднюю цену продажи всех машин этого бренда и
разницу между ценой этой  машины и средней по бренду.
 
select b.name, m.name, al.sold_price,
round(avg(al.sold_price) over(partition by b.brand_id), 2) as brand_avg_price,
round(al.sold_price - avg(al.sold_price) over(partition by b.brand_id), 2) as price_diff
from auction_lot al join car c on al.car_id = c.car_id join model m on c.model_id = m.model_id
join brand b on m.brand_id = b.brand_id where al.status = 'Sold' order by price_diff desc
 

# 7) Найти коллекционеров, которые одновременно являются и продавцами, и покупателями (в успешно закрытых сделках).

select c.first_name, c.last_name from collector c join auction_lot al on c.collector_id = al.buyer_id
where c.collector_id in (select c.collector_id from collector c join auction_lot al
on c.collector_id = al.seller_id where al.status = 'Sold')
and al.status = 'Sold'


# 8) Найти названия брендов, у которых в таблице MODEL есть записи, но ни одна модель этого бренда не 
содержится в истории аукционных лотов.

select b."name"  from brand b join model m on b.brand_id = m.brand_id
where  m.model_id not in (select m2.model_id from model m2
join car c2 on m2.model_id = c2.model_id join auction_lot al2 on c2.car_id = al2.car_id)


# 9) Рассчитать среднюю стоимость одной лошадиной силы для каждого класса автомобилей.
Учитывать только успешно проданные лоты и модели с мощностью выше 100 л.с. и расположить в порядке убывания.

select m."class" , avg(al.sold_price / m.horsepower) as price_per_hp from auction_lot al 
join car c on al.car_id = c.car_id join model m on c.model_id = m.model_id
where al.status = 'Sold' and m.horsepower > 100 group by m."class" 
order by price_per_hp desc


# 10) Рассчитать среднюю цену продажи для каждого состояния, считать только для тех моделей, у
которых в таблице CAR минимум 2 состояния.

with mod_cond as (select model_id from car group by model_id having count(distinct condition_state) >= 3)
select c.condition_state, avg(al.sold_price) from auction_lot al join car c on al.car_id = c.car_id where al.status = 'Sold' and 
c.model_id in (select model_id from mod_cond) group by c.condition_state


