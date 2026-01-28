select MDM_OWNER.ala_test.testcode
,MDM_OWNER.ala_testrequired.* 
from MDM_OWNER.ala_test,MDM_OWNER.ala_testrequired 
where MDM_OWNER.ala_test.testid=MDM_OWNER.ala_testrequired.testid and MDM_OWNER.ala_test.status='active' 
order by testreqid