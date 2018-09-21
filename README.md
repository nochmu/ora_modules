# A simple module system for the Oracle Database

# Module 
A module is a schema with dependency management. 
A module can publish some objects so that other modules can use them.

## Specification

```
/* Installs the module for a specific user.
   %param p_user   - install for this user
   %param p_prefix - Prefix for the synonyms. Using a prefix allows to install multiple versions.
*/
CREATE PROCEDURE install(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
```

```
/* Uninstalls the module for a specific user.
   %param p_user - uninstall for this user
   %param p_prefix - Prefix for the installed synonyms.
*/
CREATE PROCEDURE uninstall(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
```



# Run the test suite

```bash
$ export DEV_DB="localhost:1531/MYPDB"
$ export DEV_DB_SYS="sys/welcome-1"

$ make clean all

```