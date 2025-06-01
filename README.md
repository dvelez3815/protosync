# 🚀 Proto-Sync Monorepo

A modern full-stack application built with **NestJS** backend, **Astro** frontend, and **MongoDB** database, organized in a monorepo structure with shared packages.

## 🏗️ Architecture

This monorepo contains:
- **Backend API** (`apps/server`) - NestJS with MongoDB
- **Frontend Web** (`apps/web`) - Astro with React and Tailwind CSS  
- **Shared Package** (`packages/shared`) - Common types and utilities

## 🛠️ Installation and Configuration

### 1. Clone the repository

```bash
git clone <repository-url>
cd proto-sync
```

### 2. Install dependencies

```bash
# Install all workspace dependencies
pnpm install
```

### 3. Configure environment variables

```bash
# Copy environment template
cp .env.example .env
```

Edit the `.env` file according to your needs.

### 4. Run with Docker

#### Development Environment (with hot reload)

```bash
# Using the management script
./scripts/docker.sh dev

# Or using pnpm
pnpm run docker:dev

# Or using docker-compose directly
docker-compose -f docker/docker-compose.dev.yml up --build -d
```

#### Production Environment

```bash
# Using the management script
./scripts/docker.sh prod

# Or using pnpm
pnpm run docker:prod

# Or using docker-compose directly
docker-compose -f docker/docker-compose.yml up --build -d
```

## 📖 Available Services

| Service | Port | Description | URL |
|---------|------|-------------|-----|
| Frontend (Web) | 4321 | Astro application | http://localhost:4321 |
| Backend API | 3000 | NestJS API | http://localhost:3000/api |
| MongoDB | 27018 | Database | - |
| MongoDB Express | 8081 | Database admin | http://localhost:8081 |
| Nginx (Production) | 80 | Reverse proxy | http://localhost |

## 🔧 Docker Commands

### Management Script (`./scripts/docker.sh`)

```bash
./scripts/docker.sh dev      # Start development environment
./scripts/docker.sh prod     # Start production environment  
./scripts/docker.sh stop     # Stop all containers
./scripts/docker.sh clean    # Clean containers and volumes
./scripts/docker.sh build    # Build Docker images
./scripts/docker.sh logs     # View application logs
./scripts/docker.sh mongo    # Open MongoDB shell
./scripts/docker.sh help     # Show help
```

### pnpm Scripts

```bash
pnpm run docker:dev     # Development environment
pnpm run docker:prod    # Production environment
pnpm run docker:stop    # Stop all containers
pnpm run docker:clean   # Clean containers and volumes
pnpm run docker:build   # Build images
pnpm run docker:logs    # View logs

# Development scripts
pnpm run dev            # Start all apps in development
pnpm run build          # Build all apps
pnpm run start          # Start all apps in production
pnpm run lint           # Lint all packages
pnpm run type-check     # Type check all packages
```

### Workspace Commands

```bash
# Run commands in specific apps
pnpm --filter server dev        # Start backend only
pnpm --filter web dev          # Start frontend only  
pnpm --filter shared build    # Build shared package

# Install dependencies in specific apps
pnpm --filter server add express
pnpm --filter web add react
```

## 🌐 API Endpoints

All API endpoints are prefixed with `/api`.

### Health Check

```http
GET /api/health
```

### Users

```http
GET    /api/users           # Get all users
POST   /api/users           # Create user
GET    /api/users/:id       # Get user by ID
PUT    /api/users/:id       # Update user
DELETE /api/users/:id       # Delete user
GET    /api/users/email/:email # Get user by email
```

### User creation example

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "tags": ["developer", "nodejs"]
  }'
```

## 🌍 Frontend Features

The Astro frontend includes:
- **React integration** for interactive components
- **Tailwind CSS** for styling
- **TypeScript** support
- **User management interface** with CRUD operations
- **Responsive design**
- **API integration** with the NestJS backend

### Frontend URLs

- **Home**: http://localhost:4321
- **Users**: http://localhost:4321/users

## 🗄️ Database Schema

### User

```javascript
{
  _id: ObjectId,
  name: String,        // Required
  email: String,       // Required, unique
  age: Number,         // Required, 0-120
  isActive: Boolean,   // Default: true
  tags: [String],      // Array of tags
  createdAt: Date,     // Automatic
  updatedAt: Date      // Automatic
}
```

## 🛠️ Local Development (without Docker)

If you prefer to develop without Docker:

### 1. Install dependencies

```bash
pnpm install
```

### 2. Run MongoDB locally

```bash
# With Docker only for MongoDB
docker run -d --name proto-sync-mongo \
  -p 27018:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  mongo:7.0
```

### 3. Update .env for local development

```env
MONGODB_URI=mongodb://admin:password123@localhost:27018/proto-sync-db
```

### 4. Start the applications

```bash
# Start backend (NestJS)
pnpm --filter server dev

# Start frontend (Astro) - in another terminal
pnpm --filter web dev

# Or start both in parallel
pnpm run dev
```

Access the applications:
- Frontend: http://localhost:4321
- Backend API: http://localhost:3000/api

## 📚 Project Structure

```
proto-sync/
├── apps/
│   ├── server/                # NestJS Backend
│   │   ├── src/
│   │   │   ├── database/      # Database module
│   │   │   ├── health/        # Health checks
│   │   │   ├── user/          # User module
│   │   │   │   ├── dto/       # Data Transfer Objects
│   │   │   │   ├── schemas/   # MongoDB schemas
│   │   │   │   ├── users.controller.ts
│   │   │   │   ├── users.service.ts
│   │   │   │   └── user.module.ts
│   │   │   ├── app.module.ts  # Main module
│   │   │   └── main.ts        # Entry point
│   │   ├── Dockerfile
│   │   └── package.json
│   └── web/                   # Astro Frontend
│       ├── src/
│       │   ├── components/    # React components
│       │   │   └── UserList.tsx
│       │   ├── layouts/       # Astro layouts
│       │   └── pages/         # Astro pages
│       ├── public/            # Static assets
│       ├── astro.config.mjs   # Astro configuration
│       ├── tailwind.config.mjs # Tailwind configuration
│       ├── Dockerfile
│       └── package.json
├── packages/
│   └── shared/                # Shared utilities
│       ├── src/
│       │   ├── types/         # TypeScript types
│       │   └── utils/         # Utility functions
│       ├── tsconfig.json
│       └── package.json
├── docker/
│   ├── docker-compose.yml     # Production
│   ├── docker-compose.dev.yml # Development
│   └── nginx.conf             # Nginx configuration
├── scripts/
│   └── docker.sh              # Docker management script
├── pnpm-workspace.yaml        # Workspace configuration
├── package.json               # Root package configuration
└── .gitignore                 # Git ignore rules
```

## 🧩 Shared Package

The `packages/shared` contains:
- **Common TypeScript types** for User entities
- **Utility functions** used across frontend and backend
- **Validation schemas** and helpers
- **Constants** and configuration

Import shared utilities:

```typescript
// In apps/server or apps/web
import { User, ApiResponse } from '@proto-sync/shared';
import { formatDate, validateEmail } from '@proto-sync/shared/utils';
```

## 🔍 Monitoring and Logs

### View logs in real time

```bash
# All services
./scripts/docker.sh logs

# Specific service
docker-compose -f docker/docker-compose.dev.yml logs -f server
docker-compose -f docker/docker-compose.dev.yml logs -f web
```

### Access services

- **Frontend**: http://localhost:4321
- **Backend API**: http://localhost:3000/api
- **MongoDB Express**: http://localhost:8081
- **Production (Nginx)**: http://localhost

### Health Checks

```bash
# Backend health
curl http://localhost:3000/api/health

# Frontend (Astro)
curl http://localhost:4321
```

## 🚨 Troubleshooting

### Problem: Port in use

```bash
# Check processes using the ports
lsof -i :4321  # Frontend
lsof -i :3000  # Backend  
lsof -i :27018 # MongoDB

# Stop conflicting services
./scripts/docker.sh stop
```

### Change ports if there are conflicts

1. **For Frontend (Astro)**: Edit `apps/web/astro.config.mjs`
   ```javascript
   export default defineConfig({
     server: { port: 4322 }, // Change port
     // ...
   });
   ```

2. **For Backend (NestJS)**: Edit the `.env` file
   ```env
   PORT=3001  # Change to another available port
   ```

3. **For MongoDB**: Edit `docker/docker-compose.yml` and `docker/docker-compose.dev.yml`
   ```yaml
   ports:
     - "27019:27017"  # Change 27018 to another port
   ```

### Problem: Workspace dependencies

```bash
# Clean and reinstall all dependencies
rm -rf node_modules apps/*/node_modules packages/*/node_modules
pnpm install

# Or clean with Docker
./scripts/docker.sh clean
```

### Problem: Corrupted volumes

```bash
# Clean completely
./scripts/docker.sh clean

# Restart
./scripts/docker.sh dev
```

### Problem: TypeScript errors in shared package

```bash
# Build shared package first
pnpm --filter shared build

# Then build other packages
pnpm run build
```

### Problem: Docker permissions

```bash
# On Linux, ensure Docker permissions
sudo usermod -aG docker $USER
# Then restart session
```

## 📝 Environment Variables

| Variable | Description | Default | Used In |
|----------|-------------|---------|---------|
| `PORT` | Backend API port | `3000` | Server |
| `NODE_ENV` | Runtime environment | `development` | Server |
| `MONGODB_URI` | MongoDB connection URI | `mongodb://mongodb:27018/proto-sync-db` | Server |
| `MONGODB_USER` | MongoDB user | `admin` | Docker |
| `MONGODB_PASSWORD` | MongoDB password | `password123` | Docker |
| `MONGODB_DATABASE` | Database name | `proto-sync-db` | Docker |
| `API_URL` | Backend API URL | `http://localhost:3000/api` | Web |

## 🚀 Deployment

### Production with Docker

The production setup uses:
- **Nginx** as reverse proxy
- **Multi-stage builds** for optimized images
- **Health checks** for all services
- **Volume persistence** for MongoDB data

```bash
# Deploy to production
./scripts/docker.sh prod

# Access via Nginx reverse proxy
http://localhost        # Frontend
http://localhost/api    # Backend API
```

### Production Environment Variables

Create a `.env.production` file with:

```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://mongodb:27017/proto-sync-db
MONGODB_USER=admin
MONGODB_PASSWORD=your-secure-password
API_URL=http://your-domain.com/api
```

## 🧪 Testing

```bash
# Run tests for all packages
pnpm run test

# Run tests for specific package
pnpm --filter server test
pnpm --filter web test
pnpm --filter shared test

# Run e2e tests
pnpm run test:e2e
```

## 🛠️ Development Guidelines

### Adding New Features

1. **Backend changes**: Work in `apps/server/src/`
2. **Frontend changes**: Work in `apps/web/src/`  
3. **Shared types**: Add to `packages/shared/src/types/`
4. **Utilities**: Add to `packages/shared/src/utils/`

### Code Quality

```bash
# Lint all packages
pnpm run lint

# Type check all packages  
pnpm run type-check

# Format code
pnpm run format
```

### Database Migrations

```bash
# Access MongoDB shell
./scripts/docker.sh mongo

# Or via Docker
docker exec -it proto-sync-mongodb mongosh -u admin -p password123
```

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes in the appropriate workspace:
   - Backend: `apps/server/`
   - Frontend: `apps/web/`
   - Shared: `packages/shared/`
4. Run tests and linting (`pnpm run lint && pnpm run test`)
5. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

### Workspace Guidelines

- **Keep shared types in sync** between frontend and backend
- **Use the shared package** for common utilities
- **Follow TypeScript best practices**
- **Update tests** for new features
- **Document API changes** in this README

## 🏗️ Technology Stack

### Backend (NestJS)
- **NestJS** - Progressive Node.js framework
- **MongoDB** with Mongoose - NoSQL database
- **TypeScript** - Type-safe JavaScript
- **Class Validator** - Validation decorators
- **Swagger** - API documentation

### Frontend (Astro)
- **Astro** - Static site generator with islands architecture
- **React** - UI components
- **Tailwind CSS** - Utility-first CSS framework
- **TypeScript** - Type safety

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Nginx** - Reverse proxy and static serving
- **pnpm** - Fast, disk space efficient package manager

## 📄 License

This project is under the UNLICENSED License - see the [LICENSE](LICENSE) file for details.

---

## 🎯 Quick Start Summary

```bash
# 1. Clone and install
git clone <repository-url>
cd proto-sync
pnpm install

# 2. Start development environment
./scripts/docker.sh dev

# 3. Access applications
# Frontend: http://localhost:4321
# Backend:  http://localhost:3000/api
# Database: http://localhost:8081
```

Built with ❤️ using modern web technologies and monorepo best practices.