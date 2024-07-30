/*
 * Copyright (c) 2024 Proton Financial AG
 * This file is part of Proton Financial AG and Proton Wallet.
 *
 * Proton Wallet is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Proton Wallet is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Proton Wallet.  If not, see <https://www.gnu.org/licenses/>.
 */

package me.proton.wallet.android.initializer

import android.content.Context
import androidx.startup.Initializer
import me.proton.wallet.android.BuildConfig
import me.proton.core.util.android.sentry.TimberLogger
import me.proton.core.util.kotlin.CoreLogger
import timber.log.Timber

class LoggerInitializer : Initializer<Unit> {

    override fun create(context: Context) {
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
        // Forward Core Logs to Timber, using TimberLogger.
        CoreLogger.set(TimberLogger)
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = listOf(
        SentryInitializer::class.java
    )
}
