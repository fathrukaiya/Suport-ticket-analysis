-- ==========================================================
-- Project: Support Ticket Analysis Dashboard
-- Author: Rukaiya Faiz
-- Tools: SQL Server, Excel, Power BI
-- Purpose:
-- Analyze ticket backlog, SLA risks, module performance,
-- priority trends, and resolution efficiency
-- ==========================================================

-- =========================================
-- Support Ticket Analysis Project
-- SQL Server / SSMS
-- =========================================

-- =========================================
-- 0. View imported data
-- =========================================
SELECT TOP 20 *
FROM dbo.support_tickets;


-- =========================================
-- 1. Total number of tickets
-- =========================================
SELECT COUNT(*) AS total_tickets
FROM dbo.support_tickets;


-- =========================================
-- 2. Tickets by priority
-- =========================================
SELECT Priority, COUNT(*) AS total
FROM dbo.support_tickets
GROUP BY Priority
ORDER BY total DESC;


-- =========================================
-- 3. Tickets by module
-- =========================================
SELECT Module, COUNT(*) AS total
FROM dbo.support_tickets
GROUP BY Module
ORDER BY total DESC;


-- =========================================
-- 4. Tickets by status
-- =========================================
SELECT Status, COUNT(*) AS total
FROM dbo.support_tickets
GROUP BY Status
ORDER BY total DESC;


-- =========================================
-- 5. Average resolution days
-- =========================================
SELECT AVG(Resolution_Days) AS avg_days
FROM dbo.support_tickets;


-- =========================================
-- 6. High priority tickets only
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Priority = 'High';


-- =========================================
-- 7. Open tickets only
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Status = 'Open';


-- =========================================
-- 8. Average resolution days by module
-- =========================================
SELECT Module, AVG(Resolution_Days) AS avg_resolution_days
FROM dbo.support_tickets
GROUP BY Module
ORDER BY avg_resolution_days DESC;


-- =========================================
-- 9. Top delayed tickets
-- =========================================
SELECT TOP 5 *
FROM dbo.support_tickets
ORDER BY Resolution_Days DESC;


-- =========================================
-- 10. CASE WHEN - Resolution speed category
-- =========================================
SELECT Ticket_ID,
       Module,
       Priority,
       Resolution_Days,
       CASE
           WHEN Resolution_Days >= 7 THEN 'Critical Delay'
           WHEN Resolution_Days >= 3 THEN 'Moderate Delay'
           ELSE 'Fast Resolution'
       END AS resolution_category
FROM dbo.support_tickets;


-- =========================================
-- 11. CASE WHEN - Priority business grouping
-- =========================================
SELECT Ticket_ID,
       Priority,
       CASE
           WHEN Priority = 'High' THEN 'Urgent'
           WHEN Priority = 'Medium' THEN 'Normal'
           ELSE 'Low Risk'
       END AS priority_group
FROM dbo.support_tickets;


-- =========================================
-- 12. CASE WHEN - SLA risk flag
-- =========================================
SELECT Ticket_ID,
       Module,
       Resolution_Days,
       CASE
           WHEN Resolution_Days > 5 THEN 'SLA Breach Risk'
           ELSE 'Within SLA'
       END AS sla_status
FROM dbo.support_tickets;


-- =========================================
-- 13. Subquery - Tickets slower than average
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Resolution_Days > (
    SELECT AVG(Resolution_Days)
    FROM dbo.support_tickets
);


-- =========================================
-- 14. Subquery - Highest delay tickets
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Resolution_Days = (
    SELECT MAX(Resolution_Days)
    FROM dbo.support_tickets
);


-- =========================================
-- 15. Subquery + HAVING - Modules above average delay
-- =========================================
SELECT Module,
       AVG(Resolution_Days) AS avg_days
FROM dbo.support_tickets
GROUP BY Module
HAVING AVG(Resolution_Days) > (
    SELECT AVG(Resolution_Days)
    FROM dbo.support_tickets
);


-- =========================================
-- 16. Data quality check - NULL values
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Ticket_ID IS NULL
   OR Ticket_Date IS NULL
   OR Client IS NULL
   OR Module IS NULL
   OR Priority IS NULL
   OR Status IS NULL
   OR Assigned_To IS NULL
   OR Resolution_Days IS NULL;


-- =========================================
-- 17. Data quality check - Count NULLs by column
-- =========================================
SELECT
    SUM(CASE WHEN Ticket_ID IS NULL THEN 1 ELSE 0 END) AS null_ticket_id,
    SUM(CASE WHEN Ticket_Date IS NULL THEN 1 ELSE 0 END) AS null_ticket_date,
    SUM(CASE WHEN Client IS NULL THEN 1 ELSE 0 END) AS null_client,
    SUM(CASE WHEN Module IS NULL THEN 1 ELSE 0 END) AS null_module,
    SUM(CASE WHEN Priority IS NULL THEN 1 ELSE 0 END) AS null_priority,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN Assigned_To IS NULL THEN 1 ELSE 0 END) AS null_assigned_to,
    SUM(CASE WHEN Resolution_Days IS NULL THEN 1 ELSE 0 END) AS null_resolution_days
FROM dbo.support_tickets;


-- =========================================
-- 18. Data quality check - Blank text values
-- =========================================
SELECT *
FROM dbo.support_tickets
WHERE Client = ''
   OR Module = ''
   OR Priority = ''
   OR Status = ''
   OR Assigned_To = '';


-- =========================================
-- =========================================
-- 19. Duplicate check - Duplicate Ticket_ID
-- =========================================
SELECT Ticket_ID, COUNT(*) AS duplicate_count
FROM dbo.support_tickets
GROUP BY Ticket_ID
HAVING COUNT(*) > 1;


-- =========================================
-- 20. Duplicate check - Duplicate full rows
-- =========================================
SELECT Ticket_ID,
       Ticket_Date,
       Client,
       Module,
       Priority,
       Status,
       Assigned_To,
       Resolution_Days,
       COUNT(*) AS duplicate_count
FROM dbo.support_tickets
GROUP BY Ticket_ID,
         Ticket_Date,
         Client,
         Module,
         Priority,
         Status,
         Assigned_To,
         Resolution_Days
HAVING COUNT(*) > 1;


-- =========================================
-- 21. Final KPI query - Module summary
-- =========================================
SELECT Module,
       COUNT(*) AS total_tickets,
       AVG(Resolution_Days) AS avg_resolution_days,
       SUM(CASE WHEN Priority = 'High' THEN 1 ELSE 0 END) AS high_priority_tickets,
       SUM(CASE WHEN Status = 'Open' THEN 1 ELSE 0 END) AS open_tickets
FROM dbo.support_tickets
GROUP BY Module
ORDER BY avg_resolution_days DESC;
