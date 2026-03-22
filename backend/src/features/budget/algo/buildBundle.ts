import { FurnitureItem } from '../../../furniture/furniture.mock';
import { BudgetBundleRequestDto, BudgetBundleResponseDto, BundleVariantDto } from '../dto/budget-bundle.dto';
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
    groups[c].push({ category: c, product: p, price: p.price, score, reason });
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

export function buildBundle(
  req: BudgetBundleRequestDto,
  furnitureItems: FurnitureItem[],
): BudgetBundleResponseDto {
  const pref = req.preferences ?? {};
  const cons = req.constraints ?? {};

  const topK = cons.topKPerCategory ?? 200;
  const step = cons.budgetStepLkr ?? 1000;
  const maxOptional = cons.maxOptionalItems ?? 3;
  const minRating = cons.minRating ?? 0;

  const required = req.requiredCategories.map(norm);
  const optional = (req.optionalCategories ?? []).map(norm);

  const filtered = furnitureItems.filter((p) => {
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
      bundles: [],
      reason: `Missing categories after filtering: ${missing.join(', ')}`,
    };
  }

  const bundles: BundleVariantDto[] = [];
  const generatedSignatures = new Set<string>();
  const MAX_LIMIT = 50;

  while (bundles.length < MAX_LIMIT) {
    const dpRes = mckp(required, requiredGroups, req.totalBudget, step);
    if (!dpRes.ok) {
      if (bundles.length > 0) break;
      return {
        ok: false,
        totalBudget: req.totalBudget,
        bundles: [],
        reason: 'No valid bundle fits the budget.',
        minPossibleCost: minCostRequired(required, requiredGroups) ?? undefined,
      };
    }

    const requiredCost = dpRes.totalCost;
    const leftover = req.totalBudget - requiredCost;
    const optRes = greedyOptional(optionalGroups, leftover, maxOptional);

    const totalCost = requiredCost + optRes.spent;
    const remaining = req.totalBudget - totalCost;

    const signature = [
      ...dpRes.picks.map((p) => p.product.id),
      ...optRes.picks.map((p) => p.product.id),
    ].sort().join(',');

    if (generatedSignatures.has(signature)) {
      break;
    }
    generatedSignatures.add(signature);

    const explanations: string[] = [];

    const requiredBundle = dpRes.picks.map((c) => {
      explanations.push(`${c.product.category}: ${c.product.name} (${c.reason})`);
      return toPicked(c);
    });

    const optionalBundle = optRes.picks.map((c) => {
      explanations.push(`Optional ${c.product.category}: ${c.product.name} (${c.reason})`);
      return toPicked(c);
    });

    bundles.push({
      totalCost,
      remaining,
      requiredBundle,
      optionalBundle,
      explanations,
    });

    for (const c of dpRes.picks) {
      const cat = norm(c.product.category);
      if (requiredGroups[cat]) {
        const item = requiredGroups[cat].find((it) => it.product.id === c.product.id);
        if (item) {
          item.score -= 10000;
        }
      }
    }
  }

  return {
    ok: true,
    totalBudget: req.totalBudget,
    bundles,
  };
}