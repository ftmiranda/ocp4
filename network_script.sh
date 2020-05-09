#!/bin/sh
# This script checks all the pre-configuration for the DNS infrastructure for Red Hat Openshift 4

if [ "$1" == "" ]; then
  echo "Usage: `basename $0` master0_name master1_name master2_name worker1_name worker2_name ocp_cluster_name domain_name bootstrap_name"
  exit 0
fi

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` master0_name master1_name master2_name worker1_name worker2_name ocp_cluster_name domain_name bootstrap_name"
  echo "Example: network_script.sh master0 master1 master2 compute1 compute2 ocp4 ibm.com boostrap"
  exit 0
fi

MASTER0_NAME=$1
MASTER1_NAME=$2
MASTER2_NAME=$3
WORKER0_NAME=$4
WORKER1_NAME=$5
OCP_CLUSTER_NAME=$6
DOMAIN_NAME=$7
BOOTSTRAP_NAME=$8

function dns {
        echo "Checking DNS name resolution"

        dig $MASTER0_NAME.$DOMAIN_NAME +short
        dig $MASTER1_NAME.$DOMAIN_NAME +short
        dig $MASTER2_NAME.$DOMAIN_NAME +short
        dig $WORKER0_NAME.$DOMAIN_NAME +short
        dig $WORKER1_NAME.$DOMAIN_NAME +short

        if [ "$BOOTSTRAP_NAME" == "" ]; then
          echo "No bootstrap"
        else
          dig $BOOTSTRAP_NAME.$DOMAIN_NAME +short
        fi

        echo "Checking etcd-[0-2] DNS name resolution"

        dig etcd-0.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig etcd-1.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig etcd-2.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short

        echo "Checking Reverse IP resolution"

        dig -x `dig $MASTER0_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $MASTER1_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $MASTER2_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $WORKER0_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $WORKER1_NAME.$DOMAIN_NAME +short` +short

        if [ "$BOOTSTRAP_NAME" == "" ]; then
          echo "No bootstrap"
        else
          dig -x `dig $BOOTSTRAP_NAME.$DOMAIN_NAME +short` +short
        fi

        echo "Checking for APIs name resolution"

        dig api.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig api-int.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig apps.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig test.apps.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short

        echo "Checking the SRV records"
        dig _etcd-server-ssl._tcp.$OCP_CLUSTER_NAME.$DOMAIN_NAME srv +short
}

dns