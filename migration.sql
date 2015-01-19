CREATE DATABASE  IF NOT EXISTS `migration` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;
USE `migration`;
-- MySQL dump 10.13  Distrib 5.6.17, for Win64 (x86_64)
--
-- Host: localhost    Database: migration
-- ------------------------------------------------------
-- Server version	5.6.21-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'migration'
--
/*!50003 DROP FUNCTION IF EXISTS `getSprints` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getSprints`(fullstr varchar(255)) RETURNS varchar(255) CHARSET utf8 COLLATE utf8_bin
BEGIN
 DECLARE cnt, sprints INT Default 0 ;
      DECLARE str, retvalue, newSprints VARCHAR(255);
      IF (fullstr is null) THEN
         RETURN fullstr;
	  END IF;
      IF (length(trim(fullstr)) = 0)THEN
		RETURN fullstr;
      END IF;
      SET retvalue='';
      simple_loop: LOOP
         SET cnt = cnt+1;
         SET str=SPLIT_STR(fullstr,",",cnt);
         IF str='' THEN
            LEAVE simple_loop;
         END IF;
         Select CAST(str AS SIGNED INT) + 1000 INTO sprints;
         
         SELECT concat(retvalue, cast(sprints AS Char),', ') into retvalue;
         
   END LOOP simple_loop;
   SELECT TRIM(TRAILING ', ' FROM retvalue) into newSprints;
RETURN newSprints;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `SPLIT_STR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT_STR`(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
) RETURNS varchar(255) CHARSET utf8 COLLATE utf8_bin
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '') ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisNodeAssociationProc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisNodeAssociationProc`()
BEGIN
DECLARE v_id, v_issuenum, newId, new_prj_id, ROWCNT, l_last_row_fetched, v_cnt, v_project INT DEFAULT 0;
DECLARE v_description text;
DECLARE v_summary,  v_vname, v_name, v_pname, v_cname, v_lead VARCHAR(255);
DECLARE LOOPCNT INT DEFAULT 1;

DECLARE c_ji_id CURSOR FOR SELECT h.id, h.project, h.summary, h.issuenum from source.jiraissue h order by h.id desc;
DECLARE c_pv_id CURSOR FOR SELECT h.id, h.vname, h.project from source.projectversion h order by h.id desc;
DECLARE c_prj_id CURSOR FOR SELECT h.id, h.pname from source.project h order by h.id desc;
DECLARE c_comp_id CURSOR FOR SELECT h.id, h.project, h.cname from source.component h order by h.id desc;
DECLARE c_wfs_id CURSOR FOR SELECT h.id, h.name FROM source.workflowscheme  h order by h.id desc;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.jiraissue;

OPEN c_ji_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_ji_id INTO v_id, v_project, v_summary, v_issuenum;
select m.id into newId from target.jiraissue m where m.summary = v_summary and m.project = v_project and m.issuenum = v_issuenum;


 UPDATE source.nodeassociation h set h.source_node_id = newId where h.source_node_entity = 'Issue' and h.source_node_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_ji_id; 


set LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.projectversion;

OPEN c_pv_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_pv_id INTO v_id, v_vname, v_project;
select m.id into newId from target.projectversion m where m.vname = v_vname and m.project = v_project;
UPDATE source.nodeassociation h set h.sink_node_id = newId where h.sink_node_entity = 'Version' and h.sink_node_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_pv_id; 


set LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.project;

OPEN c_prj_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_prj_id INTO v_id, v_pname;
select m.id into newId from target.project m where m.pname = v_pname;
UPDATE source.nodeassociation h set h.source_node_id = newId where h.source_node_entity = 'Project' and h.source_node_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_prj_id; 


set LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.workflowscheme;

OPEN c_wfs_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_wfs_id INTO v_id, v_name;
select m.id into newId from target.workflowscheme m where m.name = v_name;
UPDATE source.nodeassociation h set h.sink_node_id = newId where h.sink_node_entity = 'WorkflowScheme' and h.sink_node_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_wfs_id;


set LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.component;

OPEN c_comp_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_comp_id INTO v_id, v_project, v_cname;
select m.id into new_prj_id from source.project h, target.project m where m.pname = h.pname and m.pkey =h.pkey and h.id=v_project;
select m.id into newId from target.component m where m.project = new_prj_id and m.cname = v_cname;

UPDATE source.nodeassociation h set h.sink_node_id = newId where h.sink_node_entity = 'Component' and h.sink_node_id = v_id;

SET newId = 99999;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_comp_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisPopulateChangeGroupItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisPopulateChangeGroupItem`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_source_node_id,  v_sink_node_id, v_sequence, v_id, v_issueid, newId, v_groupid, temp_id_1, temp_id_2  INT DEFAULT 0;
DECLARE v_source_node_entity,v_sink_node_entity,v_association_type,v_author, v_fieldtype, v_field  VARCHAR(255);
DECLARE v_created datetime;
DECLARE v_oldvalue, v_oldstring, v_newvalue, v_newstring longtext;

DECLARE c_id CURSOR FOR SELECT h.source_node_id, h.source_node_entity, h.sink_node_id, h.sink_node_entity, h.association_type, h.sequence  FROM source.nodeassociation h;
DECLARE c_cg_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.created FROM source.changegroup h order by h.id;
DECLARE c_ci_id CURSOR FOR SELECT h.id, h.groupid, h.fieldtype, h.field, h.oldvalue, h.oldstring, h.newvalue, h.newstring FROM source.changeitem h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;



SELECT max(id) INTO temp_id_1 from source.changegroup ;
SELECT max(id) INTO temp_id_2 from target.changegroup ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.changegroup;
OPEN c_cg_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_cg_id INTO v_id, v_issueid, v_author, v_created;

SET newId = newId + INC;
INSERT INTO target.changegroup (id, issueid, author, created)
VALUES (newId, v_issueid, v_author, v_created);

UPDATE source.changeitem h SET h.groupid = newId where h.groupid = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_cg_id; 



SELECT max(id) INTO temp_id_1 from source.changeitem ;
SELECT max(id) INTO temp_id_2 from target.changeitem ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.changeitem;
OPEN c_ci_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_ci_id INTO v_id, v_groupid, v_fieldtype, v_field, v_oldvalue, v_oldstring, v_newvalue, v_newstring;

SET newId = newId + INC;
INSERT INTO target.changeitem (id, groupid, fieldtype, field, oldvalue, oldstring, newvalue, newstring)
VALUES (newId, v_groupid, v_fieldtype, v_field, v_oldvalue, v_oldstring, v_newvalue, v_newstring);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_ci_id; 



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisPopulatePortalPage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisPopulatePortalPage`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id, v_sequence, v_fav_count, existing_id,  newId, v_ppversion, v_column_number, v_portalpage, v_positionseq, temp_id_1, temp_id_2, rec_exists INT DEFAULT 0;
DECLARE v_gadget_xml text;
DECLARE v_username, v_pagename, v_description, v_layout, v_color, v_portlet_id VARCHAR(255);

DECLARE c_id CURSOR FOR SELECT h.id, h.username,h.pagename, h.description, h.sequence, h.fav_count, h.layout, h.ppversion FROM source.portalpage h;
DECLARE c_pc_id CURSOR FOR SELECT h.id, h.portalpage, h.portlet_id, h.column_number, h.positionseq, h.gadget_xml, h.color FROM source.portletconfiguration h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.portalpage;
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id,  v_username,v_pagename, v_description, v_sequence, v_fav_count, v_layout, v_ppversion;


SELECT m.id into existing_id FROM target.portalpage m where m.username = v_username and m.pagename = v_pagename;
update source.favouriteassociations h set h.entityid= existing_id where h.entitytype='PortalPage' and h.entityid = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisPopulateProject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisPopulateProject`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, temp_id_1, temp_id_2, V_AVATAR, V_PCOUNTER, V_ASSIGNEETYPE, V_SEQUENCE, v_id, new_prj_id, new_prj_key_id, new_prj_ver_id, newAvatarId, V_PROJECT_ID INT DEFAULT 0;
DECLARE V_PNAME, V_VNAME, V_URL, V_LEAD, V_PKEY, V_ORIGINALKEY VARCHAR(255);
DECLARE V_DESCRIPTION  text;
DECLARE V_RELEASED, V_ARCHIVED VARCHAR(10);
DECLARE V_STARTDATE, V_RELEASEDATE DATETIME;
DECLARE c_id CURSOR FOR SELECT h.id, h.PNAME, h.URL, h.lead, h.DESCRIPTION, h.PKEY, h.PCOUNTER, h.ASSIGNEETYPE, h.AVATAR, h.ORIGINALKEY  FROM source.project h;
DECLARE c_pk_id CURSOR FOR SELECT  h.project_key FROM source.project_key h;
DECLARE c_pv_id CURSOR FOR SELECT  h.project, h.vname, h.description, h.sequence, h.released, h.archived, h.url, h.startdate, h.releasedate FROM source.projectversion h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.project;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_PNAME, V_URL, V_LEAD, V_DESCRIPTION, V_PKEY, V_PCOUNTER, V_ASSIGNEETYPE, V_AVATAR, V_ORIGINALKEY;



select  m.id into new_prj_id from target.project m where m.pname = V_PNAME;

update source.sharepermissions h set h.param1= new_prj_id where h.sharetype='project' and h.param1 = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThispopulateProjectRoleActor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThispopulateProjectRoleActor`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, V_AVATAR, V_PCOUNTER, V_ASSIGNEETYPE, V_SEQUENCE, v_id, new_prj_id, new_prj_key_id, new_prj_ver_id, newAvatarId, V_PROJECT_ID INT DEFAULT 0;
DECLARE V_PNAME, V_VNAME, V_URL, V_LEAD, V_PKEY, V_ORIGINALKEY VARCHAR(255);
DECLARE V_DESCRIPTION  text;
DECLARE V_RELEASED, V_ARCHIVED VARCHAR(10);
DECLARE V_STARTDATE, V_RELEASEDATE DATETIME;
DECLARE c_id CURSOR FOR SELECT h.id FROM source.project h;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.project;



OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id;

SELECT new.id into new_prj_id FROM target.project new, source.project old WHERE  old.pname = new.pname and old.pkey = new.pkey and 
old.id = v_id;

UPDATE source.projectroleactor h set h.pid = new_prj_id where h.pid = v_id;
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisPopulateSearchRequest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisPopulateSearchRequest`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, V_PROJECTID, new_sr_id, V_FAV_COUNT, v_id INT DEFAULT 0;
DECLARE V_FILTERNAME, V_AUTHORNAME, V_USERNAME, V_GROUPNAME,  V_FILTERNAME_LOWER VARCHAR(255);
DECLARE V_DESCRIPTION text;
DECLARE V_REQCONTENT longtext;
DECLARE c_id CURSOR FOR SELECT h.id, h.FILTERNAME, h.AUTHORNAME, h.DESCRIPTION, h.USERNAME, h.GROUPNAME, h.PROJECTID, h.REQCONTENT, h.FAV_COUNT, h.FILTERNAME_LOWER  
FROM source.searchrequest h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.searchrequest;


OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_FILTERNAME, V_AUTHORNAME, V_DESCRIPTION, V_USERNAME, V_GROUPNAME, V_PROJECTID, V_REQCONTENT, V_FAV_COUNT, V_FILTERNAME_LOWER;

SELECT m.id into new_sr_id FROM target.searchrequest m where  m.filtername = V_FILTERNAME and m.authorname = V_AUTHORNAME;

update source.favouriteassociations h set h.entityid= new_sr_id where h.entitytype='SearchRequest' and h.entityid = v_id;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThispopulateUserGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThispopulateUserGroup`()
BEGIN
DECLARE new_prj_id,  newId,  ROWCNT, l_last_row_fetched,  v_id, v_property_int_value, existing_id, v_entity_id, v_property_type, v_directory_id, v_active, v_deleted_externally, rec_exists, v_parent_id, v_child_id, v_local, temp_id_1, temp_id_2 INT DEFAULT 0;

DECLARE v_user_name, v_lower_user_name, v_first_name, v_lower_first_name, v_last_name, v_lower_last_name, v_user_key, v_property_key, v_entity_name,
v_display_name, v_lower_display_name, v_email_address, v_lower_email_address, v_credential, v_external_id, v_group_name, v_lower_group_name, 
v_description, v_lower_description, v_group_type, v_membership_type,  v_parent_name, v_lower_parent_name, v_child_name, v_lower_child_name  VARCHAR(255);

DECLARE v_property_string_value text;
DECLARE v_property_text_value longtext;
DECLARE v_created_date, v_updated_date datetime;
DECLARE LOOPCNT, INC INT DEFAULT 1;

DECLARE c_id CURSOR FOR SELECT s.id, s.directory_id, s.user_name, s.lower_user_name, s.active, s.created_date, s.updated_date, s.first_name, 
s.lower_first_name, s.last_name, s.lower_last_name, s.display_name, s.lower_display_name, s.email_address, s.lower_email_address, 
s.credential, s.deleted_externally, s.external_id FROM source.cwd_user s  where directory_id=1 and lower_user_name !='jira-admin-contractor' order by s.id;

DECLARE c_user_group CURSOR FOR SELECT s.id, s.group_name, s.lower_group_name, s.active, s.`local`, s.created_date, 
s.updated_date, s.description, s.lower_description, s.group_type, s.directory_id from source.cwd_group s where s.directory_id = 1 
and s.lower_group_name not in (select lower_group_name from target.cwd_group) order by s.id;

DECLARE c_cwd_membership CURSOR FOR SELECT s.id, s.parent_id, s.child_id, s.membership_type, s.group_type, s.parent_name, s.lower_parent_name, 
s.child_name, s.lower_child_name, s.directory_id FROM source.cwd_membership s where s.directory_id = 1 and s.lower_child_name !='jira-admin-contractor' order by s.id;

DECLARE c_app_user CURSOR FOR SELECT  lower_user_name FROM  target.cwd_user
WHERE  directory_id = 1 and lower_user_name NOT IN (SELECT lower_user_name  FROM   target.app_user);

DECLARE c_all_app_users CURSOR FOR SELECT id, user_key, lower_user_name from source.app_user ;


DECLARE c_all_pe_application_users CURSOR FOR SELECT id, entity_name, entity_id, property_key, propertytype FROM  source.propertyentry 
where entity_name='ApplicationUser'; 

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- APP_USER of all users only

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM  source.app_user ;


SELECT max(id) INTO temp_id_1 from source.app_user ;
SELECT max(id) INTO temp_id_2 from target.app_user ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;


OPEN c_all_app_users;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_all_app_users INTO v_id, v_user_key, v_lower_user_name;
SET rec_exists = 0;
SELECT count(*) INTO rec_exists FROM target.app_user  where user_key = v_user_key or lower_user_name = v_lower_user_name ;

IF (rec_exists=0) THEN
BEGIN
	SET newId = newId + INC ;
	INSERT INTO target.app_user (id, user_key, lower_user_name) 
	values (newId,  v_user_key, v_lower_user_name);
	UPDATE `target`.propertyentry SET entity_id = newId where entity_name ='ApplicationUser' and entity_id = v_id;
    insert into company.tableinfo(table_name, ov, nov, nv, nnv) values('Insert',v_id, newId, v_user_key, v_lower_user_name);
END;
ELSE
BEGIN
	SELECT id INTO existing_id FROM target.app_user  where user_key = v_user_key and lower_user_name = v_lower_user_name ;
	UPDATE `target`.propertyentry SET entity_id = existing_id where entity_name ='ApplicationUser' and entity_id = v_id;
    insert into company.tableinfo(table_name, ov, nov, nv, nnv) values('Update',v_id, existing_id, v_user_key, v_lower_user_name);
END;
END IF;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_all_app_users; 



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `dontUseThisUpdateJiraIssues` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `dontUseThisUpdateJiraIssues`()
BEGIN





DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, new_osw_id, new_oscs_id, new_oshs_id, v_id, v_initialized, v_state, v_entry_id, v_step_id, v_action_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_pkey, v_name, v_owner, v_status, v_caller varchar(255);
DECLARE v_start_date, v_due_date, v_finish_date datetime;

DECLARE c_osw_id CURSOR FOR SELECT h.id, h.name, h.initialized, h.state FROM source.os_wfentry h;
DECLARE c_oscs_id CURSOR FOR SELECT h.id, h.entry_id, h.step_id, h.action_id, h.owner, h.start_date, h.due_date, h.finish_date, h.status, h.caller FROM source.os_currentstep h;
DECLARE c_oshs_id CURSOR FOR SELECT h.id, h.entry_id, h.step_id, h.action_id, h.owner, h.start_date, h.due_date, h.finish_date, h.status, h.caller FROM source.os_historystep h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;



UPDATE source.JiraIssue h SET h.resolution = 10000 where h.resolution = 6;
UPDATE source.changeitem h set h.oldvalue = 10000 where h.field in ('resolution') and h.oldvalue=  6;
UPDATE source.changeitem h set h.newvalue = 10000 where h.field in ('resolution') and h.newvalue=  6;





SELECT  COUNT(*) INTO ROWCNT FROM source.os_wfentry;

SELECT max(id) INTO temp_id_1 from source.os_wfentry ;
SELECT max(id) INTO temp_id_2 from target.os_wfentry ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_osw_id = temp_id_1;
else	
	SET new_osw_id = temp_id_2;
END IF;

SET LOOPCNT = 1;

OPEN c_osw_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_osw_id INTO v_id, v_name, v_initialized, v_state;
SET new_osw_id = new_osw_id + INC ;
INSERT INTO target.os_wfentry (id, name, initialized, state) VALUES (new_osw_id,v_name, v_initialized, v_state);

UPDATE source.JiraIssue h SET h.workflow_id = new_osw_id where h.workflow_id = v_id;
UPDATE source.os_currentstep h SET h.entry_id = new_osw_id where h.entry_id = v_id;
UPDATE source.os_historystep h SET h.entry_id = new_osw_id where h.entry_id = v_id;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_osw_id; 




SELECT  COUNT(*) INTO ROWCNT FROM source.os_currentstep;

SELECT max(id) INTO temp_id_1 from source.os_currentstep ;
SELECT max(id) INTO temp_id_2 from target.os_currentstep ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_oscs_id = temp_id_1;
else	
	SET new_oscs_id = temp_id_2;
END IF;

SET LOOPCNT = 1;

OPEN c_oscs_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_oscs_id INTO v_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller;
SET new_oscs_id = new_oscs_id + INC ;
INSERT INTO target.os_currentstep (id, entry_id, step_id, action_id, owner, start_date, due_date, finish_date, status, caller) 
VALUES (new_oscs_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_oscs_id; 





SELECT  COUNT(*) INTO ROWCNT FROM source.os_historystep;

SELECT max(id) INTO temp_id_1 from source.os_historystep ;
SELECT max(id) INTO temp_id_2 from target.os_historystep ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_oshs_id = temp_id_1;
else	
	SET new_oshs_id = temp_id_2;
END IF;
SET LOOPCNT = 1;

OPEN c_oshs_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_oshs_id INTO v_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller;
SET new_oshs_id = new_oshs_id + INC ;
INSERT INTO target.os_historystep (id, entry_id, step_id, action_id, owner, start_date, due_date, finish_date, status, caller) 
VALUES (new_oshs_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_oshs_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSprts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getSprts`(fullstr varchar(255))
BEGIN
      DECLARE a, sprints INT Default 0 ;
      DECLARE str, retvalue VARCHAR(255);
      SET retvalue='';
      simple_loop: LOOP
		 
         SET a=a+1;
         SET str=SPLIT_STR(fullstr,",",a);
         IF str='' THEN
            LEAVE simple_loop;
         END IF;
         Select CAST(str AS SIGNED INT) + 1000 INTO sprints;
         select concat('   value of sprints..',sprints);
         SELECT concat(retvalue, cast(sprints AS Char),', ') into retvalue;
         select concat('--', retvalue) ;
         #Do Inserts into temp table here with str going into the row
         
   END LOOP simple_loop;
   insert into company.tableinfo(table_name) values (retvalue);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateActiveObjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateActiveObjects`()
BEGIN
DECLARE oldId, wd_id, newId  INT DEFAULT 0;
DECLARE LOOPCNT INT DEFAULT 1;
DECLARE ROWCNT INT DEFAULT 0;
DECLARE l_last_row_fetched INT DEFAULT 0;
DECLARE c_id CURSOR FOR SELECT h.id FROM source.AO_60DB71_RAPIDVIEW h  order by h.id;
DECLARE c_sprint CURSOR FOR SELECT h.id FROM source.AO_60DB71_SPRINT h  order by h.id;
DECLARE c_working_days CURSOR FOR SELECT h.id FROM source.AO_60DB71_WORKINGDAYS h  order by h.id;
DECLARE c_column CURSOR FOR SELECT h.id FROM source.AO_60DB71_COLUMN h  order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;
SET foreign_key_checks = 0;
SELECT COUNT(*) INTO ROWCNT FROM source.AO_60DB71_RAPIDVIEW;
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO oldId;

	SET newId = 0;
	INSERT into target.AO_60DB71_RAPIDVIEW (CARD_COLOR_STRATEGY, `NAME`, OWNER_USER_NAME, SAVED_FILTER_ID, SHOW_DAYS_IN_COLUMN, SPRINTS_ENABLED, SPRINT_MARKERS_MIGRATED, 
    SWIMLANE_STRATEGY) SELECT h.CARD_COLOR_STRATEGY, h.`NAME`, h.OWNER_USER_NAME, h.SAVED_FILTER_ID, h.SHOW_DAYS_IN_COLUMN, h.SPRINTS_ENABLED, h.SPRINT_MARKERS_MIGRATED, 
    h.SWIMLANE_STRATEGY  FROM source.AO_60DB71_RAPIDVIEW h WHERE h.id = oldId;
	
	SELECT LAST_INSERT_ID() INTO newId;
	UPDATE source.AO_60DB71_SPRINT h SET h.RAPID_VIEW_ID = newId where h.rapid_view_id = oldId;
	UPDATE source.AO_60DB71_COLUMN h SET h.RAPID_VIEW_ID = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_CARDCOLOR h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
	UPDATE source.AO_60DB71_CARDLAYOUT h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_BOARDADMINS h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_DETAILVIEWFIELD h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_ESTIMATESTATISTIC h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_TRACKINGSTATISTIC h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_STATSFIELD h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_SUBQUERY h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_SWIMLANE h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_WORKINGDAYS h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.AO_60DB71_QUICKFILTER h SET h.rapid_view_id = newId where h.rapid_view_id = oldId;
    UPDATE source.userhistoryitem h SET h.entityid = newId where h.entitytype ='RapidView' and h.entityid = oldId;
    UPDATE source.gadgetuserpreference h SET h.userprefvalue = newId where h.userprefkey='rapidViewId' and h.userprefvalue = oldId;
    
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id;



SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.AO_60DB71_WORKINGDAYS;

OPEN c_working_days;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_working_days INTO oldId;


	INSERT into target.AO_60DB71_WORKINGDAYS (FRIDAY, MONDAY, RAPID_VIEW_ID, SATURDAY, SUNDAY, THURSDAY, TIMEZONE, TUESDAY, WEDNESDAY) 
      SELECT FRIDAY, MONDAY, RAPID_VIEW_ID, SATURDAY, SUNDAY, THURSDAY, TIMEZONE, TUESDAY, WEDNESDAY FROM source.AO_60DB71_WORKINGDAYS where id = oldId;
	
    SELECT LAST_INSERT_ID() INTO newId;
    UPDATE source.AO_60DB71_NONWORKINGDAY h SET h.working_days_id = newId where h.working_days_id = oldId;
		
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_working_days;



SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.AO_60DB71_COLUMN;

OPEN c_column;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_column INTO oldId;

	INSERT into target.AO_60DB71_COLUMN(MAXIM, MINIM, NAME, POS,RAPID_VIEW_ID)  
    SELECT MAXIM, MINIM, NAME, POS, RAPID_VIEW_ID  FROM source.AO_60DB71_COLUMN h where id = oldId;
	select LAST_INSERT_ID() into newId;
    
    UPDATE source.ao_60db71_columnstatus h SET h.column_id = newId where h.column_id = oldId;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_column;



SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.AO_60DB71_SPRINT;

OPEN c_sprint;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_sprint INTO oldId;
	SET newId = oldId + 1000;
	INSERT into target.AO_60DB71_SPRINT (CLOSED, COMPLETE_DATE, END_DATE, id, `NAME`, RAPID_VIEW_ID, SEQUENCE, STARTED, START_DATE )
	SELECT h.CLOSED, h.COMPLETE_DATE, h.END_DATE, newId, h.`NAME`, h.RAPID_VIEW_ID, h.SEQUENCE, h.STARTED, h.START_DATE  FROM source.AO_60DB71_SPRINT h 
	WHERE h.id = oldId;
	
    
	UPDATE source.ao_60db71_auditentry h SET entity_id = newId  where entity_class = 'SPRINT' and h.entity_id = oldId;
	UPDATE source.userhistoryitem h SET h.entityid =  newId where h.entitytype ='Sprint' and h.entityid = oldId;
    UPDATE source.customfieldvalue set stringvalue = newId where customfield=10005 and stringvalue = oldId;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;

CLOSE c_sprint;


	INSERT INTO target.ao_60db71_columnstatus (column_id, pos, status_id) select h.column_id, h.pos, h.status_id FROM source.ao_60db71_columnstatus h;


	INSERT into target.AO_60DB71_CARDCOLOR(COLOR, POS, RAPID_VIEW_ID, STRATEGY, VAL) SELECT COLOR, POS, RAPID_VIEW_ID, STRATEGY, VAL FROM source.AO_60DB71_CARDCOLOR;
    

	INSERT into target.AO_60DB71_CARDLAYOUT(FIELD_ID, MODE_NAME, POS,RAPID_VIEW_ID)  SELECT FIELD_ID, MODE_NAME, POS, RAPID_VIEW_ID FROM source.AO_60DB71_CARDLAYOUT;


	INSERT into target.AO_60DB71_BOARDADMINS(`KEY`, `RAPID_VIEW_ID`, `TYPE`) SELECT `KEY`, `RAPID_VIEW_ID`, `TYPE` FROM source.AO_60DB71_BOARDADMINS;
    

	INSERT into target.AO_60DB71_DETAILVIEWFIELD(FIELD_ID, POS, RAPID_VIEW_ID) SELECT FIELD_ID, POS, RAPID_VIEW_ID FROM source.AO_60DB71_DETAILVIEWFIELD;


	INSERT into target.AO_60DB71_ESTIMATESTATISTIC(FIELD_ID, RAPID_VIEW_ID, TYPE_ID ) SELECT FIELD_ID, RAPID_VIEW_ID, TYPE_ID FROM source.AO_60DB71_ESTIMATESTATISTIC;


	INSERT into target.AO_60DB71_TRACKINGSTATISTIC (FIELD_ID, RAPID_VIEW_ID, TYPE_ID) SELECT FIELD_ID, RAPID_VIEW_ID, TYPE_ID FROM source.AO_60DB71_TRACKINGSTATISTIC;


	INSERT into target.AO_60DB71_STATSFIELD (RAPID_VIEW_ID, TYPE_ID) SELECT RAPID_VIEW_ID, TYPE_ID FROM source.AO_60DB71_STATSFIELD;
    

    INSERT into target.AO_60DB71_SUBQUERY (`QUERY`, RAPID_VIEW_ID, `SECTION`) SELECT `QUERY`, RAPID_VIEW_ID, `SECTION` FROM source.AO_60DB71_SUBQUERY;


	INSERT into target.AO_60DB71_SWIMLANE (DEFAULT_LANE, DESCRIPTION, NAME, POS, `QUERY`, RAPID_VIEW_ID) SELECT DEFAULT_LANE, DESCRIPTION, NAME, POS, `QUERY`, RAPID_VIEW_ID FROM source.AO_60DB71_SWIMLANE;


	INSERT INTO target.AO_21d670_whitelist_rules(allowinbound, expression, type) SELECT allowinbound, expression, `type` FROM source.AO_21d670_whitelist_rules;


	INSERT INTO target.ao_b9a0f0_applied_template(project_id, project_template_module_key, project_template_web_item_key) SELECT project_id, project_template_module_key, project_template_web_item_key FROM source.ao_b9a0f0_applied_template;    


	INSERT into target.AO_60DB71_NONWORKINGDAY (ISO8601_DATE, WORKING_DAYS_ID) SELECT ISO8601_DATE, WORKING_DAYS_ID FROM source.AO_60DB71_NONWORKINGDAY;    


	INSERT into target.AO_60DB71_QUICKFILTER (description, `name`, pos, `query`, rapid_view_id) SELECT description, `name`, pos, `query`, rapid_view_id FROM source.AO_60DB71_QUICKFILTER;  
    

	INSERT into target.AO_60DB71_AUDITENTRY (category, `data`, entity_class, entity_id, `time`, user) SELECT category, `data`, entity_class, entity_id, `time`, user FROM source.AO_60DB71_AUDITENTRY;  


	
   

	

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateAvatar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateAvatar`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, new_avatar_id, v_id, existing_id, V_SYSTEMAVATAR,temp_id_1, temp_id_2, new_issue_type_id INT DEFAULT 0;
DECLARE V_FILENAME, V_CONTENTTYPE, V_AVATARTYPE, V_OWNER, v_pname VARCHAR(255);
DECLARE c_id CURSOR FOR SELECT h.id, h.FILENAME, h.CONTENTTYPE, h.AVATARTYPE, h.OWNER, h.SYSTEMAVATAR  FROM `source`.avatar h;
DECLARE c_it_id CURSOR FOR SELECT h.id, h.pname FROM source.issuetype h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.avatar;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_FILENAME, V_CONTENTTYPE, V_AVATARTYPE, V_OWNER, V_SYSTEMAVATAR;

SET REC_EXISTS = 0;
SELECT 1 INTO REC_EXISTS FROM target.avatar m where m.filename = V_FILENAME and m.avatartype = V_AVATARTYPE and m.systemavatar=1;
IF (REC_EXISTS = 0) then
BEGIN
-- SET new_avatar_id = new_avatar_id + INC ;
SET new_avatar_id = v_id + 100000 ;
Insert into target.avatar (ID, FILENAME, CONTENTTYPE, AVATARTYPE, OWNER, SYSTEMAVATAR) VALUES ( new_avatar_id, V_FILENAME, V_CONTENTTYPE, V_AVATARTYPE, V_OWNER, V_SYSTEMAVATAR);
update source.project h set h.avatar = new_avatar_id where h.avatar = v_id;
END;
ELSE 
SELECT id into existing_id FROM target.avatar m where m.filename = V_FILENAME and m.avatartype = V_AVATARTYPE;
update source.project h set h.avatar = existing_id where h.avatar = v_id;

END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.issuetype;

OPEN c_it_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_it_id INTO v_id, v_pname;

SET new_issue_type_id = 0;
select m.id into new_issue_type_id from target.issuetype m where m.pname = v_pname;
IF (new_issue_type_id > 0) THEN
	UPDATE source.JiraIssue h SET h.issuetype = new_issue_type_id where h.issuetype = v_id;
	UPDATE source.fieldconfigschemeissuetype h SET h.issuetype = new_issue_type_id where h.issuetype = v_id;
	UPDATE source.ao_60db71_cardcolor h SET h.val = new_issue_type_id where h.strategy ='issuetype' and h.val = v_id;
	UPDATE source.changeitem h SET h.oldvalue = new_issue_type_id where h.field in ('issuetype') and h.oldvalue=  v_id;
	UPDATE source.changeitem h SET h.newvalue = new_issue_type_id where h.field in ('issuetype') and h.newvalue=  v_id;
    UPDATE source.workflowschemeentity h set h.issuetype = new_issue_type_id where h.issuetype = v_id;
END IF;
   SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_it_id; 


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateChangeGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateChangeGroup`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_source_node_id,  v_sink_node_id, v_sequence, v_id, v_issueid, newId, v_groupid, temp_id_1, temp_id_2  INT DEFAULT 0;
DECLARE v_source_node_entity,v_sink_node_entity,v_association_type,v_author, v_fieldtype, v_field  VARCHAR(255);
DECLARE v_created datetime;
DECLARE v_oldvalue, v_oldstring, v_newvalue, v_newstring longtext;

DECLARE c_id CURSOR FOR SELECT h.source_node_id, h.source_node_entity, h.sink_node_id, h.sink_node_entity, h.association_type, h.sequence  FROM source.nodeassociation h;
DECLARE c_cg_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.created FROM source.changegroup h order by h.id;
DECLARE c_ci_id CURSOR FOR SELECT h.id, h.groupid, h.fieldtype, h.field, h.oldvalue, h.oldstring, h.newvalue, h.newstring FROM source.changeitem h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT max(id) INTO temp_id_1 from source.changegroup ;
SELECT max(id) INTO temp_id_2 from target.changegroup ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.changegroup;
OPEN c_cg_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_cg_id INTO v_id, v_issueid, v_author, v_created;

SET newId = newId + INC;
INSERT INTO target.changegroup (id, issueid, author, created)
VALUES (newId, v_issueid, v_author, v_created);

UPDATE source.changeitem h SET h.groupid = newId where h.groupid = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_cg_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateChangeItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateChangeItem`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_source_node_id,  v_sink_node_id, v_sequence, v_id, v_issueid, newId, v_groupid, temp_id_1, temp_id_2  INT DEFAULT 0;
DECLARE v_source_node_entity,v_sink_node_entity,v_association_type,v_author, v_fieldtype, v_field  VARCHAR(255);
DECLARE v_created datetime;
DECLARE v_oldvalue, v_oldstring, v_newvalue, v_newstring longtext;

DECLARE c_id CURSOR FOR SELECT h.source_node_id, h.source_node_entity, h.sink_node_id, h.sink_node_entity, h.association_type, h.sequence  FROM source.nodeassociation h;
DECLARE c_cg_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.created FROM source.changegroup h order by h.id;
DECLARE c_ci_id CURSOR FOR SELECT h.id, h.groupid, h.fieldtype, h.field, h.oldvalue, h.oldstring, h.newvalue, h.newstring FROM source.changeitem h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;


SELECT max(id) INTO temp_id_1 from source.changeitem ;
SELECT max(id) INTO temp_id_2 from target.changeitem ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.changeitem;
OPEN c_ci_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_ci_id INTO v_id, v_groupid, v_fieldtype, v_field, v_oldvalue, v_oldstring, v_newvalue, v_newstring;

SET newId = newId + INC;
IF (v_field ='Sprint') THEN 
	INSERT INTO target.changeitem (id, groupid, fieldtype, field, oldvalue, oldstring, newvalue, newstring) values
	(newId, v_groupid, v_fieldtype, v_field, getSprints(v_oldvalue), oldstring, getSprints(v_newvalue), newstring);
ELSE
	INSERT INTO target.changeitem (id, groupid, fieldtype, field, oldvalue, oldstring, newvalue, newstring)
	VALUES (newId, v_groupid, v_fieldtype, v_field, v_oldvalue, v_oldstring, v_newvalue, v_newstring);
END IF;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_ci_id; 



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateComponent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateComponent`()
BEGIN
DECLARE new_prj_id,  newId,  ROWCNT, l_last_row_fetched,  v_project, v_assigneetype, v_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_cname, v_url, v_lead VARCHAR(255);
DECLARE v_description text;
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT id, project, cname, description, url, lead, ASSIGNEETYPE FROM source.component order by id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.component;

SELECT max(id) INTO temp_id_1 from source.component ;
SELECT max(id) INTO temp_id_2 from target.component ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_project, v_cname, v_description, v_url, v_lead,  v_assigneetype;


SET newId = newId + INC ;
INSERT INTO target.component (id, project, cname, description, url, lead, ASSIGNEETYPE) values (newId, v_project, v_cname, v_description, v_url, v_lead, v_assigneetype);

UPDATE source.nodeassociation h set h.sink_node_id = newId where h.sink_node_entity = 'Component' and h.sink_node_id = v_id;
update source.changeitem h set h.oldvalue = newId where h.field = 'Component' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = newId where h.field = 'Component' and h.newvalue=  v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateConfigurationcontext` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateConfigurationcontext`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, rec_exists, new_cc_id, v_projectcategory, v_project, v_id, v_fieldconfigscheme, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_configname, v_customfield,  v_cfname VARCHAR(255);
DECLARE src_context text;
DECLARE c_id CURSOR FOR SELECT h.id, h.projectcategory, h.project, h.customfield, h.fieldconfigscheme FROM source.configurationcontext h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.configurationcontext;

SELECT max(id) INTO temp_id_1 from source.configurationcontext ;
SELECT max(id) INTO temp_id_2 from target.configurationcontext ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_cc_id = temp_id_1;
else	
	SET new_cc_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_projectcategory, v_project, v_customfield, v_fieldconfigscheme ;
SET rec_exists = 0;

SELECT concat(IFNULL(v_projectcategory,'NULL'),'-',IFNULL(v_project,'NULL'),'-',v_customfield) into src_context;
-- SELECT 1 INTO rec_exists FROM target.configurationcontext m where  m.fieldconfigscheme = v_fieldconfigscheme and m.customfield  = v_customfield;
SELECT 1 INTO rec_exists FROM target.configurationcontext m 
where  concat(IFNULL(m.projectcategory,'NULL'),'-',IFNULL(m.project,'NULL'),'-',m.customfield) = src_context;



IF (rec_exists = 0) then
BEGIN
SET new_cc_id = new_cc_id + INC ;
Insert into target.configurationcontext (id, projectcategory, project, customfield, fieldconfigscheme) 
VALUES ( new_cc_id, v_projectcategory, v_project, v_customfield, v_fieldconfigscheme);


END;
END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateCustomField` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateCustomField`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, V_PROJECT, new_cf_id, newId, V_FIELDTYPE, v_id, temp_id_1, temp_id_2,existing_id INT DEFAULT 0;
DECLARE V_CUSTOMFIELDTYPEKEY, V_CUSTOMFIELDSEARCERKEY, V_CFNAME,  V_DEFAULTVALUE,  V_ISSUETYPE, old_customfield, 
new_customfield, v_item_id, v_item_type, v_managed, v_access_level, v_source, v_description_key VARCHAR(255);
DECLARE V_DESCRIPTION text;
DECLARE c_id CURSOR FOR SELECT h.id, h.customfieldtypekey, h.customfieldsearcherkey, h.cfname, h.description, h.defaultvalue, h.fieldtype, h.project, h.issuetype  
FROM source.customfield h;
DECLARE c_managedconfigurationitem CURSOR FOR SELECT id, item_id, item_type,managed, access_level, `source`, description_key from source.managedconfigurationitem;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

	SELECT  COUNT(*) INTO ROWCNT FROM source.customfield;

	SELECT max(id) INTO temp_id_1 from source.customfield ;
	SELECT max(id) INTO temp_id_2 from target.customfield ;
	IF (temp_id_1 > temp_id_2) THEN
		SET new_cf_id = temp_id_1;
	else	
		SET new_cf_id = temp_id_2;
	END IF;
update source.customfield h set h.cfname = 'Epic Color' where h.cfname = 'Epic Colour';
update source.changeitem h set h.field = 'Epic Color' where h.field = 'Epic Colour';
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_CUSTOMFIELDTYPEKEY, V_CUSTOMFIELDSEARCERKEY, V_CFNAME, V_DESCRIPTION, V_DEFAULTVALUE, V_FIELDTYPE, V_PROJECT, V_ISSUETYPE;
	SET REC_EXISTS = 0;
	

SELECT count(*) INTO REC_EXISTS FROM source.customfield s where  s.cfname in ( select distinct cfname from target.customfield where cfname = V_CFNAME);

IF (REC_EXISTS = 0) then
BEGIN
	SET new_cf_id = new_cf_id + INC ;
	Insert into target.customfield (ID, customfieldtypekey, customfieldsearcherkey, cfname, description, defaultvalue, fieldtype, project, issuetype) 
	VALUES ( new_cf_id, V_CUSTOMFIELDTYPEKEY, V_CUSTOMFIELDSEARCERKEY, V_CFNAME, V_DESCRIPTION, V_DEFAULTVALUE, V_FIELDTYPE, V_PROJECT, V_ISSUETYPE);

	UPDATE source.customfieldvalue h SET h.customfield = new_cf_id where h.customfield = v_id;
	UPDATE source.customfieldoption h SET h.customfield = new_cf_id where h.customfield = v_id;
	UPDATE source.ao_60db71_issueranking h SET h.CUSTOM_FIELD_ID = new_cf_id where h.CUSTOM_FIELD_ID = v_id;
	UPDATE source.ao_60db71_lexorank h SET h.FIELD_ID = new_cf_id where h.FIELD_ID = v_id;

	SELECT concat('customfield_',v_id) into old_customfield;
	SELECT concat('customfield_',new_cf_id) into new_customfield;
	UPDATE source.AO_60DB71_DETAILVIEWFIELD h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.AO_60DB71_ESTIMATESTATISTIC h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.AO_60DB71_TRACKINGSTATISTIC h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.fieldlayoutitem h SET h.fieldidentifier = new_customfield WHERE trim(h.fieldidentifier) = old_customfield;
	UPDATE source.fieldscreenlayoutitem h SET h.fieldidentifier = new_customfield WHERE trim(h.fieldidentifier) = old_customfield;
	UPDATE source.fieldconfigscheme h SET h.fieldid = new_customfield WHERE trim(h.fieldid) = old_customfield;
	UPDATE source.fieldconfiguration h SET h.fieldid = new_customfield WHERE trim(h.fieldid) = old_customfield;
	UPDATE source.managedconfigurationitem h SET h.item_id = new_customfield WHERE item_type='CUSTOM_FIELD' and  trim(h.item_id) = old_customfield;
	UPDATE source.configurationcontext h SET h.customfield = new_customfield WHERE  trim(h.customfield) = old_customfield;
    UPDATE source.userhistoryitem h SET h.entityid = new_customfield WHERE h.entitytype ='Searcher' and trim(h.entityid) = old_customfield;
	UPDATE source.columnlayoutitem h set h.fieldidentifier = new_customfield where trim(h.fieldidentifier) = old_customfield;
    UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_customfield where h.userprefvalue = old_customfield;
    UPDATE source.schemepermissions set perm_parameter= new_customfield where perm_type='userCF' and perm_parameter=old_customfield;
    
END;
ELSE 
	SET existing_id =0;
	SELECT m.id into existing_id FROM target.customfield m where  m.cfname = V_CFNAME LIMIT 1;
	
	UPDATE source.customfieldvalue h SET h.customfield = existing_id where h.customfield = v_id;
	UPDATE source.customfieldoption h SET h.customfield = existing_id where h.customfield = v_id;
	UPDATE source.ao_60db71_issueranking h SET h.CUSTOM_FIELD_ID = existing_id where h.CUSTOM_FIELD_ID = v_id;
	UPDATE source.ao_60db71_lexorank h SET h.FIELD_ID = existing_id where h.FIELD_ID = v_id;

	SELECT concat('customfield_',v_id) into old_customfield;
	SELECT concat('customfield_',existing_id) into new_customfield;
	UPDATE source.AO_60DB71_DETAILVIEWFIELD h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.AO_60DB71_ESTIMATESTATISTIC h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.AO_60DB71_TRACKINGSTATISTIC h SET h.field_id = new_customfield WHERE trim(h.field_id) = old_customfield;
	UPDATE source.fieldlayoutitem h SET h.fieldidentifier = new_customfield WHERE trim(h.fieldidentifier) = old_customfield;
	UPDATE source.fieldscreenlayoutitem h SET h.fieldidentifier = new_customfield WHERE trim(h.fieldidentifier) = old_customfield;
	UPDATE source.fieldconfigscheme h SET h.fieldid = new_customfield WHERE trim(h.fieldid) = old_customfield;
	UPDATE source.fieldconfiguration h SET h.fieldid = new_customfield WHERE trim(h.fieldid) = old_customfield;
	UPDATE source.managedconfigurationitem h SET h.item_id = new_customfield WHERE item_type='CUSTOM_FIELD' and trim(h.item_id) = old_customfield;
	UPDATE source.configurationcontext h SET h.customfield = new_customfield WHERE  trim(h.customfield) = old_customfield;
    UPDATE source.userhistoryitem h SET h.entityid = new_customfield WHERE h.entitytype ='Searcher' and trim(h.entityid) = old_customfield;
    UPDATE source.columnlayoutitem h set h.fieldidentifier = new_customfield WHERE trim(h.fieldidentifier) = old_customfield;
    UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_customfield where h.userprefvalue = old_customfield;
    UPDATE source.schemepermissions set perm_parameter= new_customfield where perm_type='userCF' and perm_parameter=old_customfield;

END IF;
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- MANAGEDCONFIGURATIONITEM
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.managedconfigurationitem;

	SELECT max(id) INTO temp_id_1 from source.managedconfigurationitem ;
	SELECT max(id) INTO temp_id_2 from target.managedconfigurationitem ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

OPEN c_managedconfigurationitem;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_managedconfigurationitem INTO v_id, v_item_id, v_item_type,v_managed, v_access_level, v_source, v_description_key;

SET REC_EXISTS = 0;
SELECT 1 INTO REC_EXISTS FROM target.managedconfigurationitem m where m.item_id = v_item_id ;
IF (REC_EXISTS = 0) then
BEGIN
SET newId = newId + INC ;
Insert into target.managedconfigurationitem (id, item_id, item_type,managed, access_level, `source`, description_key) 
VALUES (newId, v_item_id, v_item_type, v_managed, v_access_level, v_source, v_description_key);

END;
END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_managedconfigurationitem; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateCustomFieldOption` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateCustomFieldOption`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT,  new_cfo_id, v_id, v_customfield, v_customfieldconfig, v_parentoptionid, v_sequence, existing_id, rec_exists, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_customvalue, v_optiontype, v_disabled VARCHAR(255);

DECLARE c_id CURSOR FOR SELECT h.id, h.customfield, h.customfieldconfig, h.parentoptionid, h.sequence, h.customvalue, h.optiontype, h.disabled
FROM source.customfieldoption h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.customfieldoption;

SELECT max(id) INTO temp_id_1 from source.customfieldoption ;
SELECT max(id) INTO temp_id_2 from target.customfieldoption ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_cfo_id = temp_id_1;
else	
	SET new_cfo_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_customfield, v_customfieldconfig, v_parentoptionid, v_sequence, v_customvalue, v_optiontype, v_disabled;
SET rec_exists = 0;

SELECT count(*) INTO rec_exists FROM target.customfieldoption m where  m.customfield = v_customfield and m.customfieldconfig = v_customfieldconfig and m.customvalue = v_customvalue;

IF (rec_exists = 0) then
BEGIN
	SET new_cfo_id = new_cfo_id + INC ;
	Insert into target.customfieldoption (ID, customfield, customfieldconfig, parentoptionid, sequence, customvalue, optiontype, disabled) 
	VALUES ( new_cfo_id, v_customfield, v_customfieldconfig, v_parentoptionid, v_sequence, v_customvalue, v_optiontype, v_disabled);

	UPDATE source.customfieldvalue set stringvalue = new_cfo_id where customfield=
	(select id from target.customfield where cfname='Manager' and description is not null) and stringvalue = v_id;

	UPDATE source.changeitem set oldvalue = new_cfo_id where field='Manager' and oldvalue = v_id;
	UPDATE source.changeitem set newvalue = new_cfo_id where field='Manager' and newvalue = v_id;
END;
ELSE
BEGIN
	SELECT m.id into existing_id FROM target.customfieldoption m 
	where  m.customfield = v_customfield and m.customfieldconfig = v_customfieldconfig and m.customvalue = v_customvalue;

	UPDATE source.customfieldvalue set stringvalue = existing_id where customfield=
	(select id from target.customfield where cfname='Manager' and description is not null) and stringvalue = v_id;

	UPDATE source.changeitem set oldvalue = existing_id where field='Manager' and oldvalue = v_id;
	UPDATE source.changeitem set newvalue = existing_id where field='Manager' and newvalue = v_id;
END;
END IF;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateCustomFieldValue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateCustomFieldValue`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id, v_issue, v_customfield, v_numbervalue, temp_id_1, temp_id_2,new_cfv_id INT DEFAULT 0;
DECLARE v_parentkey, v_stringvalue, v_valuetype VARCHAR(255);
DECLARE v_textvalue longtext;
DECLARE v_datevalue datetime;

DECLARE c_id CURSOR FOR SELECT h.id, h.issue, h.customfield, h.parentkey, h.stringvalue, h.numbervalue, h.textvalue, h.datevalue, h.valuetype FROM source.customfieldvalue h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.customfieldvalue;

SELECT max(id) INTO temp_id_1 from source.customfieldvalue ;
SELECT max(id) INTO temp_id_2 from target.customfieldvalue ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_cfv_id = temp_id_1;
else	
	SET new_cfv_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_issue, v_customfield, v_parentkey, v_stringvalue, v_numbervalue, v_textvalue, v_datevalue, v_valuetype;

SET new_cfv_id = new_cfv_id + INC ;
Insert into target.customfieldvalue (id, issue, customfield, parentkey, stringvalue, numbervalue, textvalue, datevalue, valuetype) 
VALUES ( new_cfv_id, v_issue, v_customfield, v_parentkey, v_stringvalue, v_numbervalue, v_textvalue, v_datevalue, v_valuetype);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateFavouriteAssociations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateFavouriteAssociations`()
BEGIN
DECLARE newId,  ROWCNT, l_last_row_fetched, v_entityid, v_sequence, v_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_username, v_entitytype VARCHAR(255);
DECLARE v_description text;
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT h.id, h.username, h.entitytype, h.entityid, h.sequence FROM source.favouriteassociations h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.favouriteassociations;

SELECT max(id) INTO temp_id_1 from source.favouriteassociations ;
SELECT max(id) INTO temp_id_2 from target.favouriteassociations ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_username, v_entitytype, v_entityid, v_sequence;

SET newId = newId + INC ;
INSERT INTO target.favouriteassociations (id, username, entitytype, entityid, sequence) values (newId, v_username, v_entitytype, v_entityid, v_sequence);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateFieldConfigScheme` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateFieldConfigScheme`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, rec_exists, new_fcs_id, v_customfield, v_id, temp_id_1, temp_id_2,existing_id INT DEFAULT 0;
DECLARE v_configname, v_fieldid, v_cfname VARCHAR(255);
DECLARE V_DESCRIPTION text;
DECLARE c_id CURSOR FOR SELECT h.id, h.configname, h.description, h.fieldid, h.customfield FROM source.fieldconfigscheme h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.fieldconfigscheme;
SELECT max(id) INTO temp_id_1 from source.fieldconfigscheme ;
SELECT max(id) INTO temp_id_2 from target.fieldconfigscheme ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_fcs_id = temp_id_1;
else	
	SET new_fcs_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_configname, v_description, v_fieldid, v_customfield ;
SET rec_exists = 0;

SELECT count(*) INTO rec_exists FROM target.fieldconfigscheme m where  m.configname = v_configname  and m.fieldid  = v_fieldid;

IF (rec_exists = 0) then
BEGIN
SET new_fcs_id = new_fcs_id + INC ;
Insert into target.fieldconfigscheme (id, configname, description, fieldid, customfield) 
VALUES ( new_fcs_id, v_configname, v_description, v_fieldid, v_customfield);

UPDATE source.configurationcontext h SET h.fieldconfigscheme = new_fcs_id where h.fieldconfigscheme = v_id;
UPDATE source.customfieldoption h SET h.customfieldconfig = new_fcs_id where h.customfieldconfig = v_id;
UPDATE source.fieldconfigschemeissuetype h SET h.fieldconfigscheme = new_fcs_id where h.fieldconfigscheme = v_id;
END;
ELSE 
BEGIN
SELECT m.id into existing_id FROM target.fieldconfigscheme m where  m.configname = v_configname  and m.fieldid  = v_fieldid;

UPDATE source.configurationcontext h SET h.fieldconfigscheme = existing_id where h.fieldconfigscheme = v_id;
UPDATE source.customfieldoption h SET h.customfieldconfig = existing_id where h.customfieldconfig = v_id;
UPDATE source.fieldconfigschemeissuetype h SET h.fieldconfigscheme = existing_id where h.fieldconfigscheme = v_id;
END;
END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateFieldConfigSchemeIssueType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateFieldConfigSchemeIssueType`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, new_fcsit_id, v_id, v_fieldconfigscheme, v_fieldconfiguration, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_issuetype VARCHAR(255);

DECLARE c_id CURSOR FOR SELECT h.id, h.issuetype, h.fieldconfigscheme, h.fieldconfiguration FROM source.fieldconfigschemeissuetype h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.fieldconfigschemeissuetype;

SELECT max(id) INTO temp_id_1 from source.fieldconfigschemeissuetype ;
SELECT max(id) INTO temp_id_2 from target.fieldconfigschemeissuetype ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_fcsit_id = temp_id_1;
else	
	SET new_fcsit_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_issuetype, v_fieldconfigscheme, v_fieldconfiguration;

SET new_fcsit_id = new_fcsit_id + INC ;
Insert into target.fieldconfigschemeissuetype (ID, issuetype, fieldconfigscheme, fieldconfiguration) 
VALUES ( new_fcsit_id,v_issuetype, v_fieldconfigscheme, v_fieldconfiguration);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateFieldConfiguration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateFieldConfiguration`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, rec_exists, new_fc_id, v_customfield, v_id, temp_id_1, temp_id_2, existing_id INT DEFAULT 0;
DECLARE v_configname, v_fieldid, v_cfname VARCHAR(255);
DECLARE V_DESCRIPTION text;
DECLARE c_id CURSOR FOR SELECT h.id, h.configname, h.description, h.fieldid, h.customfield FROM source.fieldconfiguration h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.fieldconfiguration;

SELECT max(id) INTO temp_id_1 from source.fieldconfiguration ;
SELECT max(id) INTO temp_id_2 from target.fieldconfiguration ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_fc_id = temp_id_1;
else	
	SET new_fc_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_configname, v_description, v_fieldid, v_customfield ;

SET rec_exists = 0;

SELECT count(*) INTO rec_exists FROM target.fieldconfiguration m where  m.configname = v_configname  and m.fieldid  = v_fieldid;

IF (rec_exists = 0) then
	BEGIN
	SET new_fc_id = new_fc_id + INC ;
	Insert into target.fieldconfiguration (id, configname, description, fieldid, customfield) 
	VALUES ( new_fc_id, v_configname, v_description, v_fieldid, v_customfield);

	UPDATE source.fieldconfigschemeissuetype h SET h.fieldconfiguration = new_fc_id where h.fieldconfiguration = v_id;
	END;
ELSE 
	BEGIN
	SELECT m.id INTO existing_id FROM target.fieldconfiguration m where  m.configname = v_configname  and m.fieldid  = v_fieldid limit 0,1;

	UPDATE source.fieldconfigschemeissuetype h SET h.fieldconfiguration = existing_id where h.fieldconfiguration = v_id;
	END;
END IF;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateFieldScreen` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateFieldScreen`()
BEGIN








DECLARE oldId, newId, new_fs_id, ROWCNT, l_last_row_fetched, rec_exists, v_sequence, v_fieldscreen, v_fieldscreentab, temp_id_1, temp_id_2, existing_id INT DEFAULT 0;
DECLARE v_name, v_description, v_fieldidentifier VARCHAR(255);
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT h.ID, h.name, h.description FROM source.FieldScreen h  order by h.id;
DECLARE c_fst_id CURSOR FOR SELECT h.id, h.name, h.description, h.sequence, h.fieldscreen FROM source.FieldScreenTab h  order by h.id;
DECLARE c_fieldscreenlayoutitem CURSOR FOR SELECT h.id, h.fieldidentifier, h.sequence, h.fieldscreentab FROM source.fieldscreenlayoutitem h  order by h.id;



DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.FieldScreen;

SELECT max(id) INTO temp_id_1 from source.FieldScreen ;
SELECT max(id) INTO temp_id_2 from target.FieldScreen ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO oldId, v_name, v_description;
SET rec_exists = 0;
SELECT  1 INTO rec_exists FROM  target.FieldScreen m  WHERE  m.name = v_name;
IF (rec_exists = 0) then
BEGIN
	SET newId = newId + INC ;

	INSERT INTO target.FieldScreen (ID, NAME, DESCRIPTION) values  (newId, v_name, v_description);

	UPDATE source.FieldScreenTab h SET h.fieldscreen = newId where h.fieldscreen = oldId;
END;
ELSE
	SELECT  m.id INTO existing_id FROM  target.FieldScreen m  WHERE  m.name = v_name;
	UPDATE source.FieldScreenTab h SET h.fieldscreen = existing_id where h.fieldscreen = oldId;
END IF;
	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 




SET LOOPCNT = 1;

SELECT  COUNT(*) INTO ROWCNT FROM source.FieldScreenTab;

SELECT max(id) INTO temp_id_1 from source.FieldScreenTab ;
SELECT max(id) INTO temp_id_2 from target.FieldScreenTab ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_fst_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_fst_id INTO  oldId, v_name, v_description, v_sequence, v_fieldscreen;
SET rec_exists = 0;
SELECT 1 INTO rec_exists from target.FieldScreenTab m where m.name = v_name and m.fieldscreen = v_fieldscreen;
if (rec_exists = 0) THEN
BEGIN
	
	
	SET newId = newId + INC ;
	INSERT INTO target.FieldScreenTab (ID, NAME, DESCRIPTION, sequence, fieldscreen) values ( newId, V_NAME, V_DESCRIPTION, V_SEQUENCE, v_fieldscreen);
    UPDATE source.fieldscreenlayoutitem h SET h.FieldScreenTab = newId where h.FieldScreenTab = oldId;
END;
ELSE 
	SELECT m.id INTO existing_id from target.FieldScreenTab m where m.name = v_name and m.fieldscreen = v_fieldscreen;
	UPDATE source.fieldscreenlayoutitem h SET h.FieldScreenTab = existing_id where h.FieldScreenTab = oldId;

END IF;
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_fst_id;




SET LOOPCNT = 1;

SELECT  COUNT(*) INTO ROWCNT FROM source.fieldscreenlayoutitem;

SELECT max(id) INTO temp_id_1 from source.fieldscreenlayoutitem ;
SELECT max(id) INTO temp_id_2 from target.fieldscreenlayoutitem ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_fieldscreenlayoutitem;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_fieldscreenlayoutitem INTO  oldId, v_fieldidentifier, v_sequence, v_fieldscreentab;
SET rec_exists = 0;
SELECT 1 INTO rec_exists from target.fieldscreenlayoutitem m where m.fieldidentifier = v_fieldidentifier and m.fieldscreentab = v_fieldscreentab;
if (rec_exists = 0) THEN
BEGIN
	SET newId = newId + INC ;
	INSERT INTO target.fieldscreenlayoutitem (ID, fieldidentifier, sequence, fieldscreentab) values ( newId, v_fieldidentifier, v_sequence, v_fieldscreentab);
    
END;

END IF;
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_fieldscreenlayoutitem;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateIssueLink` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateIssueLink`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, new_il_id, v_id, v_linktype, v_source, v_destination, v_sequence, temp_id_1, temp_id_2 INT DEFAULT 0;

DECLARE c_id CURSOR FOR SELECT h.id, h.linktype, h.source, h.destination, h.sequence FROM source.issuelink h order by h.id;
 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.issuelink;

SELECT max(id) INTO temp_id_1 from source.issuelink ;
SELECT max(id) INTO temp_id_2 from target.issuelink ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_il_id = temp_id_1;
else	
	SET new_il_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_linktype, v_source, v_destination, v_sequence;

SET new_il_id = new_il_id + INC ;
Insert into target.issuelink (id, linktype, source, destination, sequence) 
VALUES ( new_il_id, v_linktype, v_source, v_destination, v_sequence);

UPDATE source.userhistoryitem h SET h.entityid = new_il_id where h.entitytype ='IssueLink' and h.entityid = v_id;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateIssueLinkType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateIssueLinkType`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, new_ilt_id, existing_id, v_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_linkname, v_inward, v_outward, v_pstyle VARCHAR(255);

DECLARE c_id CURSOR FOR SELECT h.id, h.linkname, h.inward, h.outward, h.pstyle FROM source.issuelinktype h order by h.id;
 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.issuelinktype;

SELECT max(id) INTO temp_id_1 from source.issuelinktype ;
SELECT max(id) INTO temp_id_2 from target.issuelinktype ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_ilt_id = temp_id_1;
else	
	SET new_ilt_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_linkname, v_inward, v_outward, v_pstyle;
SET REC_EXISTS = 0;

SELECT 1 INTO REC_EXISTS FROM target.issuelinktype m where  m.linkname = v_linkname;

IF (REC_EXISTS = 0) then
BEGIN
SET new_ilt_id = new_ilt_id + INC ;
Insert into target.issuelinktype (id, linkname, inward, outward, pstyle) 
VALUES ( new_ilt_id, v_linkname, v_inward, v_outward, v_pstyle);

UPDATE source.issuelink h SET h.linktype = new_ilt_id where h.linktype = v_id;

END;
ELSE 
SET existing_id =0;
SELECT m.id into existing_id FROM target.issuelinktype m where  m.linkname = v_linkname;

UPDATE source.issuelink h SET h.linktype = existing_id where h.linktype = v_id;


END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateIssueStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateIssueStatus`()
BEGIN

   
DECLARE  newId, ROWCNT, l_last_row_fetched, rec_exists, v_sequence, v_statuscategory, max_id, existing_id,new_seq, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_pname, v_iconurl, v_id VARCHAR(255);
DECLARE v_description text;
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT id, sequence, pname, description, iconurl, statuscategory FROM source.issuestatus h  order by h.id;
DECLARE c_max_id CURSOR FOR SELECT id FROM target.issuestatus m  order by m.id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SET newId = 0;


SELECT max(CAST(id AS SIGNED INT))  INTO temp_id_1 from source.issuestatus ;
SELECT max(CAST(id AS SIGNED INT))  INTO temp_id_2 from target.issuestatus ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

set LOOPCNT =  1;
SELECT  COUNT(*) INTO ROWCNT FROM source.issuestatus;
select max(sequence) into new_seq from target.issuestatus;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO  v_id, v_sequence, v_pname, v_description, v_iconurl, v_statuscategory;
SET rec_exists = 0;
SELECT  1 INTO rec_exists FROM  target.issuestatus m  WHERE  m.pname = v_pname;

IF (rec_exists = 0) then
BEGIN
SET newId = newId + INC ;
set new_seq = new_seq + INC;
INSERT INTO target.issuestatus (id, sequence, pname, description, iconurl, statuscategory) values  (newId, new_seq, v_pname, v_description, v_iconurl, v_statuscategory);

UPDATE source.jiraissue h set h.issuestatus = newId where h.issuestatus = v_id;
UPDATE source.ao_60db71_columnstatus h set h.status_id = newId where h.status_id = v_id;

update source.changeitem h set h.oldvalue = newId where h.field ='Epic Status' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = newId where h.field ='Epic Status' and h.newvalue=  v_id;
update source.changeitem h set h.oldvalue = newId where h.field ='status' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = newId where h.field ='status' and h.newvalue=  v_id;
END;
ELSE
BEGIN

select id into existing_id from target.issuestatus m  WHERE  m.pname = v_pname;

UPDATE source.ao_60db71_columnstatus h set h.status_id = existing_id where h.status_id = v_id;
UPDATE source.jiraissue set issuestatus = existing_id where issuestatus = v_id;
update source.changeitem h set h.oldvalue = existing_id where h.field ='Epic Status' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = existing_id where h.field ='Epic Status' and h.newvalue=  v_id;
update source.changeitem h set h.oldvalue = existing_id where h.field ='status' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = existing_id where h.field ='status' and h.newvalue=  v_id;
END;
END IF;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 
UPDATE source.userhistoryitem h SET h.entityid = 10000 where h.entitytype ='Resolution' and h.entityid = 6;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateJenkinsInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateJenkinsInfo`()
BEGIN
DECLARE oldId, newId  INT DEFAULT 0;
DECLARE LOOPCNT INT DEFAULT 1;
DECLARE ROWCNT INT DEFAULT 0;
DECLARE l_last_row_fetched INT DEFAULT 0;
DECLARE c_build_mapping CURSOR FOR SELECT id FROM source.ao_3fb43f_build_mapping   order by id;
DECLARE c_job_mapping CURSOR FOR SELECT id FROM source.ao_3fb43f_job_mapping  order by id;
DECLARE c_site_mapping CURSOR FOR SELECT id FROM source.ao_3fb43f_site_mapping order by id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;
SET foreign_key_checks = 0;
/*
SELECT COUNT(*) INTO ROWCNT FROM source.ao_3fb43f_site_mapping;
OPEN c_site_mapping;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_site_mapping INTO oldId;

	SET newId = 0;
    INSERT INTO target.ao_3fb43f_site_mapping(applink_id, auto_link, name, supports_back_link) 
    select applink_id, auto_link, name, supports_back_link From source.ao_3fb43f_site_mapping where id=oldId;
    
    SELECT LAST_INSERT_ID() INTO newId;
    
    UPDATE source.ao_3fb43f_job_mapping SET site_id = newId where site_id = oldId;
    
	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_site_mapping;



SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.ao_3fb43f_job_mapping;

OPEN c_job_mapping;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_job_mapping INTO oldId;

SET newId =0;

	INSERT into target.ao_3fb43f_job_mapping (deleted, display_name, last_build, linked, `name`, site_id) 
      SELECT deleted, display_name, last_build, linked, `name`, site_id FROM source.ao_3fb43f_job_mapping where id = oldId;
	
    SELECT LAST_INSERT_ID() INTO newId;
    UPDATE source.ao_3fb43f_build_mapping SET job_id = newId where job_id = oldId;
    UPDATE source.ao_3fb43f_issue_mapping SET job_id = newId where job_id = oldId;
		
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_job_mapping;
*/

SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.ao_3fb43f_build_mapping;

OPEN c_build_mapping;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_build_mapping INTO oldId;

SET newId =0;

	INSERT into target.ao_3fb43f_build_mapping (build_number, built_on, cause, deleted,duration, job_id, result, time_stamp) 
    SELECT build_number, built_on, cause, deleted,duration, job_id, result, time_stamp FROM source.ao_3fb43f_build_mapping where id = oldId;
	
    SELECT LAST_INSERT_ID() INTO newId;
    UPDATE source.ao_3fb43f_test_results_mapping SET build_id = newId where build_id = oldId;
    UPDATE source.ao_3fb43f_issue_mapping SET build_id = newId where build_id = oldId;
		
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_build_mapping;


	INSERT INTO target.ao_3fb43f_issue_mapping (build_date, build_id, issue_key, job_id, project_key) 
    select s.build_date, s.build_id, s.issue_key, s.job_id, s.project_key FROM source.ao_3fb43f_issue_mapping s;


	INSERT INTO target.ao_3fb43f_test_results_mapping (build_id, failed, skipped, total) 
    select s.build_id, s.failed, s.skipped, s.total FROM source.ao_3fb43f_test_results_mapping s;
	
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateJiraAction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateJiraAction`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id, v_issueid, v_rolelevel, v_actionnum, v_fieldid, v_filesize, v_zip, v_thumbnailable, new_id,temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_author, v_actiontype, v_actionlevel, v_updateauthor, v_label, v_mimetype, v_filename,v_globalid, v_title,  v_relationship,  v_statusname, v_statuscategorykey, v_statuscategorycolorname, v_applicationtype, v_applicationname VARCHAR(255);
DECLARE v_actionbody   longtext;
DECLARE v_statusdescription, v_statusiconurl, v_statusicontitle, v_statusiconlink, v_summary, v_url, v_iconurl, v_icontitle text;
DECLARE v_resolved char(1);
DECLARE v_created,  v_updated DATETIME;
DECLARE c_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.actiontype, h.actionlevel, h.rolelevel, h.actionbody, h.created, h.updateauthor, h.updated, h.actionnum FROM source.jiraaction h;
DECLARE c_lbl_id CURSOR FOR SELECT h.id, h.fieldid, h.issue, h.label FROM source.label h order by h.id;
DECLARE c_fa_id CURSOR FOR SELECT h.id, h.issueid, h.mimetype, h.filename, h.created, h.filesize, h.author, h.zip, h.thumbnailable FROM source.fileattachment h order by h.id;
DECLARE c_rl_id CURSOR FOR SELECT h.id, h.issueid, h.globalid, h.title, h.summary, h.url, h.iconurl, h.icontitle, h.relationship, h.resolved, h.statusname, 
h.statusdescription, h.statusiconurl, h.statusicontitle, h.statusiconlink, h.statuscategorykey, h.statuscategorycolorname, h.applicationtype, h.applicationname from source.remotelink h;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;


SELECT  COUNT(*) INTO ROWCNT FROM source.jiraaction;

SELECT max(id)  INTO temp_id_1 from source.jiraaction ;
SELECT max(id)  INTO temp_id_2 from target.jiraaction ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_id = temp_id_1;
else	
	SET new_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_issueid, v_author, v_actiontype, v_actionlevel, v_rolelevel, v_actionbody,  v_created, v_updateauthor, v_updated, v_actionnum;

SET new_id = new_id + INC ;
INSERT INTO target.jiraaction (id, issueid, author, actiontype, actionlevel, rolelevel, actionbody, created, updateauthor, updated, actionnum)
VALUES (new_id, v_issueid, v_author, v_actiontype, v_actionlevel, v_rolelevel, v_actionbody,  v_created, v_updateauthor, v_updated, v_actionnum);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


insert into target.issuesecurityscheme (id, name, description, defaultlevel) select id, name, description, defaultlevel from source.issuesecurityscheme;


SET new_id = 0;
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.label;

SELECT max(id)  INTO temp_id_1 from source.label ;
SELECT max(id)  INTO temp_id_2 from target.label ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_id = temp_id_1;
else	
	SET new_id = temp_id_2;
END IF;

OPEN c_lbl_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_lbl_id INTO v_id, v_fieldid, v_issueid, v_label;

SET new_id = new_id + INC ;
INSERT INTO target.label (id, fieldid, issue, label)
VALUES (new_id, v_fieldid, v_issueid, v_label);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_lbl_id; 




SET new_id = 0;
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.fileattachment;

OPEN c_fa_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_fa_id INTO v_id, v_issueid, v_mimetype, v_filename, v_created, v_filesize, v_author, v_zip, v_thumbnailable;

-- SET new_id = new_id + INC ;
SET new_id = v_id + 100000;
INSERT INTO target.fileattachment (id, issueid, mimetype, filename, created, filesize, author, zip, thumbnailable)
VALUES (new_id, v_issueid, v_mimetype, v_filename, v_created, v_filesize, v_author, v_zip, v_thumbnailable);

update source.changeitem h set h.oldvalue = new_id where h.field = 'Attachment' and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = new_id where h.field = 'Attachment' and h.newvalue=  v_id;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_fa_id; 


SET new_id = 0;
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.remotelink;

SELECT max(id)  INTO temp_id_1 from source.remotelink ;
SELECT max(id)  INTO temp_id_2 from target.remotelink ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_id = temp_id_1;
else	
	SET new_id = temp_id_2;
END IF;

OPEN c_rl_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_rl_id INTO v_id, v_issueid, v_globalid, v_title, v_summary, v_url, v_iconurl, v_icontitle, v_relationship, v_resolved, v_statusname, 
v_statusdescription, v_statusiconurl, v_statusicontitle, v_statusiconlink, v_statuscategorykey, v_statuscategorycolorname, v_applicationtype, v_applicationname;

SET new_id = new_id + INC ;
INSERT INTO target.remotelink (id, issueid, globalid, title, summary, url, iconurl, icontitle, relationship, resolved, statusname, 
statusdescription, statusiconurl, statusicontitle, statusiconlink, statuscategorykey, statuscategorycolorname, applicationtype, applicationname)
VALUES (new_id, v_issueid, v_globalid, v_title, v_summary, v_url, v_iconurl, v_icontitle, v_relationship, v_resolved, v_statusname, 
v_statusdescription, v_statusiconurl, v_statusicontitle, v_statusiconlink, v_statuscategorykey, v_statuscategorycolorname, v_applicationtype, v_applicationname
);

update source.changeitem h set h.oldvalue = new_id where h.field in ('RemoteIssueLink') and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = new_id where h.field in ('RemoteIssueLink') and h.newvalue=  v_id;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_rl_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateJiraIssues` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateJiraIssues`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, new_ji_id, v_id, v_issuenum, v_project,  v_priority, v_issue_id,
v_resolution, v_issuestatus,  v_votes, v_watches, v_timeoriginalestimate, v_timeestimate, v_timespent, v_workflow_id, v_security,
v_fixfor, v_component, temp_id_1, temp_id_2, newId INT DEFAULT 0;
DECLARE v_created, v_updated, v_duedate, v_resolutiondate DATETIME;
DECLARE v_pkey, v_reporter, v_assignee, v_creator, v_issuetype, v_summary, v_old_issue_key VARCHAR(255);
DECLARE v_description, v_environment longtext;
DECLARE c_ji_id CURSOR FOR SELECT h.id, h.pkey, h.issuenum, h.project, h.reporter, h.assignee, h.creator, h.issuetype, h.summary, h.description, h.environment, h.priority, h.resolution, 
h.issuestatus, h.created, h.updated, h.duedate, 
h.resolutiondate, h.votes, h.watches, h.timeoriginalestimate, h.timeestimate, h.timespent, h.workflow_id, h.security, h.fixfor, h.component FROM source.jiraissue h;
DECLARE c_moved_issue_key CURSOR FOR SELECT id, old_issue_key, issue_id from source.moved_issue_key;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.jiraissue;
SELECT max(id) INTO temp_id_1 from source.jiraissue ;
SELECT max(id) INTO temp_id_2 from target.jiraissue ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_ji_id = temp_id_1;
else	
	SET new_ji_id = temp_id_2;
END IF;

set AUTOCOMMIT = 1;
OPEN c_ji_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_ji_id INTO v_id, v_pkey, v_issuenum, v_project, v_reporter, v_assignee, v_creator, v_issuetype, v_summary, v_description, v_environment, v_priority,
v_resolution, v_issuestatus, v_created, v_updated, v_duedate, v_resolutiondate,  v_votes, v_watches, v_timeoriginalestimate, v_timeestimate, v_timespent, v_workflow_id, v_security,
v_fixfor, v_component;

SET new_ji_id = new_ji_id + INC ;

	Insert into target.jiraissue (id, pkey, issuenum, project, reporter, assignee, creator, issuetype, summary, description, environment, priority, resolution, 
	issuestatus, created, updated, duedate, 
	resolutiondate, votes, watches, timeoriginalestimate, timeestimate, timespent, workflow_id, security, fixfor, component) 
	VALUES ( new_ji_id, v_pkey, v_issuenum, v_project, v_reporter, v_assignee, v_creator, v_issuetype, v_summary, v_description, v_environment, v_priority,
	v_resolution, v_issuestatus, v_created, v_updated, v_duedate, v_resolutiondate,  v_votes, v_watches, v_timeoriginalestimate, v_timeestimate, v_timespent, v_workflow_id, v_security,
	v_fixfor, v_component);

	UPDATE source.customfieldvalue h set h.issue = new_ji_id where h.issue = v_id;
	UPDATE source.worklog h set h.issueid = new_ji_id where h.issueid = v_id;
	UPDATE source.fileattachment h set h.issueid = new_ji_id where h.issueid = v_id;
	
	UPDATE source.remotelink h set h.issueid = new_ji_id where h.issueid = v_id;
	UPDATE source.label h set h.issue = new_ji_id where h.issue = v_id;
	UPDATE source.issuelink h set h.source = new_ji_id where h.source = v_id;
	UPDATE source.issuelink h set h.destination = new_ji_id  where h.destination = v_id;
	UPDATE source.changegroup h set h.issueid = new_ji_id where h.issueid = v_id;
	UPDATE source.jiraaction h set h.issueid = new_ji_id where h.issueid = v_id;
	UPDATE source.votehistory h set h.issueid = new_ji_id where h.issueid = v_id;
	UPDATE source.userhistoryitem h SET h.entityid = new_ji_id where h.entitytype ='Issue' and h.entityid = v_id;
	UPDATE source.nodeassociation h set h.source_node_id = new_ji_id where h.source_node_entity = 'Issue' and h.source_node_id = v_id;
	UPDATE source.changeitem h set h.oldvalue = new_ji_id where h.field in ('Epic Link', 'Epic Child','Parent') and h.oldvalue=  v_id;
	UPDATE source.changeitem h set h.newvalue = new_ji_id where h.field in ('Epic Link', 'Epic Child','Parent') and h.newvalue=  v_id;
	UPDATE source.ao_60db71_issueranking h SET h.ISSUE_ID = new_ji_id where h.ISSUE_ID = v_id;
	UPDATE source.ao_60db71_issueranking h SET h.NEXT_ID = new_ji_id  where h.NEXT_ID = v_id;
    UPDATE source.userassociation h SET h.SINK_NODE_ID = new_ji_id  where SINK_NODE_ENTITY='Issue' and sink_node_id = v_id;
    UPDATE source.moved_issue_key h SET h.issue_id=new_ji_id where h.issue_id = v_id;
    
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_ji_id; 


	INSERT into target.AO_60DB71_LEXORANK (field_id, issue_id, lock_hash, lock_time, rank, `type`) 
    SELECT field_id, issue_id, lock_hash, lock_time, rank, `type` FROM source.AO_60DB71_LEXORANK; 
    

	INSERT into target.AO_60DB71_ISSUERANKING (custom_field_id, issue_id, next_id ) SELECT custom_field_id, issue_id, next_id FROM source.AO_60DB71_ISSUERANKING; 
    
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- MOVED_ISSUE_KEY
SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.moved_issue_key;

	SELECT max(id) INTO temp_id_1 from source.moved_issue_key ;
	SELECT max(id) INTO temp_id_2 from target.moved_issue_key ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

OPEN c_moved_issue_key;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_moved_issue_key INTO v_id, v_old_issue_key, v_issue_id;

SET newId = newId + INC ;
Insert into target.moved_issue_key (id, old_issue_key, issue_id) 
VALUES (newId, v_old_issue_key, v_issue_id);

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_moved_issue_key; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateJiraWorkflows` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateJiraWorkflows`()
BEGIN
DECLARE newId,  ROWCNT, l_last_row_fetched, v_id, temp_id_1, temp_id_2, rec_exists INT DEFAULT 0;
DECLARE v_workflowname, v_creatorname, v_islocked VARCHAR(255);
DECLARE v_descriptor longtext;
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT h.id, h.workflowname, h.creatorname, h.descriptor, h.islocked FROM source.jiraworkflows h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.jiraworkflows;

SELECT max(id) INTO temp_id_1 from source.jiraworkflows ;
SELECT max(id) INTO temp_id_2 from target.jiraworkflows ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_workflowname, v_creatorname, v_descriptor, v_islocked;
SET rec_exists=0;
Select count(*) into rec_exists from target.jiraworkflows where workflowname = v_workflowname;
IF (rec_exists = 0) THEN
SET newId = newId + INC ;
INSERT INTO target.jiraworkflows (id, workflowname, creatorname, descriptor, islocked) values (newId, v_workflowname, v_creatorname, v_descriptor, v_islocked);
END IF;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

INSERT into target.jiradraftworkflows (id, parentname, descriptor) select id, parentname, descriptor from source.jiradraftworkflows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateNodeAssociation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateNodeAssociation`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_source_node_id,  v_sink_node_id, v_sequence, v_id, v_issueid, newId, v_groupid, temp_id_1, temp_id_2  INT DEFAULT 0;
DECLARE v_source_node_entity,v_sink_node_entity,v_association_type,v_author, v_fieldtype, v_field  VARCHAR(255);
DECLARE v_created datetime;
DECLARE v_oldvalue, v_oldstring, v_newvalue, v_newstring longtext;

DECLARE c_id CURSOR FOR SELECT h.source_node_id, h.source_node_entity, h.sink_node_id, h.sink_node_entity, h.association_type, h.sequence  FROM source.nodeassociation h;
DECLARE c_cg_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.created FROM source.changegroup h order by h.id;
DECLARE c_ci_id CURSOR FOR SELECT h.id, h.groupid, h.fieldtype, h.field, h.oldvalue, h.oldstring, h.newvalue, h.newstring FROM source.changeitem h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.nodeassociation;

-- NODEASSOCIATION
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_source_node_id, v_source_node_entity, v_sink_node_id, v_sink_node_entity, v_association_type,v_sequence;

INSERT INTO target.nodeassociation (source_node_id, source_node_entity, sink_node_id, sink_node_entity, association_type, sequence)
VALUES (v_source_node_id, v_source_node_entity, v_sink_node_id, v_sink_node_entity, v_association_type,v_sequence);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateOStables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateOStables`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, new_osw_id, new_oscs_id, new_oshs_id,  v_previous_id, v_id, v_initialized, v_state, v_entry_id, v_step_id, v_action_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_pkey, v_name, v_owner, v_status, v_caller varchar(255);
DECLARE v_start_date, v_due_date, v_finish_date datetime;

DECLARE c_osw_id CURSOR FOR SELECT h.id, h.name, h.initialized, h.state FROM source.os_wfentry h;
DECLARE c_oscs_id CURSOR FOR SELECT h.id, h.entry_id, h.step_id, h.action_id, h.owner, h.start_date, h.due_date, h.finish_date, h.status, h.caller FROM source.os_currentstep h;
DECLARE c_oshs_id CURSOR FOR SELECT h.id, h.entry_id, h.step_id, h.action_id, h.owner, h.start_date, h.due_date, h.finish_date, h.status, h.caller FROM source.os_historystep h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

UPDATE source.JiraIssue h SET h.resolution = 10000 where h.resolution = 6;
UPDATE source.changeitem h set h.oldvalue = 10000 where h.field in ('resolution') and h.oldvalue=  6;
UPDATE source.changeitem h set h.newvalue = 10000 where h.field in ('resolution') and h.newvalue=  6;


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OS_WFENTRY

SELECT  COUNT(*) INTO ROWCNT FROM source.os_wfentry;

SELECT max(id) INTO temp_id_1 from source.os_wfentry ;
SELECT max(id) INTO temp_id_2 from target.os_wfentry ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_osw_id = temp_id_1;
else	
	SET new_osw_id = temp_id_2;
END IF;

SET LOOPCNT = 1;

OPEN c_osw_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_osw_id INTO v_id, v_name, v_initialized, v_state;
SET new_osw_id = new_osw_id + INC ;
INSERT INTO target.os_wfentry (id, name, initialized, state) VALUES (new_osw_id,v_name, v_initialized, v_state);

UPDATE source.JiraIssue h SET h.workflow_id = new_osw_id where h.workflow_id = v_id;
UPDATE source.os_currentstep h SET h.entry_id = new_osw_id where h.entry_id = v_id;
UPDATE source.os_historystep h SET h.entry_id = new_osw_id where h.entry_id = v_id;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_osw_id; 


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OS_CURRENTSTEP

SELECT  COUNT(*) INTO ROWCNT FROM source.os_currentstep;
/*
SELECT max(id) INTO temp_id_1 from source.os_currentstep ;
SELECT max(id) INTO temp_id_2 from target.os_currentstep ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_oscs_id = temp_id_1;
else	
	SET new_oscs_id = temp_id_2;
END IF;
*/
SET LOOPCNT = 1;

OPEN c_oscs_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_oscs_id INTO v_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller;
-- SET new_oscs_id = new_oscs_id + INC ;
SET new_oscs_id = v_id + 20000;
INSERT INTO target.os_currentstep (id, entry_id, step_id, action_id, owner, start_date, due_date, finish_date, status, caller) 
VALUES (new_oscs_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller);

-- UPDATE source.os_currentstep_prev h SET h.id = new_oscs_id where h.id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_oscs_id; 


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OS_HISTORYSTEP

SELECT  COUNT(*) INTO ROWCNT FROM source.os_historystep;
/*
SELECT max(id) INTO temp_id_1 from source.os_historystep ;
SELECT max(id) INTO temp_id_2 from target.os_historystep ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_oshs_id = temp_id_1;
else	
	SET new_oshs_id = temp_id_2;
END IF;
*/
SET LOOPCNT = 1;

OPEN c_oshs_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_oshs_id INTO v_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller;
-- SET new_oshs_id = new_oshs_id + INC ;
SET new_oshs_id = v_id + 20000;
INSERT INTO target.os_historystep (id, entry_id, step_id, action_id, owner, start_date, due_date, finish_date, status, caller) 
VALUES (new_oshs_id, v_entry_id, v_step_id, v_action_id, v_owner, v_start_date, v_due_date, v_finish_date, v_status, v_caller);
/* not needed as we are adding arbritary number 20000 to all the ids
UPDATE source.os_currentstep_prev h SET h.previous_id = new_oshs_id where h.previous_id = v_id;
UPDATE source.os_historystep_prev h SET h.id = new_oshs_id where h.id = v_id;
UPDATE source.os_historystep_prev h SET h.previous_id = new_oshs_id where h.previous_id = v_id;
*/
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_oshs_id; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OS_CURRENTSTEP_PREV

	INSERT INTO target.os_currentstep_prev (id, previous_id) select id +20000, previous_id+20000 from source.os_currentstep_prev;

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OS_HISTORYSTEP_PREV

	INSERT INTO target.os_historystep_prev (id, previous_id) select id+20000, previous_id+20000 from source.os_historystep_prev;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populatePortalPage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populatePortalPage`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id, v_sequence, v_fav_count, existing_id,  newId, v_ppversion, v_column_number, v_portalpage, v_positionseq, temp_id_1, temp_id_2, rec_exists, v_portletconfiguration INT DEFAULT 0;
DECLARE v_gadget_xml text;
DECLARE v_username, v_pagename, v_description, v_layout, v_color, v_portlet_id, v_userprefkey VARCHAR(255);
DECLARE v_userprefvalue longtext;

DECLARE c_id CURSOR FOR SELECT h.id, h.username,h.pagename, h.description, h.sequence, h.fav_count, h.layout, h.ppversion FROM source.portalpage h;
DECLARE c_pc_id CURSOR FOR SELECT h.id, h.portalpage, h.portlet_id, h.column_number, h.positionseq, h.gadget_xml, h.color FROM source.portletconfiguration h;
DECLARE c_gadgetuserpreference CURSOR FOR SELECT s.id, s.portletconfiguration, s.userprefkey, s.userprefvalue FROM source.gadgetuserpreference s;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT max(id) INTO temp_id_1 from source.portalpage ;
SELECT max(id) INTO temp_id_2 from target.portalpage ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.portalpage;
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id,  v_username,v_pagename, v_description, v_sequence, v_fav_count, v_layout, v_ppversion;
SET rec_exists = 0;
SELECT count(*) into rec_exists FROM target.portalpage m where m.username = v_username and m.pagename = v_pagename;

IF (rec_exists = 0) THEN
BEGIN
	IF (v_pagename != 'System Dashboard') THEN
    BEGIN
		SET newId = newId + INC;

		INSERT INTO target.portalpage (id, username,pagename, description, sequence, fav_count, layout, ppversion)
		VALUES (newId, v_username,v_pagename, v_description, v_sequence, v_fav_count, v_layout, v_ppversion);

		UPDATE source.portletconfiguration h SET h.portalpage = newId where h.portalpage = v_id;
		update source.sharepermissions h set h.entityid= newId where h.entitytype='PortalPage' and h.entityid = v_id;
		update source.favouriteassociations h set h.entityid= newId where h.entitytype='PortalPage' and h.entityid = v_id;
		UPDATE source.userhistoryitem h SET h.entityid = newId where h.entitytype ='Dashboard' and h.entityid = v_id;
	END;
    END IF;
END;
ELSE

SELECT m.id into existing_id FROM target.portalpage m where m.username = v_username and m.pagename = v_pagename;
UPDATE source.portletconfiguration h SET h.portalpage = existing_id where h.portalpage = v_id;
update source.sharepermissions h set h.entityid= existing_id where h.entitytype='PortalPage' and h.entityid = v_id;
update source.favouriteassociations h set h.entityid= existing_id where h.entitytype='PortalPage' and h.entityid = v_id;
UPDATE source.userhistoryitem h SET h.entityid = existing_id where h.entitytype ='Dashboard' and h.entityid = v_id;
END IF;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


SET LOOPCNT =1;
SELECT max(id) INTO temp_id_1 from source.portletconfiguration ;
SELECT max(id) INTO temp_id_2 from target.portletconfiguration ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.portletconfiguration;

OPEN c_pc_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_pc_id INTO v_id, v_portalpage, v_portlet_id, v_column_number, v_positionseq, v_gadget_xml, v_color;

SET newId = newId + INC;

INSERT INTO target.portletconfiguration (id, portalpage,portlet_id, column_number, positionseq, gadget_xml, color)
VALUES (newId, v_portalpage, v_portlet_id, v_column_number, v_positionseq, v_gadget_xml, v_color);

update source.gadgetuserpreference set portletconfiguration = newId where portletconfiguration= v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_pc_id; 



SET LOOPCNT =1;
SELECT max(id) INTO temp_id_1 from source.gadgetuserpreference ;
SELECT max(id) INTO temp_id_2 from target.gadgetuserpreference ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.gadgetuserpreference;

OPEN c_gadgetuserpreference;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_gadgetuserpreference INTO v_id, v_portletconfiguration, v_userprefkey, v_userprefvalue;

SET newId = newId + INC;

INSERT INTO target.gadgetuserpreference (id, portletconfiguration, userprefkey, userprefvalue)
VALUES (newId, v_portletconfiguration, v_userprefkey, v_userprefvalue);


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_gadgetuserpreference; 


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateProject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateProject`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, temp_id_1, temp_id_2, V_AVATAR, V_PCOUNTER, V_ASSIGNEETYPE, V_SEQUENCE, v_id, new_prj_id, new_prj_key_id, new_prj_ver_id, newAvatarId, V_PROJECT_ID INT DEFAULT 0;
DECLARE V_PNAME, V_VNAME, V_URL, V_LEAD, V_PKEY, V_ORIGINALKEY, new_project, old_project VARCHAR(255);
DECLARE V_DESCRIPTION  text;
DECLARE V_RELEASED, V_ARCHIVED VARCHAR(10);
DECLARE V_STARTDATE, V_RELEASEDATE DATETIME;

DECLARE c_id CURSOR FOR SELECT h.id, h.PNAME, h.URL, h.lead, h.DESCRIPTION, h.PKEY, h.PCOUNTER, h.ASSIGNEETYPE, h.AVATAR, h.ORIGINALKEY  FROM source.project h;
DECLARE c_pk_id CURSOR FOR SELECT  h.project_key FROM source.project_key h;
DECLARE c_pv_id CURSOR FOR SELECT  h.id, h.project, h.vname, h.description, h.sequence, h.released, h.archived, h.url, h.startdate, h.releasedate FROM source.projectversion h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.project;

SELECT max(id) INTO temp_id_1 from source.project ;
SELECT max(id) INTO temp_id_2 from target.project ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_prj_id = temp_id_1;
else	
	SET new_prj_id = temp_id_2;
END IF;

SELECT max(id) INTO temp_id_1 from source.project_key ;
SELECT max(id) INTO temp_id_2 from target.project_key ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_prj_key_id = temp_id_1;
else	
	SET new_prj_key_id = temp_id_2;
END IF;
SELECT max(id) INTO temp_id_1 from source.projectversion ;
SELECT max(id) INTO temp_id_2 from target.projectversion ;

IF (temp_id_1 > temp_id_2) THEN
	SET new_prj_ver_id = temp_id_1;
else	
	SET new_prj_ver_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_PNAME, V_URL, V_LEAD, V_DESCRIPTION, V_PKEY, V_PCOUNTER, V_ASSIGNEETYPE, V_AVATAR, V_ORIGINALKEY;



SET new_prj_id = new_prj_id + INC ;
INSERT INTO target.project (ID, PNAME, URL, LEAD, DESCRIPTION, PKEY, PCOUNTER, ASSIGNEETYPE, AVATAR, ORIGINALKEY)
VALUES (new_prj_id, V_PNAME, V_URL, V_LEAD, V_DESCRIPTION, V_PKEY, V_PCOUNTER, V_ASSIGNEETYPE, V_AVATAR, V_ORIGINALKEY);

UPDATE target.avatar h SET h.owner = new_prj_id where h.avatartype ='project' and h.owner = v_id;
UPDATE source.JiraIssue h SET h.project = new_prj_id where h.project = v_id;
UPDATE source.PROJECTVERSION h SET h.PROJECT = new_prj_id where h.PROJECT = v_id;
UPDATE source.projectroleactor h SET h.pid = new_prj_id where h.pid = v_id;
UPDATE source.nodeassociation h SET h.source_node_id = new_prj_id where h.source_node_entity = 'Project' and h.source_node_id = v_id;
UPDATE source.ao_b9a0f0_applied_template h SET h.project_id = new_prj_id where  h.project_id = v_id;
UPDATE source.configurationcontext h SET h.project = new_prj_id where  h.project = v_id;
UPDATE source.changeitem h SET h.oldvalue = new_prj_id where h.field in ('Project') and h.oldvalue=  v_id;
UPDATE source.changeitem h SET h.newvalue = new_prj_id where h.field in ('Project') and h.newvalue=  v_id;
UPDATE source.sharepermissions h SET h.param1= new_prj_id where h.sharetype='project' and h.param1 = v_id;
UPDATE source.userhistoryitem h SET h.entityid = new_prj_id where h.entitytype ='Project' and h.entityid = v_id;
UPDATE source.component h SET h.project = new_prj_id where h.project = v_id;
UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_prj_id where h.userprefkey in ('projectId', 'projectKey', 'projectsOrCategories') and h.userprefvalue = v_id;

SELECT concat('project-',v_id) into old_project;
SELECT concat('project-',new_prj_id) into new_project;

UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_project where h.userprefvalue = old_project;



SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


SET LOOPCNT = 1;
SET ROWCNT = 0;
SELECT  COUNT(*) INTO ROWCNT FROM source.project_key;
OPEN c_pk_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_pk_id INTO V_PKEY;
SET new_prj_key_id = new_prj_key_id + INC ;
SELECT ID into V_PROJECT_ID FROM target.project where pkey = V_PKEY;

INSERT INTO target.project_key (ID, PROJECT_ID, PROJECT_KEY)  VALUES (new_prj_key_id, V_PROJECT_ID, V_PKEY);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_pk_id; 


SET LOOPCNT = 1;
SET ROWCNT = 0;
SELECT  COUNT(*) INTO ROWCNT FROM source.projectversion;
OPEN c_pv_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_pv_id INTO v_id, V_PROJECT_ID, V_VNAME, V_DESCRIPTION, V_SEQUENCE, V_RELEASED, V_ARCHIVED, V_URL, V_STARTDATE, V_RELEASEDATE;

SET new_prj_ver_id = new_prj_ver_id + INC ;
-- Select t.id into new_prj_ver_id from target.projectversion t where t.vname = V_VNAME; not needed

INSERT INTO target.projectversion (id, project, vname, description, sequence, released, archived, url, startdate, releasedate)  
VALUES (new_prj_ver_id, V_PROJECT_ID, V_VNAME, V_DESCRIPTION, V_SEQUENCE, V_RELEASED, V_ARCHIVED, V_URL, V_STARTDATE, V_RELEASEDATE);

UPDATE source.nodeassociation h set h.sink_node_id = new_prj_ver_id where h.sink_node_entity = 'Version' and h.sink_node_id = v_id;
update source.changeitem h set h.oldvalue = new_prj_ver_id where h.field in ('Fix Version', 'Version') and h.oldvalue=  v_id;
update source.changeitem h set h.newvalue = new_prj_ver_id where h.field in ('Fix Version', 'Version') and h.newvalue=  v_id;
UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_prj_ver_id where h.userprefkey in ('versionId', 'version', 'currentVersion') and h.userprefvalue = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_pv_id; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateProjectRole` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateProjectRole`()
BEGIN
DECLARE  newId, ROWCNT, l_last_row_fetched, rec_exists, existing_id, v_id, v_pid, v_projectroleid, v_scheme, v_permission, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_name, v_roletype, v_roletypeparameter, v_perm_type, v_perm_parameter, v_permission_key VARCHAR(255);
DECLARE v_description, src_context text;
DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE c_id CURSOR FOR SELECT id, name, description FROM source.projectrole h  order by h.id;
DECLARE c_pra_id CURSOR FOR SELECT h.id, h.pid, h.projectroleid, h.roletype, h.roletypeparameter FROM source.projectroleactor h  order by h.id;
DECLARE c_sp_id CURSOR FOR SELECT h.id, h.scheme, h.permission, h.perm_type, h.perm_parameter, h.permission_key from source.schemepermissions h order by h.id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.projectrole;

SELECT max(id)  INTO temp_id_1 from source.projectrole ;
SELECT max(id)  INTO temp_id_2 from target.projectrole ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO  v_id, v_name, v_description;
SET rec_exists = 0;
SELECT  1 INTO rec_exists FROM  target.projectrole m  WHERE  m.name = v_name;

IF (rec_exists = 0) then
BEGIN
SET newId = newId + INC ;

INSERT INTO target.projectrole (id, name, description) values  (newId, v_name, v_description);

UPDATE source.projectroleactor h set h.projectroleid = newId WHERE h.projectroleid = v_id;
UPDATE source.schemepermissions h SET h.perm_parameter = newId WHERE h.perm_parameter = v_id and h.perm_type='projectrole';

END;
ELSE
BEGIN

select id into existing_id from target.projectrole m  WHERE  m.name = v_name;

UPDATE source.projectroleactor h SET h.projectroleid = existing_id WHERE h.projectroleid = v_id;
UPDATE source.schemepermissions h SET h.perm_parameter = existing_id WHERE h.perm_parameter = v_id and h.perm_type='projectrole';
END;
END IF;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 


SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.projectroleactor;

SELECT max(id)  INTO temp_id_1 from source.projectroleactor ;
SELECT max(id)  INTO temp_id_2 from target.projectroleactor ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_pra_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_pra_id INTO  v_id, v_pid, v_projectroleid, v_roletype, v_roletypeparameter;
SET newId = newId + INC ;
INSERT INTO target.projectroleactor (id, pid, projectroleid, roletype, roletypeparameter) 
values  (newId, v_pid, v_projectroleid, v_roletype, v_roletypeparameter);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_pra_id; 


INSERT INTO target.permissionscheme(id, name, description)  
SELECT h.id, h.name, h.description from source.permissionscheme h WHERE h.name not in (SELECT DISTINCT name FROM target.permissionscheme);



SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.schemepermissions;

SELECT max(id)  INTO temp_id_1 from source.schemepermissions ;
SELECT max(id)  INTO temp_id_2 from target.schemepermissions ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_sp_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_sp_id INTO  v_id, v_scheme, v_permission, v_perm_type, v_perm_parameter, v_permission_key;
SET rec_exists = 0;
-- select 1 into rec_exists from  target.schemepermissions m where m.scheme = v_scheme and m.permission=v_permission and m.perm_parameter= v_perm_parameter and m.perm_type = v_perm_type and m.permission_key = v_permission_key;
 
 
SELECT concat(IFNULL(v_scheme,'NULL'),'-',IFNULL(v_permission,'NULL'),'-',IFNULL(v_perm_type,'NULL'),'-',IFNULL(v_perm_parameter,'NULL'),'-',IFNULL(v_permission_key,'NULL')) into src_context;

SELECT 1 INTO rec_exists FROM target.schemepermissions m 
where  concat(IFNULL(m.scheme,'NULL'),'-',IFNULL(m.permission,'NULL'),'-',IFNULL(m.perm_type,'NULL'),'-',IFNULL(m.perm_parameter,'NULL'),'-',IFNULL(m.permission_key ,'NULL')) = src_context;
 
 
 
IF (rec_exists = 0) then
BEGIN

SET newId = newId + INC ;
INSERT INTO target.schemepermissions (id, scheme, permission, perm_type, perm_parameter, permission_key) 
values  (newId, v_scheme, v_permission, v_perm_type, v_perm_parameter, v_permission_key);

insert into company.tableinfo (table_name) values (concat('A-',id));
END;
END IF;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
-- To remove if duplicates exists
-- delete from target.schemepermissions where id in (11889,11890,11891,11892,11893,11894,11895,11896,11953, 11954);
CLOSE c_sp_id; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateSearchRequest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateSearchRequest`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, V_PROJECTID, new_sr_id, V_FAV_COUNT, v_id, existing_id,temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE V_FILTERNAME, V_AUTHORNAME, V_USERNAME, V_GROUPNAME,  V_FILTERNAME_LOWER, old_filter, new_filter  VARCHAR(255);
DECLARE V_DESCRIPTION text;
DECLARE V_REQCONTENT longtext;
DECLARE c_id CURSOR FOR SELECT h.id, h.FILTERNAME, h.AUTHORNAME, h.DESCRIPTION, h.USERNAME, h.GROUPNAME, h.PROJECTID, h.REQCONTENT, h.FAV_COUNT, h.FILTERNAME_LOWER  
FROM source.searchrequest h;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.searchrequest;

SELECT max(id) INTO temp_id_1 from source.searchrequest ;
SELECT max(id) INTO temp_id_2 from target.searchrequest ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_sr_id = temp_id_1;
else	
	SET new_sr_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, V_FILTERNAME, V_AUTHORNAME, V_DESCRIPTION, V_USERNAME, V_GROUPNAME, V_PROJECTID, V_REQCONTENT, V_FAV_COUNT, V_FILTERNAME_LOWER;
SET REC_EXISTS = 0;
SELECT 1 INTO REC_EXISTS FROM target.searchrequest m where  m.filtername = V_FILTERNAME and m.authorname = V_AUTHORNAME;
IF (REC_EXISTS = 0) then
BEGIN
SET new_sr_id = new_sr_id + INC ;
Insert into target.searchrequest (ID, FILTERNAME, AUTHORNAME, DESCRIPTION, USERNAME, GROUPNAME, PROJECTID, REQCONTENT, FAV_COUNT, FILTERNAME_LOWER) 
VALUES ( new_sr_id, V_FILTERNAME, V_AUTHORNAME, V_DESCRIPTION, V_USERNAME, V_GROUPNAME, V_PROJECTID, V_REQCONTENT, V_FAV_COUNT, V_FILTERNAME_LOWER);
update source.sharepermissions h set h.entityid= new_sr_id where h.entitytype='SearchRequest' and h.entityid = v_id;
update source.favouriteassociations h set h.entityid= new_sr_id where h.entitytype='SearchRequest' and h.entityid = v_id;
UPDATE source.columnlayout h SET h.searchrequest = new_sr_id where h.searchrequest = v_id;
UPDATE source.ao_60db71_rapidview h SET h.saved_filter_id = new_sr_id where h.saved_filter_id = v_id;
UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_sr_id where h.userprefkey='filterId' and h.userprefvalue = v_id;
UPDATE source.filtersubscription h SET h.FILTER_I_D = new_sr_id where h.FILTER_I_D=v_id;
UPDATE source.propertytext set propertyvalue = new_sr_id where propertyvalue= v_id and id in 
(select id from source.propertyentry where entity_name='ApplicationUser' and property_key='user.search.filter.id');

SELECT concat('filter-',v_id) into old_filter;
SELECT concat('filter-',new_sr_id) into new_filter;

UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_filter where h.userprefvalue = old_filter;
END;
ELSE 
SELECT m.id  INTO existing_id FROM target.searchrequest m where  m.filtername = V_FILTERNAME and m.authorname = V_AUTHORNAME;
update source.sharepermissions h set h.entityid= existing_id where h.entitytype='SearchRequest' and h.entityid = v_id;
select ja.pkey, ja.id, p.pname as 'Project' from jiraissue ja, jiraissue jb, project p where ja.pkey=jb.pkey AND ja.id != jb.id and p.id=ja.project;
update source.favouriteassociations h set h.entityid= existing_id where h.entitytype='SearchRequest' and h.entityid = v_id;
UPDATE source.columnlayout h SET h.searchrequest = existing_id where h.searchrequest = v_id;
UPDATE source.ao_60db71_rapidview h SET h.saved_filter_id = existing_id where h.saved_filter_id = v_id;
UPDATE source.gadgetuserpreference h SET h.userprefvalue = existing_id where h.userprefkey ='filterId'  and h.userprefvalue = v_id;
UPDATE source.filtersubscription h SET h.FILTER_I_D = existing_id where h.FILTER_I_D=v_id;

SELECT concat('filter-',v_id) into old_filter;
SELECT concat('filter-',existing_id) into new_filter;

UPDATE source.gadgetuserpreference h SET h.userprefvalue = new_filter where h.userprefvalue = old_filter;

END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 
INSERT INTO target.filtersubscription(id, filter_i_d, username, groupname, last_run, email_on_empty)
SELECT id + 1000, filter_i_d, username, groupname, last_run, email_on_empty FROM source.filtersubscription;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateSharePermissions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateSharePermissions`()
BEGIN









DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id,v_fieldlayout, v_columnlayout, v_entityid,  newId, temp_id_1, temp_id_2, rec_exists,  v_verticalposition, v_searchrequest, v_horizontalposition INT DEFAULT 0;
DECLARE v_entitytype, v_entity_id, v_username, v_sharetype, v_param1, v_param2, v_fieldidentifier, v_ishidden, v_isrequired, v_renderertype VARCHAR(255);
DECLARE v_data longtext;
DECLARE v_lastviewed decimal(18,0);
DECLARE v_description,  v_permission, v_group_id, src_context text;

DECLARE c_id CURSOR FOR SELECT h.id, h.entityid, h.entitytype, h.sharetype, h.param1, h.param2 FROM source.sharepermissions h;
DECLARE c_userhistoryitem CURSOR FOR SELECT id, entitytype, entityid, username, lastviewed, `data` FROM source.userhistoryitem;
DECLARE c_fieldlayoutitem CURSOR FOR SELECT h.id, h.fieldlayout, h.fieldidentifier, h.description, h.verticalposition, h.ishidden, h.isrequired, h.renderertype
FROM source.fieldlayoutitem h order by h.id;
DECLARE c_globalpermissionentry CURSOR FOR SELECT h.id, h.permission, h.group_id FROM source.globalpermissionentry h;
DECLARE c_columnlayout CURSOR FOR SELECT h.id, h.username, h.searchrequest FROM source.columnlayout h;
DECLARE c_columnlayoutitem CURSOR FOR SELECT h.id, h.columnlayout, h.fieldidentifier, h.horizontalposition FROM source.columnlayoutitem h;


DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT max(id) INTO temp_id_1 from source.sharepermissions;
SELECT max(id) INTO temp_id_2 from target.sharepermissions ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.sharepermissions;
OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_entityid, v_entitytype, v_sharetype, v_param1, v_param2;

SET newId = newId + INC;
INSERT INTO target.sharepermissions (id, entityid, entitytype, sharetype, param1, param2)
VALUES (newId, v_entityid, v_entitytype, v_sharetype, v_param1, v_param2);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 



SET LOOPCNT = 1;
	SELECT max(id) INTO temp_id_1 from source.userhistoryitem;
	SELECT max(id) INTO temp_id_2 from target.userhistoryitem ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.userhistoryitem;
OPEN c_userhistoryitem;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_userhistoryitem INTO v_id, v_entitytype, v_entity_id, v_username, v_lastviewed, v_data;
SET rec_exists = 0;
SELECT count(*) into rec_exists FROM target.userhistoryitem m 
where m.entitytype = v_entitytype and m.entityid = v_entity_id and m.username = v_username;

IF (rec_exists = 0) THEN
	SET newId = newId + INC;
	INSERT INTO target.userhistoryitem (id, entitytype, entityid, username, lastviewed, `data`)
	VALUES (newId, v_entitytype, v_entity_id,   v_username, v_lastviewed, v_data);
end if;
	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_userhistoryitem; 

/*
	INSERT INTO target.userassociation (source_name, sink_node_id, sink_node_entity, association_type, sequence, created)
	select source_name, sink_node_id, sink_node_entity, association_type, sequence, created from source.userassociation;



   



	UPDATE source.FIELDLAYOUTITEM h set h.fieldlayout = (select m.id from target.fieldlayout m where m.name = 'Default Field Configuration');



SET LOOPCNT = 1;
	SELECT max(id) INTO temp_id_1 from source.fieldlayoutitem;
	SELECT max(id) INTO temp_id_2 from target.fieldlayoutitem ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.fieldlayoutitem;
OPEN c_fieldlayoutitem;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_fieldlayoutitem INTO v_id, v_fieldlayout, v_fieldidentifier, v_description, v_verticalposition, v_ishidden, v_isrequired, v_renderertype;

	SET newId = newId + INC;
	INSERT INTO target.fieldlayoutitem (id, fieldlayout, fieldidentifier, description, verticalposition, ishidden, isrequired, renderertype)
	VALUES (newId, v_fieldlayout, v_fieldidentifier, v_description, v_verticalposition, v_ishidden, v_isrequired, v_renderertype);

	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_fieldlayoutitem; 



SET LOOPCNT = 1;
	SELECT max(id) INTO temp_id_1 from source.globalpermissionentry;
	SELECT max(id) INTO temp_id_2 from target.globalpermissionentry ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.globalpermissionentry;
OPEN c_globalpermissionentry;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_globalpermissionentry INTO v_id, v_permission, v_group_id;

	SET newId = newId + INC;
	INSERT INTO target.globalpermissionentry (id, permission, group_id)
	VALUES (newId, v_permission, v_group_id);

	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_globalpermissionentry; 



SET LOOPCNT = 1;
	SELECT max(id) INTO temp_id_1 from source.columnlayout;
	SELECT max(id) INTO temp_id_2 from target.columnlayout ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;

SELECT  COUNT(*) INTO ROWCNT FROM source.columnlayout;
OPEN c_columnlayout;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_columnlayout INTO v_id, v_username, v_searchrequest;

-- SELECT count(*)  into rec_exists FROM target.columnlayout m where m.username = v_username and m.searchrequest = v_searchrequest;
SELECT concat(IFNULL(v_username,'NULL'),'-',IFNULL(v_searchrequest,'NULL')) into src_context;

SELECT count(*)  INTO rec_exists FROM target.columnlayout m 
where  concat(IFNULL(m.username,'NULL'),'-',IFNULL(m.searchrequest,'NULL')) = src_context;


IF (rec_exists = 0) THEN
BEGIN 
		SET newId = newId + INC;
		INSERT INTO target.columnlayout (id, username, searchrequest) 	VALUES (newId, v_username, v_searchrequest);
        UPDATE source.columnlayoutitem h SET h.columnlayout = newId where h.columnlayout= v_id;
	
END;
END IF;
	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_columnlayout; 



SET LOOPCNT = 1;
	SELECT max(id) INTO temp_id_1 from source.columnlayoutitem;
	SELECT max(id) INTO temp_id_2 from target.columnlayoutitem ;
	IF (temp_id_1 > temp_id_2) THEN
		SET newId = temp_id_1;
	else	
		SET newId = temp_id_2;
	END IF;
    
    
SELECT  COUNT(*) INTO ROWCNT FROM source.columnlayoutitem;
OPEN c_columnlayoutitem;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_columnlayoutitem INTO v_id, v_columnlayout, v_fieldidentifier, v_horizontalposition;

	SET newId = newId + INC;
	INSERT INTO target.columnlayoutitem (id, columnlayout, fieldidentifier, horizontalposition) VALUES (newId, v_columnlayout, v_fieldidentifier, v_horizontalposition);

	SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_columnlayoutitem; 
*/

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateUserGroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateUserGroup`()
BEGIN
DECLARE new_prj_id,  newId,  ROWCNT, l_last_row_fetched,  v_id, v_property_int_value, existing_id, v_entity_id, v_property_type, v_directory_id, v_active, v_deleted_externally, rec_exists, v_parent_id, v_child_id, v_local, temp_id_1, temp_id_2 INT DEFAULT 0;

DECLARE v_user_name, v_lower_user_name, v_first_name, v_lower_first_name, v_last_name, v_lower_last_name, v_user_key, v_property_key, v_entity_name,
v_display_name, v_lower_display_name, v_email_address, v_lower_email_address, v_credential, v_external_id, v_group_name, v_lower_group_name, 
v_description, v_lower_description, v_group_type, v_membership_type,  v_parent_name, v_lower_parent_name, v_child_name, v_lower_child_name  VARCHAR(255);

DECLARE v_property_string_value, tbl_name text;
DECLARE v_property_text_value longtext;
DECLARE v_created_date, v_updated_date datetime;
DECLARE LOOPCNT, INC INT DEFAULT 1;

DECLARE c_id CURSOR FOR SELECT s.id, s.directory_id, s.user_name, s.lower_user_name, s.active, s.created_date, s.updated_date, s.first_name, 
s.lower_first_name, s.last_name, s.lower_last_name, s.display_name, s.lower_display_name, s.email_address, s.lower_email_address, 
s.credential, s.deleted_externally, s.external_id FROM source.cwd_user s  where directory_id=1 and lower_user_name !='jira-admin-contractor' order by s.id;

DECLARE c_user_group CURSOR FOR SELECT s.id, s.group_name, s.lower_group_name, s.active, s.`local`, s.created_date, 
s.updated_date, s.description, s.lower_description, s.group_type, s.directory_id from source.cwd_group s where s.directory_id = 1 
and s.lower_group_name not in (select lower_group_name from target.cwd_group) order by s.id;

DECLARE c_cwd_membership CURSOR FOR SELECT s.id, s.parent_id, s.child_id, s.membership_type, s.group_type, s.parent_name, s.lower_parent_name, 
s.child_name, s.lower_child_name, s.directory_id FROM source.cwd_membership s where s.directory_id = 1 and s.lower_child_name !='jira-admin-contractor' order by s.id;

DECLARE c_app_user CURSOR FOR SELECT  lower_user_name FROM  target.cwd_user
WHERE  directory_id = 1 and lower_user_name NOT IN (SELECT lower_user_name  FROM   target.app_user);

DECLARE c_all_app_users CURSOR FOR SELECT id, user_key, lower_user_name from source.app_user 
where id in (select distinct entity_id from source.propertyentry where entity_name='ApplicationUser');


DECLARE c_all_pe_application_users CURSOR FOR SELECT id, entity_name, entity_id, property_key, propertytype FROM  source.propertyentry 
where entity_name='ApplicationUser' and entity_id > 0 and property_key='user.avatar.id';

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.cwd_user s where s.directory_id=1 and s.lower_user_name !='jira-admin-contractor';

SELECT max(id) INTO temp_id_1 from source.cwd_user ;
SELECT max(id) INTO temp_id_2 from target.cwd_user ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_directory_id, v_user_name, v_lower_user_name, v_active, v_created_date, v_updated_date, v_first_name, v_lower_first_name, v_last_name, v_lower_last_name,
v_display_name, v_lower_display_name, v_email_address, v_lower_email_address, v_credential, v_deleted_externally, v_external_id;


SET newId = newId + INC ;
INSERT INTO target.cwd_user (id, directory_id, user_name, lower_user_name, active, created_date, updated_date, first_name, lower_first_name, last_name, lower_last_name,
display_name, lower_display_name, email_address, lower_email_address, credential, deleted_externally, external_id) values (newId, v_directory_id, v_user_name, v_lower_user_name, v_active, v_created_date, v_updated_date, v_first_name, v_lower_first_name, v_last_name, v_lower_last_name,
v_display_name, v_lower_display_name, v_email_address, v_lower_email_address, v_credential, v_deleted_externally, v_external_id);

UPDATE target.cwd_membership t SET t.child_id = newId where t.directory_id =1 and t.child_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- CWD_GROUP

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.cwd_group s where s.directory_id = 1 
and s.lower_group_name not in (select lower_group_name from target.cwd_group);

SELECT max(id) INTO temp_id_1 from source.cwd_group ;
SELECT max(id) INTO temp_id_2 from target.cwd_group ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_user_group;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_user_group INTO v_id, v_group_name, v_lower_group_name, v_active, v_local, v_created_date, v_updated_date, v_description, v_lower_description, v_group_type, v_directory_id;


SET newId = newId + INC ;
INSERT INTO target.cwd_group (id, group_name, lower_group_name, active, `local`, created_date, updated_date, description, lower_description, group_type, directory_id) 
values (newId, v_group_name, v_lower_group_name, v_active, v_local, v_created_date, v_updated_date, v_description, v_lower_description, v_group_type, v_directory_id);

UPDATE target.cwd_membership t SET t.parent_id = newId where t.directory_id =1 and t.parent_id = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_user_group; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- CWD_MEMBERSHIP

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM source.cwd_membership s 
where s.directory_id = 1 and s.lower_child_name !='jira-admin-contractor' order by s.id;

SELECT max(id) INTO temp_id_1 from source.cwd_membership ;
SELECT max(id) INTO temp_id_2 from target.cwd_membership ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_cwd_membership;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_cwd_membership INTO v_id, v_parent_id, v_child_id, v_membership_type, v_group_type, v_parent_name, v_lower_parent_name, v_child_name, v_lower_child_name, v_directory_id;


SET newId = newId + INC ;
INSERT INTO target.cwd_membership (id, parent_id, child_id, membership_type, group_type, parent_name, lower_parent_name, child_name, lower_child_name, directory_id) 
values (newId, v_parent_id, v_child_id, v_membership_type, v_group_type, v_parent_name, v_lower_parent_name, v_child_name, v_lower_child_name, v_directory_id);


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_cwd_membership; 



-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- APP_USER of internal directory only

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM  target.cwd_user
WHERE  directory_id = 1 and lower_user_name NOT IN (SELECT lower_user_name  FROM   target.app_user);

SELECT max(id) INTO temp_id_1 from source.app_user ;
SELECT max(id) INTO temp_id_2 from target.app_user ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_app_user;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_app_user INTO v_lower_user_name;


SET newId = newId + INC ;
INSERT INTO target.app_user (id, user_key, lower_user_name) 
values (newId,  v_lower_user_name, v_lower_user_name);


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_app_user; 


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- APP_USER of all users only

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM  source.app_user 
where id in (select distinct entity_id from source.propertyentry where entity_name='ApplicationUser');


SELECT max(id) INTO temp_id_1 from source.app_user ;
SELECT max(id) INTO temp_id_2 from target.app_user ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;


OPEN c_all_app_users;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_all_app_users INTO v_id, v_user_key, v_lower_user_name;
SET rec_exists = 0;
SELECT count(*) INTO rec_exists FROM target.app_user  where user_key = v_user_key or lower_user_name = v_lower_user_name ;

IF (rec_exists=0) THEN
BEGIN
	SET newId = newId + INC ;
	INSERT INTO target.app_user (id, user_key, lower_user_name) 
	values (newId,  v_user_key, v_lower_user_name);
 	UPDATE `source`.propertyentry SET entity_id = newId where entity_name ='ApplicationUser' and entity_id = v_id;
--    insert into company.tableinfo(table_name, ov, nov, nv, nnv) values('Insert',v_id, newId, v_user_key, v_lower_user_name);
END;
ELSE
BEGIN
    SET existing_id = 0;
	SELECT id INTO existing_id FROM target.app_user  where user_key = v_user_key and lower_user_name = v_lower_user_name ;
    -- IF (v_id=10160) THEN
		-- SELECT concat(' rowcnt- Agasandi---',ROWCNT,'-',v_id,'-',existing_id,'-',v_user_key,'-',v_lower_user_name);
    -- END IF; 
    if (existing_id=0) THEN
    select concat('Update -',v_id,'-','-',v_user_key,'-',v_lower_user_name) into tbl_name; 
    else
    select 'Update' into tbl_name;
    end if;
 	UPDATE `source`.propertyentry SET entity_id = existing_id where entity_name ='ApplicationUser' and entity_id = v_id;
--    insert into company.tableinfo(table_name, ov, nov, nv, nnv) values(tbl_name,v_id, existing_id, v_user_key, v_lower_user_name);
END;
END IF;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_all_app_users; 


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22
-- PROPERTYENTRY of all ApplicationUser entity_name only

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM  source.propertyentry where entity_name='ApplicationUser' and entity_id > 0 and property_key='user.avatar.id';


SELECT max(id) INTO temp_id_1 from source.propertyentry ;
SELECT max(id) INTO temp_id_2 from target.propertyentry ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

OPEN c_all_pe_application_users;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_all_pe_application_users INTO v_id, v_entity_name, v_entity_id, v_property_key, v_property_type;
SET rec_exists = 0;
SELECT count(*) INTO rec_exists FROM target.propertyentry  where entity_name ='ApplicationUser' 
and entity_id = v_entity_id and property_key = v_property_key;

IF (rec_exists=0) THEN
BEGIN
	SET newId = newId + INC ;
	INSERT INTO target.propertyentry (id, entity_name, entity_id, property_key, propertytype) 
	values (newId,  v_entity_name, v_entity_id, v_property_key, v_property_type);
    
     CASE 
        WHEN (v_property_type = 1 || v_property_type=2 || v_property_type=3) THEN 
			SELECT propertyvalue INTO v_property_int_value from source.propertynumber where id = v_id;
            IF (v_property_key ='user.avatar.id') THEN
				SET v_property_int_value =v_property_int_value + 100000;
            ELSE
				SET v_property_int_value =v_property_int_value;
            END IF;
            
			INSERT INTO target.propertynumber(id, propertyvalue) values (newId, v_property_int_value);
        WHEN (v_property_type = 5) THEN 
			SELECT propertyvalue INTO v_property_string_value from source.propertystring where id = v_id;
			INSERT INTO target.propertystring(id, propertyvalue) values (newId, v_property_string_value);
        WHEN (v_property_type = 6)THEN 
			SELECT propertyvalue INTO v_property_text_value from source.propertytext where id = v_id;
			INSERT INTO target.propertytext(id, propertyvalue) values (newId, v_property_text_value);
        
	END CASE;
END;
END IF;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_all_pe_application_users; 

 INSERT INTO target.external_entities (id,name,entitytype) select id, name, entitytype from source.external_entities;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateVoteHistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateVoteHistory`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, REC_EXISTS, new_vh_id, v_id, v_issueid,  v_votes,  temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_timestamp datetime;
DECLARE c_id CURSOR FOR SELECT h.id, h.issueid, h.votes, h.timestamp FROM source.votehistory h order by h.id;
 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.votehistory;

SELECT max(id) INTO temp_id_1 from source.votehistory ;
SELECT max(id) INTO temp_id_2 from target.votehistory  ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_vh_id = temp_id_1;
else	
	SET new_vh_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_issueid, v_votes, v_timestamp;

SET new_vh_id = new_vh_id + INC ;
Insert into target.votehistory (id, issueid, votes, timestamp) 
VALUES ( new_vh_id, v_issueid, v_votes, v_timestamp);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateWFS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateWFS`()
BEGIN
DECLARE wfs_id, new_wfs_id, new_wfse_id, newId, v_issue_type, mysql_issue_type, existing_id, ROWCNT, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE INC INT DEFAULT 10;
DECLARE s_name, mysql_scheme_name, v_workflow VARCHAR(100);
DECLARE LOOPCNT INT DEFAULT 1;
DECLARE l_last_row_fetched INT DEFAULT 0;
DECLARE c_id CURSOR FOR SELECT h.ID, h.name FROM source.WORKFLOWSCHEME h  order by h.id;
DECLARE c_wfse_id CURSOR FOR SELECT h.scheme, h.workflow, h.issuetype FROM source.workflowschemeentity h order by h.workflow, h.issuetype;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.WORKFLOWSCHEME;
SELECT FLOOR(max(id)/10 ) * 10  INTO temp_id_1 from source.WORKFLOWSCHEME ;
SELECT FLOOR(max(id)/10 ) * 10 INTO temp_id_2 from target.WORKFLOWSCHEME ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_wfs_id = temp_id_1;
else	
	SET new_wfs_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO wfs_id, s_name;
SET mysql_scheme_name = "false";
SELECT  'true' INTO mysql_scheme_name FROM  target.WORKFLOWSCHEME m  WHERE  m.name = s_name;
IF (mysql_scheme_name = 'false') then
BEGIN
SET new_wfs_id = new_wfs_id + INC ;
INSERT INTO target.WORKFLOWSCHEME (ID, NAME, DESCRIPTION) SELECT new_wfs_id, NAME, DESCRIPTION FROM source.WORKFLOWSCHEME old WHERE old.ID = wfs_id;
UPDATE source.nodeassociation h set h.sink_node_id = new_wfs_id where h.sink_node_entity = 'WorkflowScheme' and h.sink_node_id = wfs_id;
END; 
ELSE

SELECT  id INTO existing_id FROM  target.WORKFLOWSCHEME m  WHERE  m.name = s_name;
UPDATE source.nodeassociation h set h.sink_node_id = existing_id where h.sink_node_entity = 'WorkflowScheme' and h.sink_node_id = wfs_id;

END IF;

 
	  
    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

SELECT FLOOR(max(id)/10 ) * 10  INTO temp_id_1 from source.workflowschemeentity ;
SELECT FLOOR(max(id)/10 ) * 10 INTO temp_id_2 from target.workflowschemeentity ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_wfse_id = temp_id_1;
else	
	SET new_wfse_id = temp_id_2;
END IF;
  
SET LOOPCNT = 1;
SET ROWCNT = 0;
SELECT COUNT(*) INTO ROWCNT FROM source.workflowschemeentity;
OPEN c_wfse_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_wfse_id INTO wfs_id, v_workflow, v_issue_type;
SET new_wfse_id = new_wfse_id + INC ;
 SELECT new.id into newId FROM target.WORKFLOWSCHEME new, source.WORKFLOWSCHEME old WHERE  old.name = new.name and old.id !=new.id and old.id = wfs_id;
 
 IF (UPPER(TRIM(v_workflow)) <> UPPER(TRIM('classic default workflow'))) THEN
	IF (v_issue_type <> 0) THEN
	BEGIN
		SELECT m.id INTO mysql_issue_type FROM target.ISSUETYPE m WHERE UPPER(TRIM(m.pname)) = ( SELECT UPPER(TRIM(h.pname)) from source.ISSUETYPE h where h.id = v_issue_type) ;
		INSERT INTO target.workflowschemeentity (ID,SCHEME,WORKFLOW, ISSUETYPE) values (new_wfse_id,newId, v_workflow, mysql_issue_type );
	END;
	else
	BEGIN
		INSERT INTO target.workflowschemeentity (ID,SCHEME,WORKFLOW, ISSUETYPE) values ( new_wfse_id,newId, v_workflow, v_issue_type );
	END;
	END IF;
 END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_wfse_id;

INSERT INTO target.trustedapp (ID, APPLICATION_ID, NAME, PUBLIC_KEY, IP_MATCH, URL_MATCH, TIMEOUT, CREATED, CREATED_BY, UPDATED, UPDATED_BY) 
SELECT ID, APPLICATION_ID, NAME, PUBLIC_KEY, IP_MATCH, URL_MATCH, TIMEOUT, CREATED, CREATED_BY, UPDATED, UPDATED_BY FROM source.trustedapp;

INSERT INTO  target.SERVICECONFIG (ID, DELAYTIME, CLAZZ, SERVICENAME) SELECT 11110, h.DELAYTIME, h.CLAZZ, h.SERVICENAME FROM source.SERVICECONFIG h WHERE h.SERVICENAME  = 'JIRA Index Snapshot Service';
INSERT INTO  target.SERVICECONFIG (ID, DELAYTIME, CLAZZ, SERVICENAME) SELECT 11120, h.DELAYTIME, h.CLAZZ, h.SERVICENAME FROM source.SERVICECONFIG h WHERE h.SERVICENAME  = 'Jira Incoming Comment';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateWorkflowScheme` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateWorkflowScheme`()
BEGIN
DECLARE wfs_id, new_wfs_id, new_wfse_id, newId, v_issue_type, rec_exists, v_scheme,  existing_id, ROWCNT, temp_id_1, temp_id_2 INT DEFAULT 0;

DECLARE v_name, v_workflow VARCHAR(255);
DECLARE v_description text;

DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE l_last_row_fetched INT DEFAULT 0;
DECLARE c_id CURSOR FOR SELECT h.ID, h.`name`, h.description FROM source.WORKFLOWSCHEME h  order by h.id;
DECLARE c_wfse_id CURSOR FOR SELECT h.id, h.scheme, h.workflow, h.issuetype FROM source.workflowschemeentity h order by h.workflow, h.issuetype;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.WORKFLOWSCHEME;
SELECT max(id) INTO temp_id_1 from source.WORKFLOWSCHEME ;
SELECT max(id) INTO temp_id_2 from target.WORKFLOWSCHEME ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_wfs_id = temp_id_1;
else	
	SET new_wfs_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO wfs_id, v_name, v_description;
SET rec_exists = 0;
SELECT  count(*) INTO rec_exists FROM  target.workflowscheme m  WHERE  m.`name` = v_name;
IF (rec_exists = 0) then
BEGIN
SET new_wfs_id = new_wfs_id + INC ;
INSERT INTO target.workflowscheme (ID, `name`, DESCRIPTION) values (new_wfs_id, v_name, v_description);
UPDATE source.nodeassociation h SET h.sink_node_id = new_wfs_id where h.sink_node_entity = 'WorkflowScheme' and h.sink_node_id = wfs_id;
UPDATE source.workflowschemeentity h SET h.scheme = new_wfs_id where h.scheme = wfs_id;
END; 
ELSE

SELECT  id INTO existing_id FROM  target.workflowscheme m  WHERE  m.name = v_name;
UPDATE source.nodeassociation h set h.sink_node_id = existing_id where h.sink_node_entity = 'WorkflowScheme' and h.sink_node_id = wfs_id;
UPDATE source.workflowschemeentity h SET h.scheme = existing_id where h.scheme = wfs_id;

END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

SELECT max(id) INTO temp_id_1 from source.workflowschemeentity ;
SELECT max(id) INTO temp_id_2 from target.workflowschemeentity ;
IF (temp_id_1 > temp_id_2) THEN
	SET new_wfse_id = temp_id_1;
else	
	SET new_wfse_id = temp_id_2;
END IF;
  
SET LOOPCNT = 1;
SELECT COUNT(*) INTO ROWCNT FROM source.workflowschemeentity;
OPEN c_wfse_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_wfse_id INTO wfs_id, v_scheme, v_workflow, v_issue_type;
SET new_wfse_id = new_wfse_id + INC ;
  
 SELECT  count(*) INTO rec_exists FROM  target.workflowschemeentity m  WHERE  m.`workflow` = v_workflow and m.scheme = v_scheme and m.issuetype = v_issue_type;
 
	IF (rec_exists = 0) THEN
	BEGIN
		
		INSERT INTO target.workflowschemeentity (ID,SCHEME,WORKFLOW, ISSUETYPE) values (new_wfse_id,v_scheme, v_workflow, v_issue_type );
	END;
	END IF;

    SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_wfse_id;

INSERT INTO target.trustedapp (ID, APPLICATION_ID, NAME, PUBLIC_KEY, IP_MATCH, URL_MATCH, TIMEOUT, CREATED, CREATED_BY, UPDATED, UPDATED_BY) 
SELECT ID, APPLICATION_ID, NAME, PUBLIC_KEY, IP_MATCH, URL_MATCH, TIMEOUT, CREATED, CREATED_BY, UPDATED, UPDATED_BY FROM source.trustedapp;

INSERT INTO  target.SERVICECONFIG (ID, DELAYTIME, CLAZZ, SERVICENAME) SELECT 11110, h.DELAYTIME, h.CLAZZ, h.SERVICENAME FROM source.SERVICECONFIG h WHERE h.SERVICENAME  = 'JIRA Index Snapshot Service';
INSERT INTO  target.SERVICECONFIG (ID, DELAYTIME, CLAZZ, SERVICENAME) SELECT 11120, h.DELAYTIME, h.CLAZZ, h.SERVICENAME FROM source.SERVICECONFIG h WHERE h.SERVICENAME  = 'Jira Incoming Comment';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `populateWorklog` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateWorklog`()
BEGIN

DECLARE l_last_row_fetched, LOOPCNT, INC INT DEFAULT 1;
DECLARE ROWCNT, v_id, v_issueid, v_rolelevel, v_timeworked, new_id, temp_id_1, temp_id_2 INT DEFAULT 0;
DECLARE v_grouplevel, v_author,  v_updateauthor VARCHAR(255);
DECLARE v_worklogbody   longtext;

DECLARE v_created,  v_updated, v_startdate DATETIME;
DECLARE c_id CURSOR FOR SELECT h.id, h.issueid, h.author, h.grouplevel, h.rolelevel, h.worklogbody, h.created, h.updateauthor, h.updated, h.startdate, h.timeworked FROM source.worklog h;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.worklog;

SELECT max(id) INTO temp_id_1 from source.worklog;
SELECT max(id) INTO temp_id_2 from target.worklog;
IF (temp_id_1 > temp_id_2) THEN
	SET new_id = temp_id_1;
else	
	SET new_id = temp_id_2;
END IF;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_issueid, v_author, v_grouplevel, v_rolelevel, v_worklogbody, v_created, v_updateauthor, v_updated, v_startdate, v_timeworked;

SET new_id = new_id + INC ;
INSERT INTO target.worklog (id, issueid, author, grouplevel, rolelevel, worklogbody, created, updateauthor, updated, startdate, timeworked)
VALUES (new_id, v_issueid, v_author, v_grouplevel, v_rolelevel, v_worklogbody, v_created, v_updateauthor, v_updated, v_startdate, v_timeworked);

update source.changeitem h set h.oldvalue = new_id where h.field in ('WorklogId') and h.oldvalue=  v_id;
update source.changeitem h set h.oldstring = new_id where h.field in ('WorklogId') and h.oldstring=  v_id;
SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `updateCustomFieldValues` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCustomFieldValues`()
BEGIN
DECLARE new_prj_id,  newId,  ROWCNT, l_last_row_fetched, v_id, v_customfield, v_groupid, v_customfieldconfig, temp_id_1, temp_id_2 INT DEFAULT 0;

DECLARE LOOPCNT, INC INT DEFAULT 1;
DECLARE v_name, v_customvalue, v_fieldtype, v_field VARCHAR(255);
DECLARE v_oldvalue, v_oldstring, v_newvalue, v_newstring longtext;
DECLARE v_start_date bigint;
DECLARE c_id CURSOR FOR SELECT id, `name`, start_date FROM source.ao_60db71_sprint order by id;
DECLARE c_cfo CURSOR FOR SELECT  id, customfield, customfieldconfig, customvalue from SOURCE.customfieldoption where customfield=(
select id from target.customfield where cfname='Manager' and description is not null);
DECLARE c_ci_sprint CURSOR FOR SELECT id, groupid, fieldtype, field, oldvalue, oldstring, newvalue, newstring FROM SOURCE.changeitem  where field='Sprint'  and id > 46731;


DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_last_row_fetched=1;

SELECT  COUNT(*) INTO ROWCNT FROM source.ao_60db71_sprint;

OPEN c_id;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_id INTO v_id, v_name, v_start_date;

SELECT t.id INTO newId FROM target.ao_60db71_sprint t  where t.`name` = v_name and t.start_date = v_start_date;

UPDATE target.customfieldvalue set stringvalue = newId where customfield=10005 and stringvalue = v_id;


SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_id; 

/*
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- UPDATE customfield manager in CustomFieldValue
-- This needs recheck
--  DONT USE THIS ANYMORE. ALREADY TAKEN CARE IN CUSTOMFIELDOPTION

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM SOURCE.customfieldoption where customfield=(
select id from target.customfield where cfname='Manager' and description is not null);

OPEN c_cfo;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_cfo INTO v_id,v_customfield,v_customfieldconfig, v_customvalue;

SELECT t.id INTO newId FROM target.customfieldoption t  where t.customfield = v_customfield 
and t.customfieldconfig = v_customfieldconfig and t.customvalue = v_customvalue;

UPDATE target.customfieldvalue set stringvalue = newId where customfield=
(select id from target.customfield where cfname='Manager' and description is not null) and stringvalue = v_id;

UPDATE target.changeitem set oldvalue = newId where field='Manager' and oldvalue = v_id;
UPDATE target.changeitem set newvalue = newId where field='Manager' and newvalue = v_id;

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_cfo; 


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- UPDATE SPRINT FIELD IN changeitem
--  DONT USE THIS ANYMORE. ALREADY TAKEN CARE IN CHANGE ITEM

SELECT max(id) INTO temp_id_1 from `source`.changeitem ;
SELECT max(id) INTO temp_id_2 from target.changeitem ;
IF (temp_id_1 > temp_id_2) THEN
	SET newId = temp_id_1;
else	
	SET newId = temp_id_2;
END IF;

SET LOOPCNT = 1;
SELECT  COUNT(*) INTO ROWCNT FROM SOURCE.changeitem  where field='Sprint' and id > 46731;

OPEN c_ci_sprint;
ID_cursor: WHILE LOOPCNT <= ROWCNT DO
FETCH c_ci_sprint INTO v_id,v_groupid, v_fieldtype, v_field, v_oldvalue, v_oldstring, v_newvalue, v_newstring;

-- SET newId = newId + INC;
-- INSERT INTO target.changeitem (id, groupid, fieldtype, field, oldvalue, oldstring, newvalue, newstring) values
-- (newId, v_groupid, v_fieldtype, v_field, getSprints(v_oldvalue), oldstring, getSprints(v_newvalue), newstring);


UPDATE target.changeitem set oldvalue = getSprints(v_oldvalue) where oldvalue = v_oldvalue ; 

-- insert into company.tableinfo(id, ov, nov, nv, nnv, oid) values (newId,v_oldvalue, getSprints(v_oldvalue), v_newvalue, getSprints(v_newvalue), v_id);

SET LOOPCNT = LOOPCNT + 1;
END WHILE ID_cursor;
CLOSE c_ci_sprint; 
*/
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `updateSequence` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateSequence`()
BEGIN
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.jiraaction) where seq_name = 'Action';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.app_user) where seq_name = 'ApplicationUser';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.avatar) where seq_name = 'Avatar';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.changegroup) where seq_name = 'ChangeGroup';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.changeitem) where seq_name = 'ChangeItem';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.component) where seq_name = 'Component';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.customfield) where seq_name = 'CustomField';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.customfieldoption) where seq_name = 'CustomFieldOption';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.customfieldvalue) where seq_name = 'CustomFieldValue';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.fieldconfiguration) where seq_name = 'FieldConfiguration';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.configurationcontext) where seq_name = 'ConfigurationContext';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.external_entities) where seq_name = 'ExternalEntity';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.fieldconfigscheme) where seq_name = 'FieldConfigScheme';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.FileAttachment) where seq_name = 'FileAttachment';

update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.cwd_group) where seq_name = 'Group';

update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.jiraissue) where seq_name = 'Issue';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.IssueType) where seq_name = 'IssueType';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.IssueTypeScreenScheme) where seq_name = 'IssueTypeScreenScheme';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.IssueTypeScreenSchemeEntity) where seq_name = 'IssueTypeScreenSchemeEntity';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.IssueLink) where seq_name = 'IssueLink';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.IssueLinkType) where seq_name = 'IssueLinkType';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.Label) where seq_name = 'Label';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.cwd_membership) where seq_name = 'Membership';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.NotificationScheme) where seq_name = 'NotificationScheme';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.OS_CurrentStep) where seq_name = 'OSCurrentStep';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.OS_wfEntry) where seq_name = 'OSWorkflowEntry';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.PermissionScheme) where seq_name = 'PermissionScheme';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.propertyentry) where seq_name = 'OSPropertyEntry';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.PortalPage) where seq_name = 'PortalPage';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.PortletConfiguration) where seq_name = 'PortletConfiguration';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.Project) where seq_name = 'Project';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.Project_Key) where seq_name = 'ProjectKey';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.ProjectRole) where seq_name = 'ProjectRole';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.ProjectRoleActor) where seq_name = 'ProjectRoleActor';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.RemoteLink) where seq_name = 'RemoteIssueLink';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.Resolution) where seq_name = 'Resolution';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.SchemePermissions) where seq_name = 'SchemePermissions';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.SearchRequest) where seq_name = 'SearchRequest';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.ServiceConfig) where seq_name = 'ServiceConfig';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.SharePermissions) where seq_name = 'SharePermissions';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.issueStatus) where seq_name = 'Status';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.trustedapp) where seq_name = 'TrustedApplication';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.cwd_user) where seq_name = 'User';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.userhistoryitem) where seq_name = 'UserHistoryItem';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.VoteHistory) where seq_name = 'VoteHistory';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.WorkflowScheme) where seq_name = 'WorkflowScheme';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.WorkflowSchemeEntity) where seq_name = 'WorkflowSchemeEntity';
update target.sequence_value_item set seq_id = (SELECT FLOOR(max(id)/10 + 1 ) * 10 from target.Worklog) where seq_name = 'Worklog';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-01-19 14:39:48
