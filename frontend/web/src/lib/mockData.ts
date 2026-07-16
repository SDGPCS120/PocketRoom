export const getMockOrders = () => {
  const now = new Date();
  const mockOrders = [];
  let idCounter = 1000;

  // Generate 15 orders over the last 7 days
  for (let i = 0; i < 15; i++) {
    const daysAgo = Math.floor(Math.random() * 7);
    const orderDate = new Date(now);
    orderDate.setDate(orderDate.getDate() - daysAgo);

    const isDelivered = daysAgo > 2;
    const status = isDelivered ? 'DELIVERED' : (daysAgo > 1 ? 'SHIPPED' : 'PROCESSING');
    
    const amount = Math.floor(Math.random() * 15000) + 5000; // Between 5k and 20k

    mockOrders.push({
      orderId: `ORD-${idCounter++}`,
      customerId: `CUST-${Math.floor(Math.random() * 1000)}`,
      orderStatus: status,
      totalAmount: amount,
      createdAt: orderDate.toISOString(),
      items: [
        {
          productName: ['Modern Velvet Sofa', 'Oak Dining Table', 'Ergonomic Office Chair', 'Minimalist Bookshelf'][Math.floor(Math.random() * 4)],
          itemTotal: amount,
          quantity: 1
        }
      ]
    });
  }

  return mockOrders;
};

export const getMockProducts = () => {
  return [
    {
      productId: 'PROD-1',
      name: 'Modern Velvet Sofa',
      materials: ['Velvet', 'Wood', 'Foam'],
      modelURL: 'https://example.com/mock-model-1.glb',
      furnitureType: 'Sofa',
      price: 85000
    },
    {
      productId: 'PROD-2',
      name: 'Oak Dining Table',
      materials: ['Oak Wood', 'Metal'],
      furnitureType: 'Table',
      price: 45000
    },
    {
      productId: 'PROD-3',
      name: 'Ergonomic Office Chair',
      materials: ['Mesh', 'Plastic', 'Steel'],
      modelURL: 'https://example.com/mock-model-3.glb',
      furnitureType: 'Chair',
      price: 32000
    },
    {
      productId: 'PROD-4',
      name: 'Minimalist Bookshelf',
      materials: ['MDF', 'Metal'],
      furnitureType: 'Storage',
      price: 25000
    }
  ];
};
