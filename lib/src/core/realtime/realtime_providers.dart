import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket_io_service.dart';

final socketIoServiceProvider = Provider<SocketIoService>((ref) {
  final service = SocketIoService();
  service.connect();
  ref.onDispose(service.dispose);
  return service;
});

final socketEventsProvider = StreamProvider<SocketEvent>((ref) {
  final service = ref.watch(socketIoServiceProvider);
  return service.events;
});
