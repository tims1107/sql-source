select * from snomed_master m
join STATERPT_OWNER.MICRO_ORGANISM_FILTER f ON f.ORGANISMNAME = m.LOCALNAME
where regexp_like(localname,'candida','i');

select * from snomed_master m
where localname = '65';

update snomed_master
set localname = '65'
where snomedid = 36;

delete snomed_master
where snomedid = 38;


Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'119344008','Specimen from genital system (specimen)','65',systimestamp,'GENIT/Urethra','Urethra','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'119334006','Sputum specimen (specimen)','56',systimestamp,'RESP','BRONCHIAL ASPIR','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'309051001','Body fluid specimen (specimen)','50',systimestamp,'BFL','ABDOMINAL FLUID','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'127463000','Specimen from esophagus (specimen)','65',systimestamp,'RESP/ESOPHAGUS','ESOPHAGUS','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'119339001','Stool specimen (specimen)','56',systimestamp,'STL/RECTAL SWAB ','RECTAL SWAB ','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'455541000124107','Cultured cells specimen (specimen)','65',systimestamp,'FUNG/ABDOMEN','ABDOMEN','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'309166000
','Ear swab specimen (specimen)','65',systimestamp,'EAR/Ear','Ear','SPECIMEN');

Insert into SNOMED_MASTER (SNOMEDID,SNOMEDCODE,PREFERREDNAME,LOCALNAME,LAST_UPDATED_DATE,SPECIMEN_SOURCE_CODE,SPECIMEN_SOURCE_DESC,SNOMED_TYPE) 
values ((select max(snomedid) + 1 from snomed_master),'445160003','Ear swab specimen (specimen)','65',systimestamp,'EYE/Cornea','Cornea','SPECIMEN');

select localname,specimen_source_code,specimen_source_desc,snomed_type,count(1) from snomed_master
group by localname,specimen_source_code,specimen_source_desc,snomed_type;





select * from snomed_master 
where snomed_type = 'SPECIMEN'
and localname = '65' and SPECIMEN_SOURCE_CODE = 'BLD/ARTERIAL';

GENIT/Anus





select order_number,specimen_source from micro_messages_nc;

update micro_messages_nc
set specimen_source = 'GENIT/Anus'
where order_number = '11928J4';

update snomed_master
set snomed_type = 'SPECIMEN',specimen_source_code = 'EYE/Cornea',preferredname = 'Eye swab specimen (specimen)'
where snomedid = 34;

delete snomed_master
where snomedid = 5;

create unique index uidx_spm_localname_codedesc
ON snomed_master (localname,specimen_source_code,specimen_source_desc,snomed_type);

delete snomed_master
where localname = 'ug/mL';
