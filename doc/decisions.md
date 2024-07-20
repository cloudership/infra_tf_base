# Decisions

See the infra_management `doc/decisions.md` for the format explanation.

The prefix of decisions is "DBS" - BS is for "base"

## List of Decisions

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
