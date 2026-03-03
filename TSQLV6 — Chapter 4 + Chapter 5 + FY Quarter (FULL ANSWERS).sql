/* ============================================================
HW4 - PPG_6 - Amrina Qayyum
FULL SOLUTIONS (Chapter 4 + Chapter 5) in TSQLV6
============================================================ */
USE TSQLV6;
GO

/* ============================================================
   CHAPTER 04 - SUBQUERIES (Exercises)
 ============================================================ */

-- 1) Orders placed on the last day of activity in Orders table
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = (SELECT MAX(orderdate) FROM Sales.Orders);
GO

-- 2) Orders placed by customer(s) with the highest number of orders
SELECT o.custid, o.orderid, o.orderdate, o.empid
FROM Sales.Orders AS o
WHERE o.custid IN
(
    SELECT custid
    FROM Sales.Orders
    GROUP BY custid
    HAVING COUNT(*) =
    (
        SELECT MAX(cnt)
        FROM
        (
            SELECT COUNT(*) AS cnt
            FROM Sales.Orders
            GROUP BY custid
        ) AS D
    )
)
ORDER BY o.custid, o.orderid;
GO

-- 3) Employees who did NOT place orders on or after May 1, 2016
SELECT e.empid, e.firstname, e.lastname
FROM HR.Employees AS e
WHERE e.empid NOT IN
(
    SELECT o.empid
    FROM Sales.Orders AS o
    WHERE o.orderdate >= '20160501'
);
GO

-- 4) Countries where there are customers but NOT employees
SELECT c.country
FROM Sales.Customers AS c
WHERE c.country NOT IN
(
    SELECT e.country
    FROM HR.Employees AS e
)
GROUP BY c.country
ORDER BY c.country;
GO

-- 5) For each customer: all orders placed on that customer's last day of activity
SELECT o.custid, o.orderid, o.orderdate, o.empid
FROM Sales.Orders AS o
WHERE o.orderdate =
(
    SELECT MAX(o2.orderdate)
    FROM Sales.Orders AS o2
    WHERE o2.custid = o.custid
)
ORDER BY o.custid, o.orderid;
GO

-- 6) Customers who placed orders in 2015 but not in 2016
SELECT c.custid, c.companyname
FROM Sales.Customers AS c
WHERE c.custid IN
(
    SELECT o.custid
    FROM Sales.Orders AS o
    WHERE o.orderdate >= '20150101' AND o.orderdate < '20160101'
)
AND c.custid NOT IN
(
    SELECT o.custid
    FROM Sales.Orders AS o
    WHERE o.orderdate >= '20160101' AND o.orderdate < '20170101'
)
ORDER BY c.custid;
GO

-- 7) (Optional) Customers who ordered product 12
SELECT DISTINCT c.custid, c.companyname
FROM Sales.Customers AS c
WHERE c.custid IN
(
    SELECT o.custid
    FROM Sales.Orders AS o
    WHERE o.orderid IN
    (
        SELECT od.orderid
        FROM Sales.OrderDetails AS od
        WHERE od.productid = 12
    )
)
ORDER BY c.custid;
GO

-- 8) (Optional) Running total qty for each customer and month using subqueries
-- (If the view exists in your TSQLV6. If not, use the fallback query below.)
IF OBJECT_ID('Sales.CustOrders','V') IS NOT NULL
BEGIN
    SELECT
        co.custid,
        co.ordermonth,
        co.qty,
        (
            SELECT SUM(co2.qty)
            FROM Sales.CustOrders AS co2
            WHERE co2.custid = co.custid
              AND co2.ordermonth <= co.ordermonth
        ) AS runqty
    FROM Sales.CustOrders AS co
    ORDER BY co.custid, co.ordermonth;
END
ELSE
BEGIN
    -- Fallback: build cust-month qty from Orders + OrderDetails
    WITH CustMonth AS
    (
        SELECT
            o.custid,
            DATEFROMPARTS(YEAR(o.orderdate), MONTH(o.orderdate), 1) AS ordermonth,
            SUM(od.qty) AS qty
        FROM Sales.Orders AS o
        JOIN Sales.OrderDetails AS od
            ON od.orderid = o.orderid
        GROUP BY o.custid, DATEFROMPARTS(YEAR(o.orderdate), MONTH(o.orderdate), 1)
    )
    SELECT
        cm.custid,
        cm.ordermonth,
        cm.qty,
        (
            SELECT SUM(cm2.qty)
            FROM CustMonth AS cm2
            WHERE cm2.custid = cm.custid
              AND cm2.ordermonth <= cm.ordermonth
        ) AS runqty
    FROM CustMonth AS cm
    ORDER BY cm.custid, cm.ordermonth;
END;
GO


-- 10) 
SELECT
    o.custid,
    o.orderdate,
    o.orderid,
    DATEDIFF
    (
        day,
        (
            SELECT TOP (1) o2.orderdate
            FROM Sales.Orders AS o2
            WHERE o2.custid = o.custid
              AND (o2.orderdate < o.orderdate OR (o2.orderdate = o.orderdate AND o2.orderid < o.orderid))
            ORDER BY o2.orderdate DESC, o2.orderid DESC
        ),
        o.orderdate
    ) AS diff
FROM Sales.Orders AS o
ORDER BY o.custid, o.orderdate, o.orderid;
GO






/* ============================================================
   CHAPTER 05 - TABLE EXPRESSIONS (Exercises)
   ============================================================ */

-- 1) 
SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate), 12, 31);
GO



SELECT *
FROM
(
    SELECT orderid, orderdate, custid, empid,
      DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
    FROM Sales.Orders
) AS D
WHERE D.orderdate <> D.endofyear;
GO



-- 2-1) Max order date for each employee
SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid
ORDER BY empid;
GO



-- 2-2) Derived table join: Orders with max order date per employee
SELECT o.empid, o.orderdate, o.orderid, o.custid
FROM Sales.Orders AS o
JOIN
(
    SELECT empid, MAX(orderdate) AS maxorderdate
    FROM Sales.Orders
    GROUP BY empid
) AS mx
    ON mx.empid = o.empid
   AND mx.maxorderdate = o.orderdate
ORDER BY o.empid, o.orderdate, o.orderid;
GO


-- 3-1) Row number for each order by orderdate, orderid
SELECT
    orderid, orderdate, custid, empid,
    ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
ORDER BY rownum;
GO



-- 3-2) Rows 11 through 20 using CTE
WITH Ordered AS
(
    SELECT
        orderid, orderdate, custid, empid,
        ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rownum
    FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid, rownum
FROM Ordered
WHERE rownum BETWEEN 11 AND 20
ORDER BY rownum;
GO



-- 4) Recursive CTE: management chain leading to employee 9
WITH EmpChain AS
(
    SELECT empid, mgrid, firstname, lastname
    FROM HR.Employees
    WHERE empid = 9

    UNION ALL

    SELECT e.empid, e.mgrid, e.firstname, e.lastname
    FROM HR.Employees AS e
    JOIN EmpChain AS c
        ON e.empid = c.mgrid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpChain;
GO


-- 5-1) Create view: total qty for each employee and year
CREATE OR ALTER VIEW Sales.VEmpOrders
AS
SELECT
    o.empid,
    YEAR(o.orderdate) AS orderyear,
    SUM(od.qty) AS qty
FROM Sales.Orders AS o
JOIN Sales.OrderDetails AS od
    ON od.orderid = o.orderid
GROUP BY o.empid, YEAR(o.orderdate);
GO

-- Test view
SELECT * FROM Sales.VEmpOrders
ORDER BY empid, orderyear;
GO

-- 5-2) Running qty for each employee and year
SELECT
    empid,
    orderyear,
    qty,
    SUM(qty) OVER (PARTITION BY empid ORDER BY orderyear ROWS UNBOUNDED PRECEDING) AS runqty
FROM Sales.VEmpOrders
ORDER BY empid, orderyear;
GO

-- 6-1) Inline function: Top N products by unitprice for a supplier
CREATE OR ALTER FUNCTION Production.TopProducts
(
    @supid int,
    @n     int
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@n)
        productid, productname, unitprice
    FROM Production.Products
    WHERE supplierid = @supid
    ORDER BY unitprice DESC, productid
);
GO


-- 6-2) CROSS APPLY: for each supplier, two most expensive products
SELECT
    s.supplierid,
    s.companyname,
    p.productid,
    p.productname,
    p.unitprice
FROM Production.Suppliers AS s
CROSS APPLY Production.TopProducts(s.supplierid, 2) AS p
ORDER BY s.supplierid, p.unitprice DESC, p.productid;
GO

DROP VIEW IF EXISTS Sales.VEmpOrders;
DROP FUNCTION IF EXISTS Production.TopProducts;
GO


/* ============================================================
   FY Quarter scalar function + totals by quarter (TSQLV6)
   ============================================================ */

-- Federal FY starts Oct 1 (anchor month 10)
CREATE OR ALTER FUNCTION dbo.fn_FYQuarter (@OrderDate date)
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
    dbo.fn_FYQuarter(o.orderdate) AS FY_Quarter,
    COUNT(*) AS TotalOrders,
    SUM(o.freight) AS TotalFreight
FROM Sales.Orders AS o
GROUP BY dbo.fn_FYQuarter(o.orderdate)
ORDER BY
    CAST(SUBSTRING(dbo.fn_FYQuarter(o.orderdate), 3, 4) AS int) DESC,
    CAST(RIGHT(dbo.fn_FYQuarter(o.orderdate), 1) AS int) DESC;
GO