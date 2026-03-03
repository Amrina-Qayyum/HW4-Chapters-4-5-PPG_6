/* ============================================================
 HW4 - PPG_6 - Amrina Qayyum
 NORTHWINDS2024STUDENT - FINAL QUERIES
 Tables:
 ============================================================ */

USE Northwinds2024Student;
SET NOCOUNT ON;

/* ------------------------------------------------------------
   CHAPTER 4 - SUBQUERIES
   ------------------------------------------------------------ */

-- 4-1) Orders on the last day of activity
SELECT OrderId, OrderDate, CustomerId, EmployeeId
FROM Sales.[Order]
WHERE OrderDate = (SELECT MAX(OrderDate) FROM Sales.[Order]);

-- 4-2) Orders by customer(s) with the highest number of orders
SELECT o.CustomerId, o.OrderId, o.OrderDate, o.EmployeeId
FROM Sales.[Order] AS o
WHERE o.CustomerId IN
(
    SELECT CustomerId
    FROM Sales.[Order]
    GROUP BY CustomerId
    HAVING COUNT(*) =
    (
        SELECT MAX(cnt)
        FROM
        (
            SELECT COUNT(*) AS cnt
            FROM Sales.[Order]
            GROUP BY CustomerId
        ) AS D
    )
)
ORDER BY o.CustomerId, o.OrderId;


DECLARE 
    @EmpFirst sysname,
    @EmpLast  sysname,
    @EmpCountry sysname,
    @CustCompany sysname,
    @CustCountry sysname,
    @sql nvarchar(max);

-- Detect Employee first name column
SELECT TOP (1) @EmpFirst = c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name='HumanResources' AND o.name='Employee'
  AND (c.name LIKE '%First%' OR c.name LIKE '%FName%' OR c.name LIKE '%Given%' OR c.name LIKE '%Forename%')
ORDER BY CASE WHEN c.name LIKE '%First%' THEN 0 ELSE 1 END;

-- Detect Employee last name column
SELECT TOP (1) @EmpLast = c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name='HumanResources' AND o.name='Employee'
  AND (c.name LIKE '%Last%' OR c.name LIKE '%LName%' OR c.name LIKE '%Surname%' OR c.name LIKE '%Family%')
ORDER BY CASE WHEN c.name LIKE '%Last%' THEN 0 ELSE 1 END;

-- Detect Employee country column
SELECT TOP (1) @EmpCountry = c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name='HumanResources' AND o.name='Employee'
  AND (c.name LIKE '%Country%' OR c.name LIKE '%Nation%')
ORDER BY CASE WHEN c.name LIKE '%Country%' THEN 0 ELSE 1 END;

-- Detect Customer company/name column
SELECT TOP (1) @CustCompany = c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name='Sales' AND o.name='Customer'
  AND (c.name LIKE '%CompanyName%' OR c.name LIKE '%Company%' OR c.name LIKE '%CustomerName%' OR c.name LIKE '%Name%')
ORDER BY 
  CASE 
    WHEN c.name LIKE '%CompanyName%' THEN 0
    WHEN c.name LIKE '%Company%' THEN 1
    WHEN c.name LIKE '%CustomerName%' THEN 2
    ELSE 3
  END;

-- Detect Customer country column
SELECT TOP (1) @CustCountry = c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name='Sales' AND o.name='Customer'
  AND (c.name LIKE '%Country%' OR c.name LIKE '%Nation%')
ORDER BY CASE WHEN c.name LIKE '%Country%' THEN 0 ELSE 1 END;



-- 4-3) Employees who did NOT place orders on or after May 1, 2016
SET @sql = N'
SELECT e.EmployeeId,
       e.' + QUOTENAME(@EmpFirst) + N' AS FirstName,
       e.' + QUOTENAME(@EmpLast)  + N' AS LastName
FROM HumanResources.Employee AS e
WHERE e.EmployeeId NOT IN
(
    SELECT o.EmployeeId
    FROM Sales.[Order] AS o
    WHERE o.OrderDate >= ''20160501''
)
ORDER BY e.EmployeeId;';
EXEC sys.sp_executesql @sql;




-- 4-4) Countries with customers but not employees
SET @sql = N'
SELECT c.' + QUOTENAME(@CustCountry) + N' AS Country
FROM Sales.Customer AS c
WHERE c.' + QUOTENAME(@CustCountry) + N' NOT IN
(
    SELECT e.' + QUOTENAME(@EmpCountry) + N'
    FROM HumanResources.Employee AS e
    WHERE e.' + QUOTENAME(@EmpCountry) + N' IS NOT NULL
)
GROUP BY c.' + QUOTENAME(@CustCountry) + N'
ORDER BY c.' + QUOTENAME(@CustCountry) + N';';
EXEC sys.sp_executesql @sql;




-- 4-5) Orders on each customer's last active day
SELECT o.CustomerId, o.OrderId, o.OrderDate, o.EmployeeId
FROM Sales.[Order] AS o
WHERE o.OrderDate =
(
    SELECT MAX(o2.OrderDate)
    FROM Sales.[Order] AS o2
    WHERE o2.CustomerId = o.CustomerId
)
ORDER BY o.CustomerId, o.OrderId;




-- 4-6) Customers who ordered in 2015 but not 2016
SET @sql = N'
SELECT c.CustomerId, c.' + QUOTENAME(@CustCompany) + N' AS CompanyName
FROM Sales.Customer AS c
WHERE c.CustomerId IN
(
    SELECT o.CustomerId
    FROM Sales.[Order] AS o
    WHERE o.OrderDate >= ''20150101'' AND o.OrderDate < ''20160101''
)
AND c.CustomerId NOT IN
(
    SELECT o.CustomerId
    FROM Sales.[Order] AS o
    WHERE o.OrderDate >= ''20160101'' AND o.OrderDate < ''20170101''
)
ORDER BY c.CustomerId;';
EXEC sys.sp_executesql @sql;




-- 4-7) Customers who ordered product 12
SET @sql = N'
SELECT DISTINCT c.CustomerId, c.' + QUOTENAME(@CustCompany) + N' AS CompanyName
FROM Sales.Customer AS c
WHERE c.CustomerId IN
(
    SELECT o.CustomerId
    FROM Sales.[Order] AS o
    WHERE o.OrderId IN
    (
        SELECT od.OrderId
        FROM Sales.OrderDetail AS od
        WHERE od.ProductId = 12
    )
)
ORDER BY c.CustomerId;';
EXEC sys.sp_executesql @sql;




-- 4-8) Running total quantity by customer and month
WITH CustMonth AS
(
    SELECT
        o.CustomerId,
        DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS OrderMonth,
        SUM(od.Quantity) AS Qty
    FROM Sales.[Order] AS o
    JOIN Sales.OrderDetail AS od
        ON od.OrderId = o.OrderId
    GROUP BY o.CustomerId, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
SELECT
    cm.CustomerId,
    cm.OrderMonth,
    cm.Qty,
    (
        SELECT SUM(cm2.Qty)
        FROM CustMonth AS cm2
        WHERE cm2.CustomerId = cm.CustomerId
          AND cm2.OrderMonth <= cm.OrderMonth
    ) AS RunQty
FROM CustMonth AS cm
ORDER BY cm.CustomerId, cm.OrderMonth;



-- 4-10) Days since previous order per customer
SELECT
    o.CustomerId,
    o.OrderDate,
    o.OrderId,
    DATEDIFF
    (
        day,
        (
            SELECT TOP (1) o2.OrderDate
            FROM Sales.[Order] AS o2
            WHERE o2.CustomerId = o.CustomerId
              AND (o2.OrderDate < o.OrderDate OR (o2.OrderDate = o.OrderDate AND o2.OrderId < o.OrderId))
            ORDER BY o2.OrderDate DESC, o2.OrderId DESC
        ),
        o.OrderDate
    ) AS diff
FROM Sales.[Order] AS o
ORDER BY o.CustomerId, o.OrderDate, o.OrderId;


/* ------------------------------------------------------------
   CHAPTER 5 - TABLE EXPRESSIONS
   ------------------------------------------------------------ */

-- 5-1) 
SELECT OrderId, OrderDate, CustomerId, EmployeeId,
  DATEFROMPARTS(YEAR(OrderDate), 12, 31) AS EndOfYear
FROM Sales.[Order]
WHERE OrderDate <> DATEFROMPARTS(YEAR(OrderDate), 12, 31);

-- 5-2-1) Max order date per employee
SELECT EmployeeId, MAX(OrderDate) AS MaxOrderDate
FROM Sales.[Order]
GROUP BY EmployeeId
ORDER BY EmployeeId;

-- 5-2-2) Orders with max date per employee
SELECT o.EmployeeId, o.OrderDate, o.OrderId, o.CustomerId
FROM Sales.[Order] AS o
JOIN
(
    SELECT EmployeeId, MAX(OrderDate) AS MaxOrderDate
    FROM Sales.[Order]
    GROUP BY EmployeeId
) AS mx
    ON mx.EmployeeId = o.EmployeeId
   AND mx.MaxOrderDate = o.OrderDate
ORDER BY o.EmployeeId, o.OrderDate, o.OrderId;

-- 5-3-1) Row numbers for orders
SELECT
    OrderId, OrderDate, CustomerId, EmployeeId,
    ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS RowNum
FROM Sales.[Order]
ORDER BY RowNum;

-- 5-3-2) Rows 11 to 20 using CTE
WITH Ordered AS
(
    SELECT
        OrderId, OrderDate, CustomerId, EmployeeId,
        ROW_NUMBER() OVER (ORDER BY OrderDate, OrderId) AS RowNum
    FROM Sales.[Order]
)
SELECT OrderId, OrderDate, CustomerId, EmployeeId, RowNum
FROM Ordered
WHERE RowNum BETWEEN 11 AND 20
ORDER BY RowNum;


/* ------------------------------------------------------------
   EXTRA REQUIRED QUERY: FY Quarter (Federal FY starts Oct 1)
   ------------------------------------------------------------ */

CREATE OR ALTER FUNCTION dbo.fn_FYQuarter_NW (@OrderDate date)
RETURNS varchar(12)
AS
BEGIN
    DECLARE @fy int, @q int;

    SET @fy = CASE WHEN MONTH(@OrderDate) >= 10 THEN YEAR(@OrderDate) + 1
                   ELSE YEAR(@OrderDate) END;

    SET @q = CASE
                WHEN MONTH(@OrderDate) IN (10,11,12) THEN 1
                WHEN MONTH(@OrderDate) IN (1,2,3)   THEN 2
                WHEN MONTH(@OrderDate) IN (4,5,6)   THEN 3
                ELSE 4
             END;

    RETURN CONCAT('FY', @fy, '-Q', @q);
END;
GO

SELECT
    dbo.fn_FYQuarter_NW(o.OrderDate) AS FY_Quarter,
    COUNT(*) AS TotalOrders,
    SUM(o.Freight) AS TotalFreight
FROM Sales.[Order] AS o
GROUP BY dbo.fn_FYQuarter_NW(o.OrderDate)
ORDER BY
    CAST(SUBSTRING(dbo.fn_FYQuarter_NW(o.OrderDate), 3, 4) AS int) DESC,
    CAST(RIGHT(dbo.fn_FYQuarter_NW(o.OrderDate), 1) AS int) DESC;
GO