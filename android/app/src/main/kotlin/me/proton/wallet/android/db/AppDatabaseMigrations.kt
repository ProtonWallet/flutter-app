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

package me.proton.wallet.android.db

import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import me.proton.core.account.data.db.AccountDatabase
import me.proton.core.eventmanager.data.db.EventMetadataDatabase
import me.proton.core.key.data.db.PublicAddressDatabase
import me.proton.core.payment.data.local.db.PaymentDatabase
import me.proton.core.user.data.db.UserKeyDatabase
import me.proton.core.userrecovery.data.db.DeviceRecoveryDatabase
import me.proton.core.usersettings.data.db.UserSettingsDatabase

object AppDatabaseMigrations {

    val MIGRATION_1_2 = object : Migration(1, 2) {
        override fun migrate(db: SupportSQLiteDatabase) {
            PaymentDatabase.MIGRATION_1.migrate(db)
            UserSettingsDatabase.MIGRATION_6.migrate(db)
        }
    }

    val MIGRATION_2_3 = object : Migration(2, 3) {
        override fun migrate(db: SupportSQLiteDatabase) {
            DeviceRecoveryDatabase.MIGRATION_0.migrate(db)
            DeviceRecoveryDatabase.MIGRATION_1.migrate(db)
            UserKeyDatabase.MIGRATION_1.migrate(db)
        }
    }

    val MIGRATION_3_4 = object : Migration(3, 4) {
        override fun migrate(db: SupportSQLiteDatabase) {
            AccountDatabase.MIGRATION_8.migrate(db)
            UserSettingsDatabase.MIGRATION_7.migrate(db)
            PublicAddressDatabase.MIGRATION_3.migrate(db)
            EventMetadataDatabase.MIGRATION_3.migrate(db)
        }
    }
}
