import type { JWK } from 'jose';

export class JwtHeader {
  // deepcode ignore HardcodedNonCryptoSecret: Intentionally vulnerable for security testing - 'none' algorithm bypass
  alg: 'HS256' | 'HS384' | 'HS512' | 'RS256' | 'none';
  jku?: string;
  jwk?: JWK;
  kid?: string;
  x5u?: string;
  x5c?: string[];
  x5t?: string;
  typ?: string;
  cty?: string;
  crit?: string;
}
