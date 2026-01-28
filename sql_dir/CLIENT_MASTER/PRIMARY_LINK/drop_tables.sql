declare 
  ddl_qry varchar2(4000);
  v_deleted varchar2(32) := 'CM2_0828';
  
begin

for tab IN (select object_name from user_objects where object_type = 'TABLE'
and regexp_like (object_name,v_deleted))

loop
ddl_qry := 'drop table ' || tab.object_name;
dbms_output.put_line(ddl_qry);
EXECUTE IMMEDIATE ddl_qry;

end loop;
  
end;
/

select * from clinic_cm2_0828;

select object_name from user_objects where object_type = 'TABLE'
and regexp_like (object_name,'CM2');
/

declare 
  ddl_qry varchar2(4000);
  v_count number;
  cur sys_refcursor;
  
begin



for tab IN (select object_name from user_objects where object_type = 'TABLE'
and regexp_like (object_name,'A103147$'))

loop
ddl_qry := 'select count(1) from ' || tab.object_name;

dbms_output.put_line(ddl_qry);
--EXECUTE IMMEDIATE ddl_qry INTO v_count;

dbms_output.put_line(v_count);

end loop;
  
end;

/
declare 
  ddl_qry varchar2(4000);
  v_count number;
  cur sys_refcursor;
  
begin



for tab IN (select object_name from user_objects where object_type = 'TABLE'
and regexp_like (object_name,'20240304_01$'))

loop
ddl_qry := 'delete from ' || tab.object_name;

dbms_output.put_line(ddl_qry);
EXECUTE IMMEDIATE ddl_qry;
v_count := sql%rowcount;

dbms_output.put_line(v_count);

end loop;
  
end;
/

select * from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where hlabnumber = 'A103147';

208485


