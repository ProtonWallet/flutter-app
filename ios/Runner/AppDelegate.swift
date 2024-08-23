import CommonCrypto
import CryptoKit
import Flutter
import flutter_local_notifications
import ProtonCoreAuthentication
import ProtonCoreChallenge
import ProtonCoreCryptoGoInterface
import ProtonCoreCryptoGoImplementation
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
import MoonPaySdk
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
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
        // Inject crypto with the default implementation.
        injectDefaultCryptoImplementation()
        let rootViewController = self.window?.rootViewController as! FlutterViewController
        
        let nativeViewChannel = FlutterMethodChannel(name: "me.proton.wallet/native.views",
                                                     binaryMessenger: rootViewController.binaryMessenger)
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
                    PMLog.error("Call to native.navigation.plan.upgrade has malformed auth information")
                    return
                }
                
                self.showSubscriptionManagementScreen(sessionKey: sessionKey,
                                                      authInfo: authInfo)
            case "native.initialize.core.environment":
                print("native.initialize.core.environment data:", call.arguments ?? "")
                if let arguments = call.arguments as? [String: Any] {
                    let environment = Environment(from: arguments)
                    AppVersionHeader.shared.parseFlutterData(from: arguments)
                    PMLog.setEnvironment(environment: environment.type.title)
                    self.initAPIService(env: environment)
                    self.fetchUnauthFeatureFlags()
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Can't parse arguments. \"native.initialize.core.environment\" missing environment parameter.",
                                        details: nil))
                }
            case "native.navigation.report":
                print("native.navigation.report triggered", call.arguments ?? "")
                if let arguments = call.arguments as? [String: Any],
                   let username = arguments["username"] as? String,
                   let email = arguments["email"] as? String {
                    self.switchToBugReport(
                        username: username,
                        email: email
                    )
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Can't parse arguments. \"native.nagivation.report\" missing username and email parameters.",
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
        
        let moonPayChannel = FlutterMethodChannel(name: "me.proton.wallet/onramp.moon.pay",
                                                  binaryMessenger: rootViewController.binaryMessenger)
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
                    return result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Can't parse arguments. \"moon.pay.show\".",
                                        details: nil))
                }
                
                let params = MoonPayBuyQueryParams(apiKey: configuration.hostApiKey)
                params.setCurrencyCode(value: "btc")
                params.setBaseCurrencyCode(value: configuration.fiatCurrency)
                let mpsDoubleValue = KotlinDouble(value: configuration.fiatValue)
                params.setBaseCurrencyAmount(value: mpsDoubleValue)
                params.setPaymentMethod(value:configuration.paymentMethod)
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
        
        navigationChannel = FlutterMethodChannel(name: "me.proton.wallet/app.view",
                                                 binaryMessenger: rootViewController.binaryMessenger)
        Brand.currentBrand = .wallet
        
        // FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        //     GeneratedPluginRegistrant.register(with: registry)
        // }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        // disable
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func initAPIService(env: Environment) {
        PMAPIService.noTrustKit = true
        
        let challengeParametersProvider = ChallengeParametersProvider.forAPIService(clientApp: .wallet,
                                                                                    challenge: PMChallenge())
        let apiService = PMAPIService.createAPIServiceWithoutSession(
            environment: env.toCoreEnv(),
            challengeParametersProvider: challengeParametersProvider)
        
        self.authManager = AuthHelper()
        self.humanVerificationDelegate = HumanCheckHelper(apiService: apiService,
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
        signupAvailability = .available(parameters: SignupParameters(separateDomainsButton: true,
                                                                     passwordRestrictions: .default,
                                                                     summaryScreenVariant: summaryScreenVariant))
        return signupAvailability
    }
    
    private var getShowWelcomeScreen: WelcomeScreenVariant? {
        return .wallet(.init(body: "Create a new account or sign in with your existing Proton account to start using Proton Wallet."))
    }
    
    private var getAdditionalWork: WorkBeforeFlow? {
        return WorkBeforeFlow(stepName: "Additional work creation...") { loginData, flowCompletion in
            DispatchQueue.global(qos: .userInitiated).async {
                sleep(10)
                flowCompletion(.success(()))
            }
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
            "mailboxpasswordKeySalt": loginData.credential.passwordKeySalt,
            "mailboxpassword": loginData.credential.mailboxpassword,
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let convertedString = String(data: jsonData, encoding: .utf8)!
        
        sendDataToFlutter(jsonData: convertedString)
    }
    
    func switchToSignIn() {
        guard let rootViewController = self.window.rootViewController else {
            PMLog.error("rootViewController must be set before calling \(#function)")
            return
        }
        
        print("Showing sign-in view")
        self.initLoginAndSignup()
        login?.presentLoginFlow(over: rootViewController,
                                customization: LoginCustomizationOptions(
                                    performBeforeFlow: getAdditionalWork,
                                    inAppTheme: getInAppTheme
                                ), updateBlock: processLoginResult)
    }
    
    func switchToSignUp() {
        guard let rootViewController = self.window.rootViewController else {
            PMLog.error("rootViewController must be set before calling \(#function)")
            return
        }
        
        print("Showing sign-up view")
        self.initLoginAndSignup()
        login?.presentSignupFlow(over: rootViewController,
                                 customization: LoginCustomizationOptions(
                                    performBeforeFlow: getAdditionalWork,
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
        let auth = Credential(UID: sessionId,
                              accessToken: accessToken,
                              refreshToken: refreshToken,
                              userName: userName,
                              userID: userId,
                              scopes: scopes,
                              mailboxPassword: "")
        let authDelegate = AuthHelper(credential: auth)
        apiService.authDelegate = authDelegate
        self.paymentsManager = PaymentsManager(storage: UserDefaults(),
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
        case .loginStateChanged(.dataIsAvailable(let loginData)), .signupStateChanged(.dataIsAvailable(let loginData)):
            self.switchToFlutterView(loginData: loginData)
        case .dismissed:
            print("dismissed")
        }
    }
    
    func switchToBugReport(username: String, email: String) {
        guard let rootViewController = self.window.rootViewController else {
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
    
    
}
