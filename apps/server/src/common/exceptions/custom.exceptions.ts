import { HttpException, HttpStatus } from '@nestjs/common';

export class DatabaseException extends HttpException {
  constructor(message: string, status: HttpStatus = HttpStatus.INTERNAL_SERVER_ERROR) {
    super({
      statusCode: status,
      message: 'Database operation failed',
      error: message,
      timestamp: new Date().toISOString(),
    }, status);
  }
}

export class ValidationException extends HttpException {
  constructor(errors: any[]) {
    super({
      statusCode: HttpStatus.BAD_REQUEST,
      message: 'Validation failed',
      errors,
      timestamp: new Date().toISOString(),
    }, HttpStatus.BAD_REQUEST);
  }
}

export class DuplicateResourceException extends HttpException {
  constructor(resource: string, field: string, value: string) {
    super({
      statusCode: HttpStatus.CONFLICT,
      message: `${resource} with ${field} '${value}' already exists`,
      error: 'Duplicate resource',
      timestamp: new Date().toISOString(),
    }, HttpStatus.CONFLICT);
  }
}

export class ResourceNotFoundException extends HttpException {
  constructor(resource: string, identifier: string) {
    super({
      statusCode: HttpStatus.NOT_FOUND,
      message: `${resource} with ID '${identifier}' not found`,
      error: 'Resource not found',
      timestamp: new Date().toISOString(),
    }, HttpStatus.NOT_FOUND);
  }
}
