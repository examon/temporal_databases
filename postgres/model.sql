CREATE TABLE IF NOT EXISTS category
(
        id SERIAL PRIMARY KEY,
        name VARCHAR(100)

);

CREATE TABLE IF NOT EXISTS product
(
         id serial PRIMARY KEY,
         name VARCHAR(100),
         cost integer,
         amount integer
);

CREATE TABLE IF NOT EXISTS category_product
(
         category_id integer REFERENCES category (id),
         product_id integer REFERENCES product (id),
         PRIMARY KEY (category_id, product_id)
);

CREATE TABLE IF NOT EXISTS customer
(
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100),
        password VARCHAR(100),
        active boolean
);

CREATE TABLE IF NOT EXISTS purchase
(
        id serial PRIMARY KEY,
        date_time timestamp,
        customer_id integer REFERENCES customer (id),
        product_id integer REFERENCES product (id)
);

/*
INSERT INTO category (name) VALUES ('test');
INSERT INTO product (name, cost, amount) VALUES ('penezenka', 1,20);
INSERT INTO category_product (category_id, product_id) VALUES (1,1);
INSERT INTO customer (name, email, password, active) VALUES ('Jan Hrozný', 'jan.hrozny@email.cz', 'heslo_jan_2', true);
INSERT INTO purchase (date_time, customer_id, product_id) VALUES (NOW(), 1 ,1 );
*/
