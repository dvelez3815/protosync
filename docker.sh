#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}====== $1 ======${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to display help
show_help() {
    echo "Docker Management Script for Proto-Sync"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  dev      Start development environment"
    echo "  prod     Start production environment"
    echo "  stop     Stop all containers"
    echo "  clean    Stop containers and remove volumes"
    echo "  build    Build the Docker image"
    echo "  logs     Show application logs"
    echo "  mongo    Open MongoDB shell"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev     # Start development environment with hot reload"
    echo "  $0 prod    # Start production environment"
    echo "  $0 clean   # Clean up everything"
}

# Function to start development environment
start_dev() {
    print_header "Starting Development Environment"
    check_docker
    
    # Create .env if it doesn't exist
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
    fi
    
    docker-compose -f docker-compose.dev.yml up --build -d
    
    print_status "Development environment started!"
    print_status "Application: http://localhost:3000"
    print_status "MongoDB Express: http://localhost:8081"
    print_status "MongoDB: localhost:27018"
}

# Function to start production environment
start_prod() {
    print_header "Starting Production Environment"
    check_docker
    
    # Create .env if it doesn't exist
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
    fi
    
    docker-compose up --build -d
    
    print_status "Production environment started!"
    print_status "Application: http://localhost:3000"
    print_status "MongoDB Express: http://localhost:8081"
}

# Function to stop containers
stop_containers() {
    print_header "Stopping Containers"
    docker-compose -f docker-compose.dev.yml down
    docker-compose down
    print_status "All containers stopped!"
}

# Function to clean up
clean_up() {
    print_header "Cleaning Up"
    docker-compose -f docker-compose.dev.yml down -v
    docker-compose down -v
    docker system prune -f
    print_status "Cleanup completed!"
}

# Function to build image
build_image() {
    print_header "Building Docker Image"
    check_docker
    docker build -t proto-sync .
    print_status "Image built successfully!"
}

# Function to show logs
show_logs() {
    print_header "Application Logs"
    if docker ps | grep -q proto-sync-app; then
        docker logs -f proto-sync-app
    elif docker ps | grep -q proto-sync-app-dev; then
        docker logs -f proto-sync-app-dev
    else
        print_error "No running application container found!"
        exit 1
    fi
}

# Function to open MongoDB shell
open_mongo_shell() {
    print_header "Opening MongoDB Shell"
    if docker ps | grep -q mongodb; then
        docker exec -it proto-sync-mongodb mongosh --username admin --password password123
    elif docker ps | grep -q mongodb-dev; then
        docker exec -it proto-sync-mongodb-dev mongosh --username admin --password password123
    else
        print_error "No running MongoDB container found!"
        exit 1
    fi
}

# Main script logic
case "${1:-help}" in
    "dev")
        start_dev
        ;;
    "prod")
        start_prod
        ;;
    "stop")
        stop_containers
        ;;
    "clean")
        clean_up
        ;;
    "build")
        build_image
        ;;
    "logs")
        show_logs
        ;;
    "mongo")
        open_mongo_shell
        ;;
    "help"|*)
        show_help
        ;;
esac
