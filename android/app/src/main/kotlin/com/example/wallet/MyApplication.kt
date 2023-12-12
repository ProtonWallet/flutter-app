package com.example.wallet

import android.app.Application
import androidx.startup.AppInitializer
import dagger.hilt.android.HiltAndroidApp
import me.proton.core.auth.presentation.MissingScopeInitializer
import me.proton.core.humanverification.presentation.HumanVerificationInitializer
import me.proton.core.network.presentation.init.UnAuthSessionFetcherInitializer
import me.proton.core.plan.presentation.UnredeemedPurchaseInitializer
import me.proton.core.telemetry.presentation.ProductMetricsInitializer

import android.app.Activity
import android.os.Bundle
import coil.ImageLoader
import coil.ImageLoaderFactory
import com.example.wallet.initializer.MainInitializer
import com.example.wallet.log.api.WalletLogger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
//import com.example.wallet.inappreview.api.InAppReviewTriggerMetrics
//import com.example.wallet.initializer.MainInitializer
//import com.example.wallet.log.api.PassLogger
//import com.example.wallet.preferences.HasAuthenticated
//import com.example.wallet.preferences.UserPreferencesRepository
import javax.inject.Inject
import javax.inject.Provider

@HiltAndroidApp
class MyApplication : Application(){
    override fun onCreate() {
        super.onCreate()
        MainInitializer.init(this)
//        preferenceRepository.setHasAuthenticated(HasAuthenticated.NotAuthenticated)
        registerActivityLifecycleCallbacks(
            activityLifecycleCallbacks(
                onActivityCreated = { activity, _ ->
                    CoroutineScope(Dispatchers.IO).launch {
//                        inAppReviewTriggerMetrics.incrementAppLaunchStreakCount()
                    }
                    WalletLogger.i(TAG, "Created activity ${activity::class.java.simpleName}")
                },
                onActivityStopped = { activity ->
                    WalletLogger.i(TAG, "Stopped activity ${activity::class.java.simpleName}")
                },
            )
        )
    }

    private fun activityLifecycleCallbacks(
        onActivityCreated: (activity: Activity, savedInstanceState: Bundle?) -> Unit = { _, _ -> },
        onActivityStarted: (activity: Activity) -> Unit = {},
        onActivityResumed: (activity: Activity) -> Unit = {},
        onActivityPaused: (activity: Activity) -> Unit = {},
        onActivityStopped: (activity: Activity) -> Unit = {},
        onActivitySaveInstanceState: (activity: Activity, outState: Bundle) -> Unit = { _, _ -> },
        onActivityDestroyed: (activity: Activity) -> Unit = {}
    ) = object : ActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
            onActivityCreated(activity, savedInstanceState)
        }

        override fun onActivityStarted(activity: Activity) {
            onActivityStarted(activity)
        }

        override fun onActivityResumed(activity: Activity) {
            onActivityResumed(activity)
        }

        override fun onActivityPaused(activity: Activity) {
            onActivityPaused(activity)
        }

        override fun onActivityStopped(activity: Activity) {
            onActivityStopped(activity)
        }

        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
            onActivitySaveInstanceState(activity, outState)
        }

        override fun onActivityDestroyed(activity: Activity) {
            onActivityDestroyed(activity)
        }
    }

    companion object {
        private const val TAG = "App"
    }
}