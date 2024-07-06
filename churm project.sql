select * from customer_churn;
drop table customer_churn;
CREATE TABLE customer_churn (
    customerID VARCHAR(50),
    gender VARCHAR(10),
    SeniorCitizen varchar,
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    tenure INT,
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(20),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    OnlineBackup VARCHAR(20),
    DeviceProtection VARCHAR(20),
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    StreamingMovies VARCHAR(20),
    Contract VARCHAR(20),
    PaperlessBilling VARCHAR(10),
    PaymentMethod VARCHAR(50),
    MonthlyCharges varchar,
    TotalCharges varchar,
    Churn VARCHAR(10)
);
UPDATE customer_churn
SET MonthlyCharges_numeric = CASE WHEN monthlycharges ~ '^[0-9]+(\.[0-9]+)?$' THEN monthlycharges::NUMERIC ELSE NULL END,
    TotalCharges_numeric = CASE WHEN totalcharges ~ '^[0-9]+(\.[0-9]+)?$' THEN totalcharges::NUMERIC ELSE NULL END,
    SeniorCitizen_numeric = CASE WHEN seniorcitizen ~ '^[0-9]+$' THEN seniorcitizen::INTEGER ELSE NULL END;
ALTER TABLE customer_churn
ADD COLUMN monthlycharges_numeric NUMERIC,
ADD COLUMN totalcharges_numeric NUMERIC,
ADD COLUMN seniorcitizen_numeric INTEGER;
UPDATE customer_churn
SET monthlycharges_numeric = CASE 
                                WHEN trim(monthlycharges) ~ '^[0-9]+(\.[0-9]+)?$' THEN trim(monthlycharges)::NUMERIC 
                                ELSE NULL 
                             END,
    totalcharges_numeric = CASE 
                                WHEN trim(totalcharges) ~ '^[0-9]+(\.[0-9]+)?$' THEN trim(totalcharges)::NUMERIC 
                                ELSE NULL 
                            END,
    seniorcitizen_numeric = CASE 
                                WHEN trim(seniorcitizen) ~ '^[0-9]+$' THEN trim(seniorcitizen)::INTEGER 
                                ELSE NULL 
                            END;

select *from customer_churn;
ALTER TABLE customer_churn
DROP COLUMN monthlycharges,
DROP COLUMN totalcharges,
DROP COLUMN seniorcitizen;

ALTER TABLE customer_churn
RENAME COLUMN monthlycharges_numeric TO monthlycharges;
ALTER TABLE customer_churn
RENAME COLUMN totalcharges_numeric TO totalcharges;
ALTER TABLE customer_churn
RENAME COLUMN seniorcitizen_numeric TO seniorcitizen;

DELETE FROM customer_churn
WHERE customerID IN (
    SELECT customerID
    FROM (
        SELECT customerID, COUNT(*) AS count
        FROM customer_churn
        GROUP BY customerID
        HAVING COUNT(*) > 1
    ) AS duplicates
);

SELECT * FROM customer_churn order by customerid;
WHERE TotalCharges IS NULL;

-- Example: Remove rows with missing TotalCharges
DELETE FROM customer_churn WHERE TotalCharges IS NULL;

UPDATE customer_churn
SET gender = CASE WHEN gender = 'Male' THEN 'Male' ELSE 'Female' END,
    Partner = CASE WHEN Partner = 'Yes' THEN 'Yes' ELSE 'No' END,
    Dependents = CASE WHEN Dependents = 'Yes' THEN 'Yes' ELSE 'No' END,
    Churn = CASE WHEN Churn = 'Yes' THEN 'Yes' ELSE 'No' END;

SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM customer_churn;

SELECT gender, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM customer_churn
GROUP BY gender;

SELECT SeniorCitizen, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM customer_churn
GROUP BY SeniorCitizen;

SELECT tenure, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM customer_churn
GROUP BY tenure;

SELECT InternetService, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM customer_churn
GROUP BY InternetService;

ALTER TABLE customer_churn
ADD COLUMN AvgMonthlyCharges FLOAT;

UPDATE customer_churn
SET AvgMonthlyCharges = TotalCharges / NULLIF(tenure, 0);
select * from customer_churn order by customerid;