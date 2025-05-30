# Medusa E-commerce Platform Infrastructure
# 
# This Terraform configuration deploys a Medusa e-commerce backend
# on AWS ECS Fargate with PostgreSQL and Redis
#
# Components:
# - VPC with public subnet
# - ECS Fargate cluster
# - PostgreSQL database container
# - Redis cache container  
# - Medusa backend application container
# - IAM roles and security groups

#aws ecs execute-command \
#  --region ap-south-1 \
#  --cluster medusa-cluster \
#  --service medusa-service \
#  --task bff2ef3e6361400a8b31e192881512b0 \
#  --container "medusa-backend" \
#  --interactive \
#  --command "/bin/sh"
#
# curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
# sudo dpkg -i session-manager-plugin.deb
#
#aws ecs describe-tasks \
#--cluster medusa-cluster \
#--tasks bff2ef3e6361400a8b31e192881512b0 \
#--region ap-south-1
#
#