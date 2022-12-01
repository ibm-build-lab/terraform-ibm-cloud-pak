# DB2 setup for CP4BA

This script will set up the database schema on a DB2 database for CP4BA installation

1. Create DB2 Database using the https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/examples/Db2 

2. Set IC_API_KEY to IBM Cloud API key for account setting this up in, See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key

  ```
  export IC_API_KEY="*****************"
  ```

3. Set CLUSTER_ID to the cluster containing the DB2 database
  ```
  export CLUSTER_ID="*****************"
  ```

4. Run 
  ```
  chmod +x ./createDBSchema.sh
  source ./createDBSchema.sh
  ```
