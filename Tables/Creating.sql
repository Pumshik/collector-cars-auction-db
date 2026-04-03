CREATE TABLE IF NOT EXISTS BRAND (
	brand_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE,
	country VARCHAR(100) NOT NULL,
	city VARCHAR(100) NOT NULL,
	founded_year INT,
	website VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS DESIGNER (
    designer_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    country VARCHAR(100) NOT NULL,
    birth_year INT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS MODEL (
    model_id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    start_year INT,
    end_year INT,
    engine_type VARCHAR(50),
    horsepower INT,
    class VARCHAR(50),
    body_style VARCHAR(50),
    FOREIGN KEY (brand_id) REFERENCES BRAND(brand_id),
    CHECK (end_year >= start_year OR end_year IS NULL)
);

CREATE TABLE IF NOT EXISTS MODEL_DESIGNER (
    model_id INT NOT NULL,
    designer_id INT NOT NULL,
    design_part VARCHAR(50),
    PRIMARY KEY (model_id, designer_id),
    FOREIGN KEY (model_id) REFERENCES MODEL(model_id),
    FOREIGN KEY (designer_id) REFERENCES DESIGNER(designer_id),
    CHECK (design_part IN ('exterior', 'interior', 'full'))
);

CREATE TABLE IF NOT EXISTS COLLECTOR (
    collector_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS CAR (
    car_id SERIAL PRIMARY KEY,
    model_id INT NOT NULL,
    current_collector_id INT,
    production_year INT,
    mileage INT,
    condition_state VARCHAR(25),
    color VARCHAR(70),
    interior_color VARCHAR(70),
    notes TEXT,
    FOREIGN KEY (model_id) REFERENCES MODEL(model_id),
    FOREIGN KEY (current_collector_id) REFERENCES COLLECTOR(collector_id),
    CHECK (condition_state IN ('Mint', 'Excellent', 'Good', 'Restored'))
);

CREATE TABLE IF NOT EXISTS AUCTION_LOT (
    lot_id SERIAL PRIMARY KEY,
    car_id INT NOT NULL,
    seller_id INT NOT NULL,
    buyer_id INT,
    lot_number INT,
    date_start DATE NOT NULL,
    date_finish DATE NOT NULL,
    estimated_price_min NUMERIC(15, 2),
    estimated_price_max NUMERIC(15, 2),
    sold_price NUMERIC(15, 2),
    status VARCHAR(20),
    FOREIGN KEY (car_id) REFERENCES CAR(car_id),
    FOREIGN KEY (seller_id) REFERENCES COLLECTOR(collector_id),
    FOREIGN KEY (buyer_id) REFERENCES COLLECTOR(collector_id),
    CHECK (estimated_price_max >= estimated_price_min)
);
