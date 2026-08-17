// Waffle Cat editor QA: Rust
#[derive(Debug, Clone)]
struct Palette<'a> {
    name: &'a str,
    colors: Vec<&'a str>,
}

impl<'a> Palette<'a> {
    fn bright_count(&self) -> usize {
        self.colors.iter().filter(|color| color.starts_with("#e")).count()
    }
}

fn main() -> Result<(), &'static str> {
    let palette = Palette {
        name: "Waffle Cat",
        colors: vec!["#cf7358", "#9fad68", "#c87d2a"],
    };
    println!("{} has {} bright accents", palette.name, palette.bright_count());
    Ok(())
}
