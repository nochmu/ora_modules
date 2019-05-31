# A simple module system for the Oracle Database

# Definition: Module 
A module is a schema with dependency management. 
A module can publish some objects (called `api`) so that other modules can use them.


### Create a module
```sql
-- connected as DBA
SQL> ALTER SESSION SET current_schema=plutl;
SQL> @make_module
```

### Requirements 
- Oracle Database 12.2 or newer


# Run the test suite

```bash
$ export DEV_DB="localhost:1531/PDB"
$ export DEV_DB_DBA="SYSTEM/Oracle12c3"

$ make test 

```
