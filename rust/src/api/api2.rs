
pub fn add_one(left: usize, right: usize) -> usize {
    left + right
}


pub fn add_three(left: usize, right: usize) -> usize {
    left + right
}


#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn helloworld() -> String {
    format!("Hello, world Test111!")
}
