
.DEFAULT_GOAL = all

SQLPLUS = sqlplus
SQLPATH += $(shell pwd)/sql:$(PATH)

db_sys  = ${DEV_DB_SYS} as SYSDBA
db_dba  = ${DEV_DB_DBA}
db_test = test/test
TWO_TASK = ${DEV_DB}


sql_exec = echo 'exit' | $(SQLPLUS) -L -S
sql_exec_SYS  = $(sql_exec) $(db_sys)
sql_exec_DBA  = $(sql_exec) $(db_dba)
sql_exec_TEST = $(sql_exec) $(db_test)


.PHONY: test install all clean enter


test: 
	$(sql_exec_DBA)  @test/test_clean.sql
	$(sql_exec_DBA)  @test/test_setup.sql
	$(sql_exec_TEST) @test/test.sql
	@ echo 'all: done.'
  
enter:
	$(SQLPLUS) -L $(db_sys)
