// import 'package:wallet/scenes/app/app.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view_model.dart';

abstract class AppViewModel extends ViewModel {
  AppViewModel(Coordinator coordinator) : super(coordinator);
  // final AppModel appModel;

  // void updateUsername(String updatedUsername);

  // void updatePassword(String updatedPassword);

  // bool showUpdateUsernameError();

  // bool login();

  // InputFeedbackViewModel getInputFeedbackViewModel();

  // InputFeedbackViewModel getLoginFeedbackViewModel();

  // String? validateUsername(String? username);

  // String? validatePassword(String? password);
}

class AppViewModelImpl extends AppViewModel {
  AppViewModelImpl(Coordinator coordinator) : super(coordinator);
  // final datasourceChangedStreamController = StreamController<LoginViewModel>.broadcast();
  bool showUsernameValidationError = false;

  // @override
  // Stream<ViewModel> get datasourceChanged =>
  // datasourceChangedStreamController.stream;

  @override
  void dispose() {
    // datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    return;
  }
}
