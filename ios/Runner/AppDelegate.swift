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
import flutter_local_notifications
import ProtonCoreLog
import ProtonCoreCryptoGoInterface
import ProtonCoreCryptoGoImplementation
import SwiftUI // If using SwiftUI
import CommonCrypto
import CryptoKit

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
    private let serviceDelegate = WalletApiServiceManager()
    
    private var getInAppTheme: () -> InAppTheme {
        return { .matchSystem }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up the Flutter window
        self.flutterWindow = self.window
        // crash without this line. Inject crypto with the default implementation.
        injectDefaultCryptoImplementation()
        let controller = self.flutterWindow?.rootViewController as! FlutterViewController
        let nativeViewChannel = FlutterMethodChannel(name: "com.example.wallet/native.views", binaryMessenger: controller.binaryMessenger)
        nativeViewChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "native.navigation.login", "native.navigation.signup":
                if let arguments = call.arguments as? [String: Any] {
                    let environment = Environment(from: arguments)
                    switch environment.type {
                    case .prod, .atlas, .atlasCustom:
                        if call.method == "native.navigation.login" {
                            print("Logging in with environment:", environment.type)
                            self.switchToSignIn(env: environment)
                        } else if call.method == "native.navigation.signup" {
                            print("Signing up with environment:", environment.type)
                            self.switchToSignup(env: environment)
                        }
                    default:
                        result(FlutterError(code: "INVALID_ENVIRONMENT", message: "Environment unknown", details: nil))
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Can't parse arguments", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        navigationChannel = FlutterMethodChannel(name: "com.example.wallet/app.view", binaryMessenger: controller.binaryMessenger)
        PMLog.setEnvironment(environment: "wallet-test")

        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func initSignupLogin(env: Environment) {
        let clientApp: ClientApp = .mail
        PMAPIService.noTrustKit = true
        let apiService = PMAPIService.createAPIServiceWithoutSession(environment: env.toCoreEnv(),
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
        //  switchToFlutterView()
    }
    
    private func sendDataToFlutter(jsonData: String) {
        navigationChannel?.invokeMethod("flutter.navigation.to.home", arguments: jsonData)
    }

    func switchToFlutterView(loginData: LoginData) {
        let jsonObject: [String: Any?] = [
            "sessionId": loginData.credential.sessionID,
            "userId": loginData.credential.userID,
            "userMail": loginData.user.email,
            "userName": loginData.user.displayName,
            "userDisplayName": loginData.user.displayName,
            "accessToken": loginData.credential.accessToken,
            "refreshToken": loginData.credential.refreshToken,
            "scopes": loginData.scopes.joined(separator: ","),
            "userKeyID": loginData.user.keys[0].keyID,
            "userPrivateKey": loginData.credential.privateKey,
            "userPassphraseSalt": loginData.salts[0].keySalt,
            "userPassphrase": loginData.passphrases[loginData.salts[0].ID],
            //
            "mailboxpasswordKeySalt": loginData.credential.passwordKeySalt,
            "mailboxpassword": loginData.credential.mailboxpassword,
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let convertedString = String(data: jsonData, encoding: .utf8)!
        
        sendDataToFlutter(jsonData: convertedString)
    }

    func switchToSignIn(env: Environment) {
        print("Showing login view")
        self.initSignupLogin(env: env)
        login?.presentLoginFlow(over: flutterWindow?.rootViewController as! UIViewController,
                                customization: LoginCustomizationOptions(
                                    performBeforeFlow: getAdditionalWork,
                                    customErrorPresenter: getCustomErrorPresenter,
                                    initialError: initialLoginError(),
                                    helpDecorator: getHelpDecorator,
                                    inAppTheme: getInAppTheme
                                ), updateBlock: processLoginResult)
    }

    func switchToSignup(env: Environment) {
        print("Showing login view")
        self.initSignupLogin(env: env)
        login?.presentSignupFlow(over: flutterWindow?.rootViewController as! UIViewController,
                                 customization: LoginCustomizationOptions(
                                    performBeforeFlow: getAdditionalWork,
                                    customErrorPresenter: getCustomErrorPresenter,
                                    initialError: initialLoginError(),
                                    helpDecorator: getHelpDecorator,
                                    inAppTheme: getInAppTheme
                                 ), updateBlock: processLoginResult)
    }
    
    private func processLoginResult(_ result: LoginAndSignupResult) {
        switch result {
        case .loginStateChanged(.loginFinished):
            print("loginStateChanged(.loginFinished)")
        case .signupStateChanged(.signupFinished):
            print("signupStateChanged(.signupFinished)")
        case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
            self.switchToFlutterView(loginData: loginData)
        case .dismissed:
            print("dismissed")
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
