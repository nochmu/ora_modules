.DEFAULT_GOAL = all

SQLPLUS = sql

db_host = ${DEV_DB}
db_sys  = ${DEV_DB_SYS}
db_test = test/test

sql_exec = echo 'exit' | $(SQLPLUS) -L -S

.PHONY: test install all clean enter

test: test.sql
	$(sql_exec) $(db_test)@$(db_host) @test.sql

install: install.sql
	$(sql_exec) $(db_sys)@$(db_host) as SYSDBA @install.sql

clean: clean.sql
	$(sql_exec) $(db_sys)@$(db_host) as SYSDBA @clean.sql

enter:
	$(SQLPLUS) -L $(db_sys)@$(db_host) as SYSDBA

all: clean install test
	@ echo 'all: done.'

