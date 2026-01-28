-- start transfer

  delete southfacility where hlab_num = 'A101186';
  delete southadd_info where hlab_num = 'A101186';
  delete westmore_account_info where hlab_num = 'A101186';
  delete westequipment where hlab_num = 'A101186';
  delete westequip_detail where hlab_num = 'A101186';
  delete westphone_line_info where hlab_num = 'A101186';
  delete westmore_contact_info where hlab_num = 'A101186';
  delete westbill_info where hlab_num = 'A101186';
  delete westequipreportlabel_comments where hlab_num = 'A101186';
  delete southhard_copy where hlab_num = 'A101186';
  delete southalert_exception where hlab_num = 'A101186';
  delete southcopyto where hlab_num = 'A101186';
  delete southspecial_instructions where hlab_num = 'A101186';
  delete westemail where hlab_num = 'A101186';
  

/
  
  insert into southfacility 
  select hlab_num,facility_num,facility_pref,facility_name,fmc_number, 'S' e_w_flag,int_ext_study,cid,tla,address1,address2,city,facility_state,zip,
    country,country_code,phone,fax,phone_comments,'Pre Transfer' account_status, 'SPECTRA SOUTH' account_type,account_category,type_of_service,primary_account,primary_name,
    priority_call,order_system,ami_database,ami_market,patient_report,patient_count,hemo_count,pd_count,cour_account,courier_area,specimen_del,
    comments,cour_ship_num,korus_cid,hh_count,alt_acct_num,cour_service,ETA 
  from facility where hlab_num = 'A101186';
  
      
  insert into southadd_info 
  select * from eastadd_info where hlab_num = 'A101186';
  
  insert into westmore_account_info 
  select * from more_account_info where hlab_num = 'A101186';
  
  insert into westequipment 
  select * from equipment where hlab_num = 'A101186';
  
  insert into westequip_detail 
  select * from equip_detail where hlab_num = 'A101186';
  
  insert into westphone_line_info 
  select * from eastphone_line_info where hlab_num = 'A101186';
  
  insert into westmore_contact_info 
  select * from more_contact_info where hlab_num = 'A101186';
  
  insert into westbill_info 
  select * from eastbill_info where hlab_num = 'A101186';
  
  insert into westequipreportlabel_comments 
  select * from eastequipreportlabel_comments where hlab_num = 'A101186';
  
  insert into southhard_copy 
  select * from easthard_copy where hlab_num = 'A101186';
  
  insert into southalert_exception 
  select * from eastalert_exception where hlab_num = 'A101186';
  
  insert into southcopyto 
  select * from eastcopyto where hlab_num = 'A101186';
  
  insert into southspecial_instructions 
  select * from eastspecial_instructions where hlab_num = 'A101186';
  
  insert into westemail
  select * from eastemail where hlab_num = 'A101186';
  
 /
 
--  insert change to tables

    
    insert into southfacility_change values ('14192','North Garland','TRANPROC',current_timestamp,'Pre Transfer To South','A101186');
    insert into facility_change values ('14192','North Garland','TRANPROC',current_timestamp,'Pre Transfer To South','A101186');
    
/

-- complete transfer

    
      
     update southfacility
     set account_status = 'Active'
     where hlab_num = 'A101186';
        
      insert into southfacility_change values ('14192','North Garland','TRANPROC',current_timestamp,'Transferred To South','A101186');
      
      insert into facility_transfer values (null,null,'Transfer to Spectra South','TRANPROC',current_timestamp,'A101186');
      
      update facility
      set account_status = 'Transferred'
      where hlab_num = 'A101186';
      
  select * from customer_num
  where customer_num = 'C014192';    
  
  update customer_num
  set e_w = 'S'
  where cust_hlab_num = 'A101186';
 
  

end
  
