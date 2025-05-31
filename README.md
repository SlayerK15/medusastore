# Medusa E-commerce Platform - AWS ECS Deployment

This project deploys a [Medusa v2](https://medusajs.com/) e-commerce platform on AWS ECS Fargate using Docker containers, Terraform for infrastructure as code, and GitHub Actions for CI/CD automation.

## 🏗️ Architecture

The application stack consists of:
- **Medusa Backend** - Node.js e-commerce application
- **PostgreSQL** - Primary database
- **Redis** - Caching and session storage
- **AWS ECS Fargate** - Container orchestration
- **ECR** - Container registry
- **VPC with public subnet** - Network infrastructure

## 📋 Development Plan

### Phase 1: Local Development Setup
✅ **Docker Configuration**
- Created Dockerfile for Medusa backend
- Set up docker-compose.yml with PostgreSQL, Redis, and Medusa services
- Tested application locally on `localhost:9000`

### Phase 2: Infrastructure as Code
✅ **Terraform Configuration**
- VPC with public subnet and internet gateway
- ECS Fargate cluster and service
- IAM roles and security groups
- Multi-container task definition
- S3 backend for state management

### Phase 3: CI/CD Automation
✅ **GitHub Actions**
- Automated Docker image build and push to ECR
- Infrastructure deployment on push to main branch
- Manual destroy workflow with confirmation

## 🚧 Challenges Faced & Solutions

### 1. **Container Communication Issue**
**Problem**: Redis and PostgreSQL ports were not accessible from the Medusa container
```
Error: Connection refused to postgres:5432 and redis:6379
```
**Root Cause**: `medusa-config.ts` was overriding environment variables with default localhost values
**Solution**: 
- Added debug logging to `medusa-config.ts` to trace configuration values
- Modified Docker environment variables to ensure proper service discovery
- Updated container networking configuration

### 2. **ECS Deployment Rollback**
**Problem**: Deployment kept rolling back due to container startup failures
```
Task stopped (Essential container in task exited)
```
**Root Cause**: Alpine Node.js image had dependency conflicts during npm install
**Solution**: Enhanced Dockerfile with forced clean installation:
```dockerfile
RUN npm cache clean --force && \
    rm -rf node_modules package-lock.json && \
    npm install
```

### 3. **Application Load Balancer 404 Errors**
**Problem**: ALB was returning 404 Not Found for all requests
**Root Cause**: Medusa v2 uses Vite internally but no vite.config.js was configured for ALB path routing
**Solution**: Removed ALB and configured direct ECS service access with public IP assignment

## 🚀 Getting Started

### Prerequisites
- Docker and Docker Compose installed
- AWS CLI configured (for Terraform/GitHub Actions)
- Terraform installed (for infrastructure deployment)
- Node.js 20+ (for local development)

### Option 1: Local Development with Docker Compose

1. **Clone the repository**
```bash
git clone <repository-url>
cd medusa-store-deployment
```

2. **Start the application**
```bash
docker-compose up --build
```

3. **Access the application**
- Medusa Backend: http://localhost:9000
- Admin Panel: http://localhost:9000/app
- PostgreSQL: localhost:5432
- Redis: localhost:6379

4. **Seed sample data** (optional)
```bash
docker-compose exec medusa-backend npm run seed
```

### Option 2: Deploy with Terraform

1. **Update ECR repository**
```bash
# Edit terraform/variables.tf
variable "ecr_image_uri" {
  default = "YOUR_AWS_ACCOUNT.dkr.ecr.YOUR_REGION.amazonaws.com/medusa-store:latest"
}
```

2. **Build and push Docker image**
```bash
# Build image
docker build -t medusa-store ./my-medusa-store

# Tag and push to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin YOUR_ECR_URI
docker tag medusa-store:latest YOUR_ECR_URI:latest
docker push YOUR_ECR_URI:latest
```

3. **Deploy infrastructure**
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

4. **Clean up resources**
```bash
terraform destroy
```

⚠️ **Important**: Always destroy resources after testing to avoid AWS charges!

### Option 3: Automated Deployment with GitHub Actions

1. **Configure repository secrets**
Go to GitHub Repository → Settings → Secrets and add:
```
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
```

2. **Automatic deployment**
- Push to `main` branch triggers automatic deployment
- GitHub Actions will build, push to ECR, and deploy via Terraform

3. **Manual infrastructure destruction**
- Go to Actions tab → "Destroy Medusa Store Infrastructure"
- Click "Run workflow"
- Type "DESTROY" to confirm
- This prevents accidental resource deletion

## 📁 Project Structure

```
├── .github/workflows/
│   ├── deploy.yml          # Automated deployment workflow
│   └── destroy.yml         # Manual destroy workflow
├── my-medusa-store/        # Medusa application code
│   ├── Dockerfile          # Container configuration
│   ├── medusa-config.ts    # Medusa configuration
│   └── src/                # Application source code
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   └── *.tf               # Individual resource configurations
└── docker-compose.yml     # Local development setup
```

## 🔧 Configuration

### Environment Variables
Key environment variables for the Medusa application:
```env
NODE_ENV=production
DATABASE_URL=postgres://medusa:medusa@localhost:5432/medusa
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret
COOKIE_SECRET=your_cookie_secret
ADMIN_CORS=http://localhost:9000
STORE_CORS=http://localhost:8000,http://localhost:3000
```

### AWS Resources Created
- VPC with public subnet (10.0.0.0/16)
- ECS Fargate cluster
- ECS service with auto-scaling
- Security groups (ports 9000, 5432, 6379)
- IAM roles for ECS tasks
- CloudWatch log groups

## 🔍 Monitoring & Debugging

### View ECS logs
```bash
aws logs describe-log-groups --log-group-name-prefix "/ecs/medusa"
aws logs get-log-events --log-group-name "/ecs/medusa-backend" --log-stream-name "ecs/medusa-backend/TASK_ID"
```

### Connect to running container
```bash
aws ecs execute-command \
  --region ap-south-1 \
  --cluster medusa-cluster \
  --service medusa-service \
  --task TASK_ID \
  --container "medusa-backend" \
  --interactive \
  --command "/bin/sh"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
- Check the [Medusa documentation](https://docs.medusajs.com/)
- Review AWS ECS troubleshooting guides
- Open an issue in this repository