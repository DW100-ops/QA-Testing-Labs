SQL Validation Queries (Common QA Scenarios)Add these to a file /sql/validation-queries.sql in your repo.sql
-- ====================================================================
-- PROJECT: COMPREHENSIVE DATA INTEGRITY & QA VALIDATION SUITE
-- PURPOSE: Production-grade scripts for general application logic
--          and enterprise infrastructure database auditing.
-- ====================================================================

-- ====================================================================
-- SECTION 1: GENERAL APPLICATION DATA VALIDATION
-- ====================================================================

-- 1. Count total records (sanity check) 
SELECT COUNT(*) AS total_records FROM users; 

-- 2. Check for duplicates 
SELECT email, COUNT(*) AS count FROM users GROUP BY email HAVING COUNT(*) > 1; 

-- 3. Validate foreign key integrity (assignments reference valid users) 
SELECT a.id FROM assignments a LEFT JOIN users u ON a.userId = u.id WHERE u.id IS NULL; 

-- 4. Check data consistency (active users with assignments) 
SELECT u.id, u.name FROM users u JOIN assignments a ON u.id = a.userId WHERE u.active = 0; 

-- 5. Date range validation 
SELECT MIN(createdAt) AS earliest, MAX(createdAt) AS latest FROM assignments; 

-- 6. Enum/allowed values check 
SELECT DISTINCT result FROM assignments WHERE result NOT IN ('PASSED', 'FAILED', 'PENDING'); 

-- 7. Null check on required fields 
SELECT * FROM users WHERE name IS NULL OR email IS NULL;


-- ====================================================================
-- SECTION 2: ENTERPRISE INFRASTRUCTURE VALIDATION
-- ====================================================================

-- 8. IDENTIFY DUPLICATE HARDWARE NODES (Data Integrity Check)
-- Validates that unique Hardware IDs are not duplicated in the active asset register.
SELECT 
    hardware_id, 
    COUNT(*) as duplicate_count
FROM enterprise_network_inventory
GROUP BY hardware_id
HAVING COUNT(*) > 1;

-- 9. DETECT MISSING CRITICAL ROUTING METRICS (Null Constraint Validation)
-- Flags records where essential latency data failed to populate during database ingestion.
SELECT 
    session_id, 
    node_id, 
    ingestion_timestamp
FROM network_performance_logs
WHERE average_latency_ms IS NULL 
   OR packet_loss_ratio IS NULL;

-- 10. RECONCILE DISCONNECTED SYSTEM DETAIL RECORDS (Referential Integrity Check)
-- Identifies orphaned server log entities that do not map back to a valid registered system core.
SELECT 
    sdr.session_id, 
    sdr.source_ip, 
    sdr.timestamp
FROM system_detail_records sdr
LEFT JOIN active_infrastructure_base infrastructure 
    ON sdr.source_ip = infrastructure.ip_address
WHERE infrastructure.ip_address IS NULL;
