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

package me.proton.wallet.android.channel

import me.proton.wallet.android.WalletApiClient
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import me.proton.core.crypto.common.keystore.PlainByteArray
import me.proton.core.network.domain.session.Session
import me.proton.core.user.domain.entity.User

interface FlutterCallHandler {
    fun navigateHome(user: User, session: Session, passphrase: PlainByteArray)
}

class FlutterMethodChannel(
    engine: FlutterEngine,
) : MethodChannel(
    /* messenger = */ engine.dartExecutor.binaryMessenger,
    /* name = */ "me.proton.wallet/app.view"
), FlutterCallHandler {

    override fun navigateHome(user: User, session: Session, passphrase: PlainByteArray) {
        val arguments = mutableMapOf<String, String>()
        arguments["userId"] = user.userId.id
        arguments["userMail"] = user.email ?: ""
        arguments["userName"] = user.name ?: ""
        arguments["userDisplayName"] = user.displayName ?: ""
        arguments["userPrivateKey"] = user.keys[0].privateKey.key
        arguments["userPassphrase"] = passphrase.use { String(it.array, Charsets.UTF_8) }
        arguments["userKeyID"] = user.keys[0].keyId.id
        arguments["scopes"] = session.scopes.joinToString(separator = ",")
        arguments["sessionId"] = session.sessionId.id
        arguments["accessToken"] = session.accessToken
        arguments["refreshToken"] = session.refreshToken

        val walletApiClient = WalletApiClient()
        arguments["appVersion"] = walletApiClient.appVersionHeader
        arguments["userAgent"] = walletApiClient.userAgent

        invokeMethod("flutter.navigation.to.home", Json.encodeToString(arguments))
    }
}
