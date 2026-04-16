-- ФУНКЦИИ

--1) Функция автоматически меняет актуального владельца при продаже

CREATE OR REPLACE FUNCTION set_owner()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'Sold' AND NEW.buyer_id IS NOT NULL) THEN
        UPDATE CAR
        SET current_collector_id = NEW.buyer_id
        WHERE car_id = NEW.car_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--2) Функция не допускает скручивание пробега

CREATE OR REPLACE FUNCTION ban_mileage_rollback()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.mileage < OLD.mileage) THEN
        RAISE EXCEPTION 'Корректировка пробега невозможна. Старый: %, Новый: %', OLD.mileage, NEW.mileage;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--3) Функция считает, насколько относительно цена этой машины выше или ниже средней цены всех машин в базе

CREATE OR REPLACE FUNCTION GET_PREMIUM_PCT(p_car_id INT)
RETURNS NUMERIC AS $$
DECLARE
    car_price NUMERIC;
    market_avg NUMERIC;
    percentage NUMERIC;
BEGIN
    SELECT sold_price INTO car_price 
    FROM AUCTION_LOT 
    WHERE car_id = p_car_id AND status = 'Sold';
    SELECT AVG(sold_price) INTO market_avg 
    FROM AUCTION_LOT 
    WHERE status = 'Sold';
    IF market_avg > 0 AND car_price IS NOT NULL THEN
        percentage := ((car_price - market_avg) / market_avg) * 100;
    ELSE
        percentage := 0;
    END IF;
    RETURN ROUND(percentage, 2);
END;
$$ LANGUAGE plpgsql;


--4) Функция считает, на сколько процентов средняя цена продажи машин
-- конкретного дизайнера выше или ниже средней цены вообще всех проданных машин.

CREATE OR REPLACE FUNCTION GET_DESIGNER_PRICE_INDEX(p_designer_id INT)
RETURNS NUMERIC AS $$
DECLARE
    designer_avg_price NUMERIC;
    total_market_avg NUMERIC;
    index_pct NUMERIC;
BEGIN
    SELECT AVG(al.sold_price) INTO designer_avg_price
    FROM AUCTION_LOT al
    JOIN CAR c ON al.car_id = c.car_id
    JOIN MODEL_DESIGNER md ON c.model_id = md.model_id
    WHERE md.designer_id = p_designer_id AND al.status = 'Sold';
    SELECT AVG(sold_price) INTO total_market_avg
    FROM AUCTION_LOT
    WHERE status = 'Sold';
    IF total_market_avg > 0 AND designer_avg_price IS NOT NULL THEN
        index_pct := ((designer_avg_price - total_market_avg) / total_market_avg) * 100;
    ELSE
        index_pct := 0;
    END IF;

    RETURN ROUND(index_pct, 2);
END;
$$ LANGUAGE plpgsql;


--5) Функция для конкретной машины считает, сколько стоит одна лошадиная сила
-- по сравнению со средним показателем для её класса.

CREATE OR REPLACE FUNCTION GET_HP_EFFICIENCY_INDEX(p_car_id INT)
RETURNS NUMERIC AS $$
DECLARE
    current_car_hp_cost NUMERIC;
    class_avg_hp_cost NUMERIC;
    car_class VARCHAR;
    efficiency_pct NUMERIC;
BEGIN
    SELECT (al.sold_price / m.horsepower), m.class 
    INTO current_car_hp_cost, car_class
    FROM AUCTION_LOT al
    JOIN CAR c ON al.car_id = c.car_id
    JOIN MODEL m ON c.model_id = m.model_id
    WHERE c.car_id = p_car_id AND al.status = 'Sold';
    SELECT AVG(al.sold_price / m.horsepower) INTO class_avg_hp_cost
    FROM AUCTION_LOT al
    JOIN CAR c ON al.car_id = c.car_id
    JOIN MODEL m ON c.model_id = m.model_id
    WHERE m.class = car_class AND al.status = 'Sold';
    IF class_avg_hp_cost > 0 AND current_car_hp_cost IS NOT NULL THEN
        efficiency_pct := ((current_car_hp_cost - class_avg_hp_cost) / class_avg_hp_cost) * 100;
    ELSE
        efficiency_pct := 0;
    END IF;

    RETURN ROUND(efficiency_pct, 2);
END;
$$ LANGUAGE plpgsql;


--ТРИГГЕРЫ

-- 1) Автоматическая смена владельца после аукциона
CREATE TRIGGER TRG_AFTER_AUCTION_SALE
AFTER UPDATE ON AUCTION_LOT
FOR EACH ROW
EXECUTE FUNCTION SET_OWNER();


-- 2) Защита от скручивания
CREATE TRIGGER TRG_BEFORE_CAR_MILEAGE_UPDATE
BEFORE UPDATE OF mileage ON CAR
FOR EACH ROW
EXECUTE FUNCTION BAN_MILEAGE_ROLLBACK();


--ПРЕДСТАВЛЕНИЯ

-- 1) Собирает информауию о лотах, которые сейчас в продаже, соединяет бренд, модель и так далее для наиболее полных данных

CREATE OR REPLACE VIEW ACTIVE_AUCTIONS AS
SELECT 
    al.lot_number,
    b.name AS brand_name,
    m.name AS model_name,
    c.production_year,
    c.condition_state,
    al.estimated_price_min,
    al.estimated_price_max,
    al.date_finish
FROM AUCTION_LOT al
JOIN CAR c ON al.car_id = c.car_id
JOIN MODEL m ON c.model_id = m.model_id
JOIN BRAND b ON m.brand_id = b.brand_id
WHERE al.status = 'Active';


-- 2) Считает статистику по каждому бренду: количество проданных машин, выручку, 
-- средний процент успеха продажи (отношение фактической цены и максимальной оценки)

CREATE MATERIALIZED VIEW BRAND_MARKET_STATS AS
SELECT 
    b.name,
    COUNT(al.lot_id) AS total_lots,
    SUM(CASE WHEN al.status = 'Sold' THEN 1 ELSE 0 END) AS sold_count,
    SUM(al.sold_price) AS total_revenue,
    ROUND(AVG(al.sold_price), 2) AS avg_sale_price,
    ROUND(AVG((al.sold_price / al.estimated_price_max) * 100), 2) AS success_rate
FROM BRAND b
JOIN MODEL m ON b.brand_id = m.brand_id
JOIN CAR c ON m.model_id = c.model_id
JOIN AUCTION_LOT al ON c.car_id = al.car_id
GROUP BY b.brand_id, b.name;

-- Не забыть для обновления:
-- REFRESH MATERIALIZED VIEW BRAND_MARKET_STATS;


--ИНДЕКСЫ
--1) Индекс для статуса, потому что частно приходится использовать условие WHERE al.status = 'Sold'
CREATE INDEX IDX_AUCTION_STATUS ON AUCTION_LOT(status);

--2) Индекс для удобного соединения машин с моделями. потому что это часто происходит
CREATE INDEX IDX_CAR_MODEL_ID ON CAR(model_id);

--3) Индекс для удобной фильтрации по названию бренда и вывода названия бренда
CREATE INDEX IDX_BRAND_NAME ON BRAND(name);

