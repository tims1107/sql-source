SELECT SEQUENCE_NAME FROM USER_SEQUENCES WHERE SEQUENCE_NAME = 'HL7_MESSAGE_SEQ';

select hl7_message_seq.nextval from dual;

select * from hl7_message
order by creation_date;
