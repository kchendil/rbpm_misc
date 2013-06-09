#
# Cookbook Name:: postgres
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

build_loc=node['rbpm_misc']['build_loc']
edirectory_port=node['rbpm_misc']['edirectory_port']
ldap_port=node['rbpm_misc']['ldap_port']
ldaps_port=node['rbpm_misc']['ldaps_port']
admin_name=node['rbpm_misc']['admin_name']
dn_admin_name=node['rbpm_misc']['dn_admin_name']
idm_password=node['rbpm_misc']['idm_password']
jre_loc=node['rbpm_misc']['jre_loc']
simple_password=node['rbpm_misc']['simple_password']
cert=node['rbpm_misc']['cert']
direct=node['rbpm_misc']['direct']


 
 template "/tmp/rbpm_userapp_admin.properties" do
  source "rbpm_userapp_admin.properties.erb"
  owner "root" 
  mode "0644"  
end

template "/opt/novell/idm/Designer//NOVLUABASE.properties" do
  source "NOVLUABASE.properties.erb"
  owner "root" 
  mode "0644"  
end


template "/opt/novell/idm/Designer//NOVLRSERVB.properties" do
  source "NOVLRSERVB.properties.erb"
  owner "root" 
  mode "0644"  
end

 
  execute "Create user app admin 1" do
    command " \"#{jre_loc}/bin/java\" -classpath \"#{build_loc}/instutil.jar\":\"#{build_loc}/nxsl.jar\" com.novell.idm.wrapper.tools.CreateDriverConfig \"#{build_loc}/rbpm_userapp_admin_template.ldif\" \"/tmp/rbpm_userapp_admin.ldif\" \"/tmp/rbpm_userapp_admin.properties\" "
	creates "/var/opt/novell/userapp_admin1.log"
    action :run
  
  end
 

     execute "Create user app admin 2" do
     command " LD_LIBRARY_PATH=\"#{build_loc}\"  \"#{build_loc}/ldapmodify\" -ZZ -h 127.0.0.1 -p #{ldap_port} -D \"#{dn_admin_name}\" -w #{idm_password} -a -c -f \"/tmp/rbpm_userapp_admin.ldif\" " 
    creates "/var/opt/novell/userapp_admin2.log"
     action :run
  
  end
 
 
    execute "Create RBPM Drivers" do
    command " /bin/sh -c 'ulimit -n 4096; LD_LIBRARY_PATH=\"#{build_loc}\" \"/opt/novell/idm/Designer//Designer\" -nosplash -nl en -application com.novell.idm.rcp.DesignerHeadless -command deployDriver -p \"/opt/novell/idm/Designer//packages/eclipse/plugins\" -a \"#{admin_name}\" -w #{idm_password} -s 127.0.0.1:524 -c \"driverset1.system\" -b 12 -l \"/var/opt/novell/rbpm_drivers_configure.log\" ' " 
    creates "/var/opt/novell/rbpm_drivers_configure.log"
    action :run
  
 end
 
  execute "Delete the Pkg Properties file" do
   command " rm -rf /opt/novell/idm/Designer//NOVLRSERVB.properties; rm -rf /opt/novell/idm/Designer//NOVLUABASE.properties; "
	#creates "/var/opt/novell/idm_partition_operation.log"
   action :run
  
 end
 
