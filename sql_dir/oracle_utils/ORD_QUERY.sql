SELECT *
         FROM   user_ords_enabled_objects --where regexp_like (parsing_object,'SP_COPY')
         where regexp_like (type,'PROCEDURE')
         and regexp_like(PARSING_OBJECT,'sp_add','i')
          order by parsing_object;
         
         --sp_clinicsupport
         --sp_salesrep
         
select object_name, object_type, last_ddl_time
from all_objects
where LOWER(object_name) = 'xml_calendar_01' and object_type = 'TABLE';
         
-- views lookup
SELECT *
         FROM   user_ords_enabled_objects --where regexp_like (parsing_object,'SP_COPY')
         order by parsing_object;
         --where regexp_like (type,'VIEW','i')
         where regexp_like(PARSING_OBJECT,'^load','i')
         --and type = 'PROCEDURE'
         order by parsing_object;
         
select * from all_objects
where object_type = 'VIEW'
and regexp_like(object_name,'extract','i');
         
select * from user_objects where object_type = 'PROCEDURE'
and last_ddl_time > sysdate -28;
and regexp_like (object_name,'sp_add_clinic','i') ;

select * from v$version;

select * from CLINIC_FMCRELATIONSHIP;
select * from CLINIC_AFFILIATION;
select * from CLINIC_ECUBE_SERVER;
select * from CLINIC_MODALITY_TYPE;
select * from CLINIC_ORDER_SYSTEM;
select * from CLINIC_SALES_REP;
select * from CLINIC_SERVICELAB;
select * from CLINIC_STATUS;
select * from CLINIC_SUPPORT;
select * from CLINIC_TYPE_OF_SERVICE;
select * from CORPORATION;
select * from CUSTOM_ALERT_LOOKUP;
select * from CUSTOM_EXCEPTION_LOOKUP;
select * from STATE_LOOKUP;





