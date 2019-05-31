create or replace PROCEDURE 
-- Contains the module definition.
om_module_define
AUTHID definer
AS
BEGIN
    -- Define the basic data about the module. 
    om_helper_pkg.define_module(
        p_name        => 'My Module',                        -- The name for the module 
        p_key         => 'nochmu.net/ora_modules/my_module', -- An unique identifier 
        p_version     => '1.0.0',                            -- Version number
        p_description => 'A simple module.'                  -- A short description
    );  
    -- Add some additional metadata.
    -- The metadata are simple key-value. 
    om_helper_pkg.set_metadata('url', 'https://github.com/nochmu/ora_modules'); 
    om_helper_pkg.set_metadata('license', 'Beerware'); 
    om_helper_pkg.set_metadata('maintainer', 'https://github.com/nochmu'); 
    
    
    -- Add the API Objects to the module definition.   
    --   The following statement defines the grants
    --   and a synonym and creates some documentation. 
    om_helper_pkg.add_api_object(
        p_name        => 'EXT_GET_THE_ANSWER',                 -- The synonym name    
        p_object      => 'HELLO_WORLD',                        -- The object name
        p_privileges  => om_helper_pkg.t_privilege_list('EXECUTE'), -- Grant these privileges
        p_description => 'The only truth!'                     -- A short description
    ); 
   
 
    -- If necessary, the api definition can also be created separately. 
    om_helper_pkg.add_synonym(
        p_synonym     => 'EXT_HELLO_WORLD',             -- The synonym name    
        p_object      => 'HELLO_WORLD',                 -- The object name 
        p_description => 'A simple hello world procedure.'  -- A short description
    ); 
    om_helper_pkg.add_grant(
        p_object      => 'HELLO_WORLD',                      -- The object name
        p_privileges  => om_helper_pkg.t_privilege_list('DEBUG') -- Grant these privileges
    ); 

END om_module_define; 
/
