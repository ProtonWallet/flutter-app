import CommonCrypto
import CryptoKit
import Flutter
import MoonPaySdk
import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreCryptoGoImplementation
import ProtonCoreCryptoGoInterface
import ProtonCoreDataModel
import ProtonCoreFeatureFlags
import ProtonCoreFoundations
import ProtonCoreHumanVerification
import ProtonCoreLog
import ProtonCoreLogin
import ProtonCoreLoginUI
import ProtonCoreNetworking
import ProtonCorePayments
import ProtonCoreServices
import ProtonCoreSettings
import ProtonCoreUIFoundations
import Sentry
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    /// native code and this need to be refactored later
    private var apiService: PMAPIService?
    private var login: LoginAndSignup?
    private var paymentsManager: PaymentsManager?
    private var navigationChannel: FlutterMethodChannel?
    private var humanVerificationDelegate: HumanVerifyDelegate?
    private var authManager: AuthHelper?
    private let serviceDelegate = WalletApiServiceManager()

    private var getInAppTheme: () -> InAppTheme {
        return { .matchSystem }
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        SentrySDK.start { options in
            options.dsn = "https://f430ab6a50234e50ab7fc57174de1cbc@sentry-new.protontech.ch/69"
            options.debug = true  // Enabled debug when first installing is always helpful
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            options.tracesSampleRate = 1.0
        }

        // Inject crypto with the default implementation.
        injectDefaultCryptoImplementation()
        Brand.currentBrand = .wallet

        // FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        //     GeneratedPluginRegistrant.register(with: registry)
        // }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let messenger = engineBridge.applicationRegistrar.messenger()

        let nativeViewChannel = FlutterMethodChannel(
            name: "me.proton.wallet/native.views",
            binaryMessenger: messenger)
        nativeViewChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "native.navigation.login", "native.navigation.signup":
                self.authManager = AuthHelper()
                apiService?.authDelegate = authManager
                if call.method == "native.navigation.login" {
                    print("Starting login.")
                    self.switchToSignIn()
                } else if call.method == "native.navigation.signup" {
                    print("Starting sign-up.")
                    self.switchToSignUp()
                }
            case "native.navigation.plan.upgrade":
                print("native.navigation.plan.upgrade")
                guard let arguments = call.arguments as? [Any] else {
                    PMLog.error("Call to native.navigation.plan.upgrade includes unknown arguments")
                    return
                }

                guard let sessionKey = arguments[0] as? String else {
                    PMLog.error("Call to native.navigation.plan.upgrade is missing session-key")
                    return
                }

                guard let authInfo = arguments[1] as? [String: Any] else {
                    PMLog.error(
                        "Call to native.navigation.plan.upgrade has malformed auth information")
                    return
                }

                self.showSubscriptionManagementScreen(
                    sessionKey: sessionKey,
                    authInfo: authInfo)
            case "native.initialize.core.environment":
                print("native.initialize.core.environment data:", call.arguments ?? "")
                if let arguments = call.arguments as? [String: Any] {
                    let environment = Environment(from: arguments)
                    AppVersionHeader.shared.parseFlutterData(from: arguments)
                    self.initAPIService(env: environment)
                    self.fetchUnauthFeatureFlags()
                } else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENTS",
                            message:
                                "Can't parse arguments. \"native.initialize.core.environment\" missing environment parameter.",
                            details: nil))
                }
            case "native.navigation.report":
                print("native.navigation.report triggered", call.arguments ?? "")
                if let arguments = call.arguments as? [String: Any],
                    let username = arguments["username"] as? String,
                    let email = arguments["email"] as? String
                {
                    self.switchToBugReport(
                        username: username,
                        email: email
                    )
                } else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENTS",
                            message:
                                "Can't parse arguments. \"native.nagivation.report\" missing username and email parameters.",
                            details: nil))
                }
            case "native.account.logout":
                self.authManager = AuthHelper()
                apiService?.authDelegate = authManager
                print("native.account.logout triggered")
                FeatureFlagsRepository.shared.clearUserId()
                FeatureFlagsRepository.shared.resetFlags()
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let moonPayChannel = FlutterMethodChannel(
            name: "me.proton.wallet/onramp.moon.pay",
            binaryMessenger: messenger)
        moonPayChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "moon.pay.show":
                // These run in your application and are all the of handlers available to you.
                let handlers = MoonPayHandlers(
                    onAuthToken: { data in
                        print("onAuthToken called", data)
                    },
                    onSwapsCustomerSetupComplete: {
                        print("onSwapsCustomerSetupComplete called")
                    },
                    onUnsupportedRegion: {
                        print("onUnsupportedRegion called")
                    },
                    onKmsWalletCreated: {
                        print("onKmsWalletCreated called")
                    },
                    onLogin: { data in
                        print("onLogin called", data)
                    },
                    onInitiateDeposit: { data in
                        // place holder
                        print("onInitiateDepositCalled")
                        let response = OnInitiateDepositResponsePayload(depositId: "place holder")
                        return response
                    },
                    onTransactionCreated: { data in
                        print("onTransactionCreated called", data)
                    },
                    onTransactionCompleted: { data in
                        print("onTransactionCompleted called", data)
                    }
                )

                guard let configurationArguments = call.arguments as? [String: Any],
                    let configuration = try? MoonPayConfiguration.from(configurationArguments)
                else {
                    return result(
                        FlutterError(
                            code: "INVALID_ARGUMENTS",
                            message: "Can't parse arguments. \"moon.pay.show\".",
                            details: nil))
                }

                let params = MoonPayBuyQueryParams(apiKey: configuration.hostApiKey)
                params.setCurrencyCode(value: "btc")
                params.setBaseCurrencyCode(value: configuration.fiatCurrency)
                let mpsDoubleValue = KotlinDouble(value: configuration.fiatValue)
                params.setBaseCurrencyAmount(value: mpsDoubleValue)
                params.setPaymentMethod(value: configuration.paymentMethod)
                params.setShowWalletAddressForm(value: configuration.showAddressForm)
                params.setWalletAddress(value: configuration.userAddress)

                let config = MoonPaySdkBuyConfig(
                    debug: false,
                    environment: MoonPayWidgetEnvironment.production,
                    params: params,
                    handlers: handlers
                )
                let moonPaySdk = MoonPayiOSSdk(config: config)
                moonPaySdk.show(mode: MoonPayRenderingOptioniOS.WebViewOverlay())

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        navigationChannel = FlutterMethodChannel(
            name: "me.proton.wallet/app.view",
            binaryMessenger: messenger)
    }

    func initAPIService(env: Environment) {
        PMAPIService.noTrustKit = true

        let challengeParametersProvider = ChallengeParametersProvider.forAPIService(
            clientApp: .wallet,
            challenge: PMChallenge())
        let apiService = PMAPIService.createAPIServiceWithoutSession(
            environment: env.toCoreEnv(),
            challengeParametersProvider: challengeParametersProvider)

        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(
            apiService: apiService,
            inAppTheme: getInAppTheme,
            clientApp: .wallet)
        apiService.authDelegate = authManager
        apiService.serviceDelegate = serviceDelegate
        apiService.humanDelegate = humanVerificationDelegate

        self.apiService = apiService
    }

    private func fetchUnauthFeatureFlags() {
        guard let apiService = self.apiService else {
            PMLog.error("APIService not set.")
            return
        }
        FeatureFlagsRepository.shared.setApiService(apiService)
        FeatureFlagsRepository.shared.setFlagOverride(CoreFeatureFlagType.dynamicPlan, true)

        Task {
            do {
                try await FeatureFlagsRepository.shared.fetchFlags()
            } catch {
                PMLog.error(error)
            }
        }
    }

    func initLoginAndSignup() {
        guard let apiService = self.apiService else {
            PMLog.error("APIService not set.")
            return
        }

        let appName = "Proton Wallet"
        login = LoginAndSignup(
            appName: appName,
            clientApp: .wallet,
            apiService: apiService,
            minimumAccountType: .external,
            isCloseButtonAvailable: true,
            paymentsAvailability: .notAvailable,
            signupAvailability: getSignupAvailability
        )
    }

    private var getSignupAvailability: SignupAvailability {
        let signupAvailability: SignupAvailability
        let summaryScreenVariant: SummaryScreenVariant = .noSummaryScreen
        signupAvailability = .available(
            parameters: SignupParameters(
                separateDomainsButton: true,
                passwordRestrictions: .default,
                summaryScreenVariant: summaryScreenVariant))
        return signupAvailability
    }

    private var getShowWelcomeScreen: WelcomeScreenVariant? {
        return .wallet(
            .init(
                body:
                    "Create a new account or sign in with your existing Proton account to start using Proton Wallet."
            ))
    }

    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        actionBlock: @escaping () -> Void = {},
        over: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: actionTitle, style: .cancel,
                handler: { action in
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

    // User-facing login handoff alert copy, not credentials or key material.
    private enum LoginHandoffUserMessage {
        static let title = "Almost there" // nosemgrep: hardcoded_secret
        static let tryAgain = "Sign-in didn't finish. Please try again." // nosemgrep: hardcoded_secret
        static let needsPassword = "Please try again with your password." // nosemgrep: hardcoded_secret
    }

    private func showLoginHandoffError(
        _ logMessage: String,
        userMessage: String = LoginHandoffUserMessage.tryAgain
    ) {
        PMLog.error(logMessage)
        guard let rootViewController else {
            return
        }
        showAlert(
            title: LoginHandoffUserMessage.title,
            message: userMessage,
            actionTitle: "OK",
            over: rootViewController
        )
    }

    func switchToFlutterView(loginData: LoginData) {
        guard let userKey = loginData.user.keys.first else {
            showLoginHandoffError("Login handoff failed: user has no keys")
            return
        }
        guard let salt = loginData.salts.first else {
            showLoginHandoffError("Login handoff failed: loginData.salts is empty")
            return
        }
        guard let passphrase = loginData.passphrases[salt.ID], !passphrase.isEmpty else {
            showLoginHandoffError(
                "Login handoff failed: missing passphrase for salt \(salt.ID)",
                userMessage: LoginHandoffUserMessage.needsPassword)
            return
        }

        let jsonObject: [String: Any?] = [
            "sessionId": loginData.credential.sessionID,
            "userId": loginData.credential.userID,
            "userMail": loginData.user.email,
            "userName": loginData.user.displayName,
            "userDisplayName": loginData.user.displayName,
            "accessToken": loginData.credential.accessToken,
            "refreshToken": loginData.credential.refreshToken,
            "scopes": loginData.scopes.joined(separator: ","),
            "userKeyID": userKey.keyID,
            "userPrivateKey": loginData.credential.privateKey,
            "userPassphraseSalt": salt.keySalt,
            "userPassphrase": passphrase,
            "mailboxpasswordKeySalt": loginData.credential.passwordKeySalt,
            "mailboxpassword": loginData.credential.mailboxpassword,
        ]

        guard
            let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonObject, options: .prettyPrinted),
            let convertedString = String(data: jsonData, encoding: .utf8)
        else {
            showLoginHandoffError(
                "Login handoff failed: could not serialize login payload for Flutter")
            return
        }

        sendDataToFlutter(jsonData: convertedString)
    }

    func switchToSignIn() {
        guard let rootViewController = self.rootViewController else {
            PMLog.error("rootViewController must be set before calling \(#function)")
            return
        }

        print("Showing sign-in view")
        self.initLoginAndSignup()
        login?.presentLoginFlow(
            over: rootViewController,
            customization: LoginCustomizationOptions(
                inAppTheme: getInAppTheme
            ), updateBlock: processLoginResult)
    }

    func switchToSignUp() {
        guard let rootViewController = self.rootViewController else {
            PMLog.error("rootViewController must be set before calling \(#function)")
            return
        }

        print("Showing sign-up view")
        self.initLoginAndSignup()
        login?.presentSignupFlow(
            over: rootViewController,
            customization: LoginCustomizationOptions(
                inAppTheme: getInAppTheme
            ), updateBlock: processLoginResult)
    }

    func showSubscriptionManagementScreen(sessionKey: String, authInfo: [String: Any]) {
        guard let userId = authInfo["userId"] as? String else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }

        guard let apiService = self.apiService else {
            PMLog.error("Cannot show subscription management screen before APIService is set.")
            return
        }

        guard let accessToken = authInfo["accessToken"] as? String else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }

        guard let refreshToken = authInfo["refreshToken"] as? String else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }
        guard let userName = authInfo["userName"] as? String else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }
        guard let sessionId = authInfo["sessionId"] as? String else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }
        guard let scopes = authInfo["scopes"] as? [String] else {
            PMLog.error("Cannot show subscription management screen.  Missing userId.")
            return
        }
        apiService.setSessionUID(uid: sessionId)
        let auth = Credential(
            UID: sessionId,
            accessToken: accessToken,
            refreshToken: refreshToken,
            userName: userName,
            userID: userId,
            scopes: scopes,
            mailboxPassword: "")
        let authDelegate = AuthHelper(credential: auth)
        apiService.authDelegate = authDelegate
        self.paymentsManager = PaymentsManager(
            storage: UserDefaults(),
            apiService: apiService,
            authManager: authDelegate)

        self.paymentsManager?.upgradeSubscription(completion: { [weak self] result in
            guard let self else { return }
            // nothing for now
        })
    }

    private func processLoginResult(_ result: LoginAndSignupResult) {
        switch result {
        case .loginStateChanged(.loginFinished):
            print("loginStateChanged(.loginFinished)")
        case .signupStateChanged(.signupFinished):
            print("signupStateChanged(.signupFinished)")
        case .loginStateChanged(.dataIsAvailable(let loginData)),
            .signupStateChanged(.dataIsAvailable(let loginData)):
            self.switchToFlutterView(loginData: loginData)
        case .dismissed:
            print("dismissed")
        }
    }

    func switchToBugReport(username: String, email: String) {
        guard let rootViewController = self.rootViewController else {
            PMLog.error("rootViewController must be set before calling \(#function)")
            return
        }
        guard let apiService else {
            PMLog.error("APIService not set.")
            return
        }
        let viewController = BugReportModule.makeBugReportViewController(
            apiService: apiService,
            username: username,
            email: email
        )
        rootViewController.present(viewController, animated: true)
    }

    func aMethodThatMightFail() throws {
        try performRiskyOperation()
    }

    func performRiskyOperation() throws -> String {
        // Simulate a possible failure
        throw NSError(
            domain: "SimulatedErrorDomain", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
    }
    
    /// Gets the root view controller from the active scene's window
    /// This is needed for UIScene-based apps where AppDelegate no longer manages the window
    private var rootViewController: UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            // Fallback: try to get any window from any connected scene
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene,
                    let window = windowScene.windows.first
                {
                    return window.rootViewController
                }
            }
            return nil
        }
        return window.rootViewController
    }

}
