
import asyncio
import re

def _sanitize_text(text: str) -> str:
    """Copy of the sanitization logic from LlmWatcherAgent for verification."""
    if not text:
        return text
        
    # 1. Remove common prefixes
    prefixes_to_remove = [
        r"^Correction:\s*",
        r"^Revised summary:\s*",
        r"^Updated summary:\s*",
        r"^Fixed summary:\s*",
        r"^The corrected response is:\s*",
        r"^The total revenue is actually:\s*",
        r"^Actually,\s+",
        r"^However,\s+",
        r"^Here is the corrected response:\s*"
    ]
    
    sanitized = text
    for pattern in prefixes_to_remove:
        sanitized = re.sub(pattern, "", sanitized, flags=re.IGNORECASE)
        
    # 2. replace special asterisk
    sanitized = sanitized.replace("∗", "*")
    
    # 3. FORCE SPACES around double asterisks (markdown bold)
    sanitized = re.sub(r'(\*\*[^*]+\*\*)', r' \1 ', sanitized)
    
    # 4. Ensure no double spaces
    sanitized = re.sub(r'(?<!\*)\s{2,}(?!\*)', ' ', sanitized)
    
    return sanitized.strip()

def test_sanitization():
    test_cases = [
        {
            "input": "Today's total revenue across all restaurants reached 12,938.00**fromatotalof**240orders**.Thecorrecttotalrevenueis**12,938.00",
            "expected": "Today's total revenue across all restaurants reached 12,938.00 **fromatotalof** 240orders **.Thecorrecttotalrevenueis** 12,938.00"
        },
        {
            "input": "Actually, the total revenue is **$12,938.00**",
            "expected": "the total revenue is **$12,938.00**"
        },
        {
            "input": "The total revenue is actually: **$12,938.00**",
            "expected": "**$12,938.00**"
        }
    ]
    
    for i, tc in enumerate(test_cases):
        actual = _sanitize_text(tc['input'])
        print(f"Test {i+1}:")
        print(f"  Input:    {tc['input']}")
        print(f"  Actual:   {actual}")
        # Note: 'fromatotalof' is still smushed inside, but the asterisks are spaced.
        # However, the goal is to make it readable.
        
if __name__ == "__main__":
    test_sanitization()
