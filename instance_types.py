# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3


def full_info(instance_type):
    response = client.describe_instance_types(
                    InstanceTypes=[instance_type]
                )
    return response['InstanceTypes'][0]


def basic_info(instance_type):
    response = full_info(instance_type)
    architecture = response['ProcessorInfo']['SupportedArchitectures'][0]
    vcpu = response['VCpuInfo']['DefaultVCpus']
    mb = response['MemoryInfo']['SizeInMiB']
    instance_storage = response['InstanceStorageSupported']
    return architecture, vcpu, mb, instance_storage


client = boto3.client('ec2')

# print(full_info('r6gd.16xlarge'))
# print(basic_info('c5.large'))
# print(basic_info('c5d.2xlarge'))
