### Generating the Portworx Spec URL
* Launch the [spec generator](https://central.portworx.com/specGen/wizard)

* Select `Portworx Essentials` and press Next to continue:

* Check `Use the Portworx Operator` box and select the `Portworx version` as `2.6`. For `ETCD` select `Built-in` option and then press Next:

* Select `Cloud` for `Select your environment` option. Click on `AWS` and select `Create Using a Spec` option for `Select type of disk`.
Enter value for `Size(GB)` as `1000` and then press Next. 

* Leave `auto` as the network interfaces and press Next:

* Select `Openshift 4+` as Openshift version, go to `Advanced Settings`:

* In the `Advanced Settings` tab select all three options and press Finish:

* Copy Spec URL and Paste in a browser:

* Copy the Name (Cluster ID), the User ID and the OSB endpoint highlighted in red. This will be the value for the `cluster_id`, `user_id` and `osb_endpoint` variables respectively.
