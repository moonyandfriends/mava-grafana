#!/bin/bash

# Mava Grafana Start Script
# This script helps you start the Grafana container with different configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PROFILE=""
ENV_FILE="env.example"
DETACHED=false

# Function to display usage
usage() {
    echo -e "${BLUE}Mava Grafana Setup - Start Script${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --profile PROFILE    Docker Compose profile to use (with-prometheus)"
    echo "  -e, --env-file FILE      Environment file to use (default: env.example)"
    echo "  -d, --detached          Run in detached mode"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Start Grafana only"
    echo "  $0 -p with-prometheus                # Start with Prometheus"
    echo "  $0 -p with-prometheus -d             # Start with Prometheus in detached mode"
    echo "  $0 -e .env                           # Use custom environment file"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -e|--env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        -d|--detached)
            DETACHED=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    exit 1
fi

# Check if environment file exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "${YELLOW}Warning: Environment file '$ENV_FILE' not found${NC}"
    echo -e "${YELLOW}Creating .env file from env.example...${NC}"
    if [[ -f "env.example" ]]; then
        cp env.example .env
        ENV_FILE=".env"
        echo -e "${GREEN}✓ Created .env file${NC}"
    else
        echo -e "${RED}Error: env.example file not found${NC}"
        exit 1
    fi
fi

# Build the Docker Compose command
COMPOSE_CMD="docker-compose"
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
fi

COMPOSE_ARGS="--env-file $ENV_FILE"

if [[ -n "$PROFILE" ]]; then
    COMPOSE_ARGS="$COMPOSE_ARGS --profile $PROFILE"
fi

if [[ "$DETACHED" == true ]]; then
    COMPOSE_ARGS="$COMPOSE_ARGS -d"
fi

# Display configuration
echo -e "${BLUE}Mava Grafana Setup${NC}"
echo -e "${BLUE}==================${NC}"
echo -e "Environment file: ${GREEN}$ENV_FILE${NC}"
if [[ -n "$PROFILE" ]]; then
    echo -e "Profile: ${GREEN}$PROFILE${NC}"
fi
echo -e "Detached mode: ${GREEN}$DETACHED${NC}"
echo ""

# Start the services
echo -e "${YELLOW}Starting services...${NC}"
$COMPOSE_CMD $COMPOSE_ARGS up --build

# If not detached, show completion message
if [[ "$DETACHED" == false ]]; then
    echo ""
    echo -e "${GREEN}✓ Services stopped${NC}"
else
    echo ""
    echo -e "${GREEN}✓ Services started in detached mode${NC}"
    echo ""
    echo -e "${BLUE}Access your services:${NC}"
    
    # Read ports from environment file
    GRAFANA_PORT=$(grep GRAFANA_PORT "$ENV_FILE" | cut -d '=' -f2 | tr -d ' ')
    GRAFANA_PORT=${GRAFANA_PORT:-3000}
    
    echo -e "• Grafana: ${GREEN}http://localhost:$GRAFANA_PORT${NC}"
    
    if [[ "$PROFILE" == "with-prometheus" ]]; then
        PROMETHEUS_PORT=$(grep PROMETHEUS_PORT "$ENV_FILE" | cut -d '=' -f2 | tr -d ' ')
        PROMETHEUS_PORT=${PROMETHEUS_PORT:-9090}
        echo -e "• Prometheus: ${GREEN}http://localhost:$PROMETHEUS_PORT${NC}"
    fi
    
    echo ""
    echo -e "To stop the services, run: ${YELLOW}$0 --stop${NC}"
    echo -e "To view logs, run: ${YELLOW}docker-compose logs -f${NC}"
fi 