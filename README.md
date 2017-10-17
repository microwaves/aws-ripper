# aws-ripper

aws-ripper is a stress test utility that runs its test nodes on top of AWS.

## Dependencies

Before start to use the tool, it's necessary to install the required dependencies.

Install [wkhtmltopdf](http://wkhtmltopdf.org/).

```
$ sudo apt-get install wkhtmltopdf
```

On Red Hat-based systems:

```
$ sudo yum install wkhtmltopdf
```

After install `wkhtmltopdf`, you may now follow with the installation of the necessary
Gems.

From the project directory, run:

```
$ bundle
```

## Configuration

One who's executing `aws-ripper` must have the AWS credentials(`~/.aws/credentials`) set.
After you placed your AWS credentials, it's time to setup the tool. You may find the example
`config.yml.example` in the root directory of the project, it already has a region set, that's
possible to use, you simply need to place your key name(if available in the same region).

Below you may find a description of each configuration parameter.

- `hostname`: hostname of the server to be stressed.
- `port`: port of the service to be stressed.
- `protocol`: you may use a wide variety of protocols, for more information visit [tsung's docs](http://tsung.erlang-projects.org/user_manual/index.html).
- `urls`: URLs to be hit during the test.
- `users_amount`: users amount per node.
- `regions`: instances configuration per region.
  - `region_name`:
    - `image_id`: AMI for the stress tests.
    - `key_name`: SSH key name for the one who's executing the tool.
    - `security_group_id`: a security group in the VPC that allows outbound connections and inbound ssh.
    - `subnet_id`: a subnet in the VPC for networking.
    - `instances_amount`: the amount of instances to be created.

## Running the tool

After the necessary configuration is placed, it's time to run the tool.

From the root directory, execute:

```
$ bin/aws-ripper -s <desired_amount_of_minutes>
```

If the stress test run successfully, in the end you will be able to also check reports created in the `/tmp` directory with the prefix of `graph_node-...`.

## Author

Stephano Zanzin - [@microwaves](https://github.com/microwaves)
