# ☁️ Terraform AWS EC2 Setup (Free Tier)

This project creates a complete AWS EC2 setup using Terraform, including:

- 🧑‍💻 EC2 instance with SSH access
- 🔑 Key pair for SSH
- 🔐 Security group (SSH + HTTP)
- 🗃️ EBS volume (1 GB attached disk)
- 🪣 S3 bucket with a random name
- 📊 CloudWatch Log Group
- ✅ All resources are Free Tier–eligible

---

## 📁 Project Structure

```bash
terraform-ec2-setup/
├── main.tf             # Core infrastructure
├── outputs.tf          # Public IP, bucket name, EBS ID
├── terraform-key       # Your private key (DO NOT COMMIT)
├── terraform-key.pub   # Your public key
└── README.md           # Project documentation
