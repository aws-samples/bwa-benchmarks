# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


import boto3
import json


# Get current AWS price for an on-demand instance
def get_price(instance_type, os='Linux', region='US East (N. Virginia)'):

    data = client.get_products(
        ServiceCode='AmazonEC2',
        Filters=[
            {"Field": "tenancy", "Value": "shared", "Type": "TERM_MATCH"},
            {"Field": "operatingSystem", "Value": os, "Type": "TERM_MATCH"},
            {"Field": "preInstalledSw", "Value": "NA", "Type": "TERM_MATCH"},
            {"Field": "instanceType", "Value": instance_type, "Type": "TERM_MATCH"},
            {"Field": "location", "Value": region, "Type": "TERM_MATCH"},
            {"Field": "capacitystatus", "Value": "Used", "Type": "TERM_MATCH"}
        ])

    od = json.loads(data['PriceList'][0])['terms']['OnDemand']
    # print(od)

    id1 = list(od)[0]
    id2 = list(od[id1]['priceDimensions'])[0]
    return od[id1]['priceDimensions'][id2]['pricePerUnit']['USD']


# Use AWS Pricing API at US-East-1
client = boto3.client('pricing')

# Get current price for a given instance, region and os
# price = get_price('c5.xlarge')
# print(price)
