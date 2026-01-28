create or replace PACKAGE condition_processor AS
    TYPE state_cursor_type IS REF CURSOR;

    -- Session management
    PROCEDURE initialize_session(p_last_updated_date DATE DEFAULT TRUNC(SYSDATE));
    PROCEDURE cleanup_session;
    FUNCTION get_session_status RETURN VARCHAR2;

    -- Core processing functions
    FUNCTION process_state(
        p_state_abbrev VARCHAR2, 
        p_process_date DATE DEFAULT TRUNC(SYSDATE)
    ) RETURN SYS_REFCURSOR;

    FUNCTION validate_results(
        p_state_abbrev VARCHAR2,
        p_process_date DATE DEFAULT TRUNC(SYSDATE),
        p_max_records NUMBER DEFAULT 200,
        p_result_status_filter VARCHAR2 DEFAULT NULL
    ) RETURN SYS_REFCURSOR;

    -- Helper functions
    FUNCTION get_base_condition_sql(
        p_state_abbrev VARCHAR2,
        p_process_date DATE
    ) RETURN CLOB;

    FUNCTION build_condition_filter_sql(
        p_condition_id NUMBER,
        p_order_test_code VARCHAR2,
        p_result_test_code VARCHAR2,
        p_filter VARCHAR2,
        p_condition_value VARCHAR2,
        p_value_type VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION is_filter_safe(p_filter VARCHAR2) RETURN BOOLEAN;
    
    -- ADD THIS DECLARATION
    FUNCTION is_valid_310_record(
        p_order_number VARCHAR2,
        p_order_test_code VARCHAR2,
        p_state_abbrev VARCHAR2,
        p_process_date DATE
    ) RETURN BOOLEAN;
    
    FUNCTION filter_310_validation(
    p_state_abbrev VARCHAR2,
    p_process_date DATE,
    p_result_status_filter VARCHAR2 DEFAULT NULL
) RETURN SYS_REFCURSOR;
    
    -- Function to get active states from state_master table
    FUNCTION get_active_states RETURN SYS_REFCURSOR;

END condition_processor;


