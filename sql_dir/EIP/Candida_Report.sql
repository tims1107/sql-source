select p.requisition_id
    ,patient_last_name
    ,patient_first_name
    ,patient_account_address1 address
    ,patient_account_city
    ,patient_account_state
    ,patient_account_zip zipcode
    ,county
    ,last_updated_date final
    ,micro_organism_name organism
from micro_20240620_30 m
join pat_micro_results p ON p.requisition_id = m.requisition_id
where patient_account_state = 'NM'
and regexp_like(micro_organism_name,'candida','i');