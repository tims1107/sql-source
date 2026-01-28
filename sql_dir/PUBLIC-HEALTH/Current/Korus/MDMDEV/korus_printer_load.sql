select * from cm_change_types;

select * from vw_upd_clinicname_n;

select * from clinic_printer
where clinicid = 539389
and p;

select * from printer_type;

drop table korus_printer;

CREATE TABLE korus_printer
(
    HLAB_NUM VARCHAR2(7) NOT NULL,
    FMC_NUMBER VARCHAR2(8) ,
    INTERNAL_EXTERNAL_FLAG VARCHAR2(1),
    PRINTER_NAME VARCHAR2(60),
    IP_ADDRESS VARCHAR2(15),
    PRINTER_TYPE VARCHAR2(40)
);

CREATE TABLE cm_owner.korus_printer (
    -- New ID primary key column
    id                      NUMBER(19) NOT NULL,
    
    -- Composite key fields (now regular columns)
    hlab_num               VARCHAR2(7) NOT NULL,
    fmc_number             VARCHAR2(8),
    internal_external_flag VARCHAR2(1),
    printer_name           VARCHAR2(60) NOT NULL,
    ip_address             VARCHAR2(15) NOT NULL,
    printer_type           VARCHAR2(40) NOT NULL,
    
    -- Additional entity fields
    
    
    
    -- Constraints
    CONSTRAINT pk_korus_printer PRIMARY KEY (id)
    --CONSTRAINT uk_korus_printer_composite UNIQUE (hlab_num, printer_name, ip_address, printer_type),
    --CONSTRAINT chk_internal_external_flag CHECK (internal_external_flag IN ('I', 'E'))
);

CREATE SEQUENCE cm_owner.seq_korus_printer_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


select * from korus_printer;

select p.* from korus_printer z
join clinic c ON c.hlabnumber = z.hlab_num
join clinic_printer p ON p.clinicid = c.id and p.printername = z.printer_name
where printer_type in ('Zebra','Laser');

select * from clinic_status;

select * from printer_type;

select * from clinic_printer
where printertypeid IN (1,2);

/
delete korus_printer
where hlab_num IN
(select hlab_num from
    (select decode(servicelabid,1,'SPECTRA-EAST',2,'SPECTRA-SOUTH',3,'SPECTRA-WEST') servicelab,c.id,kp.hlab_num,kp.fmc_number,
    kp.printer_name,kp.ip_address,decode(kp.printer_type,'Zebra',2,'Laser',1) printer_type,
    case statusid 
        when 1 then 'Active' 
        when 4 then 'In progress'
        when 6 then 'Under Constr' 
        when 10 then 'Validation'
        else 'NONE' 
        end status 
    from clinic c
    join clinic_detail cd ON cd.clinic_id = c.id
    join korus_printer kp ON kp.hlab_num = c.hlabnumber
    
    where statusid IN (1,4,6,10)
    --and kp.hlab_num = 'A100757'
    and servicelabid = 1));
    
    
    select decode(servicelabid,1,'SPECTRA-EAST',2,'SPECTRA-SOUTH',3,'SPECTRA-WEST') servicelab,c.id,kp.hlab_num,kp.fmc_number,
    kp.printer_name,kp.ip_address,decode(kp.printer_type,'Zebra',2,'Laser',1) printer_type,
    case statusid 
        when 1 then 'Active' 
        when 4 then 'In progress'
        when 6 then 'Under Constr' 
        when 10 then 'Validation'
        else 'NONE' 
        end status 
    from clinic c
    join clinic_detail cd ON cd.clinic_id = c.id
    join korus_printer kp ON kp.hlab_num = c.hlabnumber
    
    where statusid IN (1,4,6,10)
    --and kp.hlab_num = 'A100757'
    and servicelabid = 1;
    --and kp.printer_type = 'Laser'
    order by statusid desc;
/

delete korus_printer

select printer_type from korus_printer
group by printer_type;

delete korus_printer;

select SEQ_KORUS_PRINTER_ID.nextval from dual;


SELECT count(*) FROM cm_owner.korus_printer;
-- Should show increasing numbers as inserts happen

@Id
    @Column(name = "HLAB_NUM", length = 7, nullable = false)
    private String hlabNum;

    @Column(name = "FMC_NUMBER", length = 8)
    private String fmcNumber;

    @Column(name = "INTERNAL_EXTERNAL_FLAG", length = 1)
    private String internalExternalFlag;

    @Column(name = "PRINTER_NAME", length = 60)
    private String printerName;

    @Column(name = "IP_ADDRESS", length = 15)
    private String ipAddress;

    @Column(name = "PRINTER_TYPE", length = 40)
    private String printerType;

select * from clinic
where hlabnumber = 'A100479';