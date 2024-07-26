
<h1 align="center">SQL Project Database<p align="center">
<a href="https://www.mysql.com/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/mysql/mysql-original-wordmark.svg" alt="mysql" width="40" height="40"/> </a>
</h1>

<h1 align="center">Bar Bettash<p align="center">
<a href="https://www.linkedin.com/in/barbettash/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="https://www.linkedin.com/in/barbettash/" height="30" width="40" /></a>
</h1>


# Project Description: Hookah Tobacco Database Management System

## Overview
The "hookah_tobacco_db" project involves designing and implementing a relational database to streamline the operations of a hookah tobacco store. This comprehensive database system efficiently manages critical aspects of the store, including product information, customer data, orders, and employee details.

## Entity Relationship Diagram:
![image](https://github.com/user-attachments/assets/2750698b-a894-4797-8095-ae71dbff3be6)


## Database Structure
The database consists of interconnected tables, each serving a specific function:

- **Brand**: Stores information about tobacco brands.
  - *Primary Key*: BrandID

- **Flavor**: Contains data on the various flavors available.
  - *Primary Key*: FlavorID

- **LeafType**: Describes the types of tobacco leaves used.
  - *Primary Key*: LeafTypeID

- **PackSize**: Details the different packaging sizes offered.
  - *Primary Key*: PackSizeID

- **Product**: Maintains comprehensive product details.
  - *Primary Key*: ProductID
  - *Foreign Keys*: BrandID, FlavorID, LeafTypeID, PackSizeID

- **Customer**: Captures customer information.
  - *Primary Key*: CustomerID

- **Order**: Tracks customer orders.
  - *Primary Key*: OrderID
  - *Foreign Key*: CustomerID

- **OrderDetails**: Provides specifics about each order.
  - *Primary Key*: OrderDetailID
  - *Foreign Keys*: OrderID, ProductID

- **Brand_Flavor_Relationship**: Represents the many-to-many relationship between brands and flavors.
  - *Primary Key*: RelationshipID
  - *Foreign Keys*: BrandID, FlavorID

- **Brand_PackSize_Relationship**: Represents the many-to-many relationship between brands and pack sizes.
  - *Primary Key*: RelationshipID
  - *Foreign Keys*: BrandID, PackSizeID

- **Employees**: Manages employee information, including hierarchical relationships.
  - *Primary Key*: EmployeeID
  - *Foreign Key*: ManagerID

## Relationships
The database encompasses various relationships to ensure data integrity and efficient querying:

- **One-to-One**: Between Order and OrderDetails.
- **One-to-Many**:
  - Brand to Product
  - Flavor to Product
  - LeafType to Product
  - PackSize to Product
  - Customer to Order
  - Order to OrderDetails
- **Many-to-Many**:
  - Brand to Flavor (via Brand_Flavor_Relationship)
  - Brand to PackSize (via Brand_PackSize_Relationship)
- **Self-Referencing**:
  - Employees table where each employee can have a manager who is also an employee.

## Enhancements and Features

### Constraints:
----------------------------------------------------------------
### Brand Table
- **Primary Key:** `BrandID` (AUTO_INCREMENT)
- **Constraints:**
  - `Brand_Name` (NOT NULL)
  - `Country` (NOT NULL)

### Flavor Table
- **Primary Key:** `FlavorID` (AUTO_INCREMENT)
- **Constraints:**
  - `Flavor_Name` (NOT NULL)

### LeafType Table
- **Primary Key:** `LeafTypeID` (AUTO_INCREMENT)
- **Constraints:**
  - `Leaf_Name` (NOT NULL)
  - `Leaf_Strength` (NOT NULL)

### PackSize Table
- **Primary Key:** `PackSizeID` (AUTO_INCREMENT)
- **Constraints:**
  - `Grams` (NOT NULL)

### Product Table
- **Primary Key:** `ProductID` (AUTO_INCREMENT)
- **Constraints:**
  - `BrandID` (NOT NULL)
  - `FlavorID` (NOT NULL)
  - `LeafTypeID` (NOT NULL)
  - `PackSizeID` (NOT NULL)
  - `Price` (NOT NULL)
  - `Manufacturing_Date` (NOT NULL)
  - `Expiry_Date` (NOT NULL)
- **Foreign Keys:**
  - `BrandID` references `Brand(BrandID)`
  - `FlavorID` references `Flavor(FlavorID)`
  - `LeafTypeID` references `LeafType(LeafTypeID)`
  - `PackSizeID` references `PackSize(PackSizeID)`

### Customer Table
- **Primary Key:** `CustomerID` (AUTO_INCREMENT)
- **Constraints:**
  - `FirstName` (NOT NULL)
  - `LastName` (NOT NULL)
  - `Email` (NOT NULL)
  - `Phone` (NOT NULL)
  - `Address` (NOT NULL)

### Order Table
- **Primary Key:** `OrderID` (AUTO_INCREMENT)
- **Constraints:**
  - `CustomerID` (NOT NULL)
  - `Order_Date` (NOT NULL)
  - `Total_Amount` (NOT NULL)
- **Foreign Keys:**
  - `CustomerID` references `Customer(CustomerID)`

### OrderDetails Table
- **Primary Key:** `OrderDetailID` (AUTO_INCREMENT)
- **Constraints:**
  - `OrderID` (UNIQUE, NOT NULL)
  - `ProductID` (NOT NULL)
  - `Quantity` (NOT NULL)
- **Foreign Keys:**
  - `OrderID` references `Order(OrderID)`
  - `ProductID` references `Product(ProductID)`

### Brand_Flavor_Relationship Table
- **Primary Key:** `RelationshipID` (AUTO_INCREMENT)
- **Constraints:**
  - `BrandID` (NOT NULL)
  - `FlavorID` (NOT NULL)
- **Foreign Keys:**
  - `BrandID` references `Brand(BrandID)`
  - `FlavorID` references `Flavor(FlavorID)`

### Brand_PackSize_Relationship Table
- **Primary Key:** `RelationshipID` (AUTO_INCREMENT)
- **Constraints:**
  - `BrandID` (NOT NULL)
  - `PackSizeID` (NOT NULL)
- **Foreign Keys:**
  - `BrandID` references `Brand(BrandID)`
  - `PackSizeID` references `PackSize(PackSizeID)`

### Employees Table
- **Primary Key:** `EmployeeID` (AUTO_INCREMENT)
- **Constraints:**
  - `FirstName` (NOT NULL)
  - `LastName` (NOT NULL)
  - `ManagerID` (NOT NULL)
- **Foreign Keys:**
  - `ManagerID` references `Employees(EmployeeID)`

----------------------------------------------------------------

### Views:
- **vw_ProductInfo**: Displays product information including brand and flavor names.
- **vw_CustomerOrderTotal**: Shows total order amounts for each customer.
- **vw_FlavorTotalQuantity**: Provides insights into the total quantity of each flavor sold.

----------------------------------------------------------------

### Triggers:
Ensure data consistency and automate specific calculations, enhancing the database's functionality and reliability.
- **Customer_before_insert_uppercase_names (Before):** AutomaFcally converts first names and last names to uppercase before inserFng new records into the Customer table.
- **Customer_before_insert_same_names (Before):** Prevents inserFng records where the first name is the same as the last name in the Customer table.
- **Order_before_insert_total_price (Before):** Calculates and sets the total amount for an order before inserFng new records into the Order table, considering the price and quanFty of products in the order.
- **Product_before_insert_date_check (Before):** Ensures that the manufacturing date is before the expiry date for each product before inserFng new records into the Product table.
- **OrderDetails_ajer_insert_update_stock (After):** Updates the stock quanFty of a product ajer inserFng new records into the OrderDetails table, considering the quanFty sold in the order.
- **OrderDetails_ajer_insert_update_total_amount (After):** Updates the total amount of an order ajer inserFng new records into the OrderDetails table, considering the total price of products in the order.
- **Order_ajer_insert_audit (After):** Creates an audit trail of inserted orders, recording the order ID, user who inserted the order, and the Fmestamp.
- **Customer_ajer_insert_audit (After):** Creates an audit trail of inserted customers, recording the customer ID, user who inserted the customer, and the Fmestamp.

----------------------------------------------------------------

## Benefits
Implementing this database system enables the hookah tobacco store to:
- Efficiently manage inventory.
- Streamline operations.
- Improve customer service.
- Provide a seamless experience for both customers and employees.
