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
import androidx.startup.Initializer
import me.proton.wallet.android.BuildConfig
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.components.SingletonComponent
import me.proton.core.featureflag.data.FeatureFlagRefreshStarter

class FeatureFlagInitializer : Initializer<Unit> {

    override fun create(context: Context) {
        EntryPointAccessors.fromApplication(
            context.applicationContext,
            FeatureFlagInitializerEntryPoint::class.java
        ).featureFlagRefreshStarter().start(BuildConfig.DEBUG)
    }

    override fun dependencies(): List<Class<out Initializer<*>?>> = listOf(
        WorkManagerInitializer::class.java
    )

    @EntryPoint
    @InstallIn(SingletonComponent::class)
    interface FeatureFlagInitializerEntryPoint {
        fun featureFlagRefreshStarter(): FeatureFlagRefreshStarter
    }
}
