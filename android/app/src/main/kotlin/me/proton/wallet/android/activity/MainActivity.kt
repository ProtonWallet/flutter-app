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

package me.proton.wallet.android.activity

import android.content.Intent
import androidx.activity.viewModels
import me.proton.wallet.android.WalletFlutterPlugin
import me.proton.wallet.android.channel.AccountSession
import me.proton.wallet.android.channel.FlutterMethodChannel
import me.proton.wallet.android.channel.NativeCallHandler
import me.proton.wallet.android.channel.NativeMethodChannel
import dagger.hilt.android.AndroidEntryPoint
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import me.proton.core.domain.entity.UserId
import me.proton.wallet.android.WalletApiClient
import me.proton.wallet.android.channel.VersionHeader
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : FlutterFragmentActivity(), NativeCallHandler {

    private val viewModel: MainActivityViewModel by viewModels()

    @Inject
    lateinit var walletApiClient: WalletApiClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine.plugins.add(WalletFlutterPlugin)

        val nativeChannel = NativeMethodChannel(flutterEngine, this)
        val flutterChannel = FlutterMethodChannel(flutterEngine)
        nativeChannel.init()
        viewModel.register(this, flutterChannel)
    }

    override fun startLogin() {
        viewModel.startLogin()
    }

    override fun startSignUp() {
        viewModel.startSignUp()
    }

    override fun startReport() {
        viewModel.startReport()
    }

    override fun startSubscription(accountSession: AccountSession) {
        viewModel.startSubscription(accountSession)
    }

    override fun startUpgrade(accountSession: AccountSession) {
        viewModel.startUpgrade(accountSession)
    }

    override fun startChangePassword(accountSession: AccountSession) {
        viewModel.startPasswordManagement(accountSession)
    }

    override fun startUpdateRecoveryEmail(accountSession: AccountSession) {
        viewModel.startUpdateRecoveryEmail(accountSession)
    }

    override fun restartActivity() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
    }

    override fun restartApplication() {
        restartActivity()
        Runtime.getRuntime().exit(0)
    }

    override fun logout(userId: UserId?) {
        viewModel.logout(userId)
    }

    override fun setWalletApiClientHeader(versionHeader: VersionHeader) {
        walletApiClient.updateVersion(versionHeader.version, versionHeader.agent)
    }
}
