# A simple module system for the Oracle Database

# Definition: Module 
A module is a schema with dependency management. 
A module can publish some objects so that other modules can use them.

## Specification v1

```sql
CREATE PROCEDURE 
/* Installs the module for a specific user.
   %param p_user   - install for this user
*/
install(
    p_user varchar2 default USER
)
AUTHID current_user
```

```sql
CREATE PROCEDURE 
/* Uninstalls the module for a specific user.
   %param p_user - uninstall for this user
*/
uninstall(
    p_user varchar2 default USER
)
AUTHID current_user
```

## Default Implementation
A default implementation can be installed with 

`@make_module [<api_role> [<definition_table>]]`. 
```
api_role: 
    To use the module, the <api_role> must be granted. 
    The role must not yet exist.
    default value: <module_schema>_users

definition_table: 
    The API definition is stored in a table. The name can be changed. 
    default value: OMM_API_OBJECT_TBL
```

### Example 
```sql
-- connected as DBA
SQL> ALTER SESSION SET current_schema=plsql_utils;
SQL> @make_modules 
SQL> GRANT plsql_utils_users TO test_user; 
```



### Define API Member

See [test_define_api.sql](test_define_api.sql) how to define a new  API member.



# Run the test suite

```bash
$ export DEV_DB="localhost:1531/PDB"
$ export DEV_DB_DBA="SYSTEM/Oracle12c3"

$ make test_all  

```
