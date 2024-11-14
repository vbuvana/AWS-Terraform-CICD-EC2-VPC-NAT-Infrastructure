
# AWS VPC Infrastructure Setup

This project sets up a Virtual Private Cloud (VPC) on AWS with the following architecture:

* **Public and Private Subnets** across multiple Availability Zones.
* **Internet Gateway** to enable internet access for resources in the public subnet.
* **NAT Gateway** to allow instances in the private subnet to access the internet securely.
* **Routing Tables** configured to direct traffic within the VPC and to external resources as necessary.

## Architecture Diagram

### Diagram Details

* **VPC CIDR**: `10.0.0.0/16`
* **Public Subnet (Availability Zone A)**:
  * CIDR: `10.0.0.0/24`
  * Contains EC2 instances with public IP addresses.
  * Connected to the Internet Gateway (IGW) for public access.
* **Private Subnet (Availability Zone B)**:
  * CIDR: `10.0.1.0/24`
  * Contains EC2 instances without public IP addresses.
  * Access to the internet is routed through the NAT Gateway in the public subnet.

### Route Tables

|Destination|Target|Notes|
|---|---|---|
|10.0.0.0/16|local|Routes traffic within the VPC|
|0.0.0.0/0|IGW|Routes public traffic from public subnet to IGW|
|0.0.0.0/0|NAT|Routes private traffic through the NAT Gateway|

## Prerequisites

* AWS account with appropriate permissions to create VPC, subnets, route tables, IGW, and NAT gateway.
* Terraform (if using provided `.tf` files for deployment).
* Git for version control.

## Setup Instructions

1. **Clone the Repository**:

   ```bash
   git clone <your-repo-url>
   cd <your-repo-directory>
   ```

2. **Apply Terraform Configuration** (if Terraform files are included):

   ```bash
   terraform init
   terraform apply
   ```

3. **AWS Console**:

   * Alternatively, you can manually set up the VPC and its components by following the architecture diagram.

## Resources Created

* **VPC** with a CIDR block of `10.0.0.0/16`
* **Public Subnet** and **Private Subnet** for isolating resources
* **Internet Gateway** for enabling internet access to public instances
* **NAT Gateway** to route traffic from the private subnet
* **Route Tables** for managing traffic within the VPC

## Contributing

Feel free to contribute to this project by opening issues or submitting pull requests.

