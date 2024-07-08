package me.proton.core.configuration;

import me.proton.wallet.android.BuildConfig;

public class EnvironmentConfigurationDefaults {
    public static final String host = BuildConfig.WALLET_HOST;
    public static final String proxyToken = "";
    public static final String apiPrefix = "wallet-api";
    public static final String baseUrl = "https://wallet-api." + host;
    public static final String apiHost = "wallet-api." + host;
    public static final String hv3Host = "verify." + host;
    public static final String hv3Url = "https://verify." + host;
    public static final Boolean useDefaultPins = false;
}
