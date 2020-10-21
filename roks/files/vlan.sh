#!/usr/bin/env bash

JQ=
command -v jq > /dev/null && JQ=1

fin() {
  [[ -n $verbose && -n $1 ]] && echo -ne "$1 \n" >&2

  [[ -z $priv_vlan ]] && priv_vlan="0"
  [[ -z $pub_vlan ]]  && pub_vlan="0"

  case "$output" in
    json|JSON)
      if [[ -n $JQ ]]; then
        jq -n --arg private "$priv_vlan" --arg public "$pub_vlan" '{ "private": $private, "public": $public }'
      else
        echo "{ \"private\": \"$priv_vlan\", \"public\": \"$pub_vlan\" }"
      fi
    ;;
    *)
      echo "${priv_vlan}:${pub_vlan}"
    ;;
  esac

  # The script will fail at planning on Schematics, so return 0 always or the planning will fail
  [[ -n $2 ]] && exit 0
}

getToken() {
  T=$(curl -s -k -X POST \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
    --data-urlencode "apikey=$IC_API_KEY" \
    "https://iam.cloud.ibm.com/identity/token"
  )

  echo $T | grep -q "incidentID" && return

  if [[ -n $JQ ]]; then
    echo $T | jq  -r .access_token
  else
    echo $T | sed 's/.*"access_token":"\([^",]*\)",.*/\1/'
  fi
}

datacenters() {
  curl -s -X GET \
    https://containers.cloud.ibm.com/global/v1/datacenters \
    -H "Authorization: Bearer $IC_IAM_TOKEN" \
    -H 'accept: application/json'
}

vlans_at_dc() {
  DC=$1

  all_vlans_json=$(curl -s -X GET \
    https://containers.cloud.ibm.com/global/v1/datacenters/$DC/vlans \
      -H "Authorization: Bearer $IC_IAM_TOKEN" \
      -H 'accept: application/json'
  )

  if echo $all_vlans_json | grep -q '"incidentID":'; then
    fin "[ERROR] Fail to get the VLANs from DC $DC. $all_vlans_json"
    return
  fi

  if [[ -n $JQ ]]; then
    echo $all_vlans_json | jq -r "[.[] | select(.properties.name==\"\")]"
  else
    echo $all_vlans_json | sed 's/.*"access_token":"\([^",]*\)",.*/\1/'
  fi
}

datacenter=$1
shift

output="text"
verbose=
while (( "$#" )); do
  case "$1" in
    -o|--output)
      output=$2
      shift
    ;;
    -v|--verbose)
      verbose=true
    ;;
    -q|--quiet)
      verbose=
    ;;
    *)
      break
    ;;
  esac
  shift
done

# The API Token on the Schematics container is set in the env variable IC_IAM_TOKEN
if [[ -z $IC_IAM_TOKEN ]]; then
  [[ -z $IC_API_KEY ]] && fin "[ERROR] neither the IBM API Key or a Token were found. Export 'IC_API_KEY' with the IBM Cloud API Key" 1

  IC_IAM_TOKEN=$(getToken)
  [[ -z $IC_IAM_TOKEN ]] && fin "[ERROR] Fail to get the IBM Cloud API Token" 1
fi

if ! echo $(datacenters) | grep -q "\"$datacenter\""; then
  fin "[ERROR] datacenter '$datacenter' is not supported by IBM Cloud Classic\n        The supported datacenters are: $(datacenters)" 1
fi

vlans_json=$(vlans_at_dc $datacenter)
[[ -z "$vlans_json" ]] && exit 1

if [[ -n $JQ ]]; then
  priv_vlan=$(echo $vlans_json | jq -r "[.[] | select(.type==\"private\") | .id][0]")
  pub_vlan=$(echo $vlans_json | jq -r "[.[] | select(.type==\"public\") | .id][0]")
else
  priv_vlan=$(type="private"; echo $vlans_json | sed 's/.*"id":"\([^"]*\)","type":"'$type'","properties":{"name":"",.*/\1/')
  pub_vlan=$(type="public"; echo $vlans_json | sed 's/.*"id":"\([^"]*\)","type":"'$type'","properties":{"name":"",.*/\1/')
fi

fin ""
