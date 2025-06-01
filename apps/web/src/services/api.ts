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
