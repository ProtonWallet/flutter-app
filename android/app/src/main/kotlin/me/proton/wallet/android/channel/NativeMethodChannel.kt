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
import me.proton.wallet.android.LogTag
import me.proton.wallet.android.WalletLogger

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
    fun setWalletApiClientHeader(versionHeader: VersionHeader)
}

data class AccountSession(
    val account: Account,
    val session: Session
)

data class VersionHeader(
    val version: String?,
    val agent: String?
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
                    "native.initialize.core.environment" -> callHandler.setWalletApiClientHeader(
                        getVersionHeader(arguments)
                    )
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
                onSuccess = {
                    result.success(null)
                },
                onFailure = {
                    WalletLogger.e(LogTag.CHANNEL_NATIVE, it)
                    result.error("code", it.message, null)
                }
            )
        }
    }

    private fun getVersionHeader(arguments: Map<String, Any>): VersionHeader {
        val appVersionKey = "app-version"
        val userAgentKey = "user-agent"
        return VersionHeader(
            version = arguments[appVersionKey] as String?,
            agent = arguments[userAgentKey] as String?,
        )
    }

    private fun getAccountSession(
        account: Account?,
        session: Session?,
    ) = AccountSession(
        account = requireNotNull(account),
        session = requireNotNull(session),
    )

    @Suppress("UNCHECKED_CAST")
    private fun getArgumentsOrNull(arguments: Any?): Map<String, Any>? = runCatching {
        (arguments as? Map<String, String>) ?:
        (arguments as? ArrayList<*>)?.getOrNull(1) as? Map<String, Any> ?:
        Json.decodeFromString<Map<String, Any>>(arguments as String)
    }.getOrNull()

    private fun getUserIdOrNull(arguments: Map<String, Any>): UserId? = runCatching {
        arguments["userId"]?.let { UserId(it as String) }
    }.getOrNull()

    private fun getSessionIdOrNull(arguments: Map<String, Any>): SessionId? = runCatching {
        arguments["sessionId"]?.let { SessionId(it as String) }
    }.getOrNull()

    private fun getAccountOrNull(arguments: Map<String, Any>) = runCatching {
        Account(
            username = arguments["userName"] as String?,
            userId = requireNotNull(getUserIdOrNull(arguments)),
            email = arguments["userMail"] as String?,
            sessionId = requireNotNull(getSessionIdOrNull(arguments)),
            state = AccountState.Ready,
            sessionState = SessionState.Authenticated,
            details = AccountDetails(null, null)
        )
    }.onFailure {
        WalletLogger.e(LogTag.CHANNEL_NATIVE, it)
    }.getOrNull()

    @Suppress("UNCHECKED_CAST")
    private fun getSessionOrNull(arguments: Map<String, Any>) = runCatching {
        Session.Authenticated(
            userId = requireNotNull(getUserIdOrNull(arguments)),
            sessionId = requireNotNull(getSessionIdOrNull(arguments)),
            accessToken = requireNotNull(arguments["accessToken"] as String),
            refreshToken = requireNotNull(arguments["refreshToken"] as String),
            scopes = arguments["scopes"] as ArrayList<String>,
        )
    }.onFailure {
        WalletLogger.e(LogTag.CHANNEL_NATIVE, it)
    }.getOrNull()
}
