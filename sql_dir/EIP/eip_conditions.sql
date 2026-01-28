select * from state_master
where entity_type = 'EIP';

select * from condition_master
where state_fk IN (
select state_master_pk from state_master
where entity_type = 'EIP'
and state = 'MSSA');

select * from condition_master
where condition_master_pk = 76;


update condition_master
set condition ='Organism Name Like',condition_filter_fk = 10,condition_value='Acinetobacter baumannii complex'
where CONDITION_MASTER_PK = 1893;

select * from STATERPT_OWNER.CONDITION_MASTER
where state_fk = 10;

select * from condition_filters
where condition_filter_pk = 43;

select * from STATERPT_OWNER.GENERATOR_FIELDS_MAP
where generator_fk = 9;

select * from STATERPT_OWNER.GENERATOR_FIELDS
where generator_fields_group = 4;

--D:/ASR/EIP/ASR_MUGSI_TIMER_TASK/{0}/XLS_destination/

--D:/ASR/EIP/{0}/XLS_destination/

update generator_fields
set generator_field_value = 'D:/ASR/EIP/ASR_MUGSI_TIMER_TASK/{0}/XLS_destination/'
where generator_field_pk = 62;


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),10,43,null,null,'regexp_like(eip.MICRO_ORGANISM_NAME','ST','^Acinetobacter','active',systimestamp,'staterpt',systimestamp,'staterpt');



Insert into CONDITION_FILTERS (CONDITION_FILTER_PK,CONDITION,FILTER,VALUE_TYPE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_filter_pk) + 1 from condition_filters),'Acinetobacter','(regexp_like(eip.MICRO_ORGANISM_NAME,''{0}'',''i'')','ST','active',systimestamp,'eip',systimestamp,'eip');

select '(regexp_like(eip.MICRO_ORGANISM_NAME,''{0}'',''i'') ' from dual;


/

select * from
(select decode(lab_fk,5,'East',7,'South','') performing_lab,e.order_test_code,order_test_name,result_test_code,result_test_name,result_status,e.REQUISITION_ID,micro_organism_name
,DBMS_LOB.SUBSTR(e.result_comment,4000,1) result_comment
,e.LAST_UPDATED_DATE,pat.patient_account_zip,c.county,pat.patient_account_state state from MICRO_RESULTS_EXTRACT e
    
		join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join dl_zip_code c ON c.zip = pat.patient_account_zip
		--where e.LAST_UPDATED_DATE > to_date('01-SEP-24','dd-MON-yy')
    where e.result_status = 'F'
    and regexp_like(result_test_name,'isolate','i')) results
    join 
(select * from condition_master
where state_fk IN (
select state_master_pk from state_master
where entity_type = 'EIP'
and state = 'MSSA')) mssa ON mssa.condition_value = results.state
--and requisition_id = '1263VY4';
where (regexp_like(results.micro_organism_name,
'^Methicillin Resistant Staphylococcus aureus|^Staphylococcus aureu|^Streptococcus pyogenes \(Beta Hemolytic Streptococci Group A\)','i')
or 
regexp_like(results.micro_organism_name,
'^Streptococcus agalactiae \(Beta Hemolytic Streptococci Group B\)|^Streptococcus pneumoniae|^Haemophilus influenzae|^Neisseria meningitidis','i'))
and 
not regexp_like(results.result_test_code,'^731$|^734$')
;

select requisition_id,count(1) from
(select * from micro_results_extract
where requisition_id IN
('1263VY4','1278PX7','1269V34','1269V44','1286FK4','1286FM4','1286H24','1310KP4','13183V4','1328AY4','13298S4','1527BN7','1527BM7','1448J47','1448J57','1528BP7',
'15265P7','15265N7','13626W4','1595UB7','1594J17','1594J27','15858G7','1573K27','1573K37','15748V7','1583JP7','17469R7','17469P7','1690Z37','1746U57','1621A47',
'16227K7','1621T67','18204K7','1822K07','1822K17','1822K27','1820T57','1819RP7','1819RR7','18195T7','1878GR7','1875PW7','1877RX7','1874HB7','20420Z7','20421A7',
'2039WU7','1916WB7','18919X7','21210N7','2120PW7','20450N7','21204W7','21186C7','2044CA7','2182ZT7','21809N7','2167B17','2168FH7','2170C07','2168T57','2166ZA7',
'2167H97','2345SB7','2345SC7','2223CC7','2197T37','21985H7','21971X7','21969H7','21971Y7','2193ZN7','2195JM7','2421YW7','24236M7','24236T7','24224P7','24224R7',
'2423J87','2422NW7','2421GN7','2421G07','2420SS7','2347K27','2476XZ7','2463TB7','2463TC7','24921R7','2646A27','2646A37','25165N7','25165P7','25166V7','2514X27',
'25152C7','25152F7','2491A37','2489MT7','2484GW7','2484GZ7','2484H57','2484H47','2777WV7','2777PW7','2777WW7','2777PX7','2731TT7','2731TW7','2731U07','26494M7',
'26504Y7','26504Z7','26505G7','2647PA7','2650XK7','2792G57','2778G57','2792S17','2792NB7','2777XK7','2777XM7')
and regexp_like(result_test_name,'isolate','i'))
group by requisition_id;
having count(1) > 1;

select * from
(select * from condition_master
where state_fk IN (
select state_master_pk from state_master
where entity_type = 'EIP'
and state = 'MUGSI'));

select micro_organism_name from micro_results_extract
group by micro_organism_name
order by micro_organism_name;
   