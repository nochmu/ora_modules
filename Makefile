.DEFAULT_GOAL = all

SQLPLUS = sqlplus


db_sys  = ${DEV_DB_SYS} as SYSDBA
db_dba  = ${DEV_DB_DBA}
db_test = test/test
TWO_TASK = ${DEV_DB}


sql_exec = echo 'exit' | $(SQLPLUS) -L -S
sql_exec_SYS  = $(sql_exec) $(db_sys)
sql_exec_DBA  = $(sql_exec) $(db_dba)
sql_exec_TEST = $(sql_exec) $(db_test)


.PHONY: test_all  install all clean enter


test: 
	$(sql_exec_DBA)  @test_clean.sql
	$(sql_exec_DBA)  @test_setup.sql
	$(sql_exec_TEST) @test.sql

enter:
	$(SQLPLUS) -L $(db_sys)


test_all: test install test
	@ echo 'all: done.'

