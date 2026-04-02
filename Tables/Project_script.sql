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

INSERT INTO BRAND (name, country, city, founded_year, website) VALUES
('Ferrari', 'Italy', 'Maranello', 1947, 'ferrari.com'),
('Lamborghini', 'Italy', 'Sant Agata Bolognese', 1963, 'lamborghini.com'),
('Porsche', 'Germany', 'Stuttgart', 1931, 'porsche.com'),
('Aston Martin', 'UK', 'Gaydon', 1913, 'astonmartin.com'),
('Bugatti', 'France', 'Molsheim', 1909, 'bugatti.com'),
('Mercedes-Benz', 'Germany', 'Stuttgart', 1926, 'mercedes-benz.com'),
('BMW', 'Germany', 'Munich', 1916, 'bmw.com'),
('Audi', 'Germany', 'Ingolstadt', 1909, 'audi.com'),
('Maserati', 'Italy', 'Modena', 1914, 'maserati.com'),
('Alfa Romeo', 'Italy', 'Milan', 1910, 'alfaromeo.com'),
('Jaguar', 'UK', 'Coventry', 1922, 'jaguar.com'),
('Rolls-Royce', 'UK', 'Goodwood', 1904, 'rolls-roycemotorcars.com'),
('Bentley', 'UK', 'Crewe', 1919, 'bentleymotors.com'),
('McLaren', 'UK', 'Woking', 1963, 'mclaren.com'),
('Pagani', 'Italy', 'San Cesario sul Panaro', 1992, 'pagani.com'),
('Koenigsegg', 'Sweden', 'Ängelholm', 1994, 'koenigsegg.com'),
('Ford', 'USA', 'Dearborn', 1903, 'ford.com'),
('Chevrolet', 'USA', 'Detroit', 1911, 'chevrolet.com'),
('Toyota', 'Japan', 'Toyota City', 1937, 'toyota-global.com'),
('Nissan', 'Japan', 'Yokohama', 1933, 'nissan-global.com');

INSERT INTO DESIGNER (name, country, birth_year, notes) VALUES
('Marcello Gandini', 'Italy', 1938, 'Worked for Bertone, designed Miura and Countach.'),
('Giorgetto Giugiaro', 'Italy', 1938, 'Founder of Italdesign, Car Designer of the Century.'),
('Leonardo Fioravanti', 'Italy', 1938, 'Designed classic Ferraris at Pininfarina.'),
('Ian Callum', 'UK', 1954, 'Known for Aston Martin DB9 and Jaguar F-Type.'),
('Gordon Murray', 'South Africa', 1946, 'Designer of the McLaren F1.'),
('Horacio Pagani', 'Argentina', 1955, 'Founder of Pagani Automobili.'),
('Sergio Scaglietti', 'Italy', 1920, 'Famous for Ferrari 250 Testa Rossa.'),
('Bruno Sacco', 'Italy', 1933, 'Head of design at Mercedes-Benz for decades.'),
('Malcolm Sayer', 'UK', 1916, 'Aerodynamicist, designed Jaguar E-Type.'),
('Battista Pininfarina', 'Italy', 1893, 'Founder of Pininfarina design house.'),
('Ercole Spada', 'Italy', 1937, 'Worked for Zagato, designed Aston Martin DB4 GT.'),
('Peter Stevens', 'UK', 1943, 'Worked on McLaren F1 and Lotus Esprit.'),
('Frank Stephenson', 'Morocco', 1959, 'Designed BMW Mini, Fiat 500, and McLaren MP4-12C.'),
('Walter de Silva', 'Italy', 1951, 'Designed Alfa Romeo 156 and Audi R8.'),
('Peter Schreyer', 'Germany', 1953, 'Known for Audi TT design.'),
('Robert Opron', 'France', 1932, 'Designed Citroën SM and Alpine A310.'),
('Adrian Newey', 'UK', 1958, 'F1 engineer, designed Aston Martin Valkyrie.'),
('Marek Reichman', 'UK', 1966, 'Chief Creative Officer at Aston Martin.'),
('Ferdinand Alexander Porsche', 'Germany', 1935, 'Designer of the Porsche 911.'),
('Shiro Nakamura', 'Japan', 1950, 'Designed Nissan GT-R and 350Z.');

INSERT INTO MODEL (brand_id, name, start_year, end_year, engine_type, horsepower, class, body_style) VALUES
(1, 'F40', 1987, 1992, 'V8 Twin-Turbo', 471, 'Supercar', 'Coupe'),
(2, 'Miura', 1966, 1973, 'V12', 350, 'Sports Car', 'Coupe'),
(3, '911 Turbo (930)', 1975, 1989, 'Flat-6 Turbo', 260, 'Sports Car', 'Coupe'),
(4, 'DB5', 1963, 1965, 'Straight-6', 282, 'Grand Tourer', 'Coupe'),
(5, 'Veyron', 2005, 2015, 'W16 Quad-Turbo', 1001, 'Hypercar', 'Coupe'),
(6, '300 SL Gullwing', 1954, 1957, 'Straight-6', 215, 'Sports Car', 'Coupe'),
(7, 'M1', 1978, 1981, 'Straight-6', 273, 'Sports Car', 'Coupe'),
(8, 'R8', 2006, 2023, 'V10', 525, 'Supercar', 'Coupe'),
(9, 'MC12', 2004, 2005, 'V12', 621, 'Supercar', 'Coupe'),
(10, 'Giulia TZ', 1963, 1967, 'Inline-4', 112, 'Racing Car', 'Coupe'),
(11, 'E-Type', 1961, 1975, 'Straight-6', 265, 'Sports Car', 'Roadster'),
(12, 'Phantom VII', 2003, 2017, 'V12', 453, 'Luxury', 'Sedan'),
(13, 'Continental R', 1991, 2003, 'V8 Turbo', 325, 'Luxury', 'Coupe'),
(14, 'F1', 1992, 1998, 'V12', 618, 'Hypercar', 'Coupe'),
(15, 'Zonda C12', 1999, 2002, 'V12', 394, 'Hypercar', 'Coupe'),
(16, 'CCX', 2006, 2010, 'V8 Twin-Supercharged', 806, 'Hypercar', 'Coupe'),
(17, 'GT40', 1964, 1969, 'V8', 485, 'Racing Car', 'Coupe'),
(18, 'Corvette C2', 1963, 1967, 'V8', 250, 'Sports Car', 'Coupe'),
(19, '2000GT', 1967, 1970, 'Straight-6', 150, 'Sports Car', 'Coupe'),
(20, 'GT-R (R34)', 1999, 2002, 'Straight-6 Twin-Turbo', 276, 'Sports Car', 'Coupe');

INSERT INTO MODEL_DESIGNER (model_id, designer_id, design_part) VALUES
(1, 3, 'full'), (2, 1, 'exterior'), (3, 19, 'full'), (4, 11, 'exterior'),
(5, 13, 'full'), (6, 10, 'exterior'), (7, 2, 'full'), (8, 14, 'full'),
(9, 2, 'exterior'), (10, 11, 'full'), (11, 9, 'full'), (12, 18, 'interior'),
(13, 12, 'full'), (14, 5, 'full'), (15, 6, 'full'), (16, 6, 'full'),
(17, 17, 'exterior'), (18, 20, 'exterior'), (19, 2, 'exterior'), (20, 20, 'full');

INSERT INTO COLLECTOR (first_name, last_name, country, city) VALUES
('Jay', 'Leno', 'USA', 'Burbank'),
('Jerry', 'Seinfeld', 'USA', 'New York'),
('Ralph', 'Lauren', 'USA', 'New York'),
('Lawrence', 'Stroll', 'Canada', 'Montreal'),
('Horacio', 'Pagani', 'Italy', 'Modena'),
('Nick', 'Mason', 'UK', 'London'),
('Ken', 'Lingenfelter', 'USA', 'Brighton'),
('Magnus', 'Walker', 'UK', 'Los Angeles'),
('James', 'Glickenhaus', 'USA', 'Sleepy Hollow'),
('David', 'Lee', 'USA', 'Los Angeles'),
('Khalid', 'Abdul Rahim', 'Bahrain', 'Manama'),
('Miles', 'Collier', 'USA', 'Naples'),
('Evert', 'Louwman', 'Netherlands', 'The Hague'),
('Bruce', 'Meyer', 'USA', 'Beverly Hills'),
('Rob', 'Walton', 'USA', 'Bentonville'),
('Gordon', 'Ramsey', 'UK', 'London'),
('Lewis', 'Hamilton', 'UK', 'Monaco'),
('Cristiano', 'Ronaldo', 'Portugal', 'Lisbon'),
('Manny', 'Khoshbin', 'USA', 'Irvine'),
('Rowan', 'Atkinson', 'UK', 'Oxford');

INSERT INTO CAR (model_id, current_collector_id, production_year, mileage, condition_state, color, interior_color, notes) VALUES
(1, 1, 1990, 1500, 'Mint', 'Rosso Corsa', 'Red', 'Ex-collection of a famous racer.'),
(2, 2, 1971, 12000, 'Excellent', 'Arancio Miura', 'Black', 'Original engine.'),
(3, 8, 1978, 45000, 'Restored', 'Silver', 'Black', 'Restored by Magnus Walker.'),
(4, 1, 1964, 30000, 'Excellent', 'Silver Birch', 'Black', 'Movie spec car.'),
(5, 19, 2008, 2500, 'Mint', 'Blue/Black', 'Beige', 'Special edition Hermès.'),
(6, 14, 1955, 18000, 'Excellent', 'Silver', 'Red Plaid', 'Original Gullwing doors.'),
(7, 7, 1980, 5000, 'Good', 'White', 'Black', 'Homologation special.'),
(8, 16, 2010, 8000, 'Excellent', 'Daytona Grey', 'Black', 'V10 Manual.'),
(9, 11, 2005, 500, 'Mint', 'White/Blue', 'Blue', 'One of 50 units.'),
(10, 12, 1964, 4500, 'Restored', 'Alfa Red', 'Black', 'Tube chassis race car.'),
(11, 6, 1961, 25000, 'Excellent', 'British Racing Green', 'Tan', 'Early flat-floor model.'),
(12, 18, 2015, 1200, 'Mint', 'Black', 'White', 'Custom interior.'),
(13, 20, 1995, 35000, 'Good', 'Green', 'Cream', 'Luxury grand tourer.'),
(14, 20, 1997, 10000, 'Excellent', 'Dark Purple', 'Grey', 'Famously crashed and repaired.'),
(15, 5, 1999, 100, 'Mint', 'Silver', 'Blue', 'Chassis number 001.'),
(16, 11, 2007, 3000, 'Excellent', 'Carbon Fiber', 'Black', 'Top Gear tested.'),
(17, 4, 1966, 15000, 'Restored', 'Gulf Livery', 'Black', 'Le Mans winner.'),
(18, 1, 1963, 40000, 'Good', 'Split Window Blue', 'Blue', 'Iconic split window.'),
(19, 13, 1967, 12000, 'Excellent', 'White', 'Black', 'The first Japanese supercar.'),
(20, 19, 2002, 15000, 'Mint', 'Bayside Blue', 'Grey', 'Z-Tune spec.');

INSERT INTO AUCTION_LOT (car_id, seller_id, buyer_id, lot_number, date_start, date_finish, estimated_price_min, estimated_price_max, sold_price, status) VALUES
(1, 3, 1, 101, '2023-01-10', '2023-01-12', 2000000, 2500000, 2400000, 'Sold'),
(2, 4, 2, 202, '2023-02-15', '2023-02-16', 1500000, 1800000, 1750000, 'Sold'),
(3, 8, 8, 303, '2023-03-05', '2023-03-06', 150000, 200000, NULL, 'Passed'),
(4, 15, 1, 404, '2023-04-20', '2023-04-22', 5000000, 7000000, 6800000, 'Sold'),
(5, 11, 19, 505, '2023-05-12', '2023-05-13', 1200000, 1500000, 1400000, 'Sold'),
(6, 12, 14, 606, '2023-06-01', '2023-06-02', 3000000, 4000000, 3850000, 'Sold'),
(7, 10, 7, 707, '2023-07-14', '2023-07-15', 400000, 600000, 550000, 'Sold'),
(8, 13, 16, 808, '2023-08-10', '2023-08-11', 150000, 200000, 185000, 'Sold'),
(9, 6, 11, 909, '2023-09-20', '2023-09-22', 3000000, 3500000, 3300000, 'Sold'),
(10, 20, 12, 1010, '2023-10-05', '2023-10-07', 800000, 1100000, 950000, 'Sold'),
(11, 1, 6, 1111, '2023-11-12', '2023-11-14', 1000000, 1500000, 1450000, 'Sold'),
(12, 2, 18, 1212, '2023-12-01', '2023-12-03', 300000, 450000, 420000, 'Sold'),
(13, 9, 20, 1313, '2024-01-15', '2024-01-16', 50000, 80000, 75000, 'Sold'),
(14, 17, 20, 1414, '2024-02-10', '2024-02-12', 15000000, 20000000, 19800000, 'Sold'),
(15, 15, 5, 1515, '2024-03-05', '2024-03-07', 2500000, 3000000, 2900000, 'Sold'),
(16, 19, 11, 1616, '2024-04-18', '2024-04-20', 1000000, 1200000, 1150000, 'Sold'),
(17, 10, 4, 1717, '2024-05-22', '2024-05-24', 8000000, 12000000, 11000000, 'Sold'),
(18, 16, 1, 1818, '2024-06-12', '2024-06-14', 200000, 300000, 275000, 'Sold'),
(19, 7, 13, 1919, '2024-07-01', '2024-07-03', 900000, 1200000, 1100000, 'Sold'),
(20, 14, 19, 2020, '2024-08-15', '2024-08-17', 300000, 500000, 480000, 'Sold');
