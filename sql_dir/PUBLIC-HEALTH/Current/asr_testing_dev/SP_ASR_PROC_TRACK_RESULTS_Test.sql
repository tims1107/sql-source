select * from results_sent_log
order by last_update_time desc;

/
declare p_state varchar2(2) := 'PA';
p_out number := 0;
input_cursor sys_refcursor;
  output_cursor sys_refcursor;
  v_row gtt_results_extract%rowtype;

begin

    SP_ASR_PROC_TRACK_RESULTS_G(p_state,p_out);
 
end;
/

select  from ih_dw.results
where requisition_id = '96666VK'
and result_test_code = '319N';

select * from gtt_results_extract;