import UIKit
import ProtonCoreServices
import ProtonCoreChallenge
import ProtonCoreDataModel
import ProtonCoreFoundations
import ProtonCoreLoginUI
import ProtonCoreLogin
import ProtonCoreAuthentication
import ProtonCoreHumanVerification
import ProtonCoreUIFoundations
import ProtonCoreFoundations
import ProtonCoreNetworking
import ProtonCorePayments
import Flutter
import SwiftUI // If using SwiftUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SimpleViewDelegate {
    var flutterWindow: UIWindow?

    /// native code and this need to be refactored later
    private var apiService: PMAPIService?
    private var login: LoginAndSignup?
    private var navigationChannel: FlutterMethodChannel?
    private var humanVerificationDelegate: HumanVerifyDelegate?
    // private var missingScopesDelegate: MissingScopesDelegate?
    var authManager: AuthHelper?
    private let serviceDelegate = AnonymousServiceManager()
    
    private var getInAppTheme: () -> InAppTheme {
        return { .matchSystem }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up the Flutter window
        self.flutterWindow = self.window
        let controller = self.flutterWindow?.rootViewController as! FlutterViewController
        let nativeViewChannel = FlutterMethodChannel(name: "com.example.wallet/native.views", binaryMessenger: controller.binaryMessenger)
        nativeViewChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "native.navigation.login" {
                self?.switchToNativeView()
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        navigationChannel = FlutterMethodChannel(name: "com.example.wallet/app.view", binaryMessenger: controller.binaryMessenger)
        
        self.initSignupLogin()
        dummy_method_to_enforce_bundling()
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func initSignupLogin() {
        let clientApp: ClientApp = .mail
        PMAPIService.noTrustKit = true
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: .black,
                                                                     challengeParametersProvider: ChallengeParametersProvider.forAPIService(clientApp: clientApp,
                                                                                                                                            challenge: PMChallenge()))
        self.apiService = apiService
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService, inAppTheme: getInAppTheme, clientApp: clientApp)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        //apiService.forceUpgradeDelegate = forceUpgradeServiceDelegate
        apiService.humanDelegate = humanVerificationDelegate
        
        let appName = "Proton Wallet"
        login = LoginAndSignup(
            appName: appName,
            clientApp: .mail,
            apiService: apiService,
            minimumAccountType: .internal,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: getSignupAvailability
        )
    }
    
    private var getSignupAvailability: SignupAvailability {
        let signupAvailability: SignupAvailability
        let summaryScreenVariant: SummaryScreenVariant = .noSummaryScreen //showSignupSummaryScreenSwitch.isOn ? signupSummaryScreenVariant : .noSummaryScreen
        signupAvailability = .available(parameters: SignupParameters(separateDomainsButton: false,
                                                                     passwordRestrictions: .default,
                                                                     summaryScreenVariant: summaryScreenVariant))
        return signupAvailability
    }
    
    private var getShowWelcomeScreen: WelcomeScreenVariant? {
        return .mail(.init(body: "Please Mister Postman, look and see! Is there's a letter in your bag for me?"))
    }

    private var getAdditionalWork: WorkBeforeFlow? {
        return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                flowCompletion(.success(()))
            }
        }
    }
    
    private var getCustomErrorPresenter: LoginErrorPresenter? {
        // guard alternativeErrorPresenterSwitch.isOn else { return nil }
        return AlternativeLoginErrorPresenter()
    }
    
    private func initialLoginError() -> String? {
        nil
    }
    
    private var getHelpDecorator: ([[HelpItem]]) -> [[HelpItem]] {
        // guard veryStrangeHelpScreenSwitch.isOn else { return { $0 } }
        return { [weak self] _ in
            [
                [
                    HelpItem.staticText(text: "🍌🍌🍌 Bananas 🍌🍌🍌"),
                    HelpItem.custom(icon: IconProvider.eyeSlash,
                                    title: "Look ma, I'm a pirate! 🏴‍☠️",
                                    behaviour: { _ in
                                        UIApplication.openURLIfPossible(URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8c/Treasure-Island-map.jpg")!) }),
                    HelpItem.otherIssues
                ],
                [
                    HelpItem.support,
                    HelpItem.staticText(text: "Have you ever seen a living dinosaur? I have"),
                    HelpItem.custom(icon: IconProvider.mobile,
                                    title: "Hello?",
                                    behaviour: { [weak self] vc in
                                        self?.showAlert(title: "Hello?",
                                                       message: "Is it me you're looking for?",
                                                       actionTitle: "Nope",
                                                       actionBlock: {
                                            UIApplication.openURLIfPossible(URL(string: "https://www.youtube.com/watch?v=bfBu2rV-aYs")!)
                                        },
                                                       over: vc)
                                    })
                ]
            ]
        }
    }
    
    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        actionBlock: @escaping () -> Void = {},
        over: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: { action in
            actionBlock()
            alert.dismiss(animated: true, completion: nil)
        }))
        over.present(alert, animated: true, completion: nil)
    }
    
    func onButtonTap() {
        switchToFlutterView()
    }
    
    private func sendDataToFlutter(data: String) {
        navigationChannel?.invokeMethod("flutter.navigation.to.home", arguments: data)
    }

    // Example function to trigger sending data
    func triggerSendingData() {
        sendDataToFlutter(data: "Hello from Swift!")
    }
    
    func switchToFlutterView() {
        self.triggerSendingData()
    }

    func switchToNativeView() {
        print("Showing login view")
        login?.presentLoginFlow(over: flutterWindow?.rootViewController as! UIViewController,
                                customization: LoginCustomizationOptions(
                                    performBeforeFlow: getAdditionalWork,
                                    customErrorPresenter: getCustomErrorPresenter,
                                    initialError: initialLoginError(),
                                    helpDecorator: getHelpDecorator,
                                    inAppTheme: getInAppTheme
                                )) { [weak self] result in
                                    switch result {
                                    case .loginStateChanged(.loginFinished):
                                        print("dismissed")
                                    case .signupStateChanged(.signupFinished):
                                        print("dismissed")
                                    case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
                                        print(loginData)
                                    case .dismissed:
                                        print("dismissed")
                                        self?.switchToFlutterView()
                                    }
                                }
    }
    
    private func processLoginResult(_ result: LoginAndSignupResult) {
        switch result {
        case .loginStateChanged(.loginFinished):
            login = nil
        case .signupStateChanged(.signupFinished):
            login = nil
        case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
            //data = loginData
            //authManager?.onSessionObtaining(credential: loginData.getCredential)
            print(loginData)
        case .dismissed:
            print("dismissed")
            login = nil
            self.switchToFlutterView()
        }
    }
}

struct SomeVeryObscureInternalError: Error {}

final class AlternativeLoginErrorPresenter: LoginErrorPresenter {
    
    func showAlert(message: String, over: UIViewController) {
        let alert = UIAlertController(title: "The magnificent alternative error presenter proudly presents", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Well, that's a shame", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        over.present(alert, animated: true, completion: nil)
    }
    
    func willPresentError(error: LoginError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: SignupError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: AvailabilityError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
    
    func willPresentError(error: SetUsernameError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: CreateAddressKeysError, from viewController: UIViewController) -> Bool {
        if case .generic(_, _, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInLogin, over: viewController)
        return true
    }
    
    func willPresentError(error: StoreKitManagerErrors, from viewController: UIViewController) -> Bool {
        if case .unknown(_, let originalError) = error, originalError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.userFacingMessageInPayments, over: viewController)
        return true
    }
    
    func willPresentError(error: ResponseError, from viewController: UIViewController) -> Bool {
        if error.underlyingError is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
    
    func willPresentError(error: Error, from viewController: UIViewController) -> Bool {
        if error is SomeVeryObscureInternalError {
            showAlert(message: "Internal error coming from additional work closure", over: viewController)
            return true
        }
        showAlert(message: error.localizedDescription, over: viewController)
        return true
    }
}
