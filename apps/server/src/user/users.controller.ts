import { 
  Body, 
  Controller, 
  Get, 
  Post, 
  Put, 
  Patch,
  Delete, 
  Param, 
  Query,
  HttpCode, 
  HttpStatus
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto, UpdateUserDto } from './dto/user.dto';
import { User } from './schemas/user.schema';
import { PaginatedResponse } from '../common/interfaces/api-response.interface';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createUser(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.usersService.createUser(createUserDto);
  }

  @Get()
  async getUsers(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ): Promise<User[] | PaginatedResponse<User>> {
    // If pagination parameters are provided, return paginated response
    if (page || limit) {
      const pageNum = parseInt(page || '1', 10);
      const limitNum = parseInt(limit || '10', 10);
      return this.usersService.getUsersPaginated(pageNum, limitNum);
    }
    
    // Otherwise return all users
    return this.usersService.getAllUsers();
  }

  @Get(':id')
  async getUserById(@Param('id') id: string): Promise<User> {
    return this.usersService.getUserById(id);
  }

  @Put(':id')
  async updateUser(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<User> {
    return this.usersService.updateUser(id, updateUserDto);
  }

  @Patch(':id')
  async patchUser(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<User> {
    return this.usersService.updateUser(id, updateUserDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteUser(@Param('id') id: string): Promise<void> {
    return this.usersService.deleteUser(id);
  }

  @Get('email/:email')
  async getUserByEmail(@Param('email') email: string): Promise<User | null> {
    return this.usersService.getUserByEmail(email);
  }
}