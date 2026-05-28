import os
import sys
import emoji

def remove_emojis_from_line(line):
    # Remove all emojis using the emoji library
    line = emoji.replace_emoji(line, replace='')
    # Fix up empty spaces left in quotes
    line = line.replace('print(" ', 'print("')
    line = line.replace('print("  ', 'print("')
    return line

def is_unnecessary_print(line):
    lower_line = line.lower()
    if 'print(' not in lower_line:
        return False
        
    # Necessary prints typically contain "error" or "failed"
    if 'error' in lower_line or 'failed' in lower_line or 'guard' in lower_line or 'catch' in lower_line:
        return False
        
    # Almost all other prints are debugging traces
    return True

def clean_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    new_lines = []
    modified = False
    
    for line in lines:
        if 'print(' in line:
            if is_unnecessary_print(line):
                modified = True
                continue
                
            # If keeping it, make sure it has no emojis
            cleaned_line = remove_emojis_from_line(line)
            if cleaned_line != line:
                modified = True
                line = cleaned_line
                
        new_lines.append(line)
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        return True
    return False

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    count = 0
    for dirpath, _, filenames in os.walk(root):
        if '.git' in dirpath:
            continue
        for fn in filenames:
            if fn.endswith('.swift'):
                if clean_file(os.path.join(dirpath, fn)):
                    count += 1
    print(f"Modified {count} files.")

if __name__ == '__main__':
    main()
