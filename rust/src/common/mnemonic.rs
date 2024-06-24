// mnemonic.rs
// use andromeda_bitcoin::BdkLanguage;

pub enum FrbLanguage {
    English,
    SimplifiedChinese,
    TraditionalChinese,
    Czech,
    French,
    Italian,
    Japanese,
    Korean,
    Spanish,
}

// impl From<FrbLanguage> for BdkLanguage {
//     fn from(value: FrbLanguage) -> Self {
//         match value {
//             _ => BdkLanguage::English,
//         }
//     }
// }
