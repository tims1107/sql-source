-- First, set DEFINE OFF to handle ampersands properly
SET DEFINE OFF;

/


select field_value from 
(WITH hl7_data AS (
    SELECT hl7_message_pk AS id, message_content
    FROM hl7_message
    WHERE hl7_message_pk = 721
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
),
-- Split segment text into an array of fields
obx_segments AS (
    SELECT
        segment_number,
        segment_type,
        segment_text,
        -- Add a trailing pipe to ensure we capture the last field even if empty
        segment_text || '|' AS padded_segment_text,
        -- Count total fields (pipe count + 1)
        LENGTH(segment_text) - LENGTH(REPLACE(segment_text, '|', '')) + 1 AS field_count
    FROM segments
    -- segment selection
    WHERE segment_type = 'OBR'
),
-- Extract all fields with positions using a more robust approach
obx_fields AS (
    SELECT
        os.segment_number,
        os.segment_type,
        os.segment_text,
        LEVEL - 1 AS field_position,  -- Start from 0 instead of 1
        -- Extract field by finding text between pipes
        CASE 
            WHEN LEVEL = 1 THEN 
                SUBSTR(os.padded_segment_text, 1, INSTR(os.padded_segment_text, '|', 1, 1) - 1)
            ELSE 
                SUBSTR(
                    os.padded_segment_text,
                    INSTR(os.padded_segment_text, '|', 1, LEVEL - 1) + 1,
                    INSTR(os.padded_segment_text, '|', 1, LEVEL) - INSTR(os.padded_segment_text, '|', 1, LEVEL - 1) - 1
                )
        END AS field_value
    FROM obx_segments os
    CONNECT BY LEVEL <= os.field_count
        AND PRIOR os.segment_number = os.segment_number
        AND PRIOR SYS_GUID() IS NOT NULL
)
-- Final result with all OBX fields
SELECT
    segment_number,
    segment_type,
    field_position,
    field_value,
    -- Common OBX field names for reference
    CASE field_position
        WHEN 0 THEN 'Segment ID'
        WHEN 1 THEN 'Set ID'
        WHEN 2 THEN 'Value Type'
        WHEN 3 THEN 'Observation ID'
        WHEN 4 THEN 'Observation Sub-ID'
        WHEN 5 THEN 'Observation Value'
        WHEN 6 THEN 'Units'
        WHEN 7 THEN 'Reference Range'
        WHEN 8 THEN 'Abnormal Flags'
        WHEN 9 THEN 'Probability'
        WHEN 10 THEN 'Nature of Abnormal Test'
        WHEN 11 THEN 'Observation Result Status'
        WHEN 12 THEN 'Effective Date'
        WHEN 13 THEN 'User Defined Access Checks'
        WHEN 14 THEN 'Date/Time of Observation'
        WHEN 15 THEN 'Producer ID'
        WHEN 16 THEN 'Responsible Observer'
        WHEN 17 THEN 'Observation Method'
        WHEN 18 THEN 'Equipment Instance Identifier'
        WHEN 19 THEN 'Date/Time of Analysis'
        WHEN 20 THEN 'Observation Site'
        WHEN 21 THEN 'Observation Instance Identifier'
        WHEN 22 THEN 'Mood Code'
        WHEN 23 THEN 'Performing Organization Name'
        WHEN 24 THEN 'Performing Organization Address'
        WHEN 25 THEN 'Performing Organization Medical Director'
        ELSE 'Field ' || field_position
    END AS field_name
FROM obx_fields) t1
where t1.field_position = 3;
ORDER BY segment_number, field_position;
/

-- *****  all message content ******

-- First, set DEFINE OFF to handle ampersands properly
SET DEFINE OFF;
select hl7_message_pk,field_position,field_value from 
(WITH hl7_data AS (
    SELECT hl7_message_pk AS id, message_content
    FROM hl7_message
    -- No WHERE clause to select all messages
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
        AND PRIOR d.id = d.id
        AND PRIOR SYS_GUID() IS NOT NULL
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
),
-- Split segment text into an array of fields
obx_segments AS (
    SELECT
        id,
        segment_number,
        segment_type,
        segment_text,
        -- Add a trailing pipe to ensure we capture the last field even if empty
        segment_text || '|' AS padded_segment_text,
        -- Count total fields (pipe count + 1)
        LENGTH(segment_text) - LENGTH(REPLACE(segment_text, '|', '')) + 1 AS field_count
    FROM segments
    WHERE segment_type = 'OBX'
),
-- Extract all fields with positions using a more robust approach
obx_fields AS (
    SELECT
        os.id,
        os.segment_number,
        os.segment_type,
        os.segment_text,
        LEVEL - 1 AS field_position,  -- Start from 0 instead of 1
        -- Extract field by finding text between pipes
        CASE 
            WHEN LEVEL = 1 THEN 
                SUBSTR(os.padded_segment_text, 1, INSTR(os.padded_segment_text, '|', 1, 1) - 1)
            ELSE 
                SUBSTR(
                    os.padded_segment_text,
                    INSTR(os.padded_segment_text, '|', 1, LEVEL - 1) + 1,
                    INSTR(os.padded_segment_text, '|', 1, LEVEL) - INSTR(os.padded_segment_text, '|', 1, LEVEL - 1) - 1
                )
        END AS field_value
    FROM obx_segments os
    CONNECT BY LEVEL <= os.field_count
        AND PRIOR os.id = os.id
        AND PRIOR os.segment_number = os.segment_number
        AND PRIOR SYS_GUID() IS NOT NULL
)
-- Final result with all OBX fields
SELECT
    id AS hl7_message_pk,
    segment_number,
    segment_type,
    field_position,
    field_value,
    -- Common OBX field names for reference
    CASE field_position
        WHEN 0 THEN 'Segment ID'
        WHEN 1 THEN 'Set ID'
        WHEN 2 THEN 'Value Type'
        WHEN 3 THEN 'Observation ID'
        WHEN 4 THEN 'Observation Sub-ID'
        WHEN 5 THEN 'Observation Value'
        WHEN 6 THEN 'Units'
        WHEN 7 THEN 'Reference Range'
        WHEN 8 THEN 'Abnormal Flags'
        WHEN 9 THEN 'Probability'
        WHEN 10 THEN 'Nature of Abnormal Test'
        WHEN 11 THEN 'Observation Result Status'
        WHEN 12 THEN 'Effective Date'
        WHEN 13 THEN 'User Defined Access Checks'
        WHEN 14 THEN 'Date/Time of Observation'
        WHEN 15 THEN 'Producer ID'
        WHEN 16 THEN 'Responsible Observer'
        WHEN 17 THEN 'Observation Method'
        WHEN 18 THEN 'Equipment Instance Identifier'
        WHEN 19 THEN 'Date/Time of Analysis'
        WHEN 20 THEN 'Observation Site'
        WHEN 21 THEN 'Observation Instance Identifier'
        WHEN 22 THEN 'Mood Code'
        WHEN 23 THEN 'Performing Organization Name'
        WHEN 24 THEN 'Performing Organization Address'
        WHEN 25 THEN 'Performing Organization Medical Director'
        ELSE 'Field ' || field_position
    END AS field_name
FROM obx_fields
ORDER BY id, segment_number, field_position) t1
where t1.field_position = 19
and not regexp_like(field_value,'^\d{8}0000-0[4-5]00')
order by field_value;


/

select * from hl7_message
where state_code = 'IL'
order by creation_date desc;