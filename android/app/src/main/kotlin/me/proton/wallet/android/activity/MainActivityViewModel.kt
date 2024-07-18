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

import androidx.activity.ComponentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import me.proton.wallet.android.channel.AccountSession
import me.proton.wallet.android.channel.FlutterCallHandler
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import me.proton.core.account.domain.entity.Account
import me.proton.core.account.domain.entity.AccountState
import me.proton.core.account.domain.entity.AccountType
import me.proton.core.account.domain.repository.AccountRepository
import me.proton.core.accountmanager.domain.AccountManager
import me.proton.core.accountmanager.domain.getAccounts
import me.proton.core.accountmanager.presentation.observe
import me.proton.core.accountmanager.presentation.onAccountCreateAddressFailed
import me.proton.core.accountmanager.presentation.onAccountCreateAddressNeeded
import me.proton.core.accountmanager.presentation.onAccountReady
import me.proton.core.accountmanager.presentation.onAccountTwoPassModeFailed
import me.proton.core.accountmanager.presentation.onAccountTwoPassModeNeeded
import me.proton.core.accountmanager.presentation.onSessionSecondFactorNeeded
import me.proton.core.auth.presentation.AuthOrchestrator
import me.proton.core.crypto.common.keystore.KeyStoreCrypto
import me.proton.core.crypto.common.keystore.decrypt
import me.proton.core.domain.entity.UserId
import me.proton.core.network.domain.session.SessionId
import me.proton.core.network.domain.session.SessionProvider
import me.proton.core.plan.presentation.PlansOrchestrator
import me.proton.core.report.presentation.ReportOrchestrator
import me.proton.core.user.domain.UserManager
import me.proton.core.user.domain.repository.PassphraseRepository
import me.proton.core.usersettings.presentation.UserSettingsOrchestrator
import javax.inject.Inject

@HiltViewModel
class MainActivityViewModel @Inject constructor(
    private val requiredAccountType: AccountType,
    private val accountManager: AccountManager,
    private val accountRepository: AccountRepository,
    private val userManager: UserManager,
    private val sessionProvider: SessionProvider,
    private val keyStoreCrypto: KeyStoreCrypto,
    private val passphraseRepository: PassphraseRepository,
    private val authOrchestrator: AuthOrchestrator,
    private val plansOrchestrator: PlansOrchestrator,
    private val reportOrchestrator: ReportOrchestrator,
    private val userSettingsOrchestrator: UserSettingsOrchestrator,
) : ViewModel() {

    fun register(context: ComponentActivity, callHandler: FlutterCallHandler) {
        authOrchestrator.register(context)
        plansOrchestrator.register(context)
        reportOrchestrator.register(context)
        userSettingsOrchestrator.register(context)

        disableExistingReadyAccount()

        accountManager.observe(context.lifecycle, Lifecycle.State.CREATED)
            .onAccountReady(initialState = false) { onAccountReady(it, callHandler) }
            .onAccountTwoPassModeFailed { accountManager.disableAccount(it.userId) }
            .onAccountCreateAddressFailed { accountManager.disableAccount(it.userId) }
            .onSessionSecondFactorNeeded { authOrchestrator.startSecondFactorWorkflow(it) }
            .onAccountTwoPassModeNeeded { authOrchestrator.startTwoPassModeWorkflow(it) }
            .onAccountCreateAddressNeeded { authOrchestrator.startChooseAddressWorkflow(it) }
    }

    private fun disableExistingReadyAccount() = viewModelScope.launch {
        accountManager.getAccounts(AccountState.Ready).first().forEach {
            disableAccountSession(it.userId, it.sessionId)
        }
    }

    private suspend fun disableAccountSession(userId: UserId, sessionId: SessionId?) {
        sessionId?.let { accountRepository.deleteSession(it) }
        accountManager.disableAccount(userId)
    }

    private suspend fun onAccountReady(account: Account, callHandler: FlutterCallHandler) {
        val user = userManager.getUser(account.userId)
        val sessionId = sessionProvider.getSessionId(user.userId)
        val session = sessionProvider.getSession(sessionId) ?: return
        val passphrase = passphraseRepository.getPassphrase(user.userId)?.decrypt(keyStoreCrypto)
        when {
            // Parent session ?
            session.scopes.map { it.lowercase() }.contains("parent") -> {
                // Drop from Core.
                disableAccountSession(user.userId, requireNotNull(sessionId))
                // Forward to Flutter.
                callHandler.navigateHome(user, session, requireNotNull(passphrase))
            }
            // Child session: will be dropped on next app creation.
            else -> Unit
        }
    }

    private suspend fun addOrUpdateAccount(accountSession: AccountSession): UserId {
        // Remove any existing session, without revoking.
        sessionProvider.getSessions().forEach { accountRepository.deleteSession(it.sessionId) }
        accountManager.addAccount(accountSession.account, accountSession.session)
        return accountSession.account.userId
    }

    fun startLogin() {
        authOrchestrator.startLoginWorkflow(requiredAccountType)
    }

    fun startSignUp() {
        authOrchestrator.startSignupWorkflow(requiredAccountType)
    }

    fun startSubscription(accountSession: AccountSession) = viewModelScope.launch {
        addOrUpdateAccount(accountSession)
        plansOrchestrator.showCurrentPlanWorkflow(accountSession.account.userId)
    }

    fun startUpgrade(accountSession: AccountSession) = viewModelScope.launch {
        addOrUpdateAccount(accountSession)
        plansOrchestrator.startUpgradeWorkflow(accountSession.account.userId)
    }

    fun startReport() = viewModelScope.launch {
        reportOrchestrator.startBugReport()
    }

    fun startPasswordManagement(accountSession: AccountSession) = viewModelScope.launch {
        addOrUpdateAccount(accountSession)
        userSettingsOrchestrator.startPasswordManagementWorkflow(accountSession.account.userId)
    }

    fun startUpdateRecoveryEmail(accountSession: AccountSession) = viewModelScope.launch {
        addOrUpdateAccount(accountSession)
        userSettingsOrchestrator.startUpdateRecoveryEmailWorkflow(accountSession.account.userId)
    }

    fun logout(userId: UserId?) = viewModelScope.launch {
        userId ?: accountManager.getPrimaryUserId().firstOrNull()?.let {
            accountManager.removeAccount(it)
        }
    }
}
