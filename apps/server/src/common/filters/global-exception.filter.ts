import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ApiResponse } from '../interfaces/api-response.interface';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status: HttpStatus;
    let errorResponse: ApiResponse;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      // Handle custom formatted responses
      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        errorResponse = {
          success: false,
          message: (exceptionResponse as any).message || 'An error occurred',
          errors: (exceptionResponse as any).errors || [],
          meta: {
            timestamp: new Date().toISOString(),
            path: request.url,
            method: request.method,
          },
        };
      } else {
        errorResponse = {
          success: false,
          message: exceptionResponse as string,
          meta: {
            timestamp: new Date().toISOString(),
            path: request.url,
            method: request.method,
          },
        };
      }
    } else {
      // Handle unexpected errors
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      errorResponse = {
        success: false,
        message: 'Internal server error occurred. Please try again later.',
        meta: {
          timestamp: new Date().toISOString(),
          path: request.url,
          method: request.method,
        },
      };

      // Log the unexpected error for debugging
      this.logger.error(
        `Unexpected error occurred: ${exception}`,
        exception instanceof Error ? exception.stack : undefined,
      );
    }

    // Log all errors for monitoring
    this.logger.error(
      `HTTP ${status} Error: ${request.method} ${request.url} - ${errorResponse.message}`,
    );

    response.status(status).json(errorResponse);
  }
}
