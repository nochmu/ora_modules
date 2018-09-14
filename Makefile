.DEFAULT_GOAL = all

db_host = ${DEV_DB}
db_sys  = ${DEV_DB_SYS}
db_test = test/test

.PHONY: test install all

test: test.sql
	echo 'exit' | sqlplus -L -S $(db_test)@$(db_host) @test.sql

install: install.sql
	echo 'exit' | sqlplus -L -S $(db_sys)@$(db_host) as SYSDBA @install.sql


all: install test


