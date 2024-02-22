use andromeda_common::Network as BdkNetwork;

#[derive(Debug, Clone, Default)]
///The cryptocurrency to act on
pub enum Network {
    ///Bitcoin’s testnet
    #[default]
    Testnet,
    ///Bitcoin’s regtest
    Regtest,
    ///Classic Bitcoin
    Bitcoin,
    ///Bitcoin’s signet
    Signet,
}

impl From<Network> for BdkNetwork {
    fn from(network: Network) -> Self {
        match network {
            Network::Signet => BdkNetwork::Signet,
            Network::Testnet => BdkNetwork::Testnet,
            Network::Regtest => BdkNetwork::Regtest,
            Network::Bitcoin => BdkNetwork::Bitcoin,
        }
    }
}

impl From<BdkNetwork> for Network {
    fn from(network: BdkNetwork) -> Self {
        match network {
            BdkNetwork::Signet => Network::Signet,
            BdkNetwork::Testnet => Network::Testnet,
            BdkNetwork::Regtest => Network::Regtest,
            BdkNetwork::Bitcoin => Network::Bitcoin,
        }
    }
}
