#! /bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

yum update -y

# install compilers, git etc
yum groupinstall "Development Tools" -y

# install fsx-lustre drivers
amazon-linux-extras install -y lustre2.10
mkdir /fsx
# mount the lustre FS
mount -t lustre -o noatime,flock fs-0947447c8050a84bb.fsx.us-east-1.amazonaws.com@tcp:/e6skvbmv /fsx

# get BWA and build it.
git clone https://github.com/lh3/bwa.git
cd bwa/ || exit
# Change headers for ARM
sed -i -e 's/<emmintrin.h>/"sse2neon.h"/' ksw.c
wget https://gitlab.com/arm-hpc/packages/uploads/ca862a40906a0012de90ef7b3a98e49d/sse2neon.h
make clean all

# meta data to determine where to write results
benchmark=bwa
TOKEN=$(curl --silent -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
instance_type=$(curl --silent -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
instance_id=$(curl --silent -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
benchmark_dir=/fsx/FSxLustre20200915T153335Z/benchmarks/"$benchmark"/$instance_type/$instance_id

mkdir -p "$benchmark_dir"

# run the process n times
for i in {1..3}
do
        # the stderr of BWA contains the run time. For other apps you may need to time it
        /bwa/bwa mem -t "$(nproc)" /fsx/FSxLustre20200915T153335Z/human_g1k_v37.fasta /fsx/FSxLustre20200915T153335Z/NIST7035_TAAGGCGA_L001_R1_001.fastq.gz 1> "$benchmark_dir"/aln.sam 2> "$benchmark_dir"/stderr-"$i"

        # cause Fsx FS to sync the cached file back to S3
        lfs hsm_archive "$benchmark_dir"/stderr-"$i"
        lfs hsm_action "$benchmark_dir"/stderr-"$i"
done

# probably not needed but give everything 30s to finish
sleep 30

# Clean up
# typically I specify the EC2 to terminate on shutdown so this will remove the EC2 and EBS volumes.
sudo shutdown now
