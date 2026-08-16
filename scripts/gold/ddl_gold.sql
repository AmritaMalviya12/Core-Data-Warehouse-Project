/*
DDL Script: Create Gold Views

    This script creates views for the Gold layer of the data warehouse.
    The Gold layer contains the final, business-ready data used for analysis
    and reporting. These views combine and transform data from the Silver layer
    into useful dimension and fact tables following a Star Schema design.
*/

-- DELETE FROM silver.crm_cust_info
-- WHERE cst_id IS NULL;

-- NOTE -> whenever we find that the joined table object is considered as a dimension then we have to make a surrogate key to act as of it's primary key . 

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date	
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
	ON	ci.cst_key = la.cid


	-- quality check after making the views
	SELECT DISTINCT gender FROM gold.dim_customers




    IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
    GO

	CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- here null is used because we want the most recent date for the product details leaving all the historical data behind . 

SELECT * FROM gold.dim_products







IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

-- NOTE -> sales view table is a fact and thus it needs to get itself connected with all the dimensions that we have declared above , thus we need to put in and mention all the surrogate keys in this sales views this is really very very important

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;


-- quality check for foreign key integrity dimensions . 
-- sales facts view and customers view tables
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
   ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

-- sales facts view and products view tables
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
   ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
   ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
