import assert from 'node:assert/strict';
import { Buffer } from 'node:buffer';
import { describe, it } from 'node:test';

import {
  extractOpenAIAccountId,
  parseCodexUsagePayload,
} from '../pi/extensions/statusline/usage.ts';

function jwtWithPayload(payload: object): string {
  return `header.${Buffer.from(JSON.stringify(payload)).toString('base64url')}.signature`;
}

describe('parseCodexUsagePayload', () => {
  it('maps primary and secondary windows to the footer usage windows', () => {
    const result = parseCodexUsagePayload({
      plan_type: 'plus',
      rate_limit: {
        allowed: true,
        limit_reached: false,
        primary_window: {
          used_percent: 42.4,
          limit_window_seconds: 18_000,
          reset_at: 1_735_693_200,
        },
        secondary_window: {
          used_percent: 81,
          limit_window_seconds: 604_800,
          reset_at: 1_736_298_000,
        },
      },
    });

    assert.deepEqual(result, {
      fiveHour: { pct: 42, resetEpochSec: 1_735_693_200, rejected: false, label: '5h' },
      sevenDay: { pct: 81, resetEpochSec: 1_736_298_000, rejected: false, label: '7d' },
    });
  });

  it('uses the reported duration even when only the primary window is returned', () => {
    const result = parseCodexUsagePayload({
      rate_limit: {
        allowed: true,
        limit_reached: false,
        primary_window: {
          used_percent: 11,
          limit_window_seconds: 604_800,
          reset_at: 1_736_298_000,
        },
      },
    });

    assert.equal(result?.fiveHour?.label, '7d');
    assert.equal(result?.sevenDay, null);
  });

  it('marks returned windows as rejected when the account limit is reached', () => {
    const result = parseCodexUsagePayload({
      rate_limit: {
        allowed: false,
        limit_reached: true,
        primary_window: { used_percent: 100, reset_at: 1_735_693_200 },
      },
    });

    assert.equal(result?.fiveHour?.rejected, true);
    assert.equal(result?.sevenDay, null);
  });

  it('ignores malformed and empty account payloads', () => {
    assert.equal(parseCodexUsagePayload(null), undefined);
    assert.equal(parseCodexUsagePayload({ rate_limit: { primary_window: { used_percent: '42' } } }), undefined);
  });
});

describe('extractOpenAIAccountId', () => {
  it('reads the account id from the OpenAI auth claim', () => {
    const token = jwtWithPayload({
      'https://api.openai.com/auth': { chatgpt_account_id: 'account-123' },
    });

    assert.equal(extractOpenAIAccountId(token), 'account-123');
  });

  it('rejects malformed tokens and missing claims', () => {
    assert.equal(extractOpenAIAccountId('not-a-jwt'), undefined);
    assert.equal(extractOpenAIAccountId(jwtWithPayload({ sub: 'user-123' })), undefined);
  });
});
