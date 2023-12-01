import re

text_digit = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
}


def intstr(x):
    try:
        int(x)
        return x
    except Exception:
        return None


def numify(x):
    if x in text_digit:
        return text_digit[x]
    else:
        return x


def mergedstr(x):
    filtered = [a for a in x if a]
    return int(f"{filtered[0]}{filtered[-1]}")


def part_1(ins):
    foo = []
    for x in ins:
        ints = [intstr(char) for char in list(x)]
        foo.append(mergedstr(ints))

    return sum(foo)


def part_2(ins):
    foo = []
    for x in ins:
        matches = re.findall(
            r"(?=(one|two|three|four|five|six|seven|eight|nine|\d))", x
        )
        digits = [numify(x) for x in [matches[0], matches[-1]]]
        ints = [intstr(char) for char in digits]
        foo.append(mergedstr(ints))
    return sum(foo)
