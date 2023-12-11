/*
 * Copyright (c) 2020 Proton Technologies AG
 * This file is part of Proton Technologies AG and ProtonCore.
 *
 * ProtonCore is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ProtonCore is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.example.wallet.api

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import me.proton.core.network.data.protonApi.BaseRetrofitApi
import me.proton.core.network.data.protonApi.GenericResponse
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.PUT

interface CoreExampleApi : BaseRetrofitApi {

    @GET("internal/tests/humanverification")
    suspend fun triggerHumanVerification(): GenericResponse

    @GET("core/v4/keys/salts")
    suspend fun triggerConfirmPasswordLockedScope(): GenericResponse

    @GET("core/v4/settings/mnemonic")
    suspend fun triggerConfirmPasswordForPasswordScope(): GenericResponse

    @PUT("mail/v4/messages/read")
    suspend fun markAsRead(@Body request: MarkAsReadRequest): GenericResponse

    @Serializable
    class MarkAsReadRequest(
        @SerialName("IDs")
        val ids: List<String>,
    )
}
