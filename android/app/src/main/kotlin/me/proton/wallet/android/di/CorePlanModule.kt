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

package me.proton.wallet.android.di

import android.app.Activity
import dagger.Binds
import dagger.BindsOptionalOf
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import me.proton.core.domain.entity.UserId
import me.proton.core.plan.data.IsSplitStorageEnabledImpl
import me.proton.core.plan.data.PlanIconsEndpointProviderImpl
import me.proton.core.plan.data.repository.PlansRepositoryImpl
import me.proton.core.plan.data.usecase.ObserveUserCurrencyImpl
import me.proton.core.plan.data.usecase.PerformSubscribeImpl
import me.proton.core.plan.domain.IsDynamicPlanAdjustedPriceEnabled
import me.proton.core.plan.domain.IsDynamicPlanEnabled
import me.proton.core.plan.domain.IsSplitStorageEnabled
import me.proton.core.plan.domain.PlanIconsEndpointProvider
import me.proton.core.plan.domain.repository.PlansRepository
import me.proton.core.plan.domain.usecase.CreatePaymentTokenForGooglePurchase
import me.proton.core.plan.domain.usecase.ObserveUserCurrency
import me.proton.core.plan.domain.usecase.PerformGiapPurchase
import me.proton.core.plan.domain.usecase.PerformSubscribe
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
public interface CorePlanModule {

    @Binds
    @Singleton
    public fun providePlansRepository(impl: PlansRepositoryImpl): PlansRepository

    @Binds
    @Singleton
    public fun provideIconsEndpoint(impl: PlanIconsEndpointProviderImpl): PlanIconsEndpointProvider

    @Binds
    @Singleton
    public fun provideIsSplitStorageEnabled(impl: IsSplitStorageEnabledImpl): IsSplitStorageEnabled

    @Binds
    public fun bindPerformSubscribe(impl: PerformSubscribeImpl): PerformSubscribe

    @Binds
    public fun bindObserveUserCurrency(impl: ObserveUserCurrencyImpl): ObserveUserCurrency

    @BindsOptionalOf
    public fun optionalPerformGiapPurchase(): PerformGiapPurchase<Activity>

    @BindsOptionalOf
    public fun optionalCreateSubscriptionForGiap(): CreatePaymentTokenForGooglePurchase
}

@Module
@InstallIn(SingletonComponent::class)
object CorePlansFeaturesModule {
    @Provides
    @Singleton
    fun provideIsDynamicPlanEnabled(): IsDynamicPlanEnabled = object : IsDynamicPlanEnabled {
        override fun invoke(userId: UserId?): Boolean = true
        override fun isLocalEnabled(): Boolean = true
        override fun isRemoteEnabled(userId: UserId?): Boolean = true
    }

    @Provides
    @Singleton
    fun provideIsDynamicPlanAdjustedPricesEnabled(): IsDynamicPlanAdjustedPriceEnabled = object : IsDynamicPlanAdjustedPriceEnabled {
        override fun invoke(userId: UserId?): Boolean = true
        override fun isLocalEnabled(): Boolean = true
        override fun isRemoteEnabled(userId: UserId?): Boolean = true
    }
}
