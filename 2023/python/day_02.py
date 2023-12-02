import re
from collections import defaultdict


def input_reader():
    with open("inputs/day_02.txt") as f:
        lines = f.readlines()

    return {
        int(line.split(":")[0].lstrip("Game ")): [
            x.strip() for x in line.split(":")[1].split(";")
        ]
        for line in lines
    }


def part_1():
    games_dict = input_reader()

    for k, v in games_dict.items():
        grabs = [
            {b: int(a) for a, b in re.findall(r"(\d+) (red|green|blue)", grab)}
            for grab in v
        ]

        grabs = [
            grab
            for grab in grabs
            if grab.get("red", 0) > 12
            or grab.get("green", 0) > 13
            or grab.get("blue", 0) > 14
        ]

        games_dict[k] = grabs

    return sum([k for k, v in games_dict.items() if not v])


def part_2():
    games_dict = input_reader()

    sum = 0
    for k, v in games_dict.items():
        grabs = [
            {b: int(a) for a, b in re.findall(r"(\d+) (red|green|blue)", grab)}
            for grab in v
        ]

        max_vals = defaultdict(int)
        for grab in grabs:
            max_vals["green"] = max(grab.get("green", 0), max_vals["green"])
            max_vals["red"] = max(grab.get("red", 0), max_vals["red"])
            max_vals["blue"] = max(grab.get("blue", 0), max_vals["blue"])

        a, b, c = max_vals.values()
        sum += a * b * c

    return sum


if __name__ == "__main__":
    print(part_1())
    print(part_2())
