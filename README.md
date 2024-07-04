
<h1 align="center">SQL Project Database<p align="center">
<a href="https://www.mysql.com/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/mysql/mysql-original-wordmark.svg" alt="mysql" width="40" height="40"/> </a>
</h1>

<h1 align="center">Bar Bettash<p align="center">
<a href="https://www.linkedin.com/in/barbettash/" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="https://www.linkedin.com/in/barbettash/" height="30" width="40" /></a>
</h1>


# Project Description: Hookah Tobacco Database Management System

## Overview
The "hookah_tobacco_db" project involves designing and implementing a relational database to streamline the operations of a hookah tobacco store. This comprehensive database system efficiently manages critical aspects of the store, including product information, customer data, orders, and employee details.

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
### Views:
- **vw_ProductInfo**: Displays product information including brand and flavor names.
- **vw_CustomerOrderTotal**: Shows total order amounts for each customer.
- **vw_FlavorTotalQuantity**: Provides insights into the total quantity of each flavor sold.

### Triggers:
Ensure data consistency and automate specific calculations, enhancing the database's functionality and reliability.

## Benefits
Implementing this database system enables the hookah tobacco store to:
- Efficiently manage inventory.
- Streamline operations.
- Improve customer service.
- Provide a seamless experience for both customers and employees.
