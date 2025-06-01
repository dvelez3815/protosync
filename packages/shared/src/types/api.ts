export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
  timestamp: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface HealthCheck {
  status: string;
  timestamp: string;
  uptime: number;
  version: string;
  environment: string;
  database: {
    status: string;
    connected: boolean;
  };
}
