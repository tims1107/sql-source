create or replace procedure sp_post_carrier_type
(
  p_name IN carrier_type.name%type,
  p_addressline1 IN carrier_type.addressline1%type,
  p_addressline2 IN carrier_type.addressline2%type,
  p_city IN carrier_type.city%type,
  p_state IN carrier_type.state%type,
  p_country IN carrier_type.country%type,
  p_zip IN carrier_type.zip%type,
  p_contactname IN carrier_type.contactname%type,
  p_primaryphone IN carrier_type.primaryphone%type,
  p_secondaryphone IN carrier_type.secondaryphone%type,
  p_faxnumber IN carrier_type.faxnumber%type,
  p_username IN CLINIC.EMAIL%type,
  carriertypeid OUT carrier_type.carriertypeid%type
)
as

v_seqno number := 0;

begin


  
  v_seqno := carrier_type$seq.nextval;
  
  insert into carrier_type (CARRIERTYPEID,NAME,ADDRESSLINE1,ADDRESSLINE2,CITY,STATE,COUNTRY,ZIP,CONTACTNAME,PRIMARYPHONE,SECONDARYPHONE,FAXNUMBER)
  values
  (v_seqno,p_name,p_ADDRESSLINE1,p_ADDRESSLINE2,p_CITY,p_STATE,p_COUNTRY,p_ZIP,p_CONTACTNAME,p_PRIMARYPHONE,p_SECONDARYPHONE,p_FAXNUMBER);
  
  commit;

  carriertypeid := v_seqno;
  
EXCEPTION
WHEN OTHERS THEN carriertypeid := 0;


end;