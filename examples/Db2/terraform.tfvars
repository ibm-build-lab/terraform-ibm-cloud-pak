###################### LDAP ######################
//ibmcloud_api_key      = "JzQHRAa-UGWdnTM2sQoOvYTKfgjU_TxbcUVBqYxxxQSm"
ibmcloud_api_key      = "2lT1xRhO_PSfohImF4sB02IrlTXFltwYjfjtxihqqrsK"
iaas_classic_api_key  = "1b66ab35ae00cef227f7b7c5b3fdf4dd7ad9fcaeebfda373ea533efa74eb2072"
iaas_classic_username = "2129514_joel.goddot@ibm.com"
region                = "us-south"
os_reference_code     = "CentOS_7_64" # "CentOS_8_64"
datacenter            = "dal12"
hostname              = "ldapvm"
ibmcloud_domain       = "ibm.cloud"
cores                 = 2
memory                = 4096
disks                 = [25]
hourly_billing        = true
local_disk            = true
private_network_only  = false
ldapBindDN            = "cn=root"
ldapBindDNPassword    = "Passw0rd"


//# ldapBindDNPassword = "LDAP-Passw0rd"
//###################### CLOUD ######################
//resource_group = "cloud-pak-sandbox-ibm"
//region = "us_south"
//
//
//###################### CLUSTER ######################
cluster_id            = "c7k5n2rd02oue2lo2c60"
//
//
//
###################### DB2 ######################
entitled_registry_user_email = "joel.goddot@ibm.com"
entitlement_key              = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2NDAwMjIyNDUsImp0aSI6ImQwMmJjMTZlY2Q3NzQzNmZiYTFmZmUyNjcxMzRkODQ0In0.4_WXu3b_TTqGlC4yGkKpjgn3sy3URHEKzjvyfpUWLR4"
db2_admin_username           = "cpadmin"
db2_user                     = "db2inst1"
db2_admin_user_password      = "Passw0rd"
db2_host_name                = "joeltestingcp4baclassic-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud"
db2_host_port                = "30788"
db2_standard_license_key     = "W0xpY2Vuc2VDZXJ0aWZpY2F0ZV0KQ2hlY2tTdW09Q0FBODlCOTA0QzU3RTY2OTU1RjJDQTY4MzlCRTZCOTMKVGltZVN0YW1wPTE1NjU3MjM5MDIKUGFzc3dvcmRWZXJzaW9uPTQKVmVuZG9yTmFtZT1JQk0gVG9yb250byBMYWIKVmVuZG9yUGFzc3dvcmQ9N3Y4cDRmcTJkdGZwYwpWZW5kb3JJRD01ZmJlZTBlZTZmZWIuMDIuMDkuMTUuMGYuNDguMDAuMDAuMDAKUHJvZHVjdE5hbWU9REIyIFN0YW5kYXJkIEVkaXRpb24KUHJvZHVjdElEPTE0MDUKUHJvZHVjdFZlcnNpb249MTEuNQpQcm9kdWN0UGFzc3dvcmQ9MzR2cnc1MmQyYmQyNGd0NWFmNHU4Y2M0ClByb2R1Y3RBbm5vdGF0aW9uPTEyNyAxNDMgMjU1IDI1NSA5NCAyNTUgMSAwIDAgMC0yNzsjMCAxMjggMTYgMCAwCkFkZGl0aW9uYWxMaWNlbnNlRGF0YT0KTGljZW5zZVN0eWxlPW5vZGVsb2NrZWQKTGljZW5zZVN0YXJ0RGF0ZT0wOC8xMy8yMDE5CkxpY2Vuc2VEdXJhdGlvbj02NzE2CkxpY2Vuc2VFbmREYXRlPTEyLzMxLzIwMzcKTGljZW5zZUNvdW50PTEKTXVsdGlVc2VSdWxlcz0KUmVnaXN0cmF0aW9uTGV2ZWw9MwpUcnlBbmRCdXk9Tm8KU29mdFN0b3A9Tm8KQnVuZGxlPU5vCkN1c3RvbUF0dHJpYnV0ZTE9Tm8KQ3VzdG9tQXR0cmlidXRlMj1ObwpDdXN0b21BdHRyaWJ1dGUzPU5vClN1YkNhcGFjaXR5RWxpZ2libGVQcm9kdWN0PU5vClRhcmdldFR5cGU9QU5ZClRhcmdldFR5cGVOYW1lPU9wZW4gVGFyZ2V0ClRhcmdldElEPUFOWQpFeHRlbmRlZFRhcmdldFR5cGU9CkV4dGVuZGVkVGFyZ2V0SUQ9ClNlcmlhbE51bWJlcj0KVXBncmFkZT1ObwpJbnN0YWxsUHJvZ3JhbT0KQ2FwYWNpdHlUeXBlPQpNYXhPZmZsaW5lUGVyaW9kPQpEZXJpdmVkTGljZW5zZVN0eWxlPQpEZXJpdmVkTGljZW5zZVN0YXJ0RGF0ZT0KRGVyaXZlZExpY2Vuc2VFbmREYXRlPQpEZXJpdmVkTGljZW5zZUFnZ3JlZ2F0ZUR1cmF0aW9uPQo"

//###################### CP4BA ######################
//entitlement_key     = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzgxMzkzMDcsImp0aSI6ImNmOTViYjU0NjNjODRiZTc4YjkwZjg5MjU2YTVjNDQyIn0.MeJ93o0sMDzWp_wKLCkkhYUqS48duGe7EnCcx1w43Rc"
//entitled_registry_user = "joel.goddot@ibm.com"
//
//
////cluster_name_or_id = "c58u6l6d073pl99nil4g"
////ibmcloud_api_key = "wRYZPhawQp365OSPZXOgeBT8CBnf1DrllAjFH1EhbGNn"
//resource_group = "cloud-pak-sandbox-ibm"
//region = "us_south"
////entitlement_key = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1OTY4MzcwMjUsImp0aSI6IjcwMDNkYmU0ZDczZjQ4Y2M4NmQ4Y2Q5ZWE0YzVlYmY4In0.62Llbq4dGKWhPWOngqBMz5SdMZdbnGYjOFlzmN7Fgvw"
////entitled_registry_user = "ann.umberhocker@ibm.com"
//ldap_admin = "cn=root"
//ldap_password = "Passw0rd"
//ldap_host_ip = "50.22.130.123"
//db2_admin = "cpadmin"
//db2_user = "db2inst1"
//db2_password = "Passw0rd"
//db2_host_name = "joeltestingcp4baclassic-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud"
//db2_host_port = "30788"
//
////ibmcloud_api_key             = "JzQHRAa-UGWdnTM2sQoOvYTKfgjU_TxbcUVBqYxxxQSm"
////iaas_classic_username        = "joel.goddot@ibm.com"
////iaas_classic_api_key         = "1b66ab35ae00cef227f7b7c5b3fdf4dd7ad9fcaeebfda373ea533efa74eb2072"
////entitled_registry_user_email = "joel.goddot@ibm.com"
//docker_server                = "cp.icr.io"
//docker_username              = "cp"
//entitled_registry_user = "joel.goddot@ibm.com"
//entitlement_key              = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzgxMzkzMDcsImp0aSI6ImNmOTViYjU0NjNjODRiZTc4YjkwZjg5MjU2YTVjNDQyIn0.MeJ93o0sMDzWp_wKLCkkhYUqS48duGe7EnCcx1w43Rc"
//cluster_name_or_id           = "" #
//db2_admin_password           = ""

