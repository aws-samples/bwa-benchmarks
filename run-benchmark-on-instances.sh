#! /bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


if [ -z "$1" ]
  then
    echo "usage: run-benchmark-on-instances.sh launch_template [instance_regex]"
fi

# first arg specifies the launch template for the instances
launch_template=$1

# second arg specifies a regex for instance types to run on. The default is m6g*large
instance_regex=${2:-"m6g*large"}


for i in $(aws ec2 describe-instance-types --filters Name=instance-type,Values="$instance_regex" --query InstanceTypes[].InstanceType --output text)
do
  rc=99
  fail_count=0

  while [[ $rc != 0 ]]
  do
    echo Attempting to launch instance of type: "$i"
    aws ec2 run-instances --instance-type "$i" --launch-template LaunchTemplateId="$launch_template" --count 1 > /dev/null
    rc=$?

    if [[ $rc != 0 ]]
    then
      echo Failed to launch, may have hit a limit, will try again in 30 seconds
      sleep 30
    fi

    fail_count=$((fail_count+1))

    if [[ $fail_count -gt 2 ]]
    then
        echo Failed $fail_count times. Skipping instance type "$i"
        break
    fi
  done

  # avoid throttling
  sleep 5
done
