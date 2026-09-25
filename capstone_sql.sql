create database capstone;
use capstone;
show tables;
select * from capstone.products;
-- task 1
CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name TEXT NOT NULL
);
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code INT
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code INT
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year INT,
    list_price DOUBLE NOT NULL,

    FOREIGN KEY (brand_id)
        REFERENCES brands(brand_id),

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE staffs (
    staff_id INT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    active INT,
    store_id INT NOT NULL,
    manager_id INT,

    FOREIGN KEY (store_id)
        REFERENCES stores(store_id),

    FOREIGN KEY (manager_id)
        REFERENCES staffs(staff_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_status TEXT NOT NULL,
    order_date TEXT NOT NULL,
    required_date TEXT,
    shipped_date TEXT,
    store_id INT NOT NULL,
    staff_id INT NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (store_id)
        REFERENCES stores(store_id),

    FOREIGN KEY (staff_id)
        REFERENCES staffs(staff_id)
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    list_price DOUBLE NOT NULL,
    discount DOUBLE DEFAULT 0,

    PRIMARY KEY (order_id, item_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CHECK (quantity > 0),
    CHECK (list_price >= 0),
    CHECK (discount >= 0 AND discount <= 1)
);
CREATE TABLE stocks (
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,

    PRIMARY KEY (store_id, product_id),

    FOREIGN KEY (store_id)
        REFERENCES stores(store_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CHECK (quantity >= 0)
);



-- task 3
SELECT o.order_id,p.product_name,oi.item_id,oi.quantity,oi.list_price,oi.discount,(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_price FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id INNER JOIN products p ON oi.product_id = p.product_id;
-- task 4
SELECT o.store_id,st.store_name,SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales FROM orders o INNER JOIN order_items oi ON o.order_id = oi.order_id INNER JOIN stores st
ON o.store_id = st.store_id GROUP BY o.store_id,st.store_name ORDER BY total_sales DESC;

-- task 5
SELECT p.product_id,p.product_name,SUM(oi.quantity) AS total_quantity_sold FROM order_items oi INNER JOIN products p ON oi.product_id = p.product_id GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC LIMIT 5;

-- task 6
SELECT c.customer_id,CONCAT(c.first_name, ' ', c.last_name) AS customer_name,COUNT(DISTINCT o.order_id) AS total_orders,COALESCE(SUM(oi.quantity), 0) AS total_items_purchased,
COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS total_revenue FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi
ON o.order_id = oi.order_id GROUP BY c.customer_id,c.first_name,c.last_name ORDER BY total_revenue DESC;

-- task 7
SELECT c.customer_id,CONCAT(c.first_name, ' ', c.last_name) AS customer_name,COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS total_spend,
CASE WHEN COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) < 1000 THEN 'Low' WHEN COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) < 5000 THEN 'Medium'
ELSE 'High' END AS spending_category FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.first_name,c.last_name ORDER BY total_spend DESC;

-- task 8
SELECT s.staff_id,CONCAT(s.first_name, ' ', s.last_name) AS staff_name,COUNT(DISTINCT o.order_id) AS total_orders,COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),0) AS total_revenue
FROM staffs s LEFT JOIN orders o ON s.staff_id = o.staff_id LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.staff_id,s.first_name,s.last_name ORDER BY total_revenue DESC;

-- task 9
SELECT s.store_id,p.product_id,p.product_name,s.quantity AS stock_quantity FROM stocks s INNER JOIN products p ON s.product_id = p.product_id WHERE s.quantity < 10 ORDER BY s.quantity ASC;
-- task 10
CREATE TABLE customer_segments (customer_bkql INT PRIMARY KEY,segment VARCHAR(50),cluster_id INT,total_spend DOUBLE,total_orders INT,total_items INT)