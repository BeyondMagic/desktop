def colorize_parentheses(text: str) -> str:
    # 16 terminal colors (Standard, High-Intensity, and 256-color palette extensions)
    colors = [
        "\033[31m", "\033[32m", "\033[33m", "\033[34m", "\033[35m", "\033[36m", "\033[90m", "\033[91m",
        "\033[92m", "\033[93m", "\033[94m", "\033[95m", "\033[96m", "\033[38;5;208m", "\033[38;5;135m", "\033[38;5;45m"
    ]
    reset = "\033[0m"
    
    stack = []
    chars = list(text)
    color_counter = 0
    
    for i, char in enumerate(chars):
        if char == '(':
            # Select the next color and keep track of it
            current_color = colors[color_counter % 16]
            chars[i] = f"{current_color}({reset}"
            stack.append(current_color)
            color_counter += 1
            
        elif char == ')':
            if stack:
                # Pop the matching color from the stack to pair them
                matching_color = stack.pop()
                chars[i] = f"{matching_color}){reset}"
            else:
                # Leave unmatched closing parentheses uncolored
                pass
                
    return "".join(chars)

# Example Usage:
print(colorize_parentheses(input()))
