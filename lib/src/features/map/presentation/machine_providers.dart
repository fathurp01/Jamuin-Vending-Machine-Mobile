import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'machine_models.dart';

final machinesProvider = Provider<List<VendingMachine>>((ref) {
  return const [
    VendingMachine(id: 'm1', name: 'Jamuin SCBD', lat: -6.2247, lng: 106.8093),
    VendingMachine(
      id: 'm2',
      name: 'Jamuin Senayan',
      lat: -6.2186,
      lng: 106.8020,
    ),
    VendingMachine(
      id: 'm3',
      name: 'Jamuin Kuningan',
      lat: -6.2261,
      lng: 106.8305,
    ),
  ];
});
