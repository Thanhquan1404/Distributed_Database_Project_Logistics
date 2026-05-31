connect ThanhQuan_Distributed_Database;

-- CREATE TABLES AS DATABASE SYSTEM SCHEME
drop table Products cascade constraints;
create table Products(
    Product_ID varchar2(255) PRIMARY KEY,
    Product_Name NVARCHAR2(255),
    Weight NUMBER,
    Cost_Of_Product NUMBER,
    Rating NUMBER,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Created_By VARCHAR2(255) 
);

drop table Warehouses cascade constraints;
create table Warehouses(
    Hub_ID VARCHAR2(255) PRIMARY KEY,
    Hub_Name NVARCHAR2(255),
    Region_Code VARCHAR2(255)
);

drop table Customers cascade constraints;
create table Customers(
    Customer_ID VARCHAR2(255) PRIMARY KEY,
    Customer_Name NVARCHAR2(255),
    City NVARCHAR2(255),
    Customer_Rating NUMBER
);

drop table Orders_Ops cascade constraints;
create table Orders_Ops(
    Order_ID VARCHAR2(255) PRIMARY KEY,
    Customer_ID VARCHAR(255),
    Product_ID VARCHAR(255),
    Root_Hub VARCHAR2(255),
    Dest_Hub VARCHAR2(255),
    Mode_Of_Shipment VARCHAR2(255),
    Status VARCHAR2(255)
);

drop table Orders_Payment cascade constraints;
create table Orders_Payment(
    Order_ID VARCHAR2(255),
    Amount NUMBER,
    Pay_Status VARCHAR2(255)
);


-- INITIALIZE SYSTEM CONTRAINTS 
--- Products contraints
ALTER TABLE Products ADD CONSTRAINT CK_PRODUCTS_CREATED_BY CHECK (Created_By IN ('DN', 'HCM', 'HN'));

--- Warehouses constraints
ALTER TABLE Warehouses ADD CONSTRAINT CK_WAREHOUSES_DANANG CHECK (Region_Code='DN');

--- Orders_Ops
ALTER TABLE Orders_Ops ADD CONSTRAINT FK_CUSTOMERS_CUSTOMER_ID FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE; 
ALTER TABLE Orders_Ops ADD CONSTRAINT FK_PRODUCTS_PRODUCT_ID FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE; 
ALTER TABLE Orders_Ops ADD CONSTRAINT FK_WAREHOUSES_ROOT_HUB FOREIGN KEY (Root_Hub) REFERENCES Warehouses(Hub_ID) ON DELETE CASCADE; 
ALTER TABLE Orders_Ops ADD CONSTRAINT FK_WAREHOUSES_DEST_HUB FOREIGN KEY (Dest_Hub) REFERENCES Warehouses(Hub_ID) ON DELETE CASCADE; 






