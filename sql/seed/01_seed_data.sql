SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tally') IS NOT NULL DROP TABLE #tally;
------------------------------------------------------------
-- PARAMETERS
------------------------------------------------------------
DECLARE @Seed int = 20260223;

DECLARE @EmployeeCount int = 18;
DECLARE @TrainerCount  int = 10;
DECLARE @MemberCount   int = 320;

DECLARE @ClassCount    int = 60;   -- group classes
DECLARE @RegTarget     int = 1400; -- registrations
DECLARE @AptTarget     int = 900;  -- training appointments
DECLARE @PaymentCount  int = 2200; -- payments

-- How far back to generate dates (days)
DECLARE @LookbackDays int = 540;

------------------------------------------------------------
-- SAFETY: Delete data in FK-safe order
------------------------------------------------------------
DELETE FROM dbo.Appointment;
DELETE FROM dbo.Registration;
DELETE FROM dbo.Payment;
DELETE FROM dbo.VIP_Sub;
DELETE FROM dbo.Normal_Sub;
DELETE FROM dbo.Subscription;
DELETE FROM dbo.Member;
DELETE FROM dbo.Equipment;
DELETE FROM dbo.Class;
DELETE FROM dbo.Trainer;
DELETE FROM dbo.Employee;

------------------------------------------------------------
-- Helper tally (fast row generator)
------------------------------------------------------------
;WITH tally AS (
  SELECT TOP (100000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
)
SELECT 1 AS ok INTO #tally FROM tally WHERE 1 = 0; -- creates nothing, just validates tally exists

------------------------------------------------------------
-- 1) EMPLOYEE (with simple supervisor chain)
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@EmployeeCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':EMP:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':EMP2:', rn))) AS r2
  FROM n
)
INSERT INTO dbo.Employee (EMP_ID, EMP_FName, EMP_LName, EMP_Phone, SUPERVISOR_ID)
SELECT
  rn AS EMP_ID,
  CASE (r1 % 10)
    WHEN 0 THEN 'Avery' WHEN 1 THEN 'Jordan' WHEN 2 THEN 'Taylor' WHEN 3 THEN 'Casey' WHEN 4 THEN 'Riley'
    WHEN 5 THEN 'Morgan' WHEN 6 THEN 'Drew' WHEN 7 THEN 'Cameron' WHEN 8 THEN 'Parker' ELSE 'Quinn'
  END AS EMP_FName,
  CASE (r2 % 10)
    WHEN 0 THEN 'Johnson' WHEN 1 THEN 'Williams' WHEN 2 THEN 'Brown' WHEN 3 THEN 'Jones' WHEN 4 THEN 'Garcia'
    WHEN 5 THEN 'Miller' WHEN 6 THEN 'Davis' WHEN 7 THEN 'Rodriguez' WHEN 8 THEN 'Martinez' ELSE 'Anderson'
  END AS EMP_LName,
  CONCAT('419-', RIGHT(CONCAT('000', (r1 % 1000)), 3), '-', RIGHT(CONCAT('0000', (r2 % 10000)), 4)) AS EMP_Phone,
  CASE
    WHEN rn = 1 THEN NULL
    WHEN rn <= 4 THEN 1
    ELSE 1 + (r1 % 3)
  END AS SUPERVISOR_ID
FROM r;

------------------------------------------------------------
-- 2) TRAINER
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@TrainerCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':TRN:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':TRN2:', rn))) AS r2
  FROM n
)
INSERT INTO dbo.Trainer (TRAINER_ID, Trainer_FName, Trainer_LName, T_Phone)
SELECT
  rn AS TRAINER_ID,
  CASE (r1 % 10)
    WHEN 0 THEN 'Sam' WHEN 1 THEN 'Devin' WHEN 2 THEN 'Kai' WHEN 3 THEN 'Skyler' WHEN 4 THEN 'Rowan'
    WHEN 5 THEN 'Blake' WHEN 6 THEN 'Jamie' WHEN 7 THEN 'Reese' WHEN 8 THEN 'Logan' ELSE 'Harper'
  END,
  CASE (r2 % 10)
    WHEN 0 THEN 'Clark' WHEN 1 THEN 'Lewis' WHEN 2 THEN 'Walker' WHEN 3 THEN 'Young' WHEN 4 THEN 'Allen'
    WHEN 5 THEN 'King' WHEN 6 THEN 'Wright' WHEN 7 THEN 'Scott' WHEN 8 THEN 'Green' ELSE 'Baker'
  END,
  CONCAT('567-', RIGHT(CONCAT('000', (r1 % 1000)), 3), '-', RIGHT(CONCAT('0000', (r2 % 10000)), 4))
FROM r;

------------------------------------------------------------
-- 3) MEMBER
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@MemberCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':MEM:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':MEM2:', rn))) AS r2,
    ABS(CHECKSUM(CONCAT(@Seed, ':MEM3:', rn))) AS r3
  FROM n
)
INSERT INTO dbo.Member (MEM_ID, Mem_FName, Mem_LName, Mem_City, Mem_Phone, SUB_ID, EMP_ID)
SELECT
  rn AS MEM_ID,
  CASE (r1 % 12)
    WHEN 0 THEN 'Alex' WHEN 1 THEN 'Mia' WHEN 2 THEN 'Noah' WHEN 3 THEN 'Olivia' WHEN 4 THEN 'Ethan' WHEN 5 THEN 'Ava'
    WHEN 6 THEN 'Liam' WHEN 7 THEN 'Sophia' WHEN 8 THEN 'Elijah' WHEN 9 THEN 'Isabella' WHEN 10 THEN 'Lucas' ELSE 'Amelia'
  END,
  CASE (r2 % 12)
    WHEN 0 THEN 'Hill' WHEN 1 THEN 'Adams' WHEN 2 THEN 'Carter' WHEN 3 THEN 'Mitchell' WHEN 4 THEN 'Perez' WHEN 5 THEN 'Roberts'
    WHEN 6 THEN 'Turner' WHEN 7 THEN 'Phillips' WHEN 8 THEN 'Campbell' WHEN 9 THEN 'Parker' WHEN 10 THEN 'Evans' ELSE 'Edwards'
  END,
  CASE (r3 % 6)
    WHEN 0 THEN 'Toledo'
    WHEN 1 THEN 'Cleveland'
    WHEN 2 THEN 'Columbus'
    WHEN 3 THEN 'Detroit'
    WHEN 4 THEN 'Chicago'
    ELSE 'Pittsburgh'
  END,
  CONCAT('419-', RIGHT(CONCAT('000', (r1 % 1000)), 3), '-', RIGHT(CONCAT('0000', (r2 % 10000)), 4)),
  NULL AS SUB_ID,
  1 + (r1 % @EmployeeCount) AS EMP_ID
FROM r;

------------------------------------------------------------
-- 4) SUBSCRIPTION (one per member)
-- VIP is determined by inserting into VIP_Sub vs Normal_Sub
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@MemberCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUB:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUB2:', rn))) AS r2
  FROM n
),
typed AS (
  SELECT
    rn,
    CASE WHEN (r1 % 100) < 28 THEN 1 ELSE 0 END AS is_vip, -- ~28% VIP
    CASE WHEN (r2 % 100) < 82 THEN 'Active' ELSE 'Inactive' END AS status,
    CASE
      WHEN (r2 % 100) < 82 THEN NULL
      WHEN (r2 % 3) = 0 THEN 'Moved'
      WHEN (r2 % 3) = 1 THEN 'Cost'
      ELSE 'No Time'
    END AS reason
  FROM r
)
INSERT INTO dbo.Subscription (SUB_ID, Sub_Status, SUB_Reason, MEM_ID)
SELECT
  rn AS SUB_ID,
  status,
  ISNULL(reason, 'N/A'),
  rn AS MEM_ID
FROM typed;

-- Put SUB_ID back onto Member (not enforced by FK, but helpful for joins)
UPDATE m
SET m.SUB_ID = s.SUB_ID
FROM dbo.Member m
JOIN dbo.Subscription s ON s.MEM_ID = m.MEM_ID;

-- VIP_Sub + Normal_Sub details
;WITH r AS (
  SELECT
    s.SUB_ID,
    s.MEM_ID,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUBD:', s.SUB_ID))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUBD2:', s.SUB_ID))) AS r2
  FROM dbo.Subscription s
),
typed AS (
  SELECT
    SUB_ID,
    CASE WHEN (r1 % 100) < 28 THEN 1 ELSE 0 END AS is_vip,
    DATEADD(DAY, -1 * (@LookbackDays - (r2 % @LookbackDays)), CAST(GETDATE() AS date)) AS start_date
  FROM r
)

INSERT INTO dbo.VIP_Sub (VIP_ID, VIP_Sub_Date, SUB_ID)
SELECT
  SUB_ID,
  start_date,
  SUB_ID
FROM typed
WHERE is_vip = 1;


;WITH r AS (
  SELECT
    s.SUB_ID,
    s.MEM_ID,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUBD:', s.SUB_ID))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':SUBD2:', s.SUB_ID))) AS r2
  FROM dbo.Subscription s
),
typed AS (
  SELECT
    SUB_ID,
    CASE WHEN (r1 % 100) < 28 THEN 1 ELSE 0 END AS is_vip,
    DATEADD(DAY, -1 * (@LookbackDays - (r2 % @LookbackDays)), CAST(GETDATE() AS date)) AS start_date
  FROM r
)

INSERT INTO dbo.Normal_Sub (NORM_ID, Sub_Date, SUB_ID)
SELECT
  SUB_ID,
  start_date,
  SUB_ID
FROM typed
WHERE is_vip = 0;

------------------------------------------------------------
-- 5) CLASS (group classes)
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@ClassCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':CLS:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':CLS2:', rn))) AS r2
  FROM n
)
INSERT INTO dbo.Class
(
  CLASS_ID, REG_ID, TRAINER_ID,
  Class_Names, Class_Date, Class_Time, Class_Capacity
)
SELECT
  rn AS CLASS_ID,
  NULL AS REG_ID,
  1 + (r1 % @TrainerCount) AS TRAINER_ID,
  CASE (r2 % 8)
    WHEN 0 THEN 'Strength 101'
    WHEN 1 THEN 'HIIT Burn'
    WHEN 2 THEN 'Yoga Flow'
    WHEN 3 THEN 'Spin Sprint'
    WHEN 4 THEN 'Core & Cardio'
    WHEN 5 THEN 'Bootcamp'
    WHEN 6 THEN 'Glutes & Legs'
    ELSE 'Mobility'
  END,
  DATEADD(DAY, -1 * (r1 % @LookbackDays), CAST(GETDATE() AS date)) AS Class_Date,
  -- times: 6am, 9am, 12pm, 5pm, 7pm
  CASE (r2 % 5)
    WHEN 0 THEN CAST('06:00:00' AS time)
    WHEN 1 THEN CAST('09:00:00' AS time)
    WHEN 2 THEN CAST('12:00:00' AS time)
    WHEN 3 THEN CAST('17:00:00' AS time)
    ELSE CAST('19:00:00' AS time)
  END AS Class_Time,
  10 + (r1 % 21) AS Class_Capacity
FROM r;

------------------------------------------------------------
-- 6) REGISTRATION (VIP registers more)
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@RegTarget)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':REG:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':REG2:', rn))) AS r2,
    ABS(CHECKSUM(CONCAT(@Seed, ':REG3:', rn))) AS r3
  FROM n
),
pick AS (
  SELECT
    rn,
    1 + (r1 % @ClassCount)  AS CLASS_ID,
    1 + (r2 % @MemberCount) AS MEM_ID,
    (r3 % 100) AS roll
  FROM r
),
vipflag AS (
  SELECT
    p.*,
    CASE WHEN v.SUB_ID IS NOT NULL THEN 1 ELSE 0 END AS is_vip
  FROM pick p
  LEFT JOIN dbo.Subscription s ON s.MEM_ID = p.MEM_ID
  LEFT JOIN dbo.VIP_Sub v ON v.SUB_ID = s.SUB_ID
),
filtered AS (
  SELECT *
  FROM vipflag
  WHERE
    -- VIP: ~75% keep; Normal: ~40% keep
    (is_vip = 1 AND roll < 75)
    OR
    (is_vip = 0 AND roll < 40)
)
INSERT INTO dbo.Registration (REG_ID, Registered_Amt, MEM_ID, CLASS_ID)
SELECT
  rn AS REG_ID,
  1 AS Registered_Amt,
  MEM_ID,
  CLASS_ID
FROM (
  SELECT DISTINCT TOP (@RegTarget) rn, MEM_ID, CLASS_ID
  FROM filtered
  ORDER BY rn
) d;

------------------------------------------------------------
-- 7) APPOINTMENT (VIP books more)
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@AptTarget)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':APT:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':APT2:', rn))) AS r2,
    ABS(CHECKSUM(CONCAT(@Seed, ':APT3:', rn))) AS r3
  FROM n
),
pick AS (
  SELECT
    rn,
    1 + (r1 % @MemberCount)  AS MEM_ID,
    1 + (r2 % @TrainerCount) AS TRAINER_ID,
    DATEADD(DAY, -1 * (r3 % @LookbackDays), CAST(GETDATE() AS date)) AS APT_Date,
    CASE (r2 % 6)
      WHEN 0 THEN CAST('07:00:00' AS time)
      WHEN 1 THEN CAST('09:00:00' AS time)
      WHEN 2 THEN CAST('11:00:00' AS time)
      WHEN 3 THEN CAST('14:00:00' AS time)
      WHEN 4 THEN CAST('16:00:00' AS time)
      ELSE CAST('18:00:00' AS time)
    END AS APT_Time
  FROM r
),
vipflag AS (
  SELECT
    p.*,
    CASE WHEN v.SUB_ID IS NOT NULL THEN 1 ELSE 0 END AS is_vip,
    (ABS(CHECKSUM(CONCAT(@Seed, ':KEEPAPT:', p.rn))) % 100) AS keep_roll
  FROM pick p
  LEFT JOIN dbo.Subscription s ON s.MEM_ID = p.MEM_ID
  LEFT JOIN dbo.VIP_Sub v ON v.SUB_ID = s.SUB_ID
)
INSERT INTO dbo.Appointment (APT_ID, APT_Date, APT_Time, MEM_ID, TRAINER_ID)
SELECT
  rn AS APT_ID, APT_Date, APT_Time, MEM_ID, TRAINER_ID
FROM vipflag
WHERE
  -- VIP: ~70% keep, Normal: ~25% keep
  (is_vip = 1 AND keep_roll < 70)
  OR
  (is_vip = 0 AND keep_roll < 25);

------------------------------------------------------------
-- 8) PAYMENT (VIP pays more, higher amount)
------------------------------------------------------------
;WITH n AS (
  SELECT TOP (@PaymentCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':PAY:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':PAY2:', rn))) AS r2,
    ABS(CHECKSUM(CONCAT(@Seed, ':PAY3:', rn))) AS r3
  FROM n
),
pick AS (
  SELECT
    rn,
    1 + (r1 % @MemberCount) AS MEM_ID,
    DATEADD(DAY, -1 * (r2 % @LookbackDays), CAST(GETDATE() AS date)) AS due_date,
    (r3 % 100) AS roll
  FROM r
),
vipflag AS (
  SELECT
    p.*,
    s.SUB_ID,
    CASE WHEN v.SUB_ID IS NOT NULL THEN 1 ELSE 0 END AS is_vip
  FROM pick p
  JOIN dbo.Subscription s ON s.MEM_ID = p.MEM_ID
  LEFT JOIN dbo.VIP_Sub v ON v.SUB_ID = s.SUB_ID
)
INSERT INTO dbo.Payment (PAYMENT_ID, Invoice, Due_Date, Paid_Date, Paid_Amount, SUB_ID)
SELECT
  rn AS PAYMENT_ID,
  CONCAT('INV-', RIGHT(CONCAT('000000', rn), 6)) AS Invoice,
  due_date AS Due_Date,
  -- paid_date: VIP tends to pay on/before due date more often
  CASE
    WHEN is_vip = 1 AND roll < 88 THEN DATEADD(DAY, -1 * (roll % 5), due_date)
    WHEN is_vip = 1 AND roll < 96 THEN DATEADD(DAY,  1 * (roll % 7), due_date)
    WHEN is_vip = 0 AND roll < 70 THEN DATEADD(DAY,  1 * (roll % 10), due_date)
    WHEN is_vip = 0 AND roll < 82 THEN DATEADD(DAY, -1 * (roll % 3), due_date)
    ELSE NULL
  END AS Paid_Date,
  CAST(
    CASE
      WHEN is_vip = 1 THEN 75.00 + ((roll % 26) * 2.50)  -- roughly $75–$137.50
      ELSE 25.00 + ((roll % 21) * 1.50)                -- roughly $25–$56.50
    END
    AS decimal(6,2)
  ) AS Paid_Amount,
  SUB_ID
FROM vipflag;

------------------------------------------------------------
-- 9) EQUIPMENT
------------------------------------------------------------
DECLARE @EquipCount int = 55;

;WITH n AS (
  SELECT TOP (@EquipCount)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a
  CROSS JOIN sys.all_objects b
),
r AS (
  SELECT
    rn,
    ABS(CHECKSUM(CONCAT(@Seed, ':EQ:', rn))) AS r1,
    ABS(CHECKSUM(CONCAT(@Seed, ':EQ2:', rn))) AS r2
  FROM n
)
INSERT INTO dbo.Equipment (Equip_ID, Equip_Status, Last_Check_Date, EMP_ID)
SELECT
  rn AS Equip_ID,
  CASE (r1 % 5)
    WHEN 0 THEN 'Operational'
    WHEN 1 THEN 'Operational'
    WHEN 2 THEN 'Operational'
    WHEN 3 THEN 'Needs Repair'
    ELSE 'Out of Service'
  END AS Equip_Status,
  DATEADD(DAY, -1 * (r2 % 120), CAST(GETDATE() AS date)) AS Last_Check_Date,
  1 + (r1 % @EmployeeCount) AS EMP_ID
FROM r;

------------------------------------------------------------
-- VALIDATION QUICK CHECKS
------------------------------------------------------------
SELECT 'Employee'      AS table_name, COUNT(*) AS row_count FROM dbo.Employee
UNION ALL SELECT 'Trainer', COUNT(*) FROM dbo.Trainer
UNION ALL SELECT 'Member', COUNT(*) FROM dbo.Member
UNION ALL SELECT 'Subscription', COUNT(*) FROM dbo.Subscription
UNION ALL SELECT 'VIP_Sub', COUNT(*) FROM dbo.VIP_Sub
UNION ALL SELECT 'Normal_Sub', COUNT(*) FROM dbo.Normal_Sub
UNION ALL SELECT 'Class', COUNT(*) FROM dbo.Class
UNION ALL SELECT 'Registration', COUNT(*) FROM dbo.Registration
UNION ALL SELECT 'Appointment', COUNT(*) FROM dbo.Appointment
UNION ALL SELECT 'Payment', COUNT(*) FROM dbo.Payment
UNION ALL SELECT 'Equipment', COUNT(*) FROM dbo.Equipment;

-- FK integrity spot checks:
SELECT TOP 10 a.*
FROM dbo.Appointment a
LEFT JOIN dbo.Member m ON m.MEM_ID = a.MEM_ID
LEFT JOIN dbo.Trainer t ON t.TRAINER_ID = a.TRAINER_ID
WHERE m.MEM_ID IS NULL OR t.TRAINER_ID IS NULL;

SELECT TOP 10 r.*
FROM dbo.Registration r
LEFT JOIN dbo.Member m ON m.MEM_ID = r.MEM_ID
LEFT JOIN dbo.Class  c ON c.CLASS_ID = r.CLASS_ID
WHERE m.MEM_ID IS NULL OR c.CLASS_ID IS NULL;

SELECT TOP 10 p.*
FROM dbo.Payment p
LEFT JOIN dbo.Subscription s ON s.SUB_ID = p.SUB_ID
WHERE s.SUB_ID IS NULL;
