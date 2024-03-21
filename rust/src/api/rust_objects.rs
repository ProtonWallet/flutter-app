pub struct MyTestObject {
    //    pub dir: ProtonAPIService,
}

impl MyTestObject {
    pub fn new() -> MyTestObject {
        MyTestObject {
            // dir: ProtonAPIService::default(),
        }
    }

    // pub fn directory_path(&self) -> String {
    //     self.dir.test()
    // }

    pub fn read_text(&self) -> String {
        // self.dir.test()
        "Hello World".to_string()
    }
}

impl Default for MyTestObject {
    fn default() -> Self {
        Self::new()
    }
}
