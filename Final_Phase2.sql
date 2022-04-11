-- Group Project - Phase 2
-- Robert Parker, Arianne Guedes, Jorge Gayer

-- Step 1. Implementing different functionalities using stored procedure and user defined function

-- STORED PROCEDURES
-- How many unpaid loans each branch has at the moment (LoanID by Branch)
USE SKS_BANK;

CREATE PROCEDURE spUnpaidLoansByBranch (@BranchID AS INT = 0)
AS
BEGIN
	IF @BranchID = 0
		SELECT 
			C.BranchID,
			B.Name,
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
			LEFT JOIN Branches B 
			ON 
				B.BranchID = C.BranchID
		WHERE Balance > 0
		GROUP BY C.BranchID, B.Name
	ELSE
		SELECT 
			C.BranchID,
			B.Name,
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
			LEFT JOIN Branches B 
			ON 
				B.BranchID = C.BranchID
		WHERE Balance > 0 AND C.branchid = @BranchID
		GROUP BY C.BranchID, B.Name
END;

EXEC spUnpaidLoansByBranch;
EXEC spUnpaidLoansByBranch 1;


CREATE PROC spAccountsByBankerID (@BankerID AS INT = 0)
AS
BEGIN
	IF @BankerID = 0
		THROW 50001, 'Please enter the Banker ID', 1;
	ELSE
	-- Account numbers by banker
			SELECT C.BankerID, C.name, AC.AccountID AS AccountNumber
				FROM 
					Customers C LEFT JOIN Employees ON C.BankerID = Employees.EmployeeID
					LEFT JOIN AccountCustomers AC ON AC.CustomerID = C.CustomerID
				WHERE 
					BankerID = @BankerID
					
				ORDER BY Name ASC
END;

EXEC spAccountsByBankerID;
EXEC spAccountsByBankerID 8;


-- USER DEFINED FUNCTION
CREATE FUNCTION getPaymentBranchAmountByDate (@BranchID AS INT, @PaymentDate AS DATE)
RETURNS MONEY
AS
BEGIN
RETURN (
	SELECT 
	SUM(p.Amount) AS Total
		FROM Payments p 
		LEFT JOIN Loans l ON p.LoanID = L.LoanID
		LEFT JOIN LoanCustomers lc ON lc.LoanID = l.LoanID
		LEFT JOIN Customers c ON c.CustomerID = lc.CustomerID
		LEFT JOIN Branches b ON c.BranchID = b.BranchID
	WHERE c.BranchID = @BranchID and p.Date = @PaymentDate
	GROUP BY b.Name, p.Date
	)
END;

SELECT dbo.getPaymentBranchAmountByDate (1, '2021-12-16');


--Step 2. Create different set of triggers (minimum 2 numbers) to monitor the different DML and DDL activates in the database

-- Trigger to upload the balance on Loans table once you do a payment on Payments table
CREATE TRIGGER tgUpdateLoanBalance
ON Payments
AFTER INSERT
AS
BEGIN
	DECLARE @Value AS MONEY;
	DECLARE @LoanID AS INT;
	SELECT @Value = Amount FROM inserted;
	SELECT @LoanID = LoanID FROM inserted;
	UPDATE Loans SET Balance = Balance - @Value WHERE LoanID = @LoanID
END;

SELECT * FROM Loans;
SELECT * FROM Payments;
SELECT * FROM LoanCustomers;
SELECT * FROM Customers;

INSERT INTO Payments (LoanID, Amount, Date) VALUES (1, 1000, getdate());


-- Trigger preventing to drop or alter a table
-- ENABLE/DISABLE TRIGGER safety on database
CREATE TRIGGER safety 
ON DATABASE 
FOR DROP_TABLE, ALTER_TABLE 
AS 
	PRINT 'Contact your Database admin to disable the safety trigger!' 
	ROLLBACK;

ALTER TABLE Accounts
ADD FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);


-- Step 3. Create index based on frequently used attribute for three of any table

-- Replace the default cluster index with non-key attribute for one table
-- a
-- Disable the safety trigger first and at the end enable it
ALTER TABLE Accounts
DROP CONSTRAINT FK__Accounts__Accoun__46E78A0C

-- b
-- Delete the AccountTypes default index through GUI and then
CREATE Clustered INDEX cuix_AccountTypes
ON AccountTypes (Description);

-- c
ALTER TABLE AccountTypes
ADD PRIMARY KEY (AccountTypeID);

-- d
ALTER TABLE Accounts
ADD FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);


-- Create composite clustered index for one of the table by removing the default clustered index
-- a
-- Disable the safety trigger first and at the end enable it
ALTER TABLE Employees
DROP CONSTRAINT FK__Employees__Offic__4E88ABD4

-- b
-- Delete the Offices default index through GUI and then
CREATE Clustered INDEX cuix_Offices
ON Offices (Name, CityID);

-- c
ALTER TABLE Offices
ADD PRIMARY KEY (OfficeID);

-- d
ALTER TABLE Employees
ADD FOREIGN KEY (OfficeID) REFERENCES Offices(OfficeID);


-- Create non clustered composite index for one of the table
CREATE INDEX nix_Account
ON Accounts (BranchID, AccountTypeid);


-- Step 4. Create different level of users and assign appropriate privilege

-- Customer user
CREATE LOGIN 
	customer_1 
WITH 
	PASSWORD = 'customer'

CREATE USER 
	customer_1

CREATE ROLE Customers
ALTER ROLE Customers ADD MEMBER customer_1

-- Grant update and select access to customers for Accounts table
GRANT SELECT, UPDATE
ON Accounts 
TO Customers

-- Grant update and select access to customers for Customers table
GRANT SELECT, UPDATE
ON Customers 
TO Customers

-- Grant update and select access to customers for Loans table
GRANT SELECT, UPDATE
ON Loans 
TO Customers

-- Grant update and select access to customers for Payments table
GRANT SELECT, UPDATE
ON Payments 
TO Customers


-- Accountant user
CREATE LOGIN 
	accountant_1 
WITH 
	PASSWORD = 'accountant'

CREATE USER 
	accountant_1

CREATE ROLE Accountant
ALTER ROLE Accountant ADD MEMBER Accountant_1

GRANT SELECT, UPDATE, DELETE ON AccountCustomers TO Accountant
GRANT SELECT, UPDATE, DELETE ON AccountInterest TO Accountant
GRANT SELECT, UPDATE, DELETE ON AccountOverdrafts TO Accountant
GRANT SELECT ON Accounts TO Accountant
GRANT SELECT, UPDATE, DELETE ON AccountTypes TO Accountant
GRANT SELECT, UPDATE, DELETE ON Branches TO Accountant
GRANT SELECT, UPDATE, DELETE ON Cities TO Accountant
GRANT SELECT, UPDATE, DELETE ON Customers TO Accountant
GRANT SELECT, UPDATE, DELETE ON Employees TO Accountant
GRANT SELECT, UPDATE, DELETE ON EmployeeTypes TO Accountant
GRANT SELECT,UPDATE, DELETE ON LoanCustomers TO Accountant
GRANT SELECT ON Loans TO Accountant
GRANT SELECT, UPDATE, DELETE ON Offices TO Accountant
GRANT SELECT ON Payments TO Accountant


-- Proof of access to customer
-- Customers should not have access to the queries below
DELETE FROM Loans WHERE LoanID = 5;
CREATE ROLE Accountant
SELECT * FROM Cities

-- Proof of access to accountant
-- This should work with granted access
UPDATE Cities SET Name = 'teamwork' WHERE CityID = 1
UPDATE Cities SET Name = 'Vancouver' WHERE CityID = 1
SELECT * FROM Cities

-- Access to this should not be allowed
INSERT INTO Payments (LoanID, Amount, Date) VALUES (1, 1000, getdate())


-- Step 5. Recovery model and backup

ALTER DATABASE SKS_Bank SET RECOVERY FULL WITH no_wait;

BACKUP DATABASE SKS_BANK TO DISK = 'D:\Software Development\DATA2201\FullSKS.bak'