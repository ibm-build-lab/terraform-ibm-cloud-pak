// Openshift cluster parameters
// ----------------------------

// Create a cluster based on values below
project_name 	= "vpc"
owner        	= "ann"
environment  	= "iaf-test"

// Region, run "ibmcloud regions"
region       	= "us-south"

// Resource group, run "ibmcloud resource groups" to see options.
resource_group 	= "cloud-pak-sandbox-ibm"

// OpenShift version, run command "ibmcloud ks versions" to see options
roks_version	= 4.6

// Remove peristent storage during deletion
force_delete_storage	= true

// Classic required variables
//on_vpc        	= false
// To see classic datacenters, run "ibmcloud ks zone ls --provider classic"
//datacenter     = "dal12"
// VLAN numbers on selected datacenter. Run command "ibmcloud ks vlan ls --zone <datacenter>". 
// NOTE: If this is the first created cluster, the VLANS will not exists and will be created, so leave blank
//private_vlan_number = ""
//public_vlan_number  = ""
// flavor, run command "ibmcloud ks flavors --zone dal10 --provider classic"
//flavors 		= ["b3c.16x64"]
// # or workers
//workers_count	= [4]

// VPC required variables
on_vpc        	= true
// zone names, run "ibmcloud ks zone ls --provider vpc-gen2"
vpc_zone_names     = ["us-south-1"]
// flavor, run "ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2
flavors	= ["bx2.16x64"]
workers_count	= [4]

