#! /bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# First arg specifies a regex for instance types to run on. The default is m6g*large
instance_regex=${1:-"m6g*large"}

for i in $(aws ec2 describe-instance-types --filters Name=instance-type,Values="$instance_regex" --query InstanceTypes[].InstanceType --output text)
do
  echo "$i"
done