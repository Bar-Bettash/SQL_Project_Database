

-- ------------------------------
	-- CREATE THE DATABASE --
	     -- DDL CODE --
-- ------------------------------
-- If needed to Drop:
DROP database IF EXISTS hookah_tobacco_db;

CREATE DATABASE hookah_tobacco_db;
USE hookah_tobacco_db;

-- ------------------------------
		-- CREATE THE TABLES --
-- ------------------------------

-- Create the Brand table
CREATE TABLE Brand (
    BrandID INT AUTO_INCREMENT PRIMARY KEY,
    Brand_Name VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL
);

-- Create the Flavor table
CREATE TABLE Flavor (
    FlavorID INT AUTO_INCREMENT PRIMARY KEY,
    Flavor_Name VARCHAR(50) NOT NULL
);

-- Create the LeafType table
CREATE TABLE LeafType (
    LeafTypeID INT AUTO_INCREMENT PRIMARY KEY,
    Leaf_Name VARCHAR(50) NOT NULL,
    Leaf_Strength VARCHAR(50) NOT NULL
);

-- Create the PackSize table
CREATE TABLE PackSize (
    PackSizeID INT AUTO_INCREMENT PRIMARY KEY,
    Grams INT NOT NULL
);

-- Create the Product table
CREATE TABLE Product (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    BrandID INT NOT NULL,
    FlavorID INT NOT NULL,
    LeafTypeID INT NOT NULL,
    PackSizeID INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Manufacturing_Date DATE NOT NULL,
    Expiry_Date DATE NOT NULL,
	Stock_Quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (BrandID) REFERENCES Brand (BrandID),
    FOREIGN KEY (FlavorID) REFERENCES Flavor (FlavorID),
    FOREIGN KEY (LeafTypeID) REFERENCES LeafType (LeafTypeID),
    FOREIGN KEY (PackSizeID) REFERENCES PackSize (PackSizeID)
);

-- Create the Customer table
CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(200) NOT NULL
);

-- Create the Order table
CREATE TABLE `Order` (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
);

-- Create the OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES `Order` (OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
);

-- Create the Brand_Flavor_Relationship table
-- Emplementing a Many-to-Many Relationship between Brand and Flavor
CREATE TABLE Brand_Flavor_Relationship (
    RelationshipID INT AUTO_INCREMENT PRIMARY KEY,
    BrandID INT NOT NULL,
    FlavorID INT NOT NULL,
    FOREIGN KEY (BrandID) REFERENCES Brand (BrandID),
    FOREIGN KEY (FlavorID) REFERENCES Flavor (FlavorID)
);

-- Create the Brand_PackSize_Relationship table
-- Implementing a Many-to-Many Relationship between Brand and PackSize
CREATE TABLE Brand_PackSize_Relationship (
    RelationshipID INT AUTO_INCREMENT PRIMARY KEY,
    BrandID INT NOT NULL,
    PackSizeID INT NOT NULL,
    FOREIGN KEY (BrandID) REFERENCES Brand (BrandID),
    FOREIGN KEY (PackSizeID) REFERENCES PackSize (PackSizeID)
);

-- Create the Employees table
-- Implementing a Self-Reference relationship
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    ManagerID INT, -- Foreign key referencing EmployeeID in the same table
    -- Other columns related to employee information
    FOREIGN KEY (ManagerID) REFERENCES Employees (EmployeeID)
);


-- ------------------------------
		-- CREATE THE VIEWS --
-- ------------------------------


-- Create an updateable view to show product information with brand and flavor names
CREATE VIEW vw_ProductInfo AS
SELECT p.ProductID, b.Brand_Name, f.Flavor_Name, p.Price, p.Manufacturing_Date, p.Expiry_Date
FROM Product p
JOIN Brand b ON p.BrandID = b.BrandID
JOIN Flavor f ON p.FlavorID = f.FlavorID;

-- Create a non-updateable view to show the total order amount for each customer
CREATE VIEW vw_CustomerOrderTotal AS
SELECT c.CustomerID, c.FirstName,c.LastName, SUM(od.Quantity * pr.Price) AS TotalAmount
FROM Customer c
JOIN `Order` o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Product pr ON od.ProductID = pr.ProductID
GROUP BY c.CustomerID;

-- Create another non-updateable view to show the total quantity of each flavor sold
CREATE VIEW vw_FlavorTotalQuantity AS
SELECT f.FlavorID, f.Flavor_Name, SUM(od.Quantity) AS TotalQuantitySold
FROM Flavor f
JOIN Product pr ON f.FlavorID = pr.FlavorID
JOIN OrderDetails od ON pr.ProductID = od.ProductID
GROUP BY f.FlavorID, f.Flavor_Name;

-- ------------------------------
	-- CREATE THE TRIGGERS --
-- ------------------------------

-- we can use the following if the trigger is already exists
-- Drop the trigger only if it exists:
-- DROP TRIGGER IF EXISTS Trigger_Name;

-- TRIGGER - BEFORE 1 --

-- Create a BEFORE INSERT trigger to automatically convert FirstName and LastName to uppercase in the Customer table
DELIMITER //
CREATE TRIGGER Customer_before_insert_uppercase_names
    BEFORE INSERT ON Customer
    FOR EACH ROW
BEGIN
    SET NEW.FirstName = UPPER(NEW.FirstName);
    SET NEW.LastName = UPPER(NEW.LastName);
END//
DELIMITER ;

-- TRIGGER - BEFORE 2 --

-- Create a BEFORE INSERT trigger to prevent inserting records where FirstName equals LastName in the Customer table
DELIMITER //
CREATE TRIGGER Customer_before_insert_same_names
    BEFORE INSERT ON Customer
    FOR EACH ROW
BEGIN
    IF NEW.FirstName = NEW.LastName THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "first name must not equal last name";
    END IF;
END//
DELIMITER ;

-- TRIGGER - BEFORE 3 --

DELIMITER //
CREATE TRIGGER Order_before_insert_total_price
    BEFORE INSERT ON `Order`
    FOR EACH ROW
BEGIN
    DECLARE total_amount DECIMAL(10, 2) DEFAULT 0.00;
    
    SELECT SUM(od.Quantity * p.Price) INTO total_amount
    FROM OrderDetails od
    JOIN Product p ON od.ProductID = p.ProductID
    WHERE od.OrderID = NEW.OrderID;
    
    SET NEW.Total_Amount = total_amount;
END//
DELIMITER ;

-- TRIGGER - BEFORE 4 --

DELIMITER //
CREATE TRIGGER Product_before_insert_date_check
    BEFORE INSERT ON Product
    FOR EACH ROW
BEGIN
    IF NEW.Manufacturing_Date >= NEW.Expiry_Date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Manufacturing date must be before expiry date";
    END IF;
END//
DELIMITER ;

-- TRIGGER - AFTER 1 --

DELIMITER //
CREATE TRIGGER OrderDetails_after_insert_update_stock
    AFTER INSERT ON OrderDetails
    FOR EACH ROW
BEGIN
    UPDATE Product
    SET Stock_Quantity = Stock_Quantity - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END//
DELIMITER ;

-- TRIGGER - AFTER 2 --

DELIMITER //
CREATE TRIGGER OrderDetails_after_insert_update_total_amount
    AFTER INSERT ON OrderDetails
    FOR EACH ROW
BEGIN
    UPDATE `Order`
    SET Total_Amount = (
        SELECT SUM(od.Quantity * p.Price)
        FROM OrderDetails od
        JOIN Product p ON od.ProductID = p.ProductID
        WHERE od.OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END//
DELIMITER ;


-- TRIGGER - AFTER 3 --

CREATE TABLE Order_audit (
    `Order_audit_id` INT AUTO_INCREMENT PRIMARY KEY,
    `Order_id` INT NOT NULL, 
    `who` VARCHAR(255), 
    `when` TIMESTAMP NOT NULL);


DELIMITER //
CREATE TRIGGER Order_after_insert_audit
AFTER INSERT ON `Order`
FOR EACH ROW
BEGIN
    INSERT INTO Order_audit
        (`Order_id`, `who`, `when`)
    VALUES
        (NEW.OrderID, CURRENT_USER(), CURRENT_TIMESTAMP);
END//
DELIMITER ;

-- TRIGGER - AFTER 4 --

CREATE TABLE Customer_audit (
    Customer_audit_id INT AUTO_INCREMENT PRIMARY KEY,
    Customer_id INT NOT NULL,
    `who` VARCHAR(255),
    `when` TIMESTAMP NOT NULL
);

DELIMITER //
CREATE TRIGGER Customer_after_insert_audit
AFTER INSERT ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_audit (Customer_id, `who`, `when`)
    VALUES (NEW.CustomerID, CURRENT_USER(), CURRENT_TIMESTAMP);
END//
DELIMITER ;

-- ------------------------------
	     -- DML CODE --
		-- SAMPLE DATA --
-- ------------------------------

-- Insert sample data into the Brand table
INSERT INTO Brand (Brand_Name, Country) VALUES
    ('Black_Burn', 'Russia '),
    ('Musthave', 'Russia '),
    ('Daft', 'Russia '),
    ('Element', 'Russia '),
    ('DarkSide', 'Russia ');

-- Insert sample data into the Flavor table
INSERT INTO Flavor (Flavor_Name) VALUES
    ('Apple'),
    ('Mango'),
    ('Strawberry'),
    ('Lime'),
    ('Peach');

-- Insert sample data into the LeafType table
INSERT INTO LeafType (Leaf_Name, Leaf_Strength) VALUES
    ('Virginia', 'light'),
    ('Oriental', 'medium'),
    ('Cavendish', 'medium'),
    ('Perique', 'strong'),
    ('Burley', 'extra_strong');

-- Insert sample data into the PackSize table
INSERT INTO PackSize (Grams) VALUES
    (50),
    (100),
    (200),
    (250),
    (1000);

-- Insert sample data into the Product table
INSERT INTO Product (BrandID, FlavorID, LeafTypeID, PackSizeID, Price, Manufacturing_Date, Expiry_Date, Stock_Quantity) VALUES
    (1, 1, 1, 1, 10.50, '2023-08-01', '2023-12-31', 50),
    (2, 2, 2, 2, 15.75, '2023-08-01', '2024-01-31', 50),
    (3, 3, 3, 3, 15.75, '2023-08-01', '2024-01-31', 50),
    (4, 4, 4, 4, 15.75, '2023-08-01', '2024-01-31', 50),
    (5, 5, 5, 5, 12.00, '2023-08-01', '2023-10-31', 50);

-- Insert sample data into the Customer table
INSERT INTO Customer (FirstName,LastName, Email, Phone, Address) VALUES
    ('Averin','Vladimir', 'Avladimir@gmail.com', '1234567890', '123 Main St, Moscow'),
    ('Romanova','Alexandra', 'Ralexandra@gmail.com', '9876553211', '456 Oak Ave, St.Petersburg'),
	('Kudriashov','Gleb', 'Kgleb@gmail.com', '9876583910', '456 Oak Ave, St.Petersburg'),
    ('Korzh','Mikhail', 'Kmikhail@gmail.com', '9876683210', '456 Oak Ave, St.Petersburg'),
    ('Mike','Johnson', 'MJohnson@gmail.com', '5551234567', '789 Elm Rd, Novosibirsk');

-- Insert sample data into the Order table
INSERT INTO `Order` (CustomerID, Order_Date, Total_Amount) VALUES
    (1, '2023-08-01', 31.50),
    (2, '2023-08-02', 47.25),
	(3, '2023-08-02', 47.25),
	(4, '2023-08-02', 47.25),
    (5, '2023-08-03', 24.00);

-- Insert sample data into the OrderDetails table
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
    (1, 1, 3),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 1),
    (5, 5, 2);
    
-- Insert sample data into the Brand_Flavor_Relationship table
INSERT INTO Brand_Flavor_Relationship (BrandID, FlavorID) VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 5);

-- Insert sample data into the Brand_PackSize_Relationship table
INSERT INTO Brand_PackSize_Relationship (BrandID, PackSizeID) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);
    
-- Insert sample data into the Employees table  
INSERT INTO Employees (FirstName, LastName, ManagerID) VALUES
    ('John', 'Doe', NULL), -- John Doe is a manager and has no manager (NULL value)
    ('Jane', 'Smith', 1),  -- Jane Smith is an employee and her manager is John Doe (EmployeeID = 1)
    ('Mike', 'Johnson', 1), -- Mike Johnson is an employee and his manager is John Doe (EmployeeID = 1)
    ('Anna', 'Lee', 2),    -- Anna Lee is an employee and her manager is Jane Smith (EmployeeID = 2)
    ('Alex', 'Brown', 2);   -- Alex Brown is an employee and his manager is Jane Smith (EmployeeID = 2)


-- ------------------------------
		-- REPORT QUERY --
-- ------------------------------

SELECT
    b.Brand_Name AS 'Brand Name',
    f.Flavor_Name AS 'Flavor Name',
    lt.Leaf_Name AS 'Leaf Type',
    ps.Grams AS 'Pack Size (Grams)',
    AVG(p.Price) AS 'Average Price',
    SUM(p.Stock_Quantity) AS 'Total Stock Quantity'
FROM
    Brand b
JOIN
    Brand_Flavor_Relationship bfr ON b.BrandID = bfr.BrandID
JOIN
    Flavor f ON bfr.FlavorID = f.FlavorID
JOIN
    Product p ON b.BrandID = p.BrandID AND f.FlavorID = p.FlavorID
JOIN
    LeafType lt ON p.LeafTypeID = lt.LeafTypeID
JOIN
    PackSize ps ON p.PackSizeID = ps.PackSizeID
 WHERE
    ps.Grams = 50
GROUP BY
    b.Brand_Name, f.Flavor_Name, lt.Leaf_Name, ps.Grams WITH ROLLUP
HAVING
    b.Brand_Name IS NOT NULL AND f.Flavor_Name IS NOT NULL AND lt.Leaf_Name IS NOT NULL AND ps.Grams IS NOT NULL;




