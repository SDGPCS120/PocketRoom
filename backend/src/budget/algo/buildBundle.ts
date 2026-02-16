import { MOCK_FURNITURE, FurnitureItem } from '../../furniture/furniture.mock';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from '../dto/budget-bundle.dto';
import { norm, scoreItem } from './scoring';
import { Candidate, mckp, minCostRequired } from './mckp';
import { greedyOptional } from './greedy';

function topKByCategory(
  items: FurnitureItem[],
  categories: string[],
  pref: any,
  k: number,
): Record<string, Candidate[]> {
  const groups: Record<string, Candidate[]> = {};
  const catSet = new Set(categories.map(norm));
  categories.forEach((c) => (groups[norm(c)] = []));

  for (const p of items) {
    const c = norm(p.category);
    if (!catSet.has(c)) continue;

    const { score, reason } = scoreItem(p, pref);
    groups[c].push({ product: p, price: p.price, score, reason });
  }

  for (const c of Object.keys(groups)) {
    groups[c].sort((a, b) => b.score - a.score);
    groups[c] = groups[c].slice(0, k);
  }

  return groups;
}

function toPicked(c: Candidate) {
  return {
    category: c.product.category,
    id: c.product.id,
    name: c.product.name,
    price: c.price,
    score: Number(c.score.toFixed(4)),
    reason: c.reason,
    product: c.product,
  };
}

export function buildBundle(req: BudgetBundleRequestDto): BudgetBundleResponseDto {
  const pref = req.preferences ?? {};
  const cons = req.constraints ?? {};

  const topK = cons.topKPerCategory ?? 30;
  const step = cons.budgetStepLkr ?? 1000;
  const maxOptional = cons.maxOptionalItems ?? 3;
  const minRating = cons.minRating ?? 0;

  const required = req.requiredCategories.map(norm);
  const optional = (req.optionalCategories ?? []).map(norm);

  // Hard filter
  const filtered = MOCK_FURNITURE.filter((p) => {
    if (typeof p.price !== 'number' || p.price <= 0) return false;
    if (typeof p.rating === 'number' && p.rating < minRating) return false;
    if (p.inStock === false) return false;
    return true;
  });

  const requiredGroups = topKByCategory(filtered, required, pref, topK);
  const optionalGroups = topKByCategory(filtered, optional, pref, topK);

  const missing = required.filter((c) => !requiredGroups[c] || requiredGroups[c].length === 0);
  if (missing.length) {
    return {
      ok: false,
      totalBudget: req.totalBudget,
      totalCost: 0,
      remaining: req.totalBudget,
      requiredBundle: [],
      optionalBundle: [],
      explanations: [],
      reason: `Missing categories after filtering: ${missing.join(', ')}`,
    };
  }

  const dpRes = mckp(required, requiredGroups, req.totalBudget, step);
  if (!dpRes.ok) {
    return {
      ok: false,
      totalBudget: req.totalBudget,
      totalCost: 0,
      remaining: req.totalBudget,
      requiredBundle: [],
      optionalBundle: [],
      explanations: [],
      reason: 'No valid bundle fits the budget.',
      minPossibleCost: minCostRequired(required, requiredGroups) ?? undefined,
    };
  }

  const requiredCost = dpRes.totalCost;
  const leftover = req.totalBudget - requiredCost;

  const optRes = greedyOptional(optionalGroups, leftover, maxOptional);

  const totalCost = requiredCost + optRes.spent;
  const remaining = req.totalBudget - totalCost;

  const explanations: string[] = [];

  const requiredBundle = dpRes.picks.map((c) => {
    explanations.push(`${c.product.category}: ${c.product.name} (${c.reason})`);
    return toPicked(c);
  });

  const optionalBundle = optRes.picks.map((c) => {
    explanations.push(`Optional ${c.product.category}: ${c.product.name} (${c.reason})`);
    return toPicked(c);
  });

  return {
    ok: true,
    totalBudget: req.totalBudget,
    totalCost,
    remaining,
    requiredBundle,
    optionalBundle,
    explanations,
  };
}
