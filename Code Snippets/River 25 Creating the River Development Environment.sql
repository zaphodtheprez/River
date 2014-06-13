call "_SYS_BIC"."sap.hana.rdl.setup::create_river_environment" ('RiverPackage', ?);
call "_SYS_BIC"."sap.hana.rdl.setup::add_user_to_river_dt_role" ('DEVUSER','Password123', 'RiverPackage');
call "_SYS_BIC"."sap.hana.rdl.setup::add_user_to_river_rt_role" ('DEVUSER','Password123', 'RiverPackage');
