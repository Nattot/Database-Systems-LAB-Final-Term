USE VOVeggieHotpot

--1
SELECT 
	s.StaffName,
	s.StaffGender,
	s.StaffPhone
FROM MsStaff s
WHERE s.StaffName LIKE '%a' OR  
	s.StaffName LIKE '%e' OR  
	s.StaffName LIKE '%i' OR  
	s.StaffName LIKE '%o' OR  
	s.StaffName LIKE '%u'

--2
SELECT
	c.CustomerID,
	c.CustomerEmail,
	c.CustomerGender,
	th.TransactionDate
FROM MsCustomer c, TransactionHeader th
WHERE c.CustomerID = th.CustomerID AND
	DATEDIFF(month, th.TransactionDate, '2022-01-16') = 2

--3
SELECT
	[CustomerCode] = RIGHT(c.CustomerID, 3),
	c.CustomerName,
	[CustomerPhone] = REPLACE(c.CustomerPhone, '+62', '0'),
	[TotalTransaction] = COUNT(th.TransactionID)
FROM MsCustomer c, TransactionHeader th, MsStaff s
WHERE c.CustomerID = th.CustomerID AND
	s.StaffID = th.StaffID AND
	CAST(RIGHT(th.StaffID, 3) AS INT)%2 = 1
GROUP BY c.CustomerID, c.CustomerName, c.CustomerPhone

--4
SELECT
	SUBSTRING(s.StaffName, 1, CHARINDEX(' ',s.StaffName)-1) AS [StaffAlias],
	s.StaffSalary,
	[TotalService] = COUNT(th.CustomerID)
FROM MsCustomer c, TransactionHeader th, MsStaff s, (SELECT Aveg = AVG(s.StaffSalary) FROM MsStaff s) as egv
WHERE c.CustomerID = th.CustomerID AND
	s.StaffID = th.StaffID AND
	th.CustomerID LIKE 'CU006' AND
	s.StaffSalary > egv.Aveg
GROUP BY s.StaffName, s.StaffSalary
UNION
SELECT
	SUBSTRING(s.StaffName, 1, CHARINDEX(' ',s.StaffName)-1) AS [StaffAlias],
	s.StaffSalary,
	[TotalService] = COUNT(th.CustomerID)
FROM MsCustomer c, TransactionHeader th, MsStaff s, (SELECT Aveg = AVG(s.StaffSalary) FROM MsStaff s) as egv
WHERE c.CustomerID = th.CustomerID AND
	s.StaffID = th.StaffID AND
	th.CustomerID LIKE 'CU008' AND
	s.StaffSalary > egv.Aveg
GROUP BY s.StaffName, s.StaffSalary

--5
SELECT
	c.CustomerName,
	c.CustomerGender,
	[CustomerAge] = DATEDIFF(year, c.CustomerDOB, '2022-01-16')
FROM MsCustomer c, TransactionHeader th, TransactionDetail td, MsMenu m
WHERE c.CustomerID = th.CustomerID AND
	td.TransactionID = th.TransactionID AND
	m.MenuID = td.MenuID AND
	c.CustomerGender LIKE 'female' AND 
	m.MenuName LIKE 'Silken Tofu'

--6
SELECT 
	c.CustomerID,
	c.CustomerName,
	[Total Money Spent] = 'IDR suh.sm'
FROM MsCustomer c, TransactionHeader th, (SELECT sm = SUM(m.MenuPrice) FROM MsMenu m) as suh
WHERE c.CustomerID = th.CustomerID AND
	CAST(RIGHT(c.CustomerID, 3) AS INT)%2 = 1 AND
	[Total Money Spent] BETWEEN 50000 and 150000

--7
CREATE VIEW FemaleStaffData AS
SELECT
	s.StaffID,
	s.StaffName,
	s.StaffPhone,
	[StaffDOB] = CONVERT(VARCHAR, s.StaffDOB, 107)
FROM MsStaff s
WHERE s.StaffGender LIKE 'female'
SELECT *FROM FemaleStaffData

--8
CREATE VIEW 4thQuarterSalesView AS
SELECT
	m.MenuID,
	m.MenuName,
	[Total Purchased] = COUNT(td.Quantity)
FROM MsMenu m, TransactionDetail td, TransactionHeader th
WHERE m.MenuID = td.MenuID AND
	th.TransactionID = td.TransactionID AND
	m.MenuName LIKE '% %' AND
	DATENAME(quarter, th.TransactionDate) LIKE '4'
GROUP BY m.MenuID, m.MenuName
SELECT *FROM 4thQuarterSalesView 

--9
BEGIN TRAN
ALTER TABLE MsStaff
	ADD StaffEmail VARCHAR(50)
ALTER TABLE MsStaff
	ADD CONSTRAINT StaffEmailConstraint CHECK (StaffEmail LIKE '%@veggie.hotpot')
ROLLBACK
COMMIT
SELECT *FROM MsStaff

--10
BEGIN TRAN
UPDATE Menu
	set MenuPrice = MenuPrice + MenuPrice*30%
	FROM MsMenu m, TransactionDetail td, TransactionHeader th
	WHERE m.MenuID = td.MenuID AND
		td.TransactionID = th.TransactionID AND
		m.MenuPrice < 50000 AND
		DATENAME(weekday, th.TransactionDate) LIKE 'Saturday' OR DATENAME(weekday, th.TransactionDate) LIKE 'Sunday'
ROLLBACK
COMMIT
SELECT *FROM Menu