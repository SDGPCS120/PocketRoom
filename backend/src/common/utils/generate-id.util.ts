import { randomBytes } from 'crypto';

/**
 * Generates a URL-friendly meaningful ID based on a given prefix.
 * Removes special characters, replaces spaces with hyphens,
 * and appends a short 6-character random hex string for uniqueness.
 *
 * @param prefix Your subject string (e.g. "Arpico Sofa" or "order")
 * @returns string (e.g. "arpico-sofa-a1b2c3")
 */
export function generateMeaningfulId(prefix: string): string {
  const safePrefix = prefix ? String(prefix) : 'doc';
  
  const slug = safePrefix
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with hyphens
    .replace(/(^-|-$)/g, '');    // Remove leading/trailing hyphens

  const uuid = randomBytes(3).toString('hex'); // 6 hex characters

  return slug ? `${slug}-${uuid}` : uuid;
}
