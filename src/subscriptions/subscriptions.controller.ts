import { Controller, Post, Query } from '@nestjs/common';

@Controller('subscriptions')
export class SubscriptionsController {
  @Post()
  async subscribe(@Query('email') email: string): Promise<string> {
    console.log('Subscribed with email ' + email);
    return email;
  }
}