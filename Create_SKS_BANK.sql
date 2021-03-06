/*******************************************************************************

   SKS_BANK Database 
   Description: it creates and populates the SKS_BANK
   DB Server: SqlServer
   Author: Arianne Guedes, Jorge Gayer and Robert Parker

********************************************************************************/

USE MASTER;

/*******************************************************************************
   Drop Database if it Exists
********************************************************************************/

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'SKS_BANK')
BEGIN
	ALTER DATABASE [SKS_BANK] SET OFFLINE WITH ROLLBACK IMMEDIATE;
	ALTER DATABASE [SKS_BANK] SET ONLINE;
	DROP DATABASE [SKS_BANK];
END

GO

/*******************************************************************************
   Create Database
********************************************************************************/

CREATE DATABASE [SKS_BANK];
GO

USE [SKS_BANK];
GO

/*******************************************************************************
   Create Tables
********************************************************************************/

CREATE TABLE [dbo].[Branches]
(
    [BranchID] SMALLINT IDENTITY PRIMARY KEY,
    [Name] VARCHAR(30) NOT NULL UNIQUE,
	[Street] VARCHAR(30) NOT NULL, 
	[PostalCode] VARCHAR(30) NOT NULL, 
	[CityID] SMALLINT NOT NULL,
	[DepositAmount] MONEY NOT NULL,
	[LoanAmount] MONEY NOT NULL 
);
GO

CREATE TABLE [dbo].[Cities]
(
    [CityID] SMALLINT IDENTITY PRIMARY KEY,
    [Name] VARCHAR(30) NOT NULL UNIQUE,
    [Province] VARCHAR(30) NOT NULL
);
GO

CREATE TABLE [dbo].[Customers]
(
    [CustomerID] INT IDENTITY PRIMARY KEY,
    [Name] VARCHAR(30) NOT NULL, 
	[Street] VARCHAR(30) NOT NULL, 
	[PostalCode] VARCHAR(30) NOT NULL, 
	[CityID] SMALLINT NOT NULL, 
	[BranchID] SMALLINT NOT NULL, 
	[BankerID] INT NULL, 
	[LoanOfficerID] INT NULL 
);
GO

CREATE TABLE [dbo].[Accounts]
(
    [AccountID] INT IDENTITY PRIMARY KEY,
	[BranchID] SMALLINT NOT NULL, 
	[AccountTypeID] TINYINT NOT NULL, 
	[Balance] MONEY NOT NULL, 
	[LastAccessDate] DATE, 
	[OverdraftLimit] MONEY NOT NULL
);
GO

CREATE TABLE [dbo].[AccountCustomers]
(
    [AccountID] INT NOT NULL,
    [CustomerID] INT NOT NULL
);
GO

CREATE TABLE [dbo].[AccountInterest]
(
    [AccountID] INT NOT NULL,
    [InterestRate] MONEY NOT NULL
);
GO

CREATE TABLE [dbo].[AccountOverdrafts]
(
    [AccountID] INT NOT NULL,
    [Amount] MONEY NOT NULL CHECK (Amount <> 0),
	[Date] DATE NOT NULL,
	[OverdraftLimit] MONEY NOT NULL
);
GO

CREATE TABLE [dbo].[AccountTypes]
(
    [AccountTypeID] TINYINT IDENTITY PRIMARY KEY,
    [Description] VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE [dbo].[Employees]
(
    [EmployeeID] INT IDENTITY PRIMARY KEY,
	[EmployeeTypeID] TINYINT NOT NULL,
    [Name] VARCHAR(30) NOT NULL, 
	[StartDate] DATE NOT NULL, 
	[Street] VARCHAR(30) NOT NULL, 
	[PostalCode] VARCHAR(30) NOT NULL,  
	[CityID] SMALLINT NOT NULL, 
	[BranchID] SMALLINT, -- Check something 
	[OfficeID] SMALLINT, -- Check something 
	[ManagerID] INT
);
GO

CREATE TABLE [dbo].[Offices]
(
    [OfficeID] SMALLINT IDENTITY PRIMARY KEY,
    [Name] VARCHAR(30) NOT NULL UNIQUE, 
	[Street] VARCHAR(30) NOT NULL, 
	[PostalCode] VARCHAR(30) NOT NULL, 
	[CityID] SMALLINT NOT NULL
);
GO

CREATE TABLE [dbo].[EmployeeTypes]
(
    [EmployeeTypeID] TINYINT IDENTITY PRIMARY KEY,
    [Description] VARCHAR(30) NOT NULL UNIQUE 
);
GO

CREATE TABLE [dbo].[Loans]
(
    [LoanID] SMALLINT IDENTITY PRIMARY KEY,
    [Amount] MONEY NOT NULL CHECK (Amount <> 0), 
    [Balance] MONEY NOT NULL 
);
GO

CREATE TABLE [dbo].[LoanCustomers]
(
    [LoanID] SMALLINT NOT NULL,
    [CustomerID] INT NOT NULL
);
GO

CREATE TABLE [dbo].[Payments]
(
	[PaymentID] SMALLINT IDENTITY,
    [LoanID] SMALLINT NOT NULL,
    [Amount] MONEY NOT NULL CHECK (Amount <> 0), 
	[Date] DATE NOT NULL
);
GO

--/*******************************************************************************
--   Populate Tables
--********************************************************************************/

-- Cities Table
INSERT INTO Cities (Name, Province) VALUES ('Vancouver','British Columbia' );
INSERT INTO Cities (Name, Province) VALUES ('Toronto','Ontario' );
INSERT INTO Cities (Name, Province) VALUES ('Calgary','Alberta' );
INSERT INTO Cities (Name, Province) VALUES ('Edmonton','Alberta' );
INSERT INTO Cities (Name, Province) VALUES ('Saskatoon','Saskatchewan' );
INSERT INTO Cities (Name, Province) VALUES ('Montreal','Quebec' );
GO

-- Branches Table
INSERT INTO Branches (CityID, Name, DepositAmount, LoanAmount, street, PostalCode) VALUES (1, 'Vancouver', 162000, 156800, '129 Tolmie St','V6A 4E6' );
INSERT INTO Branches (CityID, Name, DepositAmount, LoanAmount, street, PostalCode) VALUES (1, 'Toronto', 10040580, 5000, '129 Tolmie St','V6A 4E6' );
INSERT INTO Branches (CityID, Name, DepositAmount, LoanAmount, street, PostalCode) VALUES (1, 'Calgary', 147000, 8000, '129 Tolmie St','V6A 4E6' );
GO

-- EmployeeTypes Table
INSERT INTO EmployeeTypes(Description) VALUES ('Bankers');
INSERT INTO EmployeeTypes(Description) VALUES ('Loan Officers');
INSERT INTO EmployeeTypes(Description) VALUES ('Managers');
GO

-- Offices Table
INSERT INTO Offices(Name, Street, PostalCode, CityID) VALUES ('Calgary', '4944 40th Street', 'T2P 2V7', 3);
INSERT INTO Offices(Name, Street, PostalCode, CityID) VALUES ('Toronto', '2409 Victoria Park Ave', 'M2J 3T7', 2);
GO

-- Loans Table
INSERT INTO Loans(Amount, Balance) VALUES (100000, 100000);
INSERT INTO Loans(Amount, Balance) VALUES (50000, 5000);
INSERT INTO Loans(Amount, Balance) VALUES (10000, 8000);
INSERT INTO Loans(Amount, Balance) VALUES (30000, 2800);
INSERT INTO Loans(Amount, Balance) VALUES (80000, 54000);
GO

-- LoanCustomers Table
INSERT INTO LoanCustomers(LoanID, CustomerID) VALUES (1, 1);
INSERT INTO LoanCustomers(LoanID, CustomerID) VALUES (2, 3);
INSERT INTO LoanCustomers(LoanID, CustomerID) VALUES (3, 4);
INSERT INTO LoanCustomers(LoanID, CustomerID) VALUES (4, 6);
INSERT INTO LoanCustomers(LoanID, CustomerID) VALUES (5, 9);
GO

-- Accounts Table
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 1, 20000, '2021-10-18', 300);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 1, 30000, '2020-05-06', 300);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (3, 1, 30000, '2021-11-05', 300);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 1, 2500000, '2021-10-21', 500);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 1, 23000, '2021-10-22', 500);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 1, 15000, '2021-10-23', 500);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 1, 18000, '2021-10-24', 1000);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 1, 10000, '2021-10-25', 1000);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (3, 1, 20000, '2021-09-13', 1000);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 1, 500, '2021-01-27', 400);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 2, 70000, '2021-07-28', 0);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 2, 7500000, '2021-10-16', 0);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (3, 2, 45000, '2021-08-30', 0);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (1, 2, 16000, '2021-10-31', 0);
INSERT INTO Accounts(BranchID, AccountTypeID, balance, LastAccessDate, OverdraftLimit) VALUES (2, 2, 80, '2021-11-01', 0);
GO

-- AccountInterest Table
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (1, 2);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (2, 2);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (3, 2);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (4, 2.5);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (5, 2.5);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (6, 2.5);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (7, 2.5);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (8, 3);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (9, 3);
INSERT INTO AccountInterest(AccountID, InterestRate) VALUES (10, 3);
GO

-- AccountCustomers Table
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (1, 1);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (2, 2);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (3, 3);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (4, 4);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (5, 5);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (6, 6);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (7, 7);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (8, 8);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (9, 9);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (10, 10);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (11, 1);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (12, 2);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (13, 5);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (14, 7);
INSERT INTO AccountCustomers(AccountID, CustomerID) VALUES (15, 10);
GO

-- Payments Table
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-03-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-04-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-05-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-06-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-07-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-08-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-09-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-10-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (2,  5000, '2021-11-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (3,  1000, '2021-10-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (3,  1000, '2021-11-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (4,  200, '2021-11-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (5,  1000, '2021-10-01');
INSERT INTO Payments( LoanID,  Amount, Date) VALUES (5,  1000, '2021-11-01');


-- Employees Table
INSERT INTO Employees( StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES ('2016-10-25', 'Britt M Smith','1307 Tanner Street' , 'V5R 2T4', 1,1, 3 );
INSERT INTO Employees( StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES ('2019-04-11', 'Aaron Fleming','2469 Bay Street' , 'M5J 2R8', 2,2, 3 );
INSERT INTO Employees( StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES ('2020-03-05', 'Charlena W Ford','1668 40th Street' , 'T2T 2Y6', 3,3, 3 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES (2 ,'2014-08-14', 'Jeanie Belanger','3787 Acton Avenue' , 'M3H 4J1', 2,2 ,1 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID,   OfficeID,EmployeeTypeID) VALUES (3 ,'2021-10-22', 'Stephen E Rodriguez','1011 Heritage Drive' , 'T2V 2W2', 3,1 ,2 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES (3 ,'2020-12-03', 'Gracie D Williams','799 7th Ave' , 'T2P 0W4', 3,3 ,1 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID,   OfficeID,EmployeeTypeID) VALUES (2 ,'2017-07-06', 'Jack  Hernandez','770 Glen Long Avenue' , 'M6B 1J8', 2,2 ,2 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES (1 ,'2018-09-18', 'Shirley S Lance','3531 Tolmie St' , 'V6M 1Y8', 1,1 ,1 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES (2 ,'2016-06-07', 'Jenny Mathews','2402 Yonge Street' , 'M4W 1J7', 2,2 ,1 );
INSERT INTO Employees(ManagerID , StartDate, Name, Street, PostalCode, CityID, BranchID,  EmployeeTypeID) VALUES (1 ,'2019-11-03', 'Cathleen T Nguyen','3919 St George Street' , 'V5T 1Z7', 1,1 ,1 );

GO

-- Customers Table
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID, LoanOfficerID) VALUES ('Mark M Briley','129 Tolmie St', 'V6A 4E6', 1, 1, 8, 7 );
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID) VALUES ('Marie D Campbell','1670 Adelaide St', 'M5H 1P6', 2, 2, 9 );
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID, LoanOfficerID) VALUES ('Michael Morgan','3196 7th Ave', 'T2P 0W4', 3, 3, 6, 7 );
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID, LoanOfficerID) VALUES ('Johnathan Hassen','428 Bay Street', 'M5J 2R8', 2, 2, 4, 7 );
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID) VALUES ('Oscar Waugh','702 40th Street', 'T2A 1C8', 3, 3, 6);
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID, LoanOfficerID) VALUES ('Michael B Powell','3115 Tanner Street', 'V5R 2T4', 1, 1, 8, 5 );
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID) VALUES ('Chris K Williams','3015 Robson St', 'V6B 3K9', 1, 1, 10);
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID) VALUES ('Donna Simmons','1532 Islington Ave', 'M9V 2X5', 2, 2, 4);
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, LoanOfficerID) VALUES ('Melissa G Ross','4464 Robson St', 'V6B 3K9', 1, 1, 5);
INSERT INTO Customers (Name, Street, PostalCode, BranchID, CityID, BankerID) VALUES ('Cheryl Tigner','3936 11th Ave', 'T2P 1M6', 3, 3, 6);
GO

-- AccountTypes Table
INSERT INTO AccountTypes(Description) VALUES ('Checking');
INSERT INTO AccountTypes(Description) VALUES ('Savings');

--/*******************************************************************************
--   Create the Foreign Keys Between the Tables
--********************************************************************************/

ALTER TABLE Branches
ADD FOREIGN KEY (CityID) REFERENCES Cities(CityID);

ALTER TABLE Payments
ADD PRIMARY KEY (PaymentID, LoanID);

ALTER TABLE Customers
ADD FOREIGN KEY (CityID) REFERENCES Cities(CityID);

ALTER TABLE Customers
ADD FOREIGN KEY (BranchID) REFERENCES Branches(BranchID);

ALTER TABLE Customers
ADD FOREIGN KEY (BankerID) REFERENCES Employees(EmployeeID);

ALTER TABLE Customers
ADD FOREIGN KEY (LoanOfficerID) REFERENCES Employees(EmployeeID);

ALTER TABLE Accounts
ADD FOREIGN KEY (BranchID) REFERENCES Branches(BranchID);

ALTER TABLE Accounts
ADD FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);

ALTER TABLE AccountCustomers
ADD FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID);

ALTER TABLE AccountCustomers
ADD FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

ALTER TABLE AccountInterest
ADD FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID);

ALTER TABLE AccountOverdrafts
ADD FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID);

ALTER TABLE Employees
ADD FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

ALTER TABLE Employees
ADD FOREIGN KEY (CityID) REFERENCES Cities(CityID);

ALTER TABLE Employees
ADD FOREIGN KEY (BranchID) REFERENCES Branches(BranchID);

ALTER TABLE Employees
ADD FOREIGN KEY (OfficeID) REFERENCES Offices(OfficeID);

ALTER TABLE Employees
ADD FOREIGN KEY (EmployeeTypeID) REFERENCES EmployeeTypes(EmployeeTypeID);

ALTER TABLE Offices
ADD FOREIGN KEY (CityID) REFERENCES Cities(CityID);

ALTER TABLE LoanCustomers
ADD FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

ALTER TABLE LoanCustomers
ADD FOREIGN KEY (LoanID) REFERENCES Loans(LoanID);

ALTER TABLE Payments
ADD FOREIGN KEY (LoanID) REFERENCES Loans(LoanID);


/*******************************************************************************

   QUERIES

********************************************************************************/

-- Outstanding balances by customer (Unpaid balance by customer)
SELECT 
	C.CustomerID, 
	Name, 
	L.Amount,
	(L.Amount - L.Balance) AS AmountPaid, 
	L.Balance as UnpaidBalance
FROM 
	Customers C LEFT JOIN 
	LoanCustomers LC 
	ON 
		C.CustomerID = LC.CustomerID
	LEFT JOIN Loans L
	ON 
		L.LoanID = LC.LoanID
WHERE Balance > 0
ORDER BY (L.Amount - L.Balance)

-- Customers with more than one account
SELECT 
	C.CustomerID, 
	C.Name,
	NumberOfAccounts
FROM 
	Customers C, 
	(SELECT CustomerID, COUNT(AccountID) NumberOfAccounts FROM AccountCustomers GROUP BY CustomerID HAVING COUNT(AccountID) > 1) AS mytable
	WHERE mytable.CustomerID = C.CustomerID
   
-- How many unpaid loans each branch has at the moment (LoanID by Branch)
SELECT 
	C.BranchID,
	b.Name,
	COUNT(LC.LoanID) NumberOfLoans,
	SUM(L.Balance) AS TotalUnpaidPerBranch
FROM 
	Customers C LEFT JOIN 
	LoanCustomers LC 
	ON 
		C.CustomerID = LC.CustomerID
	LEFT JOIN Loans L 
	ON 
		L.LoanID = LC.LoanID
	left join Branches b 
	ON 
		b.BranchID = c.BranchID
WHERE Balance > 0
GROUP BY C.BranchID, b.Name

-- How many clients does each loan officer have
SELECT LoanOfficerID, Employees.Name , COUNT(CustomerID) AS NumberOfClients
	FROM 
		Customers C LEFT JOIN Employees ON C.LoanOfficerID = Employees.EmployeeID
	WHERE 
		LoanOfficerID IN (SELECT LoanOfficerID FROM Employees WHERE EmployeeTypeID = 2)
	GROUP BY LoanOfficerID, Employees.Name

-- Number of customers per branch
SELECT 
	C.BranchID, 
	B.Name AS BranchName,
	COUNT(CustomerID) NumberOfCustomers
FROM Customers C LEFT JOIN Branches B ON B.BranchID = C.BranchID
	GROUP BY C.BranchID, B.Name

-- Number of accounts per type, per branch
SELECT A.BranchID, B.Name,  AT.Description , COUNT(AccountID) AS NumberOfAccounts
	 FROM Accounts A 
		LEFT JOIN AccountTypes AT ON AT.AccountTypeID = A.AccountTypeID
		LEFT JOIN Branches B ON B.BranchID = A.BranchID
GROUP BY A.BranchID, B.Name, A.AccountTypeID, AT.Description

-- Number of accounts per InterestRate
SELECT InterestRate, COUNT(AccountID) AS NumberOfAccounts 
FROM AccountInterest
GROUP BY InterestRate

-- Account numbers by banker
SELECT C.BankerID, C.Name, AC.AccountID AS AccountNumber
	FROM 
		Customers C LEFT JOIN Employees ON C.BankerID = Employees.EmployeeID
		LEFT JOIN AccountCustomers AC ON AC.CustomerID = C.CustomerID
	WHERE 
		BankerID IN (SELECT BankerID FROM Employees WHERE EmployeeTypeID = 3)
	ORDER BY Name ASC

-- Employee lengh of service in days ordered descending
SELECT Name, 
	StartDate, 
	CAST((SELECT GETDATE() - CONVERT(DATETIME, StartDate)) AS INTEGER) AS DaysWorked 
FROM Employees
ORDER BY CAST((SELECT GETDATE() - CONVERT(DATETIME, StartDate)) AS INTEGER) DESC

-- Accounts by LoanOfficer
SELECT C.LoanOfficerID, C.Name, AC.AccountID AS AccountNumber
	FROM 
		Customers C LEFT JOIN Employees ON C.LoanOfficerID = Employees.EmployeeID
		LEFT JOIN AccountCustomers AC ON AC.CustomerID = C.CustomerID
	WHERE 
		LoanOfficerID IN (SELECT LoanOfficerID FROM Employees WHERE EmployeeTypeID = 3)
	ORDER BY Name ASC