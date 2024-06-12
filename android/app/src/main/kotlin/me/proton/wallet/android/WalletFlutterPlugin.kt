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

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object WalletFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    // init {
    //     System.loadLibrary("proton_wallet_common")
    // }

    external fun init_android(ctx: Context): Boolean

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // val ret = init_android(binding.applicationContext)
        // println("JNI init_android returned $ret")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {}
}
