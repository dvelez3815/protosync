## 🛠️ Installation and Configuration

### 1. Clone the repository

```bash
git clone <repository-url>
cd proto-sync
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit the `.env` file according to your needs.

### 3. Run with Docker

#### Development Environment (with hot reload)

```bash
# Using the management script
./docker.sh dev

# Or using pnpm
pnpm run docker:dev

# Or using docker-compose directly
docker-compose -f docker-compose.dev.yml up --build -d
```

#### Production Environment

```bash
# Using the management script
./docker.sh prod

# Or using pnpm
pnpm run docker:prod

# Or using docker-compose directly
docker-compose up --build -d
```

## 📖 Available Services

| Service | Port | Description |
|---------|------|-------------|
| NestJS Application | 3000 | Main API |
| MongoDB | 27018 | Database |
| MongoDB Express | 8081 | MongoDB web interface |

## 🔧 Docker Commands

### Management Script (`./docker.sh`)

```bash
./docker.sh dev      # Start development environment
./docker.sh prod     # Start production environment
./docker.sh stop     # Stop all containers
./docker.sh clean    # Clean containers and volumes
./docker.sh build    # Build Docker image
./docker.sh logs     # View application logs
./docker.sh mongo    # Open MongoDB shell
./docker.sh help     # Show help
```

### pnpm Scripts

```bash
pnpm run docker:dev     # Development
pnpm run docker:prod    # Production
pnpm run docker:stop    # Stop
pnpm run docker:clean   # Clean
pnpm run docker:build   # Build
pnpm run docker:logs    # View logs
```

## 🌐 API Endpoints

### Health Check

```http
GET /health
```

### Users

```http
GET    /users           # Get all users
POST   /users           # Create user
GET    /users/:id       # Get user by ID
PUT    /users/:id       # Update user
DELETE /users/:id       # Delete user
GET    /users/email/:email # Get user by email
```

### User creation example

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "tags": ["developer", "nodejs"]
  }'
```

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

### 4. Run the application

```bash
pnpm run start:dev
```

## 📚 Project Structure

```
proto-sync/
├── src/
│   ├── database/           # Database module
│   ├── health/            # Health checks
│   ├── user/              # User module
│   │   ├── dto/           # Data Transfer Objects
│   │   ├── schemas/       # MongoDB schemas
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── user.module.ts
│   ├── app.module.ts      # Main module
│   └── main.ts           # Entry point
├── docker-compose.yml     # Production
├── docker-compose.dev.yml # Development
├── Dockerfile            # Application image
├── docker.sh             # Management script
└── mongo-init.js         # MongoDB initialization
```

## 🔍 Monitoring and Logs

### View logs in real time

```bash
./docker.sh logs
```

### Access MongoDB Express

Visit [http://localhost:8081](http://localhost:8081) to manage the database.

### Health Check

```bash
curl http://localhost:3000/health
```

## 🚨 Troubleshooting

### Problem: Port in use

```bash
# Check processes using the port
lsof -i :3000
lsof -i :27018

# Stop conflicting services
./docker.sh stop
```

### Change ports if there are conflicts

If you need to change ports due to conflicts:

1. **For MongoDB**: Edit the `docker-compose.yml` and `docker-compose.dev.yml` files
   ```yaml
   ports:
     - "27019:27017"  # Change 27018 to another available port
   ```

2. **For the application**: Edit the `.env` file
   ```env
   PORT=3001  # Change to another available port
   ```

3. **Update environment variables** in the corresponding docker-compose files.

### Problem: Corrupted volumes

```bash
# Clean completely
./docker.sh clean

# Restart
./docker.sh dev
```

### Problem: Docker permissions

```bash
# On Linux, ensure Docker permissions
sudo usermod -aG docker $USER
# Then restart session
```

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Runtime environment | `development` |
| `MONGODB_URI` | MongoDB connection URI | `mongodb://mongodb:27018/proto-sync-db` |
| `MONGODB_USER` | MongoDB user | `admin` |
| `MONGODB_PASSWORD` | MongoDB password | `password123` |
| `MONGODB_DATABASE` | Database name | `proto-sync-db` |

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is under the UNLICENSED License - see the [LICENSE](LICENSE) file for details.