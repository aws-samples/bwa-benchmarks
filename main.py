# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import sys
import math
import os
import re


from scipy import stats
from price import get_price
from instance_types import basic_info


def process_benchmarks(benchmark_dir):
    immediate_subdirectories = [f for f in os.scandir(benchmark_dir) if f.is_dir()]

    for sub_dir in immediate_subdirectories:
        instance_type = sub_dir.name

        arch, vcpu, mb, instance_storage = basic_info(instance_type)

        times = []
        observations = []

        for root, dirs, files in os.walk(sub_dir.path, topdown=False):
            if len(files) > 0:
                for file_name in files:
                    if file_name.startswith("stderr"):
                        file_path = os.path.join(root, file_name)
                        file = open(file_path, "r")
                        for line in file:
                            if re.search("Real time", line):
                                time = line.split(sep=' ')[3]
                                times.append(float(time))
                                observations.append(time)

        if len(times) > 0:
            (nobs, minmax, mean, variance, skewness, kurtosis) = stats.describe(times)
            # print(desc)
            sem = mean / math.sqrt(nobs)
            price = get_price(instance_type)
            price_per_second = float(price) / 3600.0
            mean_cost = price_per_second * mean
            print(instance_type, arch, vcpu, mb, instance_storage, observations, nobs, minmax[0], minmax[1],
                  mean, sem, variance, skewness, kurtosis, price, price_per_second, mean_cost, sep="\t")


if __name__ == '__main__':
    print("instance_type\tarch\tvcpu\tram_mb\tinstance_storage\tobservations"
          "\tnum_obs\tmin\tmax\tmean\tstderr\tvariance\tskewness\tkurtosis"
          "\ton_demand_price_(USD)\tprice_per_second\tmean_cost")
    process_benchmarks(sys.argv[1])
