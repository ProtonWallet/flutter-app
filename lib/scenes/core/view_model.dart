import 'package:wallet/scenes/core/coordinator.dart';

abstract class ViewModel {
  ViewModel(this.coordinator);
  final Coordinator coordinator;
  // Stream<ViewModel> get datasourceChanged;
  void dispose();
  Future<void> loadData();
}
