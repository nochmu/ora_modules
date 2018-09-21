# A simple module system for the Oracle Database

# Definition: Module 
A module is a schema with dependency management. 
A module can publish some objects so that other modules can use them.

## Specification

```
CREATE PROCEDURE 
/* Installs the module for a specific user.
   %param p_user   - install for this user
   %param p_prefix - Prefix for the synonyms. Using a prefix allows to install multiple versions.
*/
install(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
```

```
CREATE PROCEDURE 
/* Uninstalls the module for a specific user.
   %param p_user - uninstall for this user
   %param p_prefix - Prefix for the installed synonyms.
*/
uninstall(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
```

## Default Implementation
A default implementation can be installed with `make_modules.sql`. 
```sql
-- connected as DBA
SYS@localhost:1531/MYPDB> ALTER SESSION SET current_schema=<my_module>;
SYS@localhost:1531/MYPDB> @make_modules 
SYS@localhost:1531/MYPDB> GRANT <my_module>_users TO test_user; 
```


# Run the test suite

```bash
$ export DEV_DB="localhost:1531/MYPDB"
$ export DEV_DB_SYS="sys/welcome-1"

$ make clean all

```
