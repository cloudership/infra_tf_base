# Terraform Base Module

Sets up basic networking, authentication & authorization, application load balancers, Route53 zones, and any other
infrastructure required to develop, deploy, host, and run software on AWS

## Cookbook

### Get RDS admin endpoint, username, and password

```shell
tofu output --raw rds_endpoint
tofu output --raw rds_admin_username
tofu output --raw rds_admin_password

# If using the infra_management project:
bin/tg prod base output --raw rds_endpoint
bin/tg prod base output --raw rds_admin_username
bin/tg prod base output --raw rds_admin_password
```

### Using NAT instance to port-forward to RDS instance

Ensure Session Manager plugin is installed on local host (see below).

```shell
aws ssm start-session \
    --target <NAT_INSTANCE_ID> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["<RDS_HOSTNAME>"],"portNumber":["5432"],"localPortNumber":["15432"]}'
```

### Connect to PostgreSQL instance

One-shot using infra_management account:

First port-forward to RDS instance as above. Then:

```shell
(export AWS_PROFILE=Management; PGPASSWORD="$(bin/tg prod base output --raw rds_admin_password)" PGUSER="$(bin/tg prod base output --raw rds_admin_username)" PGHOST=localhost PGPORT=15432 psql -l)
```

Replace `psql` with other commands like createuser, etc. as required.

Assumes using the infra_management project, management AWS account profile is 'Management', and port-forward uses 15432
on local machine.

### Install Session Manager plugin

https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
