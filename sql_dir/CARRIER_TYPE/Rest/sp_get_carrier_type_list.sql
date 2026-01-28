BEGIN
ords.enable_object(
p_enabled => TRUE,
p_schema => 'CM_OWNER',
p_object => 'SP_FETCH_COMMENT_LINES',
p_object_type => 'PROCEDURE',
p_object_alias => 'sp_fetch_comment_lines',
p_auto_rest_auth => FALSE);
commit;
END;
/

GRANT execute  ON SP_FETCH_COMMENT_LINES TO CM_USER;

/
----------------
DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;
BEGIN
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.CM_OWNER.SP_FETCH_COMMENT_LINES';
  l_roles(3) := 'CM REST Role';
    l_patterns(1) := '/sp_fetch_comment_lines/*';
  l_patterns(2) := '/metadata-catalog/sp_fetch_comment_lines/*';
  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.CM_OWNER.SP_FETCH_COMMENT_LINES',
      p_roles           => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label           => '',
      p_description    => '',
      p_comments       => NULL);
  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
  
  
  COMMIT;
END;

/

 

--update dbtdxt set dxstrtdt ='01-OCT-20' where DXICD9 ='S6431XA' and DXSTRTDT='01-MAY-21' and DXENDDT='02-MAY-21'

 

