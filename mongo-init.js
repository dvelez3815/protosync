// MongoDB initialization script
print('Starting database initialization...');

// Switch to the application database
db = db.getSiblingDB('proto-sync-db');

// Create a sample collection with an index
db.createCollection('users');
db.users.createIndex({ "email": 1 }, { unique: true });

print('Database initialization completed successfully!');
