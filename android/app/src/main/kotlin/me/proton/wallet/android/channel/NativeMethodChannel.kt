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

package me.proton.wallet.android.channel

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.serialization.json.Json
import me.proton.core.account.domain.entity.Account
import me.proton.core.account.domain.entity.AccountDetails
import me.proton.core.account.domain.entity.AccountState
import me.proton.core.account.domain.entity.SessionState
import me.proton.core.domain.entity.UserId
import me.proton.core.network.domain.session.Session
import me.proton.core.network.domain.session.SessionId

interface NativeCallHandler {
    fun startLogin()
    fun startSignUp()
    fun startReport()
    fun startSubscription(accountSession: AccountSession)
    fun startUpgrade(accountSession: AccountSession)
    fun startChangePassword(accountSession: AccountSession)
    fun startUpdateRecoveryEmail(accountSession: AccountSession)
    fun restartActivity()
    fun restartApplication()
    fun logout(userId: UserId?)
}

data class AccountSession(
    val account: Account,
    val session: Session
)

class NativeMethodChannel(
    engine: FlutterEngine,
    private val callHandler: NativeCallHandler,
) : MethodChannel(
    /* messenger = */ engine.dartExecutor.binaryMessenger,
    /* name = */ "me.proton.wallet/native.views"
) {
    fun init() {
        setMethodCallHandler { call: MethodCall, result ->
            runCatching {
                val arguments = getArgumentsOrNull(call.arguments).orEmpty()
                val userId = getUserIdOrNull(arguments)
                val account = getAccountOrNull(arguments)
                val session = getSessionOrNull(arguments)
                when (call.method) {
                    "native.navigation.login" -> callHandler.startLogin()
                    "native.navigation.signup" -> callHandler.startSignUp()
                    "native.navigation.report" -> callHandler.startReport()
                    "native.navigation.plan.subscription" -> callHandler.startSubscription(
                        getAccountSession(account, session)
                    )

                    "native.navigation.plan.upgrade" -> callHandler.startUpgrade(
                        getAccountSession(account, session)
                    )

                    "native.navigation.user.settings.changepassword" -> callHandler.startChangePassword(
                        getAccountSession(account, session)
                    )

                    "native.navigation.user.settings.recoveryemail" -> callHandler.startUpdateRecoveryEmail(
                        getAccountSession(account, session)
                    )

                    "native.navigation.restartActivity" -> callHandler.restartActivity()
                    "native.navigation.restartApp" -> callHandler.restartApplication()
                    "native.account.logout" -> callHandler.logout(userId)
                }
            }.fold(
                onSuccess = { result.success(null) },
                onFailure = { result.error("code", it.message, null) }
            )
        }
    }

    private fun getAccountSession(
        account: Account?,
        session: Session?,
    ) = AccountSession(
        account = requireNotNull(account),
        session = requireNotNull(session),
    )

    @Suppress("UNCHECKED_CAST")
    private fun getArgumentsOrNull(arguments: Any?): Map<String, String>? = runCatching {
        (arguments as? Map<String, String>) ?:
        (arguments as? ArrayList<*>)?.getOrNull(1) as? Map<String, String> ?:
        Json.decodeFromString<Map<String, String>>(arguments as String)
    }.getOrNull()

    private fun getUserIdOrNull(arguments: Map<String, String>): UserId? =
        arguments["userId"]?.let { UserId(it) }

    private fun getAccountOrNull(arguments: Map<String, String>) = runCatching {
        Account(
            username = arguments["userName"],
            userId = requireNotNull(arguments["userId"]?.let { UserId(it) }),
            email = arguments["userMail"],
            sessionId = requireNotNull(arguments["sessionId"]?.let { SessionId(it) }),
            state = AccountState.Ready,
            sessionState = SessionState.Authenticated,
            details = AccountDetails(null, null)
        )
    }.getOrNull()

    private fun getSessionOrNull(arguments: Map<String, String>) = runCatching {
        Session.Authenticated(
            userId = requireNotNull(arguments["userId"]?.let { UserId(it) }),
            sessionId = requireNotNull(arguments["sessionId"]?.let { SessionId(it) }),
            accessToken = requireNotNull(arguments["accessToken"]),
            refreshToken = requireNotNull(arguments["refreshToken"]),
            scopes = arguments["scopes"]?.split(",").orEmpty(),
        )
    }.getOrNull()
}
