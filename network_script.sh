#!/bin/sh
# This script ....
MASTER0_NAME=$1
MASTER1_NAME=$2
MASTER2_NAME=$3
WORKER0_NAME=$4
WORKER1_NAME=$5
OCP_CLUSTER_NAME=$6
DOMAIN_NAME=`hostname -d`

function dns {
        echo "Checking DNS name resolution"

        dig $MASTER0_NAME.$DOMAIN_NAME +short
        dig $MASTER1_NAME.$DOMAIN_NAME +short
        dig $MASTER2_NAME.$DOMAIN_NAME +short
        dig $WORKER0_NAME.$DOMAIN_NAME +short
        dig $WORKER1_NAME.$DOMAIN_NAME +short
        
        echo "Checking Reverse IP resolution"
        
        dig -x `dig $MASTER0_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $MASTER1_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $MASTER2_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $WORKER0_NAME.$DOMAIN_NAME +short` +short
        dig -x `dig $WORKER1_NAME.$DOMAIN_NAME +short` +short

        echo "Checking for APIs name resolution"

        dig api.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig api-int.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig apps.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short
        dig test.apps.$OCP_CLUSTER_NAME.$DOMAIN_NAME +short

        echo "Checking the SRV records" 
        dig _etcd-server-ssl._tcp.$OCP_CLUSTER_NAME.$DOMAIN_NAME srv +short
}

dns