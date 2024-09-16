# Decisions

See the infra_management `doc/decisions.md` for the format explanation.

The prefix of decisions is "DBS" - BS is for "base"

## List of Decisions

### DBS-2024091601 Install cert-manager alongside AWS Load Balancer Controller in EKS cluster

The need for cert-manager alongside AWS Load Balancer Controller
[is described here](https://www.reddit.com/r/kubernetes/comments/1d2etqs/comment/l60ejlt/)

### DBS-2024091501 Install AWS Load Balancer Controller manually without external TF modules

The Terraform/OpenTofu modules out there are out of date, and strongly coupled to their own EKS set up modules. The IAM
policies they use are also out of date. Using them as inspiration and doing it ourselves is more secure and more suited.

### DBS-2024090101 NAT instance instead of NAT gateway

This is purely a cost-saving initiative - using a NAT instance enables use of the EC2 free tier; a real production
workload should use a NAT gateway.

### DBS-2024083101 RDS instance tailored to simplicity and cost-savings over security and reliability

For simplicity, a single RDS instance will be provisioned. This serves several purposes:

1) As no real workloads are being run, it will suffice.
2) Having a single DB cluster makes the platform simpler.
3) It allows use of the free-tier.
4) Capabilities can easily be upgraded as needed.

The admin password will not use Secrets Manager and instead be set directly. The only benefit of using Secrets Manager
is more security so for cost-savings and simplicity's sake it will be managed by OpenTofu.

Instance will be opened to public 

A real world platform should configure RDS to use Secrets Manager, enable Multi-AZ, and potentially use several RDS
instances if required, with the full gamut of protections like KMS encryption, admin password rotation, and regular
backups.

### DBS-2024082701 EKS cluster uses Fargate pods

Using free-tier EC2 instances as nodes was explored but performance was too slow. Using Fargate pods reduces admin
overhead and is not very expensive. Maintenance overhead is also reduced.

### DBS-2024072802 Allow DB access from any IP address in the VPC (no granular IP restrictions to DB)

For simplicity's sake, the DB can be accessed from anywhere in the VPC and the only access controls are via DB password
authentication.

### DBS-2024072801 Demo project using free tier as much as possible

This project is to showcase skills and the author is broke. Hence decisions will prioritize cost savings and not
reliability; however the foundations allow it to easily evolve into a more reliable architecture should the need arise.

As an example: there will be a single DB hosted in a single availability zone for the entire platform under the free
tier, using a cheap instance type. This can easily be changed via simple refactoring if the need arises.

### DBS-2024072002 Yes Kubernetes!

Kubernetes is now the defacto container orchestration system, and EKS with Fargate runners solves the management
overhead of using your own worker nodes so the decision to use ECS is no longer valid.

However, to cut costs by exploiting the AWS free tier, t3-micro instances will still be managed as worker nodes. This is
due to this project being a hobby/showcase project. A production deployment would switch to Fargate runners.

### DBS-2024072001 All public network

Private subnets give one extra layer of security but also make things more complex and costly (NAT gateway costs,
inbound bastions/proxies). So keep everything public for simplicity and keep a careful focus on network security.

### DBS-2023020302 IPv4

IPv6 is not supported ubiquitously enough to build a platform on it; stick to IPv4.

### DBS-2023020302 Infrastructure module layout

Instead of having multiple TF modules, for now we will have 1 module will all foundational infrastructure declared in
it. We can devolve later when the need arises. Having 1 monolithic base module makes things much simpler.

### DBS-2023020301 No Kubernetes

As Jon Topper of Scale Factory, the premium AWS cloud consultancy told me: if you use AWS Fargate, you have to
understand AWS. If you use Kubernetes, you have to understand AWS, AND also Kubernetes.

So the decision is quite simple: do the simpler thing and use AWS's own container service, and lose a large slice of
cognitive load. Simplicity is its own reward.

### DBS-2023012101 Only use S3 and DynamoDB VPC endpoints

They are the only ones that are free as they are created via the route table. Others are managed through AWS Private
Link which is a paid service. Stick to the free ones.
