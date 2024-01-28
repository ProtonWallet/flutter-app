use serde::{de, Deserialize, Deserializer};
use serde::de::DeserializeOwned;
use serde_json::{Map, Value};

pub(crate) fn case_insensitive<'de, T, D>(deserializer: D) -> Result<T, D::Error>
    where T: DeserializeOwned,
          D: Deserializer<'de>
{
    let map = Map::<String, Value>::deserialize(deserializer)?;
    let lower = map.into_iter().map(|(k, v)| (k.to_lowercase(), v)).collect();
    T::deserialize(Value::Object(lower)).map_err(de::Error::custom)
}