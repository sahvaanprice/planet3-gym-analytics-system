/*
03_stored_procedure.sql
Purpose: Business logic automation for Planet 3 Gym Analytics System.
Includes stored procedures supporting payment tracking and reporting.
*/

CREATE PROCEDURE DaysUntilNextPayment
AS BEGIN
SELECT
PAYMENT_ID, SUB_ID, Invoice, Due_Date, DATEADD(DAY, 30, Due_Date) AS Next_Due_Date, DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 30, Due_Date)) AS Days_Left 
FROM Payment 
WHERE DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 30, Due_Date)) >= 0; END;
