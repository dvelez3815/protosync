export class CreateUserDto {
  name: string;
  email: string;
  age: number;
  tags?: string[];
}

export class UpdateUserDto {
  name?: string;
  email?: string;
  age?: number;
  isActive?: boolean;
  tags?: string[];
}
