/*
 * Copyright (c) 2023 Proton AG
 * This file is part of Proton AG and Proton Pass.
 *
 * Proton Pass is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Proton Pass is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Proton Pass.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.example.wallet

//import com.example.wallet.autofill.di.UserPreferenceEntryPoint
//import com.example.wallet.commonui.api.setSecureMode
//import com.example.wallet.preferences.AllowScreenshotsPreference
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowCompat
import androidx.fragment.app.FragmentActivity
import com.example.wallet.ui.launcher.LauncherViewModel
import dagger.hilt.android.AndroidEntryPoint
import io.flutter.plugin.common.MethodChannel
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import me.proton.core.notification.presentation.deeplink.DeeplinkManager
import me.proton.core.notification.presentation.deeplink.onActivityCreate
import javax.inject.Inject


@AndroidEntryPoint
class AuthActivity : FragmentActivity() {

    @Inject
    lateinit var deeplinkManager: DeeplinkManager

    private val launcherViewModel: LauncherViewModel by viewModels()

//    private val updateResultLauncher: ActivityResultLauncher<IntentSenderRequest> =
//        registerForActivityResult(ActivityResultContracts.StartIntentSenderForResult()) { result: ActivityResult ->
//            when (result.resultCode) {
//                RESULT_CANCELED -> launcherViewModel.declineUpdate()
//                else -> {}
//            }
//        }

    override fun onCreate(savedInstanceState: Bundle?) {
//        setSecureMode()
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        deeplinkManager.onActivityCreate(this, savedInstanceState)

        WindowCompat.setDecorFitsSystemWindows(window, false)

        fun callback(result: MutableMap<String, String>){
            MethodChannel(MainActivity.flutterEngineInstance?.dartExecutor!!.binaryMessenger, "com.example.wallet/app.view")
                .invokeMethod("flutter.navigation.to.home", Json.encodeToString(result))
            this.finish()
        }

        // Register activities for result.
        val method = intent.getStringExtra("method")
        launcherViewModel.register(this)
        if ( method.equals("signin") ){
            launcherViewModel.signIn(this, ::callback)
        } else {
            launcherViewModel.signUp(this, ::callback)
        }

        // launcherViewModel.signUp()

//        setContent {
//            val state by launcherViewModel.state.collectAsStateWithLifecycle()
//            runCatching {
//                splashScreen.setKeepOnScreenCondition {
//                    state == Processing || state == StepNeeded
//                }
//            }.onFailure {
//                WalletLogger.w(TAG, it, "Error setting splash screen keep on screen condition")
//            }
//            LaunchedEffect(state) {
//                launcherViewModel.onUserStateChanced(state)
//            }
//            when (state) {
//                AccountNeeded -> {
//                    launcherViewModel.addAccount()
//                }
//
//                Processing -> ProtonCenteredProgress(Modifier.fillMaxSize())
//                StepNeeded -> ProtonCenteredProgress(Modifier.fillMaxSize())
//                PrimaryExist -> {
////                    DisposableEffect(Unit) {
////                        launcherViewModel.checkForUpdates(updateResultLauncher)
////                        onDispose { launcherViewModel.cancelUpdateListener() }
////                    }
//                }
//            }
//        }
    }

    private fun restartApp() {
        val intent = intent
        finish()
        startActivity(intent)
    }

//    private fun setSecureMode() {
//        val factory = EntryPointAccessors.fromApplication(
//            context = this,
//            entryPoint = UserPreferenceEntryPoint::class.java
//        )
//        val repository = factory.getRepository()
//        val setting = runBlocking {
//            repository.getAllowScreenshotsPreference()
//                .firstOrNull()
//                ?: AllowScreenshotsPreference.Disabled
//        }
//        setSecureMode(setting)
//    }

    override fun onBackPressed() {
        super.onBackPressed()
        this.finish()
    }

    companion object {
        private const val TAG = "MainActivity"
    }
}
