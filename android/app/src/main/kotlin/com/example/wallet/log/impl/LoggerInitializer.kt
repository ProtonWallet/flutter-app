package com.example.wallet.log.impl

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.LocaleList
import android.os.StatFs
import androidx.startup.Initializer
import com.example.wallet.log.api.WalletLogger
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.components.SingletonComponent
import me.proton.core.util.android.sentry.TimberLogger
import me.proton.core.util.kotlin.CoreLogger
import com.example.wallet.appconfig.AppConfig
//import com.example.wallet.tracing.impl.SentryInitializer
import timber.log.Timber
import java.text.DecimalFormat

class LoggerInitializer : Initializer<Unit> {

    override fun create(context: Context) {
        val entryPoint = EntryPointAccessors.fromApplication(
            context.applicationContext,
            LoggerInitializerEntryPoint::class.java
        )

        if (entryPoint.appConfig().isDebug) {
            Timber.plant(Timber.DebugTree())
        }
        Timber.plant(FileLoggingTree(context))
        deviceInfo(context, entryPoint.appConfig())

        // Forward Core Logs to Timber, using TimberLogger.
        CoreLogger.set(TimberLogger)
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = listOf(
        //SentryInitializer::class.java
    )

    @EntryPoint
    @InstallIn(SingletonComponent::class)
    interface LoggerInitializerEntryPoint {
        fun appConfig(): AppConfig
    }
}

private fun deviceInfo(context: Context, appConfig: AppConfig) {
    val memory = getMemory(context)
    val storage = getStorage()
    WalletLogger.i(TAG, "-----------------------------------------")
    WalletLogger.i(
        TAG,
        "OS:          Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
    )
    WalletLogger.i(TAG, "VERSION:     ${appConfig.versionName}")
    WalletLogger.i(TAG, "DEVICE:      ${Build.MANUFACTURER} ${Build.MODEL}")
    WalletLogger.i(TAG, "FINGERPRINT: ${Build.FINGERPRINT}")
    WalletLogger.i(TAG, "ABI:         ${Build.SUPPORTED_ABIS.joinToString(",")}")
    WalletLogger.i(TAG, "LOCALE:      ${LocaleList.getDefault().toLanguageTags()}")
    WalletLogger.i(TAG, "MEMORY:      $memory")
    WalletLogger.i(TAG, "STORAGE:     $storage")
    WalletLogger.i(TAG, "-----------------------------------------")
}

private fun getStorage(): String {
    val free = freeStorage()
    val total = totalStorage()
    return "Free: ${bytesToHuman(free)} | Total: ${bytesToHuman(total)}"
}

private fun getMemory(context: Context): String {
    val mi = ActivityManager.MemoryInfo()
    val activityManager = context.getSystemService(ActivityManager::class.java)
        ?: return "UNAVAILABLE"
    activityManager.getMemoryInfo(mi)

    val availableMegs: Double = mi.availMem.toDouble() / 0x100000L
    val totalMegs: Double = mi.totalMem.toDouble() / 0x100000L
    val fractionAvail: Double = mi.availMem.toDouble() / mi.totalMem.toDouble()
    val percentAvail: Double = fractionAvail * 100

    return "Available: ${floatForm(availableMegs)} MB / ${floatForm(totalMegs)} MB (${floatForm(percentAvail)}% used)"
}

private fun totalStorage(): Long {
    val statFs = StatFs(Environment.getRootDirectory().absolutePath)
    return statFs.blockCountLong * statFs.blockSizeLong
}

private fun freeStorage(): Long {
    val statFs = StatFs(Environment.getRootDirectory().absolutePath)
    return statFs.freeBlocksLong * statFs.blockSizeLong
}

private fun floatForm(d: Double) = DecimalFormat("#.##").format(d)

private fun bytesToHuman(size: Long): String {
    val kb = (1 * 1024).toLong()
    val mb = kb * 1024
    val gb = mb * 1024
    val tb = gb * 1024
    val pb = tb * 1024
    val eb = pb * 1024

    return when {
        size < kb -> floatForm(size.toDouble()) + " byte"
        size in kb until mb -> floatForm(size.toDouble() / kb) + " KB"
        size in mb until gb -> floatForm(size.toDouble() / mb) + " MB"
        size in gb until tb -> floatForm(size.toDouble() / gb) + " GB"
        size in tb until pb -> floatForm(size.toDouble() / tb) + " TB"
        size in pb until eb -> floatForm(size.toDouble() / pb) + " PB"
        else -> floatForm(size.toDouble() / eb) + " EB"
    }
}

private const val TAG = "DEVICE_INFO"