import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto, UpdateUserDto } from './dto/user.dto';
import { DatabaseOperationService } from '../common/services/database-operation.service';
import { ApiResponse, PaginatedResponse } from '../common/interfaces/api-response.interface';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private readonly dbService: DatabaseOperationService,
  ) {}

  async createUser(createUserDto: CreateUserDto): Promise<User> {
    return this.dbService.create(
      this.userModel,
      createUserDto,
      {
        checkDuplicates: [{ field: 'email', value: createUserDto.email }],
      },
      'User',
    );
  }

  async getAllUsers(): Promise<User[]> {
    const result = await this.dbService.findAll(
      this.userModel,
      { isActive: true },
      { limit: 1000 }, // Set a reasonable default limit
      'User',
    );
    return result.data;
  }

  async getUsersPaginated(
    page: number = 1,
    limit: number = 10,
  ): Promise<PaginatedResponse<User>> {
    const result = await this.dbService.findAll(
      this.userModel,
      { isActive: true },
      { page, limit, sort: { createdAt: -1 } },
      'User',
    );

    return {
      success: true,
      data: result.data,
      pagination: {
        page,
        limit,
        total: result.total,
        totalPages: Math.ceil(result.total / limit),
      },
      meta: {
        timestamp: new Date().toISOString(),
        path: '/users',
        method: 'GET',
      },
    };
  }

  async getUserById(id: string): Promise<User> {
    return this.dbService.findById(this.userModel, id, undefined, 'User');
  }

  async updateUser(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const updateOptions = updateUserDto.email
      ? { checkDuplicates: [{ field: 'email', value: updateUserDto.email }] }
      : {};

    return this.dbService.update(
      this.userModel,
      id,
      updateUserDto,
      updateOptions,
      'User',
    );
  }

  async deleteUser(id: string): Promise<void> {
    await this.dbService.delete(this.userModel, id, 'User');
  }

  async softDeleteUser(id: string): Promise<User> {
    return this.dbService.softDelete(this.userModel, id, 'User');
  }

  async getUserByEmail(email: string): Promise<User | null> {
    return this.dbService.findOne(
      this.userModel,
      { email, isActive: true },
      undefined,
      'User',
    );
  }
} 