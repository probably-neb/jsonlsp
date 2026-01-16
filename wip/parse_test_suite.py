import re
from collections import Counter, OrderedDict


def main() -> None:
    path = "wip/test-suite.log"
    text = open(path, "r", encoding="utf-8", errors="replace").read()

    blocks = re.split(r"(?m)^error: '", text)[1:]
    failures = []
    for b in blocks:
        name, rest = b.split("' failed: Reason:\n", 1)
        m = re.search(
            r"To (REJECT|ACCEPT) Case:\n([\s\S]*?)\nBut it was (ACCEPTED|REJECTED)!",
            rest,
        )
        expectation = None
        instance = None
        result = None
        if m:
            expectation, instance, result = (
                m.group(1),
                m.group(2).strip(),
                m.group(3),
            )
        ms = re.search(
            r"Expected Schema:\n([\s\S]*?)\nTo (REJECT|ACCEPT) Case:",
            rest,
        )
        schema = ms.group(1).strip() if ms else None
        failures.append(
            {
                "name": name.strip(),
                "schema": schema,
                "expectation": expectation,
                "result": result,
                "instance": instance,
            }
        )

    cat_counter = Counter()
    for f in failures:
        parts = f["name"].split(".")
        cat = parts[2] if len(parts) >= 3 else parts[0]
        cat_counter[cat] += 1

    print("total_failures", len(failures))
    print("categories", cat_counter.most_common(60))

    seen = OrderedDict()
    for f in failures:
        parts = f["name"].split(".")
        cat = parts[2] if len(parts) >= 3 else parts[0]
        if cat not in seen:
            seen[cat] = f

    print("\nfirst_failure_per_category:")
    for cat, f in seen.items():
        print(cat, "->", f["name"])


if __name__ == "__main__":
    main()
