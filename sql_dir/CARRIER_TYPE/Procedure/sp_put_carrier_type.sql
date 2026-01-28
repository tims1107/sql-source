create or replace procedure sp_put_carrier_type
(
  p_carriertypeid IN carrier_type.carriertypeid%type,
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
  updatecount OUT carrier_type.carriertypeid%type
)
as



begin
  
  update carrier_type 
  set name = p_name
  ,addressline1 = p_ADDRESSLINE1
  ,addressline2 = p_ADDRESSLINE2
  ,city = p_CITY
  ,state = p_STATE
  ,country = p_COUNTRY
  ,zip = p_ZIP
  ,contactname = p_CONTACTNAME
  ,primaryphone = p_PRIMARYPHONE
  ,secondaryphone = p_SECONDARYPHONE
  ,faxnumber = p_FAXNUMBER
  Where carriertypeid = p_carriertypeid;
  
  updatecount := SQL%Rowcount;
  
  commit;

  
  
EXCEPTION
WHEN OTHERS THEN updatecount := 0;


end;