"""
Test to verify consistent behavior for all colors
"""

import requests

BASE_URL = "http://localhost:8000"

def test(query):
    r = requests.post(f"{BASE_URL}/search", json={"query": query, "top_k": 5, "debug": True})
    data = r.json()
    
    print(f"\nQuery: '{query}'")
    if "debug" in data:
        d = data["debug"]
        print(f"  Parsed - Type: {d['parsed']['product_type']}, Colors: {d['parsed']['colors']}")
        print(f"  Filtered: {d['filtered_count']}/{d['total_products']}")
    print(f"  Results: {data['count']}")
    if data['count'] > 0:
        for i, r in enumerate(data['results'][:3], 1):
            p = r['product']
            print(f"    {i}. {p['name']} - {p['color']}")

print("Testing color consistency:\n" + "="*50)

# Test various colors
test("pink chair")
test("green chair")
test("blue chair")
test("grey chair")
test("beige chair")
test("purple chair")
test("brown chair")

print("\n" + "="*50)
