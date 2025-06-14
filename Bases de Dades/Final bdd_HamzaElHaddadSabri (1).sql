/********************************************************************/
/*            ARXIU ÚNIC .SQL - Entrega 3 (Tenda Online)            */
/*                                                                  */
/*            Autor: [Hamza]     */
/*            Data: [Data d'entrega]                                */
/*                                                                  */
/*    Conté:                                                        */
/*      1) Creació i població de la taula RelacioUniversal          */
/*         (Es copia directament el codi donat a l’enunciat).       */
/*      2) Tasca 1: Normalització (FNBC) i creació de l'esquema.    */
/*      3) Tasca 2: Processament de comandes en ordre temporal.     */
/*      4) Tasca Bonus: Creació d'un trigger per calcular PreuTotal */
/********************************************************************/

------------------------------
-- 1) CREACIÓ DE RelacioUniversal (codi original proporcionat)
------------------------------

DROP TABLE IF EXISTS RelacioUniversal CASCADE;

CREATE TABLE RelacioUniversal (
    IDComanda SERIAL PRIMARY KEY,   -- ID de la comanda amb auto-increment
    IDClient VARCHAR(10),           -- ID del client
    NomClient VARCHAR(50),          -- Nom del client
    CorreuElectronic VARCHAR(100),  -- Correu electrònic del client
    AdrecaEnviament VARCHAR(100),   -- Adreça d'enviament
    Saldo DECIMAL(10, 2),           -- Saldo del client
    IDProducte VARCHAR(10),         -- ID del producte
    NomProducte VARCHAR(50),        -- Nom del producte
    Categoria VARCHAR(50),          -- Categoria del producte
    Preu DECIMAL(10, 2),            -- Preu del producte
    DataComanda DATE,               -- Data de la comanda
    Quantitat INT,                  -- Quantitat de productes
    PreuTotal DECIMAL(10, 2),       -- Preu total de la comanda
    MetodePagament VARCHAR(20)      -- Mètode de pagament
);

-- Establir el "seed" del generador aleatori
SELECT setseed(0.5);

DO $$ 
DECLARE 
    client_id VARCHAR(10);
    client_name VARCHAR(50);
    client_email VARCHAR(100);
    product_id VARCHAR(10);
    product_name VARCHAR(50);
    category VARCHAR(50);
    price DECIMAL(10, 2);
    quantity INT;
    total DECIMAL(10, 2);
    payment_method VARCHAR(20);
    order_date DATE;
    num_orders INT;
	street_name TEXT;
	street_number INT;
	saldo INT;
	postal_code INT;
	city_name TEXT;
	full_address TEXT;
	i INT := 1; -- Inicialitzem l'índex manualment
    max_iterations INT := 999;
    
    -- Llistes de noms, cognoms, carrers i ciutats per generar combinacions úniques
    first_names TEXT[] := ARRAY['Anna', 'Joan', 'Marta', 'Lluís', 'Carla', 'David', 'Laura', 'Pau', 'Eva', 'Andreu', 'Sergi', 'Marc', 'Xavi', 'Maria', 'Pere', 'Carles', 'Judit', 'Clara', 'Xènia', 'Alba'];
    last_names TEXT[] := ARRAY['Martínez', 'Pérez', 'García', 'Rodríguez', 'López', 'Sánchez', 'Fernández', 'González', 'Díaz', 'Romero', 'Torres', 'Vázquez', 'Ramírez', 'Serrano', 'Moreno', 'Ruiz', 'Jiménez', 'Moya', 'Suárez', 'Cordero'];
    streets TEXT[] := ARRAY['Carrer de la Pau', 'Carrer del Sol', 'Avinguda Catalunya', 'Carrer Esplugues', 'Carrer Gran de Gràcia', 'Carrer de la Rambla', 'Carrer del Portal', 'Carrer del Doctor Trueta', 'Avinguda Diagonal', 'Carrer de Balmes'];
    cities TEXT[] := ARRAY['Barcelona', 'Madrid', 'València', 'Sevilla', 'Zaragoza', 'Màlaga', 'Murcia', 'Palma de Mallorca', 'Bilbao', 'Castelló'];
    
BEGIN
    -- Crear 999 clients i les seves comandes
    WHILE i <= max_iterations LOOP
        -- Assignar valors aleatoris per a cada client
        client_id := 'C' || LPAD(i::TEXT, 3, '0');
        
        -- Combinar un nom i un cognom aleatoriament per crear el nom complet del client
        client_name := first_names[(random() * array_length(first_names, 1))::INT] || ' ' || last_names[(random() * array_length(last_names, 1))::INT];

		-- Saltar iteració si client_name és NULL
		IF client_name IS NULL THEN
		    CONTINUE;
		END IF;
        
        -- Generar un correu electrònic basat en el nom complet
        client_email := lower(replace(client_name, ' ', '.')) || '.' || (random() * 1000)::INT || '@example.com';

        -- Assignar un nombre aleatori de comandes per client (aproximadament 1000 per client)
        num_orders := floor(random() * 2) + 1000; -- 1000 o 1001 comandes per client

		-- Generar una adreça d'enviament aleatòria
		street_name := streets[(random() * array_length(streets, 1))::INT];
		street_number := (random() * 100);  -- Número entre 1 i 100
		postal_code := (random() * (99999 - 10000) + 10000);  -- Codi postal entre 10000 i 99999
		city_name := cities[(random() * array_length(cities, 1))::INT ];
		full_address := street_name || ' ' || street_number || ', ' || postal_code || ' ' || city_name;

		saldo := (random() * 2000) + 1900000;

        -- Generar les comandes per aquest client
        FOR j IN 1..num_orders LOOP
            product_id := 'P' || LPAD((random()*8)::INT::TEXT, 3, '0');
            product_name := CASE
                                WHEN product_id = 'P001' THEN 'Portàtil Dell XPS'
                                WHEN product_id = 'P002' THEN 'Auriculars Sony WH-1000XM5'
                                WHEN product_id = 'P003' THEN 'Ratolí Logitech MX Master 3'
                                WHEN product_id = 'P004' THEN 'Teclat mecànic Corsair K95'
                                WHEN product_id = 'P005' THEN 'Càmera Nikon Z6'
                                WHEN product_id = 'P006' THEN 'Smartphone Samsung Galaxy S23'
                                WHEN product_id = 'P007' THEN 'Smartwatch Apple Watch Ultra'
                                WHEN product_id = 'P008' THEN 'TV Samsung QLED 55"'
                                ELSE 'Producte ' || product_id
                            END;
            category := CASE
                            WHEN product_name LIKE '%Portàtil%' THEN 'Electrònica'
                            WHEN product_name LIKE '%Auriculars%' THEN 'Accessoris'
                            WHEN product_name LIKE '%Ratolí%' THEN 'Accessoris'
                            WHEN product_name LIKE '%Teclat%' THEN 'Accessoris'
                            WHEN product_name LIKE '%Càmera%' THEN 'Fotografia'
                            WHEN product_name LIKE '%Smartphone%' THEN 'Electrònica'
                            WHEN product_name LIKE '%Smartwatch%' THEN 'Accessoris'
                            WHEN product_name LIKE '%TV%' THEN 'Electrònica'
                            ELSE 'Electrònica'
                        END;
            price := (random() * 1000) + 50;  -- Preu aleatori entre 50 i 1050
            quantity := (random() * 5) + 1;  -- Quantitat aleatòria entre 1 i 5
            total := price * quantity;       -- Total de la comanda
            payment_method := CASE
                                WHEN random() > 0.5 THEN 'Targeta de crèdit'
                                ELSE 'PayPal'
                            END;
            order_date := TO_DATE('2024-12-18', 'YYYY-MM-DD') - (floor(random() * 30) || ' days')::INTERVAL; 

            BEGIN
                -- Insertar les comandes a la taula
                EXECUTE format('
                    INSERT INTO RelacioUniversal (IDClient, NomClient, CorreuElectronic, AdrecaEnviament, Saldo, IDProducte, NomProducte, Categoria, Preu, DataComanda, Quantitat, PreuTotal, MetodePagament)
                    VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L);',
                    client_id, client_name, client_email, full_address, saldo, product_id, product_name, category, price, order_date, quantity, total, payment_method);
            END;
        END LOOP;
	    i := i + 1;
    END LOOP;
END $$;

-- Ajust final de l’IDComanda perquè no sigui semiestratificat per l’ordre d’inserció
ALTER TABLE RelacioUniversal ADD COLUMN TempIDComanda SERIAL;

WITH RandomizedComands AS (
    SELECT IDComanda, 
           ROW_NUMBER() OVER (ORDER BY random()) AS NewIDComanda
    FROM RelacioUniversal
)
UPDATE RelacioUniversal
SET TempIDComanda = RandomizedComands.NewIDComanda
FROM RandomizedComands
WHERE RelacioUniversal.IDComanda = RandomizedComands.IDComanda;

ALTER TABLE RelacioUniversal DROP COLUMN IDComanda;
ALTER TABLE RelacioUniversal RENAME COLUMN TempIDComanda TO IDComanda;
ALTER TABLE RelacioUniversal ADD PRIMARY KEY (IDComanda);




/********************************************************************/
/*            ARXIU ÚNIC .SQL - Entrega 3 (Tenda Online)            */
/*                                                                  */
/*            Autor: [Hamza]                               */
/*            Data: [Data d'entrega]                                */
/*                                                                  */
/*    Conté:                                                        */
/*      2) Tasca 1: Normalització (FNBC) i creació de l'esquema.    */
/*      3) Tasca 2: Processament de comandes en ordre temporal.     */
/*      4) Tasca Bonus: Creació d'un trigger per calcular PreuTotal */
/*                                                                  */
/*            A partir d'aqui comença l'activitat                   */
/********************************************************************/



------------------------------
-- 2) Tasca 1: Normalització (FNBC)
------------------------------

DROP TABLE IF EXISTS DetallsComandes CASCADE;
DROP TABLE IF EXISTS Comandes CASCADE;
DROP TABLE IF EXISTS Productes CASCADE;
DROP TABLE IF EXISTS Clients CASCADE;

CREATE TABLE Clients (
    IDClient VARCHAR(10) PRIMARY KEY,
    NomClient VARCHAR(50),
    CorreuElectronic VARCHAR(100),
    AdrecaEnviament VARCHAR(100),
    Saldo DECIMAL(10, 2)
);

CREATE TABLE Productes (
    IDProducte VARCHAR(10) PRIMARY KEY,
    NomProducte VARCHAR(50),
    Categoria VARCHAR(50),
    Preu DECIMAL(10, 2)
);

CREATE TABLE Comandes (
    IDComanda SERIAL PRIMARY KEY,
    IDClient VARCHAR(10) REFERENCES Clients(IDClient),
    DataComanda DATE,
    MetodePagament VARCHAR(20)
);

CREATE TABLE DetallsComandes (
    IDComanda INT REFERENCES Comandes(IDComanda),
    IDProducte VARCHAR(10) REFERENCES Productes(IDProducte),
    Quantitat INT,
    PreuTotal DECIMAL(10, 2),
    PRIMARY KEY (IDComanda, IDProducte)
);

------------------------------
-- 3) Tasca 2: Processament de comandes en ordre temporal
------------------------------

-- Inserir dades a la taula Clients
INSERT INTO Clients (IDClient, NomClient, CorreuElectronic, AdrecaEnviament, Saldo)
SELECT DISTINCT IDClient, NomClient, CorreuElectronic, AdrecaEnviament, Saldo 
FROM RelacioUniversal;

-- Inserir dades a la taula Productes
INSERT INTO Productes (IDProducte, NomProducte, Categoria, Preu)
SELECT IDProducte, MAX(NomProducte), MAX(Categoria), MAX(Preu)
FROM RelacioUniversal
GROUP BY IDProducte;

-- Inserir dades a la taula Comandes
INSERT INTO Comandes (IDComanda, IDClient, DataComanda, MetodePagament)
SELECT DISTINCT IDComanda, IDClient, DataComanda, MetodePagament 
FROM RelacioUniversal;

-- Inserir dades a la taula DetallsComandes
INSERT INTO DetallsComandes (IDComanda, IDProducte, Quantitat, PreuTotal)
SELECT DISTINCT IDComanda, IDProducte, Quantitat, PreuTotal 
FROM RelacioUniversal;

-- Crear índexs per millorar el rendiment
CREATE INDEX idx_clients_idclient ON Clients(IDClient);
CREATE INDEX idx_productes_idproducte ON Productes(IDProducte);
CREATE INDEX idx_comandes_idclient ON Comandes(IDClient);
CREATE INDEX idx_detallscomandes_idcomanda ON DetallsComandes(IDComanda);

------------------------------
-- 4) Tasca Bonus: Trigger per calcular PreuTotal
------------------------------

CREATE OR REPLACE FUNCTION calcular_preu_total()
RETURNS TRIGGER AS $$
BEGIN
    NEW.PreuTotal := (SELECT p.Preu * NEW.Quantitat
                      FROM Productes p
                      WHERE p.IDProducte = NEW.IDProducte);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_preu_total
BEFORE INSERT OR UPDATE ON DetallsComandes
FOR EACH ROW
EXECUTE FUNCTION calcular_preu_total();

-- Consulta d'exemple per verificar el rendiment
EXPLAIN ANALYZE
SELECT c.IDComanda, c.IDClient, SUM(d.PreuTotal) AS Total
FROM Comandes c
JOIN DetallsComandes d ON c.IDComanda = d.IDComanda
GROUP BY c.IDComanda, c.IDClient
ORDER BY c.DataComanda;

/********************************************************************/
/*            ARXIU ÚNIC .SQL - Entrega Final                       */
/*                                                                  */
/*            Autor: [Hamza]                                        */  
/*            Data: [Data d'entrega]                                */
/*                                                                  */
/*    Conté:                                                        */
/*      1) Creació de taules normalitzades                          */
/*      2) Inserció de dades                                        */
/*      3) Implementació d’índexs                                   */
/*      4) Comparació del rendiment de consultes amb i sense índexs */
/********************************************************************/

------------------------------
-- 1) Creació de taules normalitzades
------------------------------

DROP TABLE IF EXISTS DetallsComandes CASCADE;
DROP TABLE IF EXISTS Comandes CASCADE;
DROP TABLE IF EXISTS Productes CASCADE;
DROP TABLE IF EXISTS Clients CASCADE;

CREATE TABLE Clients (
    IDClient VARCHAR(10) PRIMARY KEY,
    NomClient VARCHAR(50),
    CorreuElectronic VARCHAR(100),
    AdrecaEnviament VARCHAR(100),
    Saldo DECIMAL(10, 2)
);

CREATE TABLE Productes (
    IDProducte VARCHAR(10) PRIMARY KEY,
    NomProducte VARCHAR(50),
    Categoria VARCHAR(50),
    Preu DECIMAL(10, 2)
);

CREATE TABLE Comandes (
    IDComanda SERIAL PRIMARY KEY,
    IDClient VARCHAR(10) REFERENCES Clients(IDClient),
    DataComanda DATE,
    MetodePagament VARCHAR(20)
);

CREATE TABLE DetallsComandes (
    IDComanda INT REFERENCES Comandes(IDComanda),
    IDProducte VARCHAR(10) REFERENCES Productes(IDProducte),
    Quantitat INT,
    PreuTotal DECIMAL(10, 2),
    PRIMARY KEY (IDComanda, IDProducte)
);

------------------------------
-- 2) Inserció de dades
------------------------------

-- Exemple de dades per a Clients
INSERT INTO Clients (IDClient, NomClient, CorreuElectronic, AdrecaEnviament, Saldo)
VALUES 
('C001', 'Anna Pérez', 'anna.perez@example.com', 'Carrer de la Pau 5, 08001 Barcelona', 1500.00),
('C002', 'Joan Martí', 'joan.marti@example.com', 'Carrer Gran de Gràcia 10, 08012 Barcelona', 2000.00);

-- Exemple de dades per a Productes
INSERT INTO Productes (IDProducte, NomProducte, Categoria, Preu)
VALUES 
('P001', 'Portàtil Dell XPS', 'Electrònica', 1000.00),
('P002', 'Auriculars Sony WH-1000XM5', 'Accessoris', 300.00);

-- Exemple de dades per a Comandes
INSERT INTO Comandes (IDClient, DataComanda, MetodePagament)
VALUES 
('C001', '2025-01-10', 'Targeta de crèdit'),
('C002', '2025-01-11', 'PayPal');

-- Exemple de dades per a DetallsComandes
INSERT INTO DetallsComandes (IDComanda, IDProducte, Quantitat, PreuTotal)
VALUES 
(1, 'P001', 1, 1000.00),
(2, 'P002', 2, 600.00);

------------------------------
-- 3) Implementació d’índexs
------------------------------

-- Índex per millorar cerques per categoria a Productes
CREATE INDEX idx_categoria ON Productes(Categoria);

-- Índex per millorar consultes amb intervals de dates a Comandes
CREATE INDEX idx_data_comanda ON Comandes(DataComanda);

-- Índex compost per optimitzar cerques combinades a Productes
CREATE INDEX idx_categoria_preu ON Productes(Categoria, Preu);

------------------------------
-- 4) Comparació de rendiment
------------------------------

-- Sense índexs (simular eliminant índexs abans d'executar)
EXPLAIN ANALYZE
SELECT * FROM Productes WHERE Categoria = 'Electrònica';

-- Amb índexs
EXPLAIN ANALYZE
SELECT * FROM Productes WHERE Categoria = 'Electrònica';

-- Consulta optimitzada amb índexs compostos
EXPLAIN ANALYZE
SELECT * FROM Productes WHERE Categoria = 'Electrònica' AND Preu > 500;

-- Consultes amb intervals de dates
EXPLAIN ANALYZE
SELECT * FROM Comandes WHERE DataComanda BETWEEN '2025-01-01' AND '2025-01-15';
