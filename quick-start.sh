#!/bin/bash

# Architecture Firm Enrichment Pipeline - Quick Start Script
# This script sets up the environment for the n8n workflow

set -e  # Exit on error

echo "🏗️  Architecture Firm Enrichment Pipeline - Quick Start"
echo "======================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed${NC}"

# Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}⚠️  psql is not installed. You'll need it to set up the database.${NC}"
    echo "Install with: brew install postgresql (macOS) or apt-get install postgresql-client (Linux)"
fi

echo ""
echo "📋 Step 1: Environment Setup"
echo "----------------------------"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.template .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Edit .env and add your API keys!${NC}"
    echo ""
    read -p "Press Enter to open .env in your default editor..."
    ${EDITOR:-nano} .env
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

echo ""
echo "📦 Step 2: Starting PostgreSQL Database"
echo "----------------------------------------"

# Check if postgres container already exists
if docker ps -a | grep -q postgres-enrichment; then
    echo "PostgreSQL container already exists"
    if docker ps | grep -q postgres-enrichment; then
        echo -e "${GREEN}✅ PostgreSQL is running${NC}"
    else
        echo "Starting existing PostgreSQL container..."
        docker start postgres-enrichment
        echo -e "${GREEN}✅ PostgreSQL started${NC}"
    fi
else
    echo "Creating PostgreSQL container..."
    docker run --name postgres-enrichment \
        -e POSTGRES_PASSWORD=changeme123 \
        -e POSTGRES_DB=architecture_enrichment \
        -p 5432:5432 \
        -d postgres:16

    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
    echo -e "${GREEN}✅ PostgreSQL created and started${NC}"
fi

echo ""
echo "🗄️  Step 3: Creating Database Schema"
echo "------------------------------------"

# Check if psql is available
if command -v psql &> /dev/null; then
    echo "Running database schema..."
    PGPASSWORD=changeme123 psql -h localhost -U postgres -d architecture_enrichment -f database-schema.sql
    echo -e "${GREEN}✅ Database schema created${NC}"
else
    echo -e "${YELLOW}⚠️  psql not found. Run this manually:${NC}"
    echo "   PGPASSWORD=changeme123 psql -h localhost -U postgres -d architecture_enrichment -f database-schema.sql"
fi

echo ""
echo "🚀 Step 4: Starting n8n"
echo "----------------------"

# Check if n8n is already running
if docker ps | grep -q n8n-enrichment; then
    echo -e "${GREEN}✅ n8n is already running${NC}"
else
    echo "Starting n8n..."
    docker run -d --name n8n-enrichment \
        -p 5678:5678 \
        -v ~/.n8n:/home/node/.n8n \
        --link postgres-enrichment:postgres \
        n8nio/n8n

    echo "Waiting for n8n to start..."
    sleep 10
    echo -e "${GREEN}✅ n8n is running${NC}"
fi

echo ""
echo "✨ Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo ""
echo "1. Open n8n at: ${GREEN}http://localhost:5678${NC}"
echo ""
echo "2. Set up credentials in n8n:"
echo "   - Go to Settings → Credentials"
echo "   - Add OpenAI API key"
echo "   - Add SerpAPI key"
echo "   - Add Apollo.io API key"
echo "   - Add PostgreSQL credentials:"
echo "     Host: postgres (or localhost if connecting from outside Docker)"
echo "     Database: architecture_enrichment"
echo "     User: postgres"
echo "     Password: changeme123"
echo ""
echo "3. Import the workflow:"
echo "   - Click Workflows → Import from File"
echo "   - Select: ${GREEN}architecture-firm-enrichment-pipeline.json${NC}"
echo ""
echo "4. Test with sample data:"
echo "   - Use the included: ${GREEN}sample-architecture-firms.csv${NC}"
echo "   - Or prepare your 925 firm CSV"
echo ""
echo "5. Read the guides:"
echo "   - Quick overview: ${GREEN}ARCHITECTURE-PIPELINE-README.md${NC}"
echo "   - Detailed setup: ${GREEN}SETUP-GUIDE.md${NC}"
echo ""
echo "📊 Database Connection Info:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: architecture_enrichment"
echo "   User: postgres"
echo "   Password: changeme123"
echo ""
echo "🛑 To stop services:"
echo "   docker stop n8n-enrichment postgres-enrichment"
echo ""
echo "🗑️  To remove everything:"
echo "   docker stop n8n-enrichment postgres-enrichment"
echo "   docker rm n8n-enrichment postgres-enrichment"
echo ""
echo -e "${GREEN}Happy enriching! 🎉${NC}"
