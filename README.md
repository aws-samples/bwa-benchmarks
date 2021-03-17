## bwa-benchmarks

The code in this repository supports the AWS Public Sector blog titled ["A generalized approach to benchmarking genomics workloads in the cloud: Running the BWA read aligner on Graviton2"](https://aws.amazon.com/blogs/publicsector/generalized-approach-benchmarking-genomics-workloads-cloud-bwa-read-aligner-graviton2/)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

Please be aware that to benchmark BWA the source of that application is
downloaded and compiled on the test EC2 instances. The source for BWA is
separately licensed as GPL-3.0

## How to use this code
### benchmark-userdata-[arch].sh
To automate benchmarking across EC2 types it is most effective to create a LaunchTemplate that can define things that all instances should have in common such as IAM Roles, security groups, VPC, subnets, AMI etc. LaunchTemplates can also have User data which can be shell scripts that configure the instances at first start. The two userdata scripts are examples of code that can be placed in the user data section of a launch template. Specifically these scripts install and compile the BWA software and attach a FSx for Lustre volume (which has already been created). They also collect metadata about the machine (instance type and instance id) from the EC2 metadata endpoint at `http://169.254.169.254` which is used to construct the output path.

The scripts also run BWA three times and synchronize the output to S3 from FSx for Lustre. The output of BWA includes the run time so we don't need a timer in the user data. For other applications you will want to time the actual invocation of the command that you are benchmarking.

Finally the script shutsdown the instance. I recommend setting the shutdown behavior to 'Terminate' in the LaunchTemplate so that the instance and EBS volumes are cleaned up at the end of the run.

## run-benchmark-on-instances.sh
When your launch template and userdata are ready you can use a script similar to `run-benchmark-on-instances.sh`. The script takes two inputs: the ID of the LaunchTemplate used to provision the instances and a regex used to match the names of the instance types that you want to test. This can be any valid regex such as `m*2xlarge`. Any matching instance types will be launched with the launch template. There is logic in the script that will attempt to pause and retry when your requests might be throttled however you should consider any account limits you may have and if nescessary request limit increases. Using a regex of `.*` is not recommended for obvious reasons.

## Summarizing costs and runtime with main.py
The Python script `main.py` will determine the summary stastics of cost and runtime by instance type as well as basic information about the instance type like number of vCPU and amount of memory. Run this when your benchmarking is complete.

## cost_effectiveness.ipynb
The cost effectiveness Jupyter notebook is an example of an analysis on the output produced by `main.py` and generates several charts to help determine what might be the most cost-effective instance type for your application.
