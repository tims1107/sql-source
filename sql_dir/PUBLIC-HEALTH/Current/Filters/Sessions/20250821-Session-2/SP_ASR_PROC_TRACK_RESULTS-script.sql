create or replace PROCEDURE "SP_ASR_RESULTS" (
	p_state IN varchar2,
	p_otc IN varchar2,
	p_rtc IN varchar2,
	p_otc_outer IN varchar2,
	p_rtc_outer IN varchar2,
	p_otc_close IN varchar2,
	p_rtc_close IN varchar2,
	p_filter_inner IN VARCHAR2,
	p_filter_outer IN VARCHAR2,
	p_filter_ew IN varchar2, 
	p_recordset OUT sys_refcursor,
  p_sql out varchar2,
  p_gtt_count out number
) AS
	v_process  VARCHAR2(30) := 'ASR_PROCESS_' || UPPER(p_state);
	v_next_time TIMESTAMP(6) := SYSTIMESTAMP;
	v_start_time TIMESTAMP(6);
	v_error_flag BOOLEAN := FALSE;
	v_count NUMBER := 0;
  v_sql VARCHAR2(4000);
  v_gtt_count number := 0;
	
    table_or_view_not_exist exception;
    pragma exception_init(table_or_view_not_exist, -942);
    attempted_ddl_on_in_use_GTT exception;
    pragma exception_init(attempted_ddl_on_in_use_GTT, -14452);
    
	BEGIN
  

		BEGIN
    
      v_sql :=
			'select 
        *	
			from 
				--STATERPT_OWNER.TEMP_RESULTS_EXTRACT rs
        STATERPT_OWNER.GTT_RESULTS_EXTRACT rs
			where 
				--PATIENT_ACCOUNT_STATE = ''' || p_state || ''' 
        --PATIENT_ACCOUNT_STATE in (' || p_state || ')
        --and accession_number in ( 
        accession_number in ( 
					select 
						distinct(r.accession_number)
					from 
						--STATERPT_OWNER.TEMP_RESULTS_EXTRACT r,
            STATERPT_OWNER.GTT_RESULTS_EXTRACT r,
						( 
							select 
								distinct(accession_number)
							from 
								--STATERPT_OWNER.TEMP_RESULTS_EXTRACT
                STATERPT_OWNER.GTT_RESULTS_EXTRACT
							where 
								order_test_code = ''' || p_otc || ''' ';
                
                if(p_rtc is not null) then
                  v_sql := v_sql || ' and result_test_code = ''' || p_rtc || ''' ';
                end if;

                if(p_filter_inner is not null) then
                  v_sql := v_sql || ' and ' || p_filter_inner;
                end if;  
                
                v_sql := v_sql || ') p ';
  
        v_sql := v_sql || '  
					where 
						r.accession_number = p.accession_number ';                
          
            if(p_otc_outer is not null) then
              v_sql := v_sql || ' and r.order_test_code = ''' || p_otc_outer || ''' ';
            end if;
            
            if(p_rtc_outer is not null) then
              v_sql := v_sql || ' and r.result_test_code = ''' || p_rtc_outer || ''' ';
            end if;
            if(p_filter_outer is not null) then
              v_sql := v_sql || ' and (' || p_filter_outer || ')';
            end if;  
            
            v_sql := v_sql || ' ) ';
            
				if(p_otc_close is not null) then
          v_sql := v_sql || ' and rs.order_test_code = ''' || p_otc_close || '''  ';
        end if;
        
        if(p_rtc_close is not null) then
          v_sql := v_sql || ' and rs.result_test_code like ''' || p_rtc_close || ''' ';
        end if;
        
        if(p_filter_ew is not null) then
          v_sql := v_sql || ' and ' || p_filter_ew;
        end if;        
/*
      v_sql :=
			'select 
				*	
			from 
				STATERPT_OWNER.GTT_RESULTS_EXTRACT rs
			where 
				PATIENT_ACCOUNT_STATE = ''' || p_state || ''' 
				and accession_number in ( 
					select 
						distinct(r.accession_number)
					from 
						STATERPT_OWNER.GTT_RESULTS_EXTRACT r,
						( 
							select 
								distinct(accession_number)
							from 
								STATERPT_OWNER.GTT_RESULTS_EXTRACT 
							where 
								order_test_code = ''' || p_otc || ''' ';
                
                if(p_rtc is not null) then
                  v_sql := v_sql || ' and result_test_code = ''' || p_rtc || ''' ';
                end if;
                if(p_filter_inner is not null) then
                  v_sql := v_sql || ' and ' || p_filter_inner || '  
						) p
					where 
						r.accession_number = p.accession_number ';
            end if;
            if(p_otc_outer is not null) then
              v_sql := v_sql || ' and r.order_test_code = ''' || p_otc_outer || ''' ';
            end if;
            if(p_rtc_outer is not null) then
              v_sql := v_sql || ' and r.result_test_code = ''' || p_rtc_outer || ''' ';
            end if;
            if(p_filter_outer is not null) then
              v_sql := v_sql || ' and ' || p_filter_outer || ' 
            ) ';
            end if;
				if(p_otc_close is not null) then
          v_sql := v_sql || ' and rs.order_test_code = ''' || p_otc_close || '''  ';
        end if;
        if(p_rtc_close is not null) then
          v_sql := v_sql || ' and rs.result_test_code like ''' || p_rtc_close || ''' ';
        end if;
        if(p_filter_ew is not null) then
          v_sql := v_sql || ' and ' || p_filter_ew;
        end if;  
*/    
        --dbms_output.enable();

        dbms_output.put_line('p_dto.state: ' || p_state);
        dbms_output.put_line('p_dto.otc: ' || p_otc);
        dbms_output.put_line('p_dto.rtc: ' || p_rtc);
        dbms_output.put_line('p_dto.filter_inner: ' || p_filter_inner);
        dbms_output.put_line('p_dto.otc_outer: ' || p_otc_outer);
        dbms_output.put_line('p_dto.rtc_outer: ' || p_rtc_outer);
        dbms_output.put_line('p_dto.filter_outer: ' || p_filter_outer);
        dbms_output.put_line('p_dto.otc_close: ' || p_otc_close);
        dbms_output.put_line('p_dto.rtc_close: ' || p_rtc_close);
        dbms_output.put_line('p_dto.filter_ew: ' || p_filter_ew);
        
        dbms_output.put_line('v_sql: ' || v_sql);
        
        select
          count(*)
        into
          v_gtt_count
        from
          --STATERPT_OWNER.TEMP_RESULTS_EXTRACT;
          STATERPT_OWNER.GTT_RESULTS_EXTRACT;
          
        dbms_output.put_line('v_gtt_count: ' || v_gtt_count); 
        
        select v_gtt_count into p_gtt_count from dual;
        
        --dbms_output.disable();
        
        select v_sql into p_sql from dual;
        
--        OPEN p_recordset FOR select * from STATERPT_OWNER.GTT_RESULTS_EXTRACT
--        where PATIENT_ACCOUNT_STATE = p_state 
--        and order_test_code = p_otc and result_test_code = p_rtc and lab_fk = 7;
        
        -- comment for testing.
        OPEN p_recordset FOR v_sql;
        
        
        --open p_recordset for select * from temp_results_extract;
        
				EXCEPTION
				WHEN table_or_view_not_exist THEN
					dbms_output.put_line('Table STATERPT_OWNER.GTT_RESULTS_EXTRACT did not exist at time of truncate. Continuing....');

				WHEN attempted_ddl_on_in_use_GTT THEN
					dbms_output.put_line('STATERPT_OWNER.GTT_RESULTS_EXTRACT is in use. Commit!');
					raise;

				WHEN OTHERS THEN
					DBMS_OUTPUT.put_line ('Error in creating table STATERPT_OWNER.GTT_RESULTS_EXTRACT');
					DBMS_OUTPUT.put_line('v_error:'||sqlcode);
					DBMS_OUTPUT.put_line('v_sqlerrm:'||sqlerrm);
					if sqlcode = -60 then -- deadlock error is ORA-00060
					  null;
					else
					  raise;
					end if;		
		END;
	
END SP_ASR_RESULTS;

/

select result_test_code,patient_account_state from temp_results_extract
where regexp_like(order_test_code,'^(301|303|304|308|310|311|318)$')
group by result_test_code,patient_account_state
order by result_test_code;

/

update asr_process_run
set complete = 'N'
where source = 'TX'
and complete = 'R'
and activitydate > sysdate - 5;

drop table results_sent_log_20250818;

create table results_sent_log_20250818
as 
select * from results_sent_log
where order_number IN
(select order_number from asr_process_run
where complete = 'N');

select * from results_sent_log_20250818;

delete results_sent_log
where order_number IN
(select order_number from asr_process_run
where complete = 'N');

/
declare p_out number;

begin

    SP_ASR_PROC_TRACK_RESULTS('TX',p_out);
    
    dbms_output.put_line('Count: ' || p_out);
end;