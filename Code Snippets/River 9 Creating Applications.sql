CALL CREATE_RIVER_ENVIRONMENT ('RiverEnvironment', ?);
CALL ADD_USER_TO_RIVER_DT_ROLE('RIVERDEV', 'passwordGoesHere', 'RiverEnvironment');
CALL ADD_USER_TO_RIVER_RT_ROLE('RIVERDEV', '', 'RiverEnvironment');
