	
-- Business Question 1
-- Which customer segment has the highest number of customers?
	
SELECT  TOP 1 
Customer_Segment, COUNT(Customer_Segment) AS Customer_Segment_count
FROM dbo.FinTrust_Customers_Cleaned_Data
GROUP BY Customer_Segment
ORDER BY Customer_Segment_count DESC;
	

-- Result:
-- Everyday customers: 711

-- Business Interpretation:
-- The Everyday customer segment has the largest customer population,
-- with 711 customers. This indicates that Everyday customers make up
-- the largest segment within the customer dataset.


-- Business Question 2
-- How does customer tenure relate to transaction activity?


WITH Tenure_Groups AS ( SELECT fc.Tenure_Months, CASE
    WHEN Tenure_Months BETWEEN 0 AND 24 THEN '0-24 months'
    WHEN Tenure_Months BETWEEN 25 AND 48 THEN '25-48 months'
    WHEN Tenure_Months BETWEEN 49 AND 72 THEN '49-72 months'
    ELSE '73-96 months'
END AS Tenure_Group, ft.Transaction_ID

	FROM dbo.FinTrust_Transactions_Cleaned_Data as ft
	JOIN dbo.FinTrust_Customers_Cleaned_Data as fc
	On ft.Customer_ID = fc.Customer_ID )
	 

	SELECT Tenure_Group, Count(Transaction_ID) as Transaction_Count
	FROM Tenure_Groups
	GROUP BY Tenure_Group
	ORDER BY Transaction_count DESC;

 -- Result:
-- 73-96 months: 3,240 transactions
-- 49-72 months: 3,063 transactions
-- 0-24 months: 2,854 transactions
-- 25-48 months: 2,843 transactions

-- Business Interpretation:
-- The 73-96 month tenure group recorded the highest transaction activity,
-- with 3,240 transactions, while the 25-48 month group recorded the lowest
-- with 2,843 transactions. The differences in transaction volume between
-- the tenure groups were relatively moderate, so the results do not show  
-- a strong relationship between tenure and transaction activity.

-- Business Question 3
-- What is the overall transaction volume and distribution by transaction status?

SELECT 
    Transaction_Status,
    COUNT(Transaction_ID) AS Transaction_Count
FROM dbo.FinTrust_Transactions_Cleaned_Data
GROUP BY Transaction_Status;

-- Result:
-- Successful: 10,856 transactions
-- Failed: 630 transactions
-- Reversed: 326 transactions
-- Pending: 188 transactions

-- Business Interpretation:
-- Successful transactions accounted for the majority of transaction activity,
-- with 10,856 transactions. There were 630 failed transactions, 326 reversed
-- transactions, and 188 pending transactions. The failed transactions represent
-- an important area for further analysis to identify patterns associated with
-- transaction failure.

-- Business Question 4
-- -- Which transaction channel had the highest transaction volume?

SELECT TOP 1
    Channel,
    COUNT(Transaction_ID) AS Transaction_Count
FROM dbo.FinTrust_Transactions_Cleaned_Data
GROUP BY Channel
ORDER BY Transaction_Count DESC;

-- Result:
-- Mobile App: 5,102 transactions

-- Business Interpretation:
-- The Mobile App was the most frequently used transaction channel,
-- accounting for 5,102 transactions in the analysed dataset.

-- Business Question 5
-- How does transaction value differ across transaction statuses?

SELECT 
    Transaction_Status,
    SUM(Amount_NGN) AS Total_Amount
FROM dbo.FinTrust_Transactions_Cleaned_Data
GROUP BY Transaction_Status
ORDER BY Total_Amount DESC;

-- Result:
-- Successful: ₦510,807,441.97
-- Failed: ₦24,825,751.11
-- Reversed: ₦15,626,118.27
-- Pending: ₦9,218,044.00

-- Business Interpretation:
-- Successful transactions accounted for the largest total transaction value,
-- at approximately ₦510.81 million. Failed transactions represented
-- approximately ₦24.83 million in transaction value, followed by reversed
-- transactions at approximately ₦15.63 million and pending transactions
-- at approximately ₦9.22 million.

-- Business Question 6
-- Which customer segments have the highest average transaction value?

SELECT
    fc.Customer_Segment,
    AVG(ft.Amount_NGN) AS Average_Transaction_Value
FROM dbo.FinTrust_Transactions_Cleaned_Data AS ft
JOIN dbo.FinTrust_Customers_Cleaned_Data AS fc
    ON ft.Customer_ID = fc.Customer_ID
GROUP BY fc.Customer_Segment
ORDER BY Average_Transaction_Value DESC;

-- Result:
-- SME: ₦49,115.69 average transaction value
-- Student: ₦46,953.20 average transaction value
-- Everyday: ₦46,325.11 average transaction value
-- Premium: ₦45,637.95 average transaction value

-- Business Interpretation:
-- SME customers recorded the highest average transaction value at approximately
-- ₦49,115.69, while Premium customers recorded the lowest at approximately
-- ₦45,637.95. The difference between the highest and lowest segment averages
-- was relatively modest.


-- Business Question 7
-- Which transaction types have the highest transaction volumes and failure rates?

WITH transaction_activity AS 
(
    SELECT 
        Transaction_Type, 
        COUNT(Transaction_ID) AS Transaction_Count, 
        SUM(
            CASE 
                WHEN Transaction_Status = 'Failed' THEN 1 
                ELSE NULL 
            END
        ) AS Failed_Transaction 
    FROM dbo.FinTrust_Transactions_Cleaned_Data 
    GROUP BY Transaction_Type
)

SELECT 
    Transaction_Type, 
    Transaction_Count, 
    (Failed_Transaction * 1.0 / Transaction_Count * 100) AS Failure_Rates 
FROM transaction_activity
ORDER BY Failure_Rates DESC;


-- Result:
-- Bill Payment: 1,475 transactions, 5.83% failure rate
-- Airtime/Data: 1,185 transactions, 5.32% failure rate
-- Transfer: 3,549 transactions, 5.27% failure rate
-- Card Purchase: 3,033 transactions, 5.24% failure rate
-- Cash Withdrawal: 1,430 transactions, 5.10% failure rate
-- Deposit: 1,328 transactions, 4.67% failure rate

-- Business Interpretation:
-- Transfer transactions had the highest transaction volume, with 3,549 transactions.
-- However, Bill Payment had the highest failure rate at 5.83%.
-- This shows that the transaction type with the highest volume does not necessarily
-- have the highest failure rate. Failure rate provides a fairer comparison of
-- transaction reliability across transaction types with different transaction volumes.

-- Business Question 8
-- Which transaction channels have the highest failure rates?

WITH transaction_activity AS 
(
    SELECT 
        Channel, 
        COUNT(Transaction_ID) AS Transaction_Count, 
        SUM(
            CASE 
                WHEN Transaction_Status = 'Failed' THEN 1 
                ELSE NULL 
            END
        ) AS Failed_Transaction 
    FROM dbo.FinTrust_Transactions_Cleaned_Data 
    GROUP BY Channel
)

SELECT 
    Channel, 
    Transaction_Count, 
    (Failed_Transaction * 1.0 / Transaction_Count * 100) AS Failure_Rates 
FROM transaction_activity
ORDER BY Failure_Rates DESC;


-- Result:
-- Mobile App: 5,102 transactions, 5.80% failure rate
-- USSD: 889 transactions, 5.40% failure rate
-- POS: 2,393 transactions, 5.22% failure rate
-- Web: 1,869 transactions, 4.71% failure rate
-- ATM: 1,747 transactions, 4.18% failure rate

-- Business Interpretation:
-- Mobile App had the highest failure rate at 5.80%, while ATM had the
-- lowest failure rate at 4.18%. The results show that a channel's
-- transaction volume does not necessarily correspond to a higher failure rate.

-- Business Question 9
-- How do risk-reviewed transactions compare with non-risk-reviewed transactions in terms of failure rate?

WITH transaction_activity AS 
(
    SELECT 
        Risk_Review_Flag, 
        COUNT(Transaction_ID) AS Transaction_Count, 
        SUM(
            CASE 
                WHEN Transaction_Status = 'Failed' THEN 1 
                ELSE NULL 
            END
        ) AS Failed_Transaction 
    FROM dbo.FinTrust_Transactions_Cleaned_Data 
    GROUP BY Risk_Review_Flag
)

SELECT 
    Risk_Review_Flag, 
    Transaction_Count, 
    (Failed_Transaction * 1.0 / Transaction_Count * 100) AS Failure_Rates 
FROM transaction_activity
ORDER BY Failure_Rates DESC;


-- Result:
-- Risk-reviewed (1): 2,352 transactions, 7.23% failure rate
-- Non-risk-reviewed (0): 9,648 transactions, 4.77% failure rate

-- Business Interpretation:
-- Risk-reviewed transactions had a higher failure rate of 7.23% compared
-- with 4.77% for non-risk-reviewed transactions. This represents a
-- 2.46 percentage-point difference and is worth investigating to understand
-- whether risk-review processes, transaction characteristics, or other factors
-- are associated with the higher failure rate.


-- Business Question 10
-- Does the relationship between device type and transaction failure change
-- depending on whether a transaction was flagged for risk review?

WITH transaction_activity AS 
(
    SELECT 
        Risk_Review_Flag,
        Device_Type,
        COUNT(Transaction_ID) AS Transaction_Count, 
        SUM(
            CASE 
                WHEN Transaction_Status = 'Failed' THEN 1 
                ELSE NULL 
            END
        ) AS Failed_Transaction 
    FROM dbo.FinTrust_Transactions_Cleaned_Data 
    GROUP BY Risk_Review_Flag, Device_Type
)

SELECT 
    Risk_Review_Flag,
    Device_Type,
    Transaction_Count,
    (Failed_Transaction * 1.0 / Transaction_Count * 100) AS Failure_Rates 
FROM transaction_activity
ORDER BY Failure_Rates DESC;


-- Result:
-- Risk-reviewed:
-- Unknown: 16 transactions, 12.50% failure rate
-- iOS: 540 transactions, 9.26% failure rate
-- ATM Terminal: 253 transactions, 7.51% failure rate
-- Android: 957 transactions, 7.11% failure rate
-- POS Terminal: 295 transactions, 6.78% failure rate
-- Web Browser: 291 transactions, 3.78% failure rate
--
-- Non-risk-reviewed:
-- Unknown: 80 transactions, 5.00% failure rate
-- iOS: 2,380 transactions, 4.96% failure rate
-- Android: 3,840 transactions, 4.95% failure rate
-- Web Browser: 1,156 transactions, 4.58% failure rate
-- POS Terminal: 1,276 transactions, 4.47% failure rate
-- ATM Terminal: 916 transactions, 4.15% failure rate

-- Business Interpretation:
-- The relationship between device type and transaction failure changed
-- depending on risk review status. Risk-reviewed transactions generally
-- had higher failure rates across device types, with iOS recording a
-- 9.26% failure rate compared with 4.96% for non-risk-reviewed iOS
-- transactions. Web Browser was an exception, with a lower failure rate
-- among risk-reviewed transactions (3.78%) than non-risk-reviewed
-- transactions (4.58%). The Unknown device category had a small number
-- of risk-reviewed transactions, so its 12.50% failure rate should be
-- interpreted with caution.


-- Advanced SQL Analysis 1 — Customer Transaction Behaviour by Segment

-- Business Question:
-- How does transaction behaviour differ across FinTrust customer segments?

SELECT
    c.Customer_Segment,
    COUNT(DISTINCT c.Customer_ID) AS Customer_Count,
    COUNT(t.Transaction_ID) AS Transaction_Count,
    SUM(t.Amount_NGN) AS Total_Transaction_Value,
    AVG(t.Amount_NGN) AS Average_Transaction_Value
FROM dbo.FinTrust_Customers_Cleaned_Data AS c
INNER JOIN dbo.[FinTrust_Transactions_Cleaned_Data (1)] AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Total_Transaction_Value DESC;

-- Result
-- Customer_Segment	Customer_Count	Transaction_Count	Total_Transaction_Value	Average_Transaction_Value
-- Everyday	        711	            5644	            261458921.339798	    46325.1100885539
-- Premium	        295	            2361	            107751195.879646	    45637.9482760044
-- Student	        278	            2289	            107475866.449699	    46953.1963519875
-- SME	            216	            1706	            83791371.6735306	    49115.6926574036

-- Key Finding:
-- The Everyday segment generated the highest transaction activity, with 5,644 transactions worth approximately ₦261.46 million. 
-- However, the SME segment recorded the highest average transaction value at approximately ₦49,115.69 per transaction.

-- Business Meaning:
-- Everyday customers contribute strongly to overall transaction volume and value, while SME customers demonstrate higher average transaction values. 
-- This suggests that customer segments may require different approaches when analysing transaction activity and value.

 -- Analysis 2 — Transaction Value by Channel

-- Business Question:
-- How does transaction activity and value differ across transaction channels?
SELECT
    Channel,
    COUNT(Transaction_ID) AS Transaction_Count,
    SUM(Amount_NGN) AS Total_Transaction_Value,
    AVG(Amount_NGN) AS Average_Transaction_Value,
    MIN(Amount_NGN) AS Minimum_Transaction_Value,
    MAX(Amount_NGN) AS Maximum_Transaction_Value
FROM dbo.[FinTrust_Transactions_Cleaned_Data (1)]
GROUP BY Channel
ORDER BY Total_Transaction_Value DESC;

-- Channel	    Transaction_Count	Total_Transaction_Value	Average_Transaction_Value	Minimum_Transaction_Value	Maximum_Transaction_Value
-- Mobile App	5102	            240104365.325081	    47060.8320903726	        101.360000610352	        693006.625
-- POS	        2393	            104346681.356224	    43604.9650464789	        100.169998168945	        686958.4375
-- Web	        1869	            89325000.0282745	    47792.9374148071	        101.730003356934	        675336.5625
-- ATM	        1747	            83942354.4312973	    48049.4301266728	        101.559997558594	        640656.125
-- USSD	        889	                42758954.2017975	    48097.8112506158	        100.199996948242            693454.4375

-- Key Finding:
-- Mobile App was the most frequently used channel, with 5,102 transactions worth approximately ₦240.10 million.
-- USSD recorded the highest average transaction value at approximately ₦48,097.81, despite having the lowest transaction volume.


-- Business Meaning:
-- The Mobile App is an important channel in terms of transaction activity and total value, while USSD transactions tend to have a higher average value.
-- Channel performance should therefore be assessed using both transaction volume and transaction value rather than volume alone.


-- Analysis 3: Successful Versus Unsuccessful Transactions by Channel
-- Business Question

-- Which transaction channels have the highest levels of successful and unsuccessful transactions?

SELECT
    Channel,
    COUNT(*) AS Total_Transactions,

    SUM(CASE
        WHEN Transaction_Status = 'Successful'
        THEN 1 ELSE 0
    END) AS Successful_Transactions,

    SUM(CASE
        WHEN Transaction_Status IN ('Failed', 'Reversed', 'Pending')
        THEN 1 ELSE 0
    END) AS Unsuccessful_Transactions,

    ROUND(
        SUM(CASE
            WHEN Transaction_Status = 'Successful'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS Success_Rate

FROM dbo.[FinTrust_Transactions_Cleaned_Data (1)]
GROUP BY Channel
ORDER BY Success_Rate DESC;

-- Result
-- Channel	  Total_Transactions	Successful_Transactions	Unsuccessful_Transactions	Success_Rate
-- ATM	      1747	                1602	                145	                        91.700000000000
-- Web	      1869	                1698	                171	                        90.850000000000
-- POS	      2393	                2174	                219	                        90.850000000000
-- USSD	      889	                803	                    86	                        90.330000000000
-- Mobile App 5102	                4579	                523	                        89.750000000000

-- Key Finding:
-- ATM recorded the highest success rate at 91.70%, while Mobile App recorded the lowest at 89.75%. 
-- Mobile App also had the highest transaction volume, with 5,102 transactions and 523 unsuccessful transactions.

-- Business Meaning:
-- Transaction success rates are relatively similar across channels, but the higher transaction volume on Mobile App means that even a relatively small difference in success rate can represent a substantial number of unsuccessful transactions. 
-- Further investigation of unsuccessful Mobile App transactions may help identify potential service or process issues.


-- Analysis 4: Risk-Review Patterns by Customer Segment
-- Business Question

-- Which customer segments have the highest proportion of transactions flagged for risk review?

SELECT
    c.Customer_Segment,

    COUNT(t.Transaction_ID) AS Total_Transactions,

    SUM(CASE
        WHEN t.Risk_Review_Flag = 1
        THEN 1 ELSE 0
    END) AS Risk_Reviewed_Transactions,

    ROUND(
        SUM(CASE
            WHEN t.Risk_Review_Flag = 1
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(t.Transaction_ID),
        2
    ) AS Risk_Review_Rate,

    SUM(CASE
        WHEN t.Risk_Review_Flag = 1
        THEN t.Amount_NGN ELSE 0
    END) AS Risk_Reviewed_Value

FROM dbo.FinTrust_Customers_Cleaned_Data  c
INNER JOIN dbo.[FinTrust_Transactions_Cleaned_Data (1)] t
    ON c.Customer_ID = t.Customer_ID

GROUP BY c.Customer_Segment
ORDER BY Risk_Review_Rate DESC;

-- Result
-- Customer_Segment	Total_Transactions	Risk_Reviewed_Transactions	Risk_Review_Rate	Risk_Reviewed_Value
-- Premium	        2361	            480	                        20.330000000000	    30440912.1663208
-- Student	        2289	            452	                        19.750000000000	    29740823.2405014
-- SME	            1706	            331	                        19.400000000000	    23506669.9545288
-- Everyday	        5644	            1089	                    19.290000000000	    78095226.3372116

-- Key Finding:
-- Premium customers recorded the highest risk-review rate at 20.33%, followed by Student at 19.75%, SME at 19.40%, and Everyday at 19.29%. 
-- Everyday customers had the highest number of risk-reviewed transactions (1,089) and the highest risk-reviewed transaction value of approximately ₦78.10 million.

-- Business Meaning:
-- Risk-review rates are relatively consistent across customer segments. 
-- Premium customers have the highest proportion of transactions reviewed, while the Everyday segment represents the largest absolute risk-reviewed volume and value. 
-- Both the rate and the underlying transaction volume should therefore be considered when monitoring risk activity.


-- Advanced SQL Analysis 5 — International vs Domestic Transactions

-- Business Question:
-- How do international and domestic transactions differ in transaction value and risk-review activity?

SELECT
    International_Transaction,
    COUNT(*) AS Transaction_Count,
    SUM(Amount_NGN) AS Total_Transaction_Value,
    AVG(Amount_NGN) AS Average_Transaction_Value,
    SUM(CASE
        WHEN Risk_Review_Flag = 1 THEN 1
        ELSE 0
    END) AS Risk_Reviewed_Transactions,
    ROUND(
        SUM(CASE
            WHEN Risk_Review_Flag = 1 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS Risk_Review_Rate
FROM dbo.[FinTrust_Transactions_Cleaned_Data (1)]
GROUP BY International_Transaction
ORDER BY International_Transaction;

-- Result
-- International_Transaction	Transaction_Count	Total_Transaction_Value	Average_Transaction_Value	Risk_Reviewed_Transactions	Risk_Review_Rate
-- 0	                        11520	            540481571.429741	    46916.8030754983	        2175	                    18.880000000000
-- 1	                        480	                19995783.9129333	    41657.8831519445	        177	                        36.880000000000

-- Key Finding:
-- There were 480 international transactions with a total value of approximately ₦20.00 million. 
-- International transactions had a risk-review rate of 36.88%, compared with 18.88% for domestic transactions. 
-- The average international transaction value was ₦41,657.88 compared with ₦46,916.80 for domestic transactions.

-- Business Meaning:
-- International transactions have a substantially higher risk-review rate than domestic transactions, despite representing a much smaller share of transaction volume.
-- This makes international transaction activity an important area for further risk analysis.

-- Analysis 6: Risk-Review Patterns by Customer Segment
-- Business Question
-- Which customers make the most transactions, and how much transaction value do they generate?

SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(t.Transaction_ID) AS Transaction_Count,
    SUM(t.Amount_NGN) AS Total_Transaction_Value,
    AVG(t.Amount_NGN) AS Average_Transaction_Value
FROM dbo.FinTrust_Customers_Cleaned_Data AS c
INNER JOIN dbo.[FinTrust_Transactions_Cleaned_Data (1)] AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment
ORDER BY Transaction_Count



Rank        Customer        Segment     Transactions     Total Value        Average Value                                                        
FT-C01296	Fatima Adeyemi	Everyday	20	             783519.638961792	39175.9819480896
FT-C00965	Tunde Garba	    Student	    19	             376271.522338867	19803.7643336246
FT-C00351	Ada Garba	    SME	        18	             649777.492156982	36098.7495642768
FT-C00209	Emeka Williams	SME	        18	             1063845.37866211	59102.5210367839
FT-C01487	Fatima Nwosu	Everyday	18	             513210.819000244	28511.7121666802
FT-C00357	Ada Garba	    Everyday	18	             1713516.30639648	95195.3503553602
FT-C00959	Zainab Bello	Everyday	17	             909929.573242188	53525.2690142463
FT-C00816	Yusuf Ibrahim	Everyday	17	             1611209.23840332	94777.0140237247
FT-C01037	Yusuf Okafor	SME	        17	             879343.445678711	51726.0850399242
FT-C01423	Zainab Ojo	    Everyday	17	             633040.780761719	37237.6929859835

-- Key Finding:
-- The highest-frequency customer in the analysis recorded 20 transactions. 
-- The Top 10 customers recorded between 17 and 20 transactions. 
-- Transaction frequency varied independently from total transaction value, with some customers generating substantially higher values despite having similar transaction counts.

-- Business Meaning:
-- Customer activity should be assessed using multiple measures rather than transaction frequency alone. 
-- Customers with similar transaction frequencies can generate significantly different transaction values, making both measures useful for customer-level analysis.