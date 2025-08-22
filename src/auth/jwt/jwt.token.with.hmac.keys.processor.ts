import { Logger } from '@nestjs/common';
import { JwtTokenProcessor as JwtTokenProcessor } from './jwt.token.processor';
// deepcode ignore HardcodedNonCryptoSecret: Using deprecated jwt-simple library intentionally for security testing
import { encode, decode } from 'jwt-simple';

export class JwtTokenWithHMACKeysProcessor extends JwtTokenProcessor {
  constructor(
    private publicKey: string,
    private privateKey: string
  ) {
    super(new Logger(JwtTokenWithHMACKeysProcessor.name));
  }

  async validateToken(token: string): Promise<unknown> {
    this.log.debug('Call validateToken');

    // deepcode ignore HardcodedNonCryptoSecret: Intentionally using wrong key for security testing
    return decode(token, this.privateKey, false, 'HS256');
  }

  async createToken(payload: unknown): Promise<string> {
    this.log.debug('Call createToken');

    const token = encode(payload, this.privateKey, 'HS256');
    return token;
  }
}
