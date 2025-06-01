#!/bin/bash
# filepath: /home/darwin/Desktop/tests/proto-sync/scripts/docker.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if pnpm is installed
check_pnpm() {
    if ! command -v pnpm &> /dev/null; then
        print_error "pnpm is not installed. Please install it first: npm install -g pnpm"
        exit 1
    fi
}

# Help function
show_help() {
    print_header "Proto Sync Docker Management"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  dev      Start development environment"
    echo "  prod     Start production environment"
    echo "  stop     Stop all containers"
    echo "  clean    Stop containers and remove volumes"
    echo "  build    Build all Docker images"
    echo "  logs     Show application logs"
    echo "  mongo    Open MongoDB shell"
    echo "  status   Show containers status"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev     # Start development environment"
    echo "  $0 prod    # Start production environment"
    echo "  $0 clean   # Clean up everything"
}

# Function to show status
show_status() {
    print_header "Containers Status"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Function to start development environment
start_dev() {
    print_header "Starting Development Environment"
    check_docker
    check_pnpm
    
    # Navigate to docker directory
    cd "$(dirname "$0")/../docker" || exit 1
    
    # Create .env if it doesn't exist
    if [ ! -f ../.env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        if [ -f ../.env.example ]; then
            cp ../.env.example ../.env
        else
            print_info "Creating default .env file..."
            cat > ../.env << EOF
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://admin:password123@mongodb:27017/proto-sync-db?authSource=admin
MONGODB_USER=admin
MONGODB_PASSWORD=password123
MONGODB_DATABASE=proto-sync-db
FRONTEND_URL=http://localhost:4321
API_URL=http://localhost:3000
EOF
        fi
    fi
    
    # Install dependencies if not present
    if [ ! -d "../node_modules" ]; then
        print_info "Installing dependencies..."
        cd .. && pnpm install && cd docker
    fi
    
    print_info "Starting containers..."
    docker compose -f docker-compose.dev.yml up --build -d
    
    print_status "Development environment started!"
    echo ""
    print_info "Available services:"
    echo "  🌐 Frontend: http://localhost:4321"
    echo "  🔌 Backend API: http://localhost:3000"
    echo "  📊 API Docs: http://localhost:3000/api"
    echo "  🗄️  MongoDB Express: http://localhost:8081"
    echo "  💾 MongoDB: localhost:27018"
    echo ""
    print_info "Useful commands:"
    echo "  $0 logs    # View logs"
    echo "  $0 status  # Check status"
    echo "  $0 mongo   # Access MongoDB shell"
}

# Function to start production environment
start_prod() {
    print_header "Starting Production Environment"
    check_docker
    
    cd "$(dirname "$0")/../docker" || exit 1
    
    if [ ! -f ../.env ]; then
        print_warning ".env file not found. Creating production .env..."
        cat > ../.env << EOF
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://admin:password123@mongodb:27017/proto-sync-db?authSource=admin
MONGODB_USER=admin
MONGODB_PASSWORD=password123
MONGODB_DATABASE=proto-sync-db
FRONTEND_URL=http://web:4321
API_URL=http://server:3000
EOF
    fi
    
    print_info "Building and starting production containers..."
    docker compose up --build -d
    
    print_status "Production environment started!"
    echo ""
    print_info "Available services:"
    echo "  🌐 Application: http://localhost (Nginx)"
    echo "  🗄️  MongoDB Express: http://localhost:8081"
    echo ""
    print_info "Internal services:"
    echo "  🔌 Backend API: http://localhost/api"
    echo "  💾 MongoDB: localhost:27018"
}

# Function to stop containers
stop_containers() {
    print_header "Stopping Containers"
    cd "$(dirname "$0")/../docker" || exit 1
    
    print_info "Stopping development containers..."
    docker compose -f docker-compose.dev.yml down
    
    print_info "Stopping production containers..."
    docker compose down
    
    print_status "All containers stopped!"
}

# Function to clean up
clean_up() {
    print_header "Cleaning Up"
    cd "$(dirname "$0")/../docker" || exit 1
    
    print_info "Stopping and removing containers with volumes..."
    docker compose -f docker-compose.dev.yml down -v
    docker compose down -v
    
    print_info "Cleaning Docker system..."
    docker system prune -f
    
    print_info "Removing unused images..."
    docker image prune -f
    
    print_status "Cleanup completed!"
}

# Function to build images
build_images() {
    print_header "Building Docker Images"
    check_docker
    cd "$(dirname "$0")/../docker" || exit 1
    
    print_info "Building development images..."
    docker compose -f docker-compose.dev.yml build --no-cache
    
    print_info "Building production images..."
    docker compose build --no-cache
    
    print_status "Images built successfully!"
}

# Function to show logs
show_logs() {
    print_header "Application Logs"
    cd "$(dirname "$0")/../docker" || exit 1
    
    echo "Select service logs to view:"
    echo "1) Server (Backend)"
    echo "2) Web (Frontend)"
    echo "3) MongoDB"
    echo "4) Nginx"
    echo "5) All services"
    read -p "Enter choice (1-5): " choice
    
    case $choice in
        1)
            if docker ps | grep -q proto-sync-server-dev; then
                docker logs -f proto-sync-server-dev
            elif docker ps | grep -q proto-sync-server; then
                docker logs -f proto-sync-server
            else
                print_error "No server container found!"
            fi
            ;;
        2)
            if docker ps | grep -q proto-sync-web-dev; then
                docker logs -f proto-sync-web-dev
            elif docker ps | grep -q proto-sync-web; then
                docker logs -f proto-sync-web
            else
                print_error "No web container found!"
            fi
            ;;
        3)
            if docker ps | grep -q proto-sync-mongodb-dev; then
                docker logs -f proto-sync-mongodb-dev
            elif docker ps | grep -q proto-sync-mongodb; then
                docker logs -f proto-sync-mongodb
            else
                print_error "No MongoDB container found!"
            fi
            ;;
        4)
            if docker ps | grep -q proto-sync-nginx; then
                docker logs -f proto-sync-nginx
            else
                print_error "No Nginx container found!"
            fi
            ;;
        5)
            if docker ps | grep -q proto-sync-.*-dev; then
                docker compose -f docker-compose.dev.yml logs -f
            else
                docker compose logs -f
            fi
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to open MongoDB shell
open_mongo_shell() {
    print_header "Opening MongoDB Shell"
    cd "$(dirname "$0")/../docker" || exit 1
    
    if docker ps | grep -q proto-sync-mongodb-dev; then
        print_info "Connecting to development MongoDB..."
        docker exec -it proto-sync-mongodb-dev mongosh --username admin --password password123 --authenticationDatabase admin
    elif docker ps | grep -q proto-sync-mongodb; then
        print_info "Connecting to production MongoDB..."
        docker exec -it proto-sync-mongodb mongosh --username admin --password password123 --authenticationDatabase admin
    else
        print_error "No running MongoDB container found!"
        exit 1
    fi
}

# Make script executable
chmod +x "$0"

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
        build_images
        ;;
    "logs")
        show_logs
        ;;
    "mongo")
        open_mongo_shell
        ;;
    "status")
        show_status
        ;;
    "help"|*)
        show_help
        ;;
esac