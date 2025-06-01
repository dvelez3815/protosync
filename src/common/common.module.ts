import { Module, Global } from '@nestjs/common';
import { DatabaseOperationService } from './services/database-operation.service';

@Global()
@Module({
  providers: [DatabaseOperationService],
  exports: [DatabaseOperationService],
})
export class CommonModule {}
