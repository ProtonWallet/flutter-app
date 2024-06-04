/*
 * Copyright (c) 2024 Proton AG
 * This file is part of Proton AG and Proton Wallet.
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
import androidx.startup.AppInitializer
import androidx.startup.Initializer
import me.proton.core.auth.presentation.MissingScopeInitializer
import me.proton.core.humanverification.presentation.HumanVerificationInitializer
import me.proton.core.network.presentation.init.UnAuthSessionFetcherInitializer
import me.proton.core.paymentiap.presentation.GooglePurchaseHandlerInitializer
import me.proton.core.plan.presentation.PurchaseHandlerInitializer
import me.proton.core.plan.presentation.UnredeemedPurchaseInitializer

class MainInitializer : Initializer<Unit> {

    override fun create(context: Context) {
        // No-op needed
    }

    override fun dependencies() = listOf(
        FeatureFlagInitializer::class.java,
        AccountStateHandlerInitializer::class.java,
        EventManagerInitializer::class.java,
        HumanVerificationInitializer::class.java,
        SentryInitializer::class.java,
        LoggerInitializer::class.java,
        MissingScopeInitializer::class.java,
        StrictModeInitializer::class.java,
        UnAuthSessionFetcherInitializer::class.java,
        PurchaseHandlerInitializer::class.java,
        GooglePurchaseHandlerInitializer::class.java,
        UnredeemedPurchaseInitializer::class.java,
    )

    companion object {

        fun init(appContext: Context) {
            with(AppInitializer.getInstance(appContext)) {
                // WorkManager need to be initialized before any other dependant initializer.
                initializeComponent(WorkManagerInitializer::class.java)
                initializeComponent(MainInitializer::class.java)
            }
        }
    }
}
