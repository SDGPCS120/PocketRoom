import type { FurnitureItem } from '../../../furniture/furniture.mock';
import type { PreferencesDto } from '../dto/budget-bundle.dto';

export function norm(s: string): string {
  return (s ?? '').toString().trim().toLowerCase().replace(/\s+/g, ' ');
}

export function scoreItem(p: FurnitureItem, pref: PreferencesDto): { score: number; reason: string } {
  const reasons: string[] = [];
  let score = 0;

  const style = norm(p.style ?? '');
  const color = norm(p.color ?? '');
  const material = norm(p.material ?? '');

  if (pref?.style && style === norm(pref.style)) {
    score += 30; reasons.push('style match');
  }

  const prefColors = (pref?.colors ?? []).map(norm);
  if (prefColors.length && prefColors.includes(color)) {
    score += 15; reasons.push('preferred color');
  }

  const prefMats = (pref?.materials ?? []).map(norm);
  if (prefMats.length && prefMats.includes(material)) {
    score += 10; reasons.push('preferred material');
  }

  if (typeof p.rating === 'number') {
    score += p.rating * 5; reasons.push('rating considered');
  }

  if (p.price > 0) {
    score -= Math.log(p.price); reasons.push('price penalty');
  }

  if (!reasons.length) reasons.push('basic match');
  return { score, reason: reasons.join(', ') };
}
