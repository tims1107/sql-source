use sts;

drop table cm_sap_temp;

create table cm_sap_temp
(hlab_num varchar(7),
new_value varchar(8),
old_value varchar(8),
changedate smalldatetime);

/

alter trigger cm_sap_trigger_update
ON facility
for update
as BEGIN
  INSERT INTO cm_sap_temp (hlab_num,new_value,old_value,changedate)
  SELECT i.hlab_num,i.sap_number,d.sap_number,null
  FROM inserted i
  INNER JOIN deleted d ON i.hlab_num = d.hlab_num
  where i.sap_number <> d.sap_number
END;

/

select * from cm_sap_temp;

update cm_sap_temp
set changedate = getdate()
where changedate is null;

select hlab_num, sap_number from facility
where sap_number is not null;

update facility
set sap_number = '2107071'
where hlab_num = 'A116653';

select * from 
