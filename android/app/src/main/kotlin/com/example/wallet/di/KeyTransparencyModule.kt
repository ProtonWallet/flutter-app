package com.example.wallet.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import me.proton.core.keytransparency.data.KeyTransparencyEnabled

@Module
@InstallIn(SingletonComponent::class)
object KeyTransparencyModule {

    @Provides
    @KeyTransparencyEnabled
    fun provideKeyTransparencyEnabled(): Boolean = true
}
