eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) DB2_PROJECT_NAME=\(.db2_project_name)"')"

echo "*********************************************************************************"
echo "******************** Uninstalling DB2 from the Cluster ... **********************"
echo "*********************************************************************************"


echo
echo

echo "Setting project ${DB2_PROJECT_NAME} ..."
kubectl get ns "${DB2_PROJECT_NAME}"
echo

kubectl get db2ucluster -n ibm-db2 | awk '{print $1}'
echo


for resource in subscription deployments deploymentconfigs configmaps OperatorGroup statefulset EventStreams csv jobs pods secrets pv pvc services roles rolebindings namespaces ;
do
  echo " => Deleting the ${resource} ...";
  resources=$(kubectl get "${resource}" -n "${DB2_PROJECT_NAME}" | grep db2 | awk '{print $1}'); # '
  eval "elements=($resources)"
  for element in "${elements[@]}"; do
      check_resource=true
      while ( $check_resource )
      do
        cmd=$(kubectl delete "${resource}"/"${element}" -n "${DB2_PROJECT_NAME}")
        sleep 10
        get_resource=$(kubectl get "${resource}" -n "${DB2_PROJECT_NAME}" | grep db2 | awk '{print $1}')
        if [ "${get_resource}" == "${resource}" ]
        then
          continue
        elif [ "${get_resource}" == "NotFound" ]; then
          check_resource=false
          break
        else
          check_resource=false
          break
        fi
      done
  done
  echo "******************************************************************************************************************"
done

echo
echo
echo "*********************************************************************************"
echo "**************** Uninstallation of DB2 completed successfully!!! ****************"
echo "*********************************************************************************"