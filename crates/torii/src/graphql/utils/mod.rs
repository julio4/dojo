pub mod extract_value;
pub mod value_accessor;

pub fn remove_quotes(s: &str) -> String {
    s.replace(&['\"', '\''][..], "")
}

pub fn format_name(input: &str) -> (String, String) {
    let name = input.to_lowercase();
    let type_name = input.to_string();
    (name, type_name)
}

pub fn csv_to_vec(csv: &str) -> Vec<String> {
    csv.split(',').map(|s| s.trim().to_string()).collect()
}
