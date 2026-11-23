import { createHash, timingSafeEqual } from 'node:crypto';
import { BadRequestException, ForbiddenException, ServiceUnavailableException } from '@nestjs/common';

const SANDBOX_CHECKOUT = 'https://sandbox.payhere.lk/pay/checkout';

export function payHereConfig() {
  const { PAYHERE_MODE, PAYHERE_MERCHANT_ID, PAYHERE_MERCHANT_SECRET, PAYHERE_PUBLIC_BASE_URL } = process.env;
  if (PAYHERE_MODE !== 'sandbox' || !PAYHERE_MERCHANT_ID || !/^\d+$/.test(PAYHERE_MERCHANT_ID) ||
      !PAYHERE_MERCHANT_SECRET || !PAYHERE_PUBLIC_BASE_URL) {
    throw new ServiceUnavailableException('PayHere sandbox is not configured');
  }
  let url: URL;
  try {
    url = new URL(PAYHERE_PUBLIC_BASE_URL);
  } catch {
    throw new ServiceUnavailableException('Invalid PayHere callback URL');
  }
  if (url.protocol !== 'https:' || url.username || url.password || url.search || url.hash || url.pathname !== '/') {
    throw new ServiceUnavailableException('Invalid PayHere callback URL');
  }
  return { merchantId: PAYHERE_MERCHANT_ID, secret: PAYHERE_MERCHANT_SECRET, origin: url.origin };
}

type PayHereConfig = ReturnType<typeof payHereConfig>;

function md5(value: string) {
  return createHash('md5').update(value, 'utf8').digest('hex').toUpperCase();
}

export function checkoutTokenHash(token: string) {
  return createHash('sha256').update(token, 'utf8').digest('hex');
}

export function parseNotification(config: PayHereConfig, body: unknown) {
  if (typeof body !== 'object' || body === null) throw new BadRequestException('Invalid payment notification');
  const {
    merchant_id: merchantId, order_id: id, payhere_amount: amount,
    payhere_currency: currency, status_code: code, md5sig: signature,
  } = body as Record<string, unknown>;
  if (merchantId !== config.merchantId || typeof id !== 'string' || !/^[A-Za-z0-9]{20}$/.test(id) ||
      typeof amount !== 'string' || !/^\d{1,13}\.\d{2}$/.test(amount) || currency !== 'LKR' ||
      typeof code !== 'string' || !['2', '0', '-1', '-2', '-3'].includes(code) ||
      typeof signature !== 'string' || !/^[a-fA-F0-9]{32}$/.test(signature)) {
    throw new BadRequestException('Invalid payment notification');
  }
  const expected = md5(merchantId + id + amount + currency + code + md5(config.secret));
  if (!timingSafeEqual(Buffer.from(expected, 'hex'), Buffer.from(signature, 'hex'))) {
    throw new ForbiddenException('Invalid payment notification signature');
  }
  return { id, currency, code, totalMinor: Number(amount.replace('.', '')) };
}

function escapeHtml(value: string) {
  const entities: Record<string, string> = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
  return value.replace(/[&<>"']/g, (character) => entities[character]);
}

export function checkoutPage(config: PayHereConfig, id: string, totalMinor: number) {
  const amount = Math.floor(totalMinor / 100) + '.' + String(totalMinor % 100).padStart(2, '0');
  const fields = {
    merchant_id: config.merchantId,
    return_url: config.origin + '/payments/checkout-result',
    cancel_url: config.origin + '/payments/checkout-result',
    notify_url: config.origin + '/payments/notify',
    order_id: id,
    items: 'PocketRoom sandbox order',
    currency: 'LKR',
    amount,
    hash: md5(config.merchantId + id + amount + 'LKR' + md5(config.secret)),
    first_name: 'PocketRoom', last_name: 'Sandbox',
    email: 'sandbox@example.com', phone: '0770000000',
    address: 'Sandbox checkout', city: 'Colombo', country: 'Sri Lanka',
  };
  const inputs = Object.entries(fields)
    .map(([name, value]) => '<input type="hidden" name="' + name + '" value="' + escapeHtml(value) + '">')
    .join('\n');
  return '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
    + '<title>PocketRoom checkout</title><h1>PayHere sandbox checkout</h1><p>Total: LKR ' + amount + '</p>'
    + '<form method="post" action="' + SANDBOX_CHECKOUT + '">' + inputs + '<button>Continue to PayHere</button></form></html>';
}

export function checkoutLinkPage(nonce: string) {
  return '<!doctype html><html lang="en"><meta charset="utf-8"><title>PocketRoom checkout</title>'
    + '<p id="status">Opening your checkout&hellip;</p>'
    + '<form method="post"><input type="hidden" name="token"></form>'
    + '<script nonce="' + nonce + '">'
    + 'const token = location.hash.slice(1);'
    + 'history.replaceState(null, "", location.pathname);'
    + 'if (/^[a-f0-9]{64}$/.test(token)) {'
    + 'const form = document.forms[0]; form.elements.token.value = token; form.submit();'
    + '} else { document.getElementById("status").textContent = "Checkout link unavailable."; }'
    + '</script></html>';
}
