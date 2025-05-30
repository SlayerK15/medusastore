#!/bin/bash

# Medusa Store Development Setup Script
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Medusa Store Development Setup${NC}"
echo "========================================"

# Step 0: Get user credentials
echo -e "\n${YELLOW}Step 0: Admin User Setup${NC}"
read -p "Enter admin email: " ADMIN_EMAIL
read -s -p "Enter admin password: " ADMIN_PASSWORD
echo ""

if [ -z "$ADMIN_EMAIL" ] || [ -z "$ADMIN_PASSWORD" ]; then
    echo -e "${RED}❌ Email and password are required!${NC}"
    exit 1
fi

# Step 1: Start backend services
echo -e "\n${YELLOW}Step 1: Starting backend services...${NC}"
echo "🔄 Starting PostgreSQL, Redis, and Medusa Backend..."

docker-compose down > /dev/null 2>&1
docker-compose up -d postgres redis medusa-backend

# Wait for services to be ready
echo "⏳ Waiting for backend to be ready..."
sleep 10

# Check if backend is running
RETRIES=0
MAX_RETRIES=30
while [ $RETRIES -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:9000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is ready!${NC}"
        break
    fi
    echo "⏳ Backend not ready yet... (attempt $((RETRIES+1))/$MAX_RETRIES)"
    sleep 5
    RETRIES=$((RETRIES+1))
done

if [ $RETRIES -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Backend failed to start. Check logs with: docker logs medusa-store-medusa-backend-1${NC}"
    exit 1
fi

# Step 2: Create admin user
echo -e "\n${YELLOW}Step 2: Creating admin user...${NC}"
docker exec -it medusa-store-medusa-backend-1 npx medusa user -e "$ADMIN_EMAIL" -p "$ADMIN_PASSWORD"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Admin user created successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  User might already exist or there was an issue. Continuing...${NC}"
fi

# Step 3: Instructions for API key
echo -e "\n${YELLOW}Step 3: API Key Setup${NC}"
echo "📋 Please follow these steps to create a publishable API key:"
echo ""
echo -e "${BLUE}1.${NC} Open your browser and go to: ${GREEN}http://localhost:9000/app${NC}"
echo -e "${BLUE}2.${NC} Login with:"
echo -e "   Email: ${GREEN}$ADMIN_EMAIL${NC}"
echo -e "   Password: ${GREEN}[your password]${NC}"
echo -e "${BLUE}3.${NC} Navigate to: ${GREEN}Settings → API Key Management → Publishable API Keys${NC}"
echo -e "${BLUE}4.${NC} Click ${GREEN}'Create Publishable Key'${NC}"
echo -e "${BLUE}5.${NC} Give it a name (e.g., 'Development Key')"
echo -e "${BLUE}6.${NC} Copy the generated key (starts with 'pk_')"
echo ""

# Step 4: Wait for API key input
echo -e "${YELLOW}Step 4: Enter your API key${NC}"
echo -e "${YELLOW}⏳ Waiting for you to create and copy the API key...${NC}"
echo ""
read -p "Paste your publishable API key here: " API_KEY
echo ""

if [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ API key is required!${NC}"
    exit 1
fi

if [[ ! $API_KEY == pk_* ]]; then
    echo -e "${RED}❌ Invalid API key format! Key should start with 'pk_'${NC}"
    exit 1
fi

# Update docker-compose.yml with the API key
echo -e "${YELLOW}🔄 Updating docker-compose.yml with your API key...${NC}"

# Create a backup
cp docker-compose.yml docker-compose.yml.backup

# Update the API key in docker-compose.yml
sed -i.tmp "s/NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY:.*/NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY: $API_KEY/" docker-compose.yml
rm -f docker-compose.yml.tmp

echo -e "${GREEN}✅ Configuration updated!${NC}"

# Step 5: Start storefront
echo -e "\n${YELLOW}Step 5: Starting storefront...${NC}"
docker-compose up -d medusa-storefront

echo "⏳ Waiting for storefront to be ready..."
sleep 10

# Check if storefront is running
RETRIES=0
MAX_RETRIES=20
while [ $RETRIES -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:8000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Storefront is ready!${NC}"
        break
    fi
    echo "⏳ Storefront not ready yet... (attempt $((RETRIES+1))/$MAX_RETRIES)"
    sleep 5
    RETRIES=$((RETRIES+1))
done

# Step 6: Setup complete
echo -e "\n${GREEN}🎉 Setup Complete!${NC}"
echo "========================================"
echo -e "${BLUE}Your Medusa store is now running:${NC}"
echo ""
echo -e "🛍️  Storefront: ${GREEN}http://localhost:8000${NC}"
echo -e "⚙️  Admin Panel: ${GREEN}http://localhost:9000/app${NC}"
echo -e "🔌 API: ${GREEN}http://localhost:9000${NC}"
echo ""
echo -e "${BLUE}Admin Credentials:${NC}"
echo -e "📧 Email: ${GREEN}$ADMIN_EMAIL${NC}"
echo -e "🔑 Password: ${GREEN}[your password]${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "• Add products in the admin panel before testing the storefront"
echo "• Check logs with: docker-compose logs -f"
echo "• Stop services with: docker-compose down"
echo ""

# Check if everything is working
if curl -f http://localhost:8000 > /dev/null 2>&1 && curl -f http://localhost:9000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ All services are running successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Some services might not be fully ready yet. Check logs if needed.${NC}"
fi

echo -e "\n${BLUE}🚀 Happy coding!${NC}"