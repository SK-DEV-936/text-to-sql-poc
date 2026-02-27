import re

def test_regex():
    text = "SELECT * FROM merchants LIMIT 500"
    def _replace_limit(match):
        print("Matched:", match.groups())
        prefix = match.group(1)
        current_limit = int(match.group(2))
        new_limit = min(current_limit, 100)
        return f"{prefix}{new_limit}"
    text = re.sub(r"(limit\s+)(\d+)", _replace_limit, text, flags=re.IGNORECASE)
    print(text)
