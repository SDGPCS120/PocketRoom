import type { Candidate } from './mckp';

export function greedyOptional(
  optionalGroups: Record<string, Candidate[]>,
  leftover: number,
  maxItems: number,
): { picks: Candidate[]; spent: number } {
  if (leftover <= 0 || maxItems <= 0) return { picks: [], spent: 0 };

  const pool: Candidate[] = [];
  for (const cat of Object.keys(optionalGroups)) pool.push(...optionalGroups[cat]);

  const density = (it: Candidate) => (it.price > 0 ? it.score / it.price : 0);
  pool.sort((a, b) => density(b) - density(a));

  const picks: Candidate[] = [];
  let spent = 0;

  for (const it of pool) {
    if (picks.length >= maxItems) break;
    if (spent + it.price <= leftover) {
      picks.push(it);
      spent += it.price;
    }
  }

  return { picks, spent };
}
