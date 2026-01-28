select * from 
(select 'S' table_flag,f.* from westequiphlab_report f
union all
select 'E' table_flag,f.* from eastequiphlab_report f) t1
where hlab_num = 'A124399';