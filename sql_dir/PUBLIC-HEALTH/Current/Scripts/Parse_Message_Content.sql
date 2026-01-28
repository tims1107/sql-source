-- First, set DEFINE OFF to handle ampersands properly
SET DEFINE OFF;

WITH hl7_data AS (
    SELECT hl7_message_pk AS id, message_content
    FROM hl7_message
    WHERE hl7_message_pk = 421
),
-- Extract all segment starts
segment_positions AS (
    SELECT 
        d.id,
        LEVEL AS pos,
        DBMS_LOB.INSTR(d.message_content, 'MSH|', 1, LEVEL) AS msh_pos,
        DBMS_LOB.INSTR(d.message_content, 'SFT|', 1, LEVEL) AS sft_pos,
        DBMS_LOB.INSTR(d.message_content, 'PID|', 1, LEVEL) AS pid_pos,
        DBMS_LOB.INSTR(d.message_content, 'ORC|', 1, LEVEL) AS orc_pos,
        DBMS_LOB.INSTR(d.message_content, 'OBR|', 1, LEVEL) AS obr_pos,
        DBMS_LOB.INSTR(d.message_content, 'OBX|', 1, LEVEL) AS obx_pos,
        DBMS_LOB.INSTR(d.message_content, 'SPM|', 1, LEVEL) AS spm_pos
    FROM hl7_data d
    CONNECT BY LEVEL <= 100  -- Adjust based on expected number of segments
),
-- Combine all positions and sort
all_positions AS (
    SELECT sp.id, msh_pos AS position, 'MSH' AS segment_type FROM segment_positions sp WHERE msh_pos > 0
    UNION ALL
    SELECT sp.id, sft_pos AS position, 'SFT' AS segment_type FROM segment_positions sp WHERE sft_pos > 0
    UNION ALL
    SELECT sp.id, pid_pos AS position, 'PID' AS segment_type FROM segment_positions sp WHERE pid_pos > 0
    UNION ALL
    SELECT sp.id, orc_pos AS position, 'ORC' AS segment_type FROM segment_positions sp WHERE orc_pos > 0
    UNION ALL
    SELECT sp.id, obr_pos AS position, 'OBR' AS segment_type FROM segment_positions sp WHERE obr_pos > 0
    UNION ALL
    SELECT sp.id, obx_pos AS position, 'OBX' AS segment_type FROM segment_positions sp WHERE obx_pos > 0
    UNION ALL
    SELECT sp.id, spm_pos AS position, 'SPM' AS segment_type FROM segment_positions sp WHERE spm_pos > 0
),
-- Sort positions and calculate segment lengths
segment_ranges AS (
    SELECT 
        ap.id,
        ap.position,
        ap.segment_type,
        LEAD(ap.position, 1, DBMS_LOB.GETLENGTH(d.message_content) + 1) OVER (PARTITION BY ap.id ORDER BY ap.position) - ap.position AS segment_length
    FROM all_positions ap
    JOIN hl7_data d ON ap.id = d.id
),
-- Extract segments
segments AS (
    SELECT 
        sr.id,
        ROW_NUMBER() OVER (PARTITION BY sr.id ORDER BY sr.position) AS segment_number,
        sr.segment_type,
        DBMS_LOB.SUBSTR(d.message_content, LEAST(sr.segment_length, 4000), sr.position) AS segment_text
    FROM segment_ranges sr
    JOIN hl7_data d ON sr.id = d.id
)
-- Process segments
SELECT
    s.segment_number,
    s.segment_type,
    s.segment_text,
    -- Extract up to 5 fields from each segment using pipe as field separator
    REGEXP_SUBSTR(s.segment_text, '[^|]+', 1, 1) AS field_1,
    REGEXP_SUBSTR(s.segment_text, '[^|]+', 1, 2) AS field_2,
    REGEXP_SUBSTR(s.segment_text, '[^|]+', 1, 3) AS field_3,
    REGEXP_SUBSTR(s.segment_text, '[^|]+', 1, 4) AS field_4,
    REGEXP_SUBSTR(s.segment_text, '[^|]+', 1, 5) AS field_5
FROM segments s
ORDER BY s.segment_number;

