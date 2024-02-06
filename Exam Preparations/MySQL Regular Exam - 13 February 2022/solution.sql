CREATE DATABASE online_stores;

CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT,
    rating DECIMAL(10,2) NOT NULL,
    picture_url VARCHAR(80) NOT NULL,
    published_at DATETIME NOT NULL
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    price DECIMAL(19,2) NOT NULL,
    quantity_in_stock INT,
    description TEXT,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    review_id INT,
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    phone VARCHAR(30) NOT NULL UNIQUE,
    address VARCHAR(60) NOT NULL,
    discount_card BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_datetime DATETIME NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE orders_products (
    order_id INT,
    product_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO reviews (content, picture_url, published_at, rating)
SELECT 
    SUBSTRING(description, 1, 15) AS content,
    REVERSE(name) AS picture_url,
    '2010-10-10' AS published_at,
    price / 8 AS rating
FROM 
    products
WHERE 
    id >= 5;

UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock >= 60 AND quantity_in_stock <= 70;

DELETE FROM customers
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

SELECT id, name
FROM categories
ORDER BY name DESC;

SELECT id AS product_id, brand_id, name, quantity_in_stock
FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock ASC, id ASC;

SELECT id, content, rating, picture_url, published_at
FROM reviews
WHERE content LIKE 'My%' AND LENGTH(content) > 61
ORDER BY rating DESC;

SELECT CONCAT(first_name, ' ', last_name) AS full_name, address, order_datetime
FROM customers
JOIN orders ON customers.id = orders.customer_id
WHERE YEAR(order_datetime) <= 2018
ORDER BY full_name DESC;

SELECT 
    COUNT(products.id) AS items_count,
    categories.name,
    SUM(products.quantity_in_stock) AS total_quantity
FROM 
    categories
LEFT JOIN 
    products ON categories.id = products.category_id
GROUP BY 
    categories.id, categories.name
ORDER BY 
    items_count DESC, total_quantity ASC
LIMIT 5;

DELIMITER //
CREATE FUNCTION udf_customer_products_count(first_name VARCHAR(30)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_products INT;
    
    SELECT COUNT(products.id) INTO total_products
    FROM orders
    JOIN customers ON orders.customer_id = customers.id
    JOIN orders_products ON orders.id = orders_products.order_id
    JOIN products ON orders_products.product_id = products.id
    WHERE customers.first_name = first_name;
    
    RETURN total_products;
END//

DELIMITER ;

SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';

DELIMITER //

CREATE PROCEDURE udp_reduce_price(category_name VARCHAR(50))
BEGIN
	UPDATE
    products p
    JOIN categories c ON p.category_id = c.id
    JOIN reviews r ON p.review_id = r.id
    SET p.price = p.price * 0.7
    WHERE c.name = category_name
    AND r.rating <4;
END//

DELIMITER ;

CALL udp_reduce_price ('Phones and tablets');