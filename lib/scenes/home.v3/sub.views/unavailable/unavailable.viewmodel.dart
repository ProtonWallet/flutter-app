import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class UnavailableViewModel extends ViewModel<Coordinator> {
  bool get showProducts => true;

  UnavailableViewModel(
    super.coordinator,
  );
}
