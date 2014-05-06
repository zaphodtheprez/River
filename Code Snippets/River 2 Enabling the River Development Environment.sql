-- RIVER DEV SERVER
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'SYSTEM' ) SET ('rdl','developerrole') = 'DevRole' WITH RECONFIGURE;

---------------------------------------------------------------------------------------------------------- 
-- CREATE_RIVER_ENVIRONMENT(environment_name, ?)
--
-- Creates an SAP HANA repository package for SAP River development, and two development roles (design time and runtime).
-- Also creates a DB schema with the same name, which is used for SAP River runtime objects.
--
-- Note: the environment-name (package and schema name) must be system-wide unique.
-- V1.0
----------------------------------------------------------------------------------------------------------
DROP PROCEDURE CREATE_RIVER_ENVIRONMENT;
CREATE PROCEDURE CREATE_RIVER_ENVIRONMENT (in pkgName nvarchar(256) , out packageCreationResult BLOB)
LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS 
	RTRoleSuffix nvarchar(5000); 
	RTRole String; 
	configured integer := 0; 
	RTRoleExists Integer := 0; 
	DTRole String; 
	DTRoleExists Integer := 0; 
	jsonStr String; 
	schemaExists Integer := 0;
BEGIN 
	DECLARE NOT_CONFIGURED_COND CONDITION FOR SQL_ERROR_CODE 10001; 
	DECLARE EXIT HANDLER FOR NOT_CONFIGURED_COND SELECT ::SQL_ERROR_CODE, ::SQL_ERROR_MESSAGE FROM DUMMY;
	-- Create Package 
	jsonStr := '{"action":"create","what":"package","package" :"' || pkgName ||'","orig_lang" : "en","tenant" : "","description":"' || pkgName || '","responsible":""}'; 
	call REPOSITORY_REST(:jsonStr , packageCreationResult); 
	-- Create RT Role (if not yet exists). 
	select count(value) into configured from "SYS"."M_INIFILE_CONTENTS" where section = 'rdl' and key= 'developerrole'; 
	if :configured = 0 then 
		SIGNAL NOT_CONFIGURED_COND SET MESSAGE_TEXT = 'You must first configure the River Developer Role.'; 
	end if; 
	select value into RTRoleSuffix from "SYS"."M_INIFILE_CONTENTS" where section = 'rdl' and key= 'developerrole'; 
	RTRole := pkgName || '$' || :RTRoleSuffix; 
	SELECT top 1 count(1) into RTRoleExists FROM "SYS"."ROLES" WHERE "ROLE_NAME" = :RTRole; 
	if :RTRoleExists = 0 then 
		exec 'create role "' || RTRole || '"'; 
	end if;
	-- Note: read/execute privileges to activated runtime objects are dynamically granted to RTRole during activation
	-- Create DT Role (if not yet exists). 
	DTRole := pkgName || '$' || 'DTRole'; 
	SELECT top 1 count(1) into DTRoleExists FROM "SYS"."ROLES" WHERE "ROLE_NAME" = :DTRole; 
	if :DTRoleExists = 0 then 
		exec 'create role "' || DTRole || '"'; 
	end if; 
	-- Assign relevant permissions to DT Role
	exec 'grant execute on REPOSITORY_REST to "' || :DTRole || '"'; 
	exec 'grant REPO.READ on "sap.hana.rdl" to "' || :DTRole || '"'; 
	exec 'grant REPO.READ,REPO.EDIT_NATIVE_OBJECTS, REPO.ACTIVATE_NATIVE_OBJECTS, REPO.MAINTAIN_NATIVE_PACKAGES on "' || pkgName || '" to "' || :DTRole || '"'; 
	call _SYS_REPO.grant_activated_role('sap.hana.xs.debugger::Debugger', :DTRole); 
	-- Create Schema (not mandatory, since it will be created during activation if it doesn’t exist, but convenient) 
	SELECT top 1 count(1) into schemaExists FROM "SYS"."SCHEMAS" WHERE "SCHEMA_NAME" = :pkgName; 
	if :schemaExists = 0 then 
		exec 'create schema "' || pkgName || '" owned by _SYS_REPO'; 
	end if;
END;

----------------------------------------------------------------------------------------------------------
-- ADD_USER_TO_RIVER_DT_ROLE(dt_user_name, password, existing_environment_name)
--
-- Create the user if doesn't exist, and provide DTRole privileges to existing environment
-- V1.0 
----------------------------------------------------------------------------------------------------------
DROP PROCEDURE ADD_USER_TO_RIVER_DT_ROLE;
CREATE PROCEDURE ADD_USER_TO_RIVER_DT_ROLE(in userName NVARCHAR(256), in passwd NVARCHAR(256), in pkgName nvarchar(256))
LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS 
	DTName String; 
	userExists Integer := 0; 
	DTRole String; 
BEGIN 
	-- Create DT User & grant DTRole 
	DTName := upper(userName); 
	SELECT top 1 count(1) into userExists FROM "SYS"."USERS" WHERE "USER_NAME" = :DTName; 
	if :userExists = 0 then 
		exec 'create user ' || :DTName || ' password ' || passwd; 
	end if; 
	DTRole := pkgName || '$' || 'DTRole'; 
	exec 'grant "' || :DTRole || '" to ' || :DTName;
END;

--------------------------------------------------------------------------------------------------------
-- ADD_USER_TO_RIVER_RT_ROLE(dt_user_name, password, existing_environment_name)
--
-- Create the user if doesn't exist, and provide RTRole privileges to existing environment
-- V1.0
--------------------------------------------------------------------------------------------------------
DROP PROCEDURE ADD_USER_TO_RIVER_RT_ROLE;
CREATE PROCEDURE ADD_USER_TO_RIVER_RT_ROLE(in userName NVARCHAR(256), in passwd NVARCHAR(256), in pkgName nvarchar(256))
LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS 
	RTName String; 
	userExists Integer := 0; 
	configured integer := 0; 
	RTRoleSuffix nvarchar(5000); 
	RTRole String;
BEGIN 
	DECLARE NOT_CONFIGURED_COND CONDITION FOR SQL_ERROR_CODE 10001; 
	DECLARE EXIT HANDLER FOR NOT_CONFIGURED_COND SELECT ::SQL_ERROR_CODE, ::SQL_ERROR_MESSAGE FROM DUMMY;
	-- Create & Grant Roles to User.
	RTName := upper(userName); 
	SELECT top 1 count(1) into userExists FROM "SYS"."USERS" WHERE "USER_NAME" = :RTName; 
	if :userExists = 0 then 
		exec 'create user ' || :RTName || ' password ' || passwd; 
	end if; 
	select count(value) into configured from "SYS"."M_INIFILE_CONTENTS" where section = 'rdl' and key= 'developerrole'; 
	if configured=0 then 
		SIGNAL NOT_CONFIGURED_COND SET MESSAGE_TEXT = 'You must first configure the River Developer Role'; 
	end if; 
	select value into RTRoleSuffix from "SYS"."M_INIFILE_CONTENTS" where section = 'rdl' and key= 'developerrole'; 
	RTRole := pkgName || '$' || :RTRoleSuffix; 
	exec 'grant "' || :RTRole || '" to ' || :RTName;
END;
