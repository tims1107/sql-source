-- Drop the table type first (dependent on the object type)
DROP TYPE asr_filter_table FORCE;
/

-- Then drop the object type
DROP TYPE asr_filter_obj FORCE;
/-- Drop the table type first (dependent on the object type)
DROP TYPE asr_filter_table FORCE;
/

-- Then drop the object type
DROP TYPE asr_filter_obj FORCE;
/

-- Simplified object type without condition field
CREATE OR REPLACE TYPE asr_filter_obj AS OBJECT (
    order_number VARCHAR2(50),
    result_test_code VARCHAR2(10),
    order_test_code VARCHAR2(10),
    textual_result_full VARCHAR2(4000),
    source VARCHAR2(10),
    complete VARCHAR2(1),
    state_abbreviation VARCHAR2(2),
    result_comment VARCHAR2(4000)
);
/

CREATE OR REPLACE TYPE asr_filter_table AS TABLE OF asr_filter_obj;
/