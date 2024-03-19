create database AdventureWorks;

use AdventureWorks;

UPDATE `adventureworks`.`factsales` 
SET `OrderDate` = STR_TO_DATE(`OrderDate`, '%d/%m/%Y');

UPDATE `adventureworks`.`factsales` 
SET `ShipDate` = STR_TO_DATE(`ShipDate`, '%d/%m/%Y');


-- Q1. Calculate the Total Sales and Profit per year

SELECT 
    YEAR(orderdate) AS `Year`,
    CEILING(SUM(salesamount)) AS 'Total Sales',
    CEILING(SUM(salesamount - (totalproductcost + taxamt + freight))) AS `Profit`
FROM
    factsales
GROUP BY YEAR(orderDate);

-- Q2. Calculate total Sales and Profit  as per Product Category

SELECT 
    pc.EnglishProductCategoryName AS 'Product Category',
    CEILING(SUM(fs.salesamount)) AS 'Total Sales',
    CEILING(SUM(salesamount - (totalproductcost + taxamt + freight))) AS `Profit`
FROM
    factsales fs
        LEFT JOIN
    product p ON p.ProductKey = fs.ProductKey
        JOIN
    subcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
        JOIN
    productcategory pc ON pc.ProductCategoryKey = s.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName;

-- Q3. Find the top 10 products which generate the highest revenue

SELECT 
    p.EnglishProductName AS 'Product Name',
    SUM(fs.salesamount) 'Total Sales'
FROM
    factsales fs
        JOIN
    product p ON p.ProductKey = fs.ProductKey
GROUP BY p.EnglishProductName
ORDER BY SUM(fs.salesamount) DESC
LIMIT 10;

-- Q4. Find the top 10 products which generate the highest profits

SELECT 
    p.EnglishProductName AS 'Product Name',
    CEILING(SUM(salesamount - (totalproductcost + taxamt + freight))) AS `Profit`
FROM
    factsales fs
        JOIN
    product p ON p.ProductKey = fs.ProductKey
GROUP BY p.EnglishProductName
ORDER BY SUM(fs.salesamount) DESC
LIMIT 10;

-- Q5. Find the total orders and revenue generated from each country

SELECT 
    s.SalesTerritoryCountry AS 'Country',
    SUM(fs.orderquantity) AS 'Total Orders',
    TRUNCATE(SUM(fs.salesamount), 2) AS 'Total Revenue'
FROM
    factsales fs
        RIGHT JOIN
    salesterritory s ON s.SalesTerritoryKey = fs.SalesTerritoryKey
GROUP BY s.SalesTerritoryCountry;

-- Q6. Calculate the year-on-year growth percentage in terms of revenue 

Select Year(orderDate) as 'Year' , truncate(sum(salesamount),2) as 'Revenue' , 
concat(Ceiling((sum(salesamount) - lag(sum(salesamount)) over (order by Year(orderDate)))/(lag(sum(salesamount)) over (order by Year(orderDate))) * 100), ' %') as 'YOY Growth %'
from factsales
group by Year(orderDate);

-- Q7. Calculate the rolling average profits as per every Quarter 

select Year(orderdate) as 'Year' , Quarter(orderdate) as 'Quarter',
truncate(avg(SUM(salesamount) - sum(totalproductcost + taxamt + freight)) over (rows between 3 preceding and current row),2) AS 'Rolling Avg Profit'
from factsales
group by Year(orderdate) , Quarter(orderdate)
order by Year(orderdate) asc , Quarter(orderdate) asc;

-- Q8. Calculate the average number of days required to ship the products

Select avg(datediff(shipdate, orderdate)) from factsales;
    
-- Q9. Calculate the revenue distribution of Bikes within each sub-category 

SELECT 
    s.EnglishProductSubcategoryName AS 'Bikes',
    TRUNCATE(SUM(fs.salesamount), 2) AS 'Revenue'
FROM
    factsales fs
        LEFT JOIN
    product p ON p.ProductKey = fs.ProductKey
        JOIN
    subcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
WHERE
    s.EnglishProductSubcategoryName LIKE '%Bikes'
GROUP BY s.EnglishProductSubcategoryName
ORDER BY 'Revenue' DESC;

-- Q10. Find out the total number of Road Bikes sold in France 

SELECT 
    s.EnglishProductSubcategoryName, 
    SUM(fs.OrderQuantity) AS TotalOrderQuantity
FROM 
    factsales fs
LEFT JOIN 
    SalesTerritory st ON fs.SalesTerritoryKey = st.SalesTerritoryKey
LEFT JOIN 
    product p ON p.ProductKey = fs.ProductKey
JOIN 
    subcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
WHERE 
    s.EnglishProductSubcategoryName = 'Road Bikes' AND st.SalesTerritoryCountry = 'France'
GROUP BY 
    s.EnglishProductSubcategoryName, st.SalesTerritoryCountry;