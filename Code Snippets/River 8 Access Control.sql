delete from "RiverPackage"."RiverPackage::HelloWorld.Employee";

insert into "RiverPackage"."RiverPackage::HelloWorld.Employee" 
	("userId", "name", "salary") values ('M1', 'Joe the Manager', 100000);
insert into "RiverPackage"."RiverPackage::HelloWorld.Employee" 
	("userId", "name", "salary", "manager.userId") values ('E1', 'Denys the Employee', 80000, 'M1');
insert into "RiverPackage"."RiverPackage::HelloWorld.Employee" 
	("userId", "name", "salary", "manager.userId") values ('E2', 'Jamie the Employee', 75000, 'M1');

select * from "RiverPackage"."RiverPackage::HelloWorld.Employee";
	