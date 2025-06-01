import { 
  IsString, 
  IsEmail, 
  IsNumber, 
  IsOptional, 
  IsArray, 
  IsBoolean,
  Min, 
  Max, 
  MinLength,
  MaxLength 
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Name must not exceed 50 characters' })
  name: string;

  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsNumber({}, { message: 'Age must be a valid number' })
  @Min(0, { message: 'Age must be a positive number' })
  @Max(120, { message: 'Age must not exceed 120' })
  age: number;

  @IsOptional()
  @IsArray({ message: 'Tags must be an array' })
  @IsString({ each: true, message: 'Each tag must be a string' })
  tags?: string[];
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Name must not exceed 50 characters' })
  name?: string;

  @IsOptional()
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email?: string;

  @IsOptional()
  @IsNumber({}, { message: 'Age must be a valid number' })
  @Min(0, { message: 'Age must be a positive number' })
  @Max(120, { message: 'Age must not exceed 120' })
  age?: number;

  @IsOptional()
  @IsBoolean({ message: 'isActive must be a boolean value' })
  isActive?: boolean;

  @IsOptional()
  @IsArray({ message: 'Tags must be an array' })
  @IsString({ each: true, message: 'Each tag must be a string' })
  tags?: string[];
}
