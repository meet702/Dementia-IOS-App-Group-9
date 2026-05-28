import os
import sys

def remove_swift_comments(source):
    result = []
    i = 0
    n = len(source)
    in_multiline = False

    while i < n:
        if in_multiline:
            end = source.find('*/', i)
            if end == -1:
                break  
            i = end + 2
            in_multiline = False
            continue

        if source[i:i+3] == '"""':
            j = i + 3
            result.append('"""')
            while j < n:
                if source[j:j+3] == '"""':
                    result.append('"""')
                    j += 3
                    break
                if source[j] == '\\' and j + 1 < n:
                    result.append(source[j:j+2])
                    j += 2
                else:
                    result.append(source[j])
                    j += 1
            i = j
            continue

        if source[i] == '"':
            result.append('"')
            i += 1
            while i < n and source[i] != '"' and source[i] != '\n':
                if source[i] == '\\' and i + 1 < n:
                    result.append(source[i:i+2])
                    i += 2
                else:
                    result.append(source[i])
                    i += 1
            if i < n and source[i] == '"':
                result.append('"')
                i += 1
            continue

        if source[i:i+2] == '/*':
            in_multiline = True
            i += 2
            continue

        if source[i:i+2] == '//':
            while i < n and source[i] != '\n':
                i += 1
            continue

        result.append(source[i])
        i += 1

    return ''.join(result)


def clean_blank_lines(text):
    lines = [line.rstrip() for line in text.split('\n')]
    cleaned = []
    prev_blank = False
    for line in lines:
        is_blank = (line == '')
        if is_blank:
            if not prev_blank:
                cleaned.append(line)
            prev_blank = True
        else:
            prev_blank = False
            cleaned.append(line)

    while cleaned and cleaned[0] == '':
        cleaned.pop(0)
    while cleaned and cleaned[-1] == '':
        cleaned.pop()

    result = '\n'.join(cleaned)
    if result:
        result += '\n'
    return result


def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()

    stripped = remove_swift_comments(original)
    cleaned = clean_blank_lines(stripped)

    if cleaned != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(cleaned)
        return True
    else:
        return False

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    modified = 0
    total = 0

    for dirpath, dirnames, filenames in os.walk(root):
        if '.git' in dirnames:
            dirnames.remove('.git')
        for fn in sorted(filenames):
            if fn.endswith('.swift'):
                total += 1
                if process_file(os.path.join(dirpath, fn)):
                    modified += 1
    print(f"Done: {modified}/{total} files modified.")

if __name__ == '__main__':
    main()
