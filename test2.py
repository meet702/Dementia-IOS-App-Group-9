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

print(remove_swift_comments('print("❌ No caregiverUid — user not logged in")'))
