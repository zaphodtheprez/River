-- set up debugging
ALTER SYSTEM ALTER CONFIGURATION ('xsengine.ini', 'SYSTEM') SET ('debugger', 'enabled') = 'true' WITH RECONFIGURE;

--CALL GRANT_ACTIVATED_ROLE('sap.hana.xs.debugger::Debugger','userGoesHere');
