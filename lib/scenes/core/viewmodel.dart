import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

abstract class ViewModel<T extends Coordinator> extends ViewIdentifiers {
  ViewModel(this.coordinator);
  final T coordinator;
  Stream<ViewModel> get datasourceChanged;
  void dispose();
  Future<void> loadData();
  bool get keepAlive => false;
}
