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

package me.proton.wallet.android

import android.os.Build
import me.proton.core.network.domain.ApiClient
import java.util.Locale
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class WalletApiClient @Inject constructor() : ApiClient {

    private val appName = "android-wallet"
    private val productName = "ProtonWallet"
    private var versionName = BuildConfig.VERSION_NAME
    private var versionSuffix = if (BuildConfig.DEBUG) "-dev" else ""

    private var versionHeader = "$appName@$versionName$versionSuffix"
    private var userAgentHeader = defaultAgent

    /**
     * Tells the lib if DoH should be used in a given moment (based e.g. on user setting or whether
     * VPN connection is active). Will be checked before  each API call.
     */
    override val shouldUseDoh: Boolean = false

    /**
     * Client's value for 'x-pm-appversion' header.
     */
    override val appVersionHeader: String
        get() = versionHeader

    /**
     * Client's value for 'User-Agent' header.
     */
    override val userAgent: String
        get() = userAgentHeader

    /**
     * Enables debug logging in the underlying HTTP library.
     */
    override val enableDebugLogging: Boolean = BuildConfig.DEBUG

    /**
     * Tells client to force update (this client will no longer be accepted by the API).
     *
     * @param errorMessage the localized error message the user should see.
     */
    override fun forceUpdate(errorMessage: String) {
        // dummy example, not implemented for now
    }

    private val defaultAgent: String
        get() = String.format(
            Locale.US,
            "%s/%s (Android %s; %s; %s %s; %s)",
            productName,
            versionName,
            Build.VERSION.RELEASE,
            Build.MODEL,
            Build.BRAND,
            Build.DEVICE,
            Locale.getDefault().language
        )

    public fun updateVersion(version: String?, agent: String?) {
        if (version != null) {
            this.versionHeader = version
        } else {
            this.versionHeader = "$appName@$versionName$versionSuffix"
        }

        if (agent != null) {
            this.userAgentHeader = agent
        } else {
            this.userAgentHeader = defaultAgent
        }
    }
}
