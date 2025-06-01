#!/bin/bash
# filepath: /home/darwin/Desktop/tests/proto-sync/migrate-to-monorepo.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Please run this script from the proto-sync root directory"
    exit 1
fi

print_header "Migrating to Monorepo Structure"

# Backup existing files
print_info "Creating backup of existing structure..."
if [ ! -d "backup" ]; then
    mkdir backup
    # Backup existing source if it exists
    if [ -d "src" ]; then
        cp -r src backup/
        print_status "Backed up existing src directory"
    fi
fi

# Create new directory structure
print_info "Creating monorepo directory structure..."
mkdir -p apps/server
mkdir -p apps/web/src/{components,pages,layouts,services,styles}
mkdir -p apps/web/public
mkdir -p packages/shared/{types,utils}
mkdir -p docker
mkdir -p scripts
mkdir -p logs

# Move existing NestJS files to server directory
print_info "Moving existing server files..."
if [ -d "src" ]; then
    mv src apps/server/
    print_status "Moved src to apps/server/"
fi

if [ -d "test" ]; then
    mv test apps/server/
    print_status "Moved test to apps/server/"
fi

# Move NestJS config files
for file in nest-cli.json tsconfig.json tsconfig.build.json; do
    if [ -f "$file" ]; then
        mv "$file" apps/server/
        print_status "Moved $file to apps/server/"
    fi
done

# Make scripts executable
chmod +x scripts/docker.sh
print_status "Made docker script executable"

# Create Astro frontend structure
print_info "Creating Astro frontend structure..."

# Create basic Astro pages
cat > apps/web/src/pages/index.astro << 'EOF'
---
import Layout from '../layouts/Layout.astro';
import UserList from '../components/UserList';
---

<Layout title="Proto Sync - Home">
    <main class="container mx-auto px-4 py-8">
        <h1 class="text-4xl font-bold text-center mb-8 text-gray-800">
            Welcome to Proto Sync
        </h1>
        <p class="text-xl text-center mb-8 text-gray-600">
            Full-stack application with NestJS backend and Astro frontend
        </p>
        <UserList client:load />
    </main>
</Layout>
EOF

# Create layout
cat > apps/web/src/layouts/Layout.astro << 'EOF'
---
export interface Props {
    title: string;
}

const { title } = Astro.props;
---

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="description" content="Proto Sync - Full Stack Application" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
        <title>{title}</title>
    </head>
    <body class="bg-gray-50">
        <header class="bg-white shadow-sm border-b">
            <nav class="container mx-auto px-4 py-4">
                <div class="flex justify-between items-center">
                    <h1 class="text-2xl font-bold text-gray-800">Proto Sync</h1>
                    <div class="space-x-4">
                        <a href="/" class="text-gray-600 hover:text-gray-800">Home</a>
                        <a href="/api" class="text-gray-600 hover:text-gray-800">API Docs</a>
                    </div>
                </div>
            </nav>
        </header>
        <slot />
        <footer class="bg-gray-800 text-white py-8 mt-16">
            <div class="container mx-auto px-4 text-center">
                <p>&copy; 2025 Proto Sync. Built with NestJS and Astro.</p>
            </div>
        </footer>
    </body>
</html>
EOF

# Create API service
cat > apps/web/src/services/api.ts << 'EOF'
import axios, { type AxiosInstance, type AxiosResponse } from 'axios';
import type { User, CreateUserDto, UpdateUserDto, ApiResponse, PaginatedResponse, HealthCheck } from '@proto-sync/shared';

class ApiService {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: import.meta.env.API_URL || 'http://localhost:3000',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        console.log(`🔄 API Request: ${config.method?.toUpperCase()} ${config.url}`);
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor
    this.client.interceptors.response.use(
      (response: AxiosResponse<ApiResponse<any>>) => {
        console.log(`✅ API Response: ${response.status} ${response.config.url}`);
        return response;
      },
      (error) => {
        console.error(`❌ API Error: ${error.response?.status} ${error.config?.url}`, error.response?.data);
        return Promise.reject(error);
      }
    );
  }

  // Health check
  async healthCheck(): Promise<ApiResponse<HealthCheck>> {
    const response = await this.client.get('/health');
    return response.data;
  }

  // User endpoints
  async getUsers(page = 1, limit = 10): Promise<PaginatedResponse<User>> {
    const response = await this.client.get(`/api/users?page=${page}&limit=${limit}`);
    return response.data;
  }

  async getUserById(id: string): Promise<ApiResponse<User>> {
    const response = await this.client.get(`/api/users/${id}`);
    return response.data;
  }

  async createUser(userData: CreateUserDto): Promise<ApiResponse<User>> {
    const response = await this.client.post('/api/users', userData);
    return response.data;
  }

  async updateUser(id: string, userData: UpdateUserDto): Promise<ApiResponse<User>> {
    const response = await this.client.patch(`/api/users/${id}`, userData);
    return response.data;
  }

  async deleteUser(id: string): Promise<ApiResponse<void>> {
    const response = await this.client.delete(`/api/users/${id}`);
    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;
EOF

# Create UserList component
cat > apps/web/src/components/UserList.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import type { User, CreateUserDto } from '@proto-sync/shared';

const UserList: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [newUser, setNewUser] = useState<CreateUserDto>({ name: '', email: '' });
  const [isCreating, setIsCreating] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await apiService.getUsers();
      setUsers(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch users');
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newUser.name || !newUser.email) return;

    try {
      setIsCreating(true);
      await apiService.createUser(newUser);
      setNewUser({ name: '', email: '' });
      await fetchUsers();
    } catch (err) {
      setError('Failed to create user');
      console.error('Error creating user:', err);
    } finally {
      setIsCreating(false);
    }
  };

  const handleDeleteUser = async (id: string) => {
    try {
      await apiService.deleteUser(id);
      await fetchUsers();
    } catch (err) {
      setError('Failed to delete user');
      console.error('Error deleting user:', err);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {/* Create User Form */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Add New User</h2>
        <form onSubmit={handleCreateUser} className="flex gap-4">
          <input
            type="text"
            placeholder="Name"
            value={newUser.name}
            onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
          <input
            type="email"
            placeholder="Email"
            value={newUser.email}
            onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
          <button
            type="submit"
            disabled={isCreating}
            className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50"
          >
            {isCreating ? 'Creating...' : 'Add User'}
          </button>
        </form>
      </div>

      {/* Users List */}
      <div className="bg-white rounded-lg shadow-md">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold">Users ({users.length})</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {users.length === 0 ? (
            <div className="p-6 text-center text-gray-500">
              No users found. Create your first user above!
            </div>
          ) : (
            users.map((user) => (
              <div key={user._id} className="p-6 flex justify-between items-center">
                <div>
                  <h3 className="font-medium text-gray-900">{user.name}</h3>
                  <p className="text-gray-500">{user.email}</p>
                  <p className="text-sm text-gray-400">
                    Created: {new Date(user.createdAt).toLocaleDateString()}
                  </p>
                </div>
                <div className="flex gap-2">
                  <span
                    className={`px-2 py-1 text-xs rounded-full ${
                      user.isActive
                        ? 'bg-green-100 text-green-800'
                        : 'bg-red-100 text-red-800'
                    }`}
                  >
                    {user.isActive ? 'Active' : 'Inactive'}
                  </span>
                  <button
                    onClick={() => handleDeleteUser(user._id)}
                    className="px-3 py-1 bg-red-500 text-white text-sm rounded hover:bg-red-600"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default UserList;
EOF

# Update main.ts to enable CORS and API prefix
if [ -f "apps/server/src/main.ts" ]; then
    cat > apps/server/src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for frontend
  app.enableCors({
    origin: process.env.FRONTEND_URL || 'http://localhost:4321',
    credentials: true,
  });

  // Global prefix for API routes
  app.setGlobalPrefix('api');
  
  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  
  logger.log(`🚀 API Server running on: http://localhost:${port}`);
  logger.log(`📖 Health check: http://localhost:${port}/health`);
  logger.log(`👥 Users API: http://localhost:${port}/api/users`);
}

bootstrap().catch((error) => {
  console.error('❌ Failed to start the application:', error);
  process.exit(1);
});
EOF
    print_status "Updated main.ts with CORS and API prefix"
fi

print_status "Directory structure created successfully!"

print_header "Installing Dependencies"

# Install root dependencies
print_info "Installing root workspace dependencies..."
if command -v pnpm &> /dev/null; then
    pnpm install
    print_status "Root dependencies installed with pnpm"
else
    npm install
    print_status "Root dependencies installed with npm"
fi

print_header "Migration Complete!"

print_info "Next steps:"
echo "1. Review and update your existing NestJS code in apps/server/"
echo "2. Customize the Astro frontend in apps/web/"
echo "3. Update shared types in packages/shared/"
echo "4. Start development environment with: ./scripts/docker.sh dev"
echo ""
print_info "Available commands:"
echo "  pnpm run dev          # Start both frontend and backend in dev mode"
echo "  pnpm run docker:dev   # Start with Docker (recommended)"
echo "  pnpm run docker:prod  # Start production environment"
echo "  pnpm run build        # Build all applications"
echo ""
print_status "Monorepo migration completed successfully! 🎉"
EOF

chmod +x migrate-to-monorepo.sh