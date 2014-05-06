CALL CREATE_RIVER_ENVIRONMENT ('RiverPackage', ?);
CALL ADD_USER_TO_RIVER_DT_ROLE('RIVERDEV', 'pw if new user','RiverPackage');
CALL ADD_USER_TO_RIVER_RT_ROLE('RIVERDEV', 'pw if new user','RiverPackage');
