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

package com.example.wallet.initializer

import android.content.Context
import androidx.lifecycle.Lifecycle
import androidx.startup.Initializer
import com.example.wallet.log.api.WalletLogger
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.components.SingletonComponent
import me.proton.core.accountmanager.domain.AccountManager
import me.proton.core.accountmanager.presentation.observe
import me.proton.core.accountmanager.presentation.onAccountDisabled
import me.proton.core.accountmanager.presentation.onAccountRemoved
import com.example.wallet.commonui.api.PassAppLifecycleProvider
//import com.example.wallet.data.api.usecases.ResetAppToDefaults

class AccountListenerInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        val entryPoint: AccountListenerInitializerEntryPoint =
            EntryPointAccessors.fromApplication(
                context.applicationContext,
                AccountListenerInitializerEntryPoint::class.java
            )

//        val lifecycleProvider = entryPoint.passAppLifecycleProvider()
        val accountManager = entryPoint.accountManager()
//        val resetAppToDefaults = entryPoint.resetAppToDefaults()

//        accountManager.observe(
//            lifecycle = lifecycleProvider.lifecycle,
//            minActiveState = Lifecycle.State.CREATED
//        ).onAccountDisabled {
//            WalletLogger.i(TAG, "Account disabled")
//            accountManager.removeAccount(it.userId)
//        }.onAccountRemoved {
//            WalletLogger.i(TAG, "Account removed")
////            resetAppToDefaults()
//        }
    }

    override fun dependencies(): List<Class<out Initializer<*>?>> = emptyList()


    @EntryPoint
    @InstallIn(SingletonComponent::class)
    interface AccountListenerInitializerEntryPoint {
//        fun passAppLifecycleProvider(): PassAppLifecycleProvider
        fun accountManager(): AccountManager
//        fun resetAppToDefaults(): ResetAppToDefaults
    }

    companion object {
        private const val TAG = "AccountListenerInitializer"
    }
}
