export interface User {
  _id: string;
  name: string;
  email: string;
  age: number;
  isActive: boolean;
  tags?: string[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserDto {
  name: string;
  email: string;
  age: number;
  tags?: string[];
}

export interface UpdateUserDto {
  name?: string;
  email?: string;
  age?: number;
  isActive?: boolean;
  tags?: string[];
}
