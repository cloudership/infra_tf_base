# Terraform Base Module

Sets up basic networking, authentication & authorization, application load balancers, Route53 zones, and any other
infrastructure required to develop, deploy, host, and run software on AWS.

## Cookbook

NOTE: Ensure the Session Manager plugin is installed before using the session manager commands (`aws ssm`)

### Install Session Manager plugin

This is required before any of the session manager commands below are run.

https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

### Get shell on NAT instance

This gets a command-line on the NAT instance:

```shell
aws ssm start-session --target <NAT instance>
```

Make sure AWS credentials of the NAT instance account are configured in the environment.

### Get RDS admin endpoint, username, and password

```shell
tofu output --raw rds_endpoint
tofu output --raw rds_admin_username
tofu output --raw rds_admin_password

# If using the infra_management project:
bin/tg prod base output --raw rds_hostname
bin/tg prod base output --raw rds_hostname
bin/tg prod base output --raw rds_admin_username
bin/tg prod base output --raw rds_admin_password
```

Make sure AWS credentials of the management account are configured in the environment.

### Using NAT instance to port-forward to RDS instance

This allows connecting to the RDS instance from a local machine.

```shell
aws ssm start-session \
    --target <NAT_INSTANCE_ID> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["<RDS_HOSTNAME>"],"portNumber":["5432"],"localPortNumber":["15432"]}'
```

Make sure AWS credentials of the NAT instance account are configured in the environment.

### Connect to RDS instance

One-shot using infra_management account:

First port-forward to RDS instance as above. Then:

```shell
(export AWS_PROFILE=Management; PGPASSWORD="$(bin/tg prod base output --raw rds_admin_password)" PGUSER="$(bin/tg prod base output --raw rds_admin_username)" PGHOST=localhost PGPORT=15432 psql -l)
```

Replace `psql` with other commands like createuser, etc. as required.

Assumes using the infra_management project, management AWS account profile is 'Management', and port-forward uses 15432
on local machine.

Make sure AWS credentials of the Management account are configured in the environment.
