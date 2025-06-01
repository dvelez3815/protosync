import { Injectable, Logger } from '@nestjs/common';
import { Model, Document, Types } from 'mongoose';
import { 
  DatabaseException, 
  DuplicateResourceException, 
  ResourceNotFoundException, 
  ValidationException 
} from '../exceptions/custom.exceptions';

export interface QueryOptions {
  page?: number;
  limit?: number;
  sort?: any;
  populate?: string | string[];
}

export interface CreateOptions {
  checkDuplicates?: Array<{ field: string; value: any }>;
}

export interface UpdateOptions extends CreateOptions {
  validateExists?: boolean;
}

@Injectable()
export class DatabaseOperationService {
  private readonly logger = new Logger(DatabaseOperationService.name);

  /**
   * Validates if a string is a valid MongoDB ObjectId
   */
  validateObjectId(id: string, resourceName: string = 'Resource'): void {
    if (!Types.ObjectId.isValid(id)) {
      throw new ValidationException([{
        field: 'id',
        message: `Invalid ${resourceName.toLowerCase()} ID format`,
        value: id
      }]);
    }
  }

  /**
   * Handles database errors and converts them to appropriate exceptions
   */
  private handleDatabaseError(error: any, operation: string, resourceName: string): never {
    this.logger.error(`Database ${operation} failed for ${resourceName}:`, error);

    // Handle duplicate key error (MongoDB error code 11000)
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern || {})[0] || 'field';
      const value = error.keyValue?.[field] || 'unknown';
      throw new DuplicateResourceException(resourceName, field, value);
    }

    // Handle Mongoose validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map((err: any) => ({
        field: err.path,
        message: err.message,
        value: err.value
      }));
      throw new ValidationException(validationErrors);
    }

    // Handle CastError (invalid ObjectId)
    if (error.name === 'CastError') {
      throw new ValidationException([{
        field: error.path,
        message: `Invalid ${error.path} format`,
        value: error.value
      }]);
    }

    // If it's already a custom exception, re-throw it
    if (error.response?.statusCode) {
      throw error;
    }

    // Generic database error
    throw new DatabaseException(`Failed to ${operation} ${resourceName.toLowerCase()}`);
  }

  /**
   * Checks for duplicate resources before creation/update
   */
  private async checkDuplicates<T extends Document>(
    model: Model<T>, 
    checks: Array<{ field: string; value: any }>, 
    excludeId?: string,
    resourceName: string = 'Resource'
  ): Promise<void> {
    for (const check of checks) {
      const query: any = { [check.field]: check.value };
      if (excludeId) {
        query._id = { $ne: excludeId };
      }

      const existing = await model.findOne(query).exec();
      if (existing) {
        throw new DuplicateResourceException(resourceName, check.field, check.value);
      }
    }
  }

  /**
   * Generic create operation
   */
  async create<T extends Document>(
    model: Model<T>, 
    data: any, 
    options: CreateOptions = {},
    resourceName: string = 'Resource'
  ): Promise<T> {
    try {
      // Check for duplicates if specified
      if (options.checkDuplicates?.length) {
        await this.checkDuplicates(model, options.checkDuplicates, undefined, resourceName);
      }

      const document = new model(data);
      return await document.save();
    } catch (error) {
      this.handleDatabaseError(error, 'create', resourceName);
    }
  }

  /**
   * Generic find all operation with pagination
   */
  async findAll<T extends Document>(
    model: Model<T>, 
    filter: any = {}, 
    options: QueryOptions = {},
    resourceName: string = 'Resource'
  ): Promise<{ data: T[]; total: number }> {
    try {
      const { page = 1, limit = 10, sort = { createdAt: -1 }, populate } = options;
      const skip = (page - 1) * limit;

      let query = model.find(filter).sort(sort).skip(skip).limit(limit);
      
      if (populate) {
        query = query.populate(populate);
      }

      const [data, total] = await Promise.all([
        query.exec(),
        model.countDocuments(filter).exec()
      ]);

      return { data, total };
    } catch (error) {
      this.handleDatabaseError(error, 'find all', resourceName);
    }
  }

  /**
   * Generic find by ID operation
   */
  async findById<T extends Document>(
    model: Model<T>, 
    id: string, 
    populate?: string | string[],
    resourceName: string = 'Resource'
  ): Promise<T> {
    try {
      this.validateObjectId(id, resourceName);

      let query = model.findById(id);
      if (populate) {
        query = query.populate(populate);
      }

      const document = await query.exec();
      if (!document) {
        throw new ResourceNotFoundException(resourceName, id);
      }

      return document;
    } catch (error) {
      this.handleDatabaseError(error, 'find by ID', resourceName);
    }
  }

  /**
   * Generic find one operation
   */
  async findOne<T extends Document>(
    model: Model<T>, 
    filter: any, 
    populate?: string | string[],
    resourceName: string = 'Resource'
  ): Promise<T | null> {
    try {
      let query = model.findOne(filter);
      if (populate) {
        query = query.populate(populate);
      }

      return await query.exec();
    } catch (error) {
      this.handleDatabaseError(error, 'find one', resourceName);
    }
  }

  /**
   * Generic update operation
   */
  async update<T extends Document>(
    model: Model<T>, 
    id: string, 
    data: any, 
    options: UpdateOptions = {},
    resourceName: string = 'Resource'
  ): Promise<T> {
    try {
      this.validateObjectId(id, resourceName);

      // Check for duplicates if specified
      if (options.checkDuplicates?.length) {
        await this.checkDuplicates(model, options.checkDuplicates, id, resourceName);
      }

      const document = await model.findByIdAndUpdate(
        id, 
        data, 
        { new: true, runValidators: true }
      ).exec();

      if (!document) {
        throw new ResourceNotFoundException(resourceName, id);
      }

      return document;
    } catch (error) {
      this.handleDatabaseError(error, 'update', resourceName);
    }
  }

  /**
   * Generic delete operation
   */
  async delete<T extends Document>(
    model: Model<T>, 
    id: string,
    resourceName: string = 'Resource'
  ): Promise<T> {
    try {
      this.validateObjectId(id, resourceName);

      const document = await model.findByIdAndDelete(id).exec();
      if (!document) {
        throw new ResourceNotFoundException(resourceName, id);
      }

      return document;
    } catch (error) {
      this.handleDatabaseError(error, 'delete', resourceName);
    }
  }

  /**
   * Generic soft delete operation (sets isActive to false)
   */
  async softDelete<T extends Document>(
    model: Model<T>, 
    id: string,
    resourceName: string = 'Resource'
  ): Promise<T> {
    try {
      return await this.update(model, id, { isActive: false }, {}, resourceName);
    } catch (error) {
      this.handleDatabaseError(error, 'soft delete', resourceName);
    }
  }
}
