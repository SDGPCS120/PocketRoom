export type Candidate = {
  category: string;
  product: any;
  price: number;
  score: number;
  reason: string;
};

export function mckp(
  requiredOrder: string[],
  groups: Record<string, Candidate[]>,
  totalBudget: number,
  step: number,
): { ok: boolean; picks: Candidate[]; totalCost: number } {
  const B = Math.floor(totalBudget / step);
  const n = requiredOrder.length;

  const NEG = -1e15;
  let dp = new Array<number>(B + 1).fill(NEG);
  dp[0] = 0;

  const choice: Array<Array<number | null>> = Array.from({ length: n }, () => new Array(B + 1).fill(null));

  for (let i = 0; i < n; i++) {
    const cat = requiredOrder[i];
    const items = groups[cat] ?? [];
    const next = new Array<number>(B + 1).fill(NEG);

    for (let b = 0; b <= B; b++) {
      if (dp[b] <= NEG / 2) continue;

      for (let idx = 0; idx < items.length; idx++) {
        const it = items[idx];
        const costScaled = Math.ceil(it.price / step);
        const nb = b + costScaled;
        if (nb > B) continue;

        const val = dp[b] + it.score;
        if (val > next[nb]) {
          next[nb] = val;
          choice[i][nb] = idx;
        }
      }
    }

    dp = next;
  }

  let bestB = -1;
  let bestScore = NEG;
  for (let b = 0; b <= B; b++) {
    if (dp[b] > bestScore) {
      bestScore = dp[b];
      bestB = b;
    }
  }

  if (bestB === -1 || bestScore <= NEG / 2) return { ok: false, picks: [], totalCost: 0 };

  const picks: Candidate[] = new Array(n);
  let b = bestB;

  for (let i = n - 1; i >= 0; i--) {
    const cat = requiredOrder[i];
    const idx = choice[i][b];
    if (idx === null) return { ok: false, picks: [], totalCost: 0 };

    const picked = groups[cat][idx];
    picks[i] = picked;
    b -= Math.ceil(picked.price / step);
  }

  const totalCost = picks.reduce((s, it) => s + it.price, 0);
  return { ok: true, picks, totalCost };
}

export function minCostRequired(requiredOrder: string[], groups: Record<string, Candidate[]>): number | null {
  let total = 0;
  for (const cat of requiredOrder) {
    const items = groups[cat];
    if (!items || items.length === 0) return null;
    total += items.reduce((min, it) => Math.min(min, it.price), Number.POSITIVE_INFINITY);
  }
  return total;
}
