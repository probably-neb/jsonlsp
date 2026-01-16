import json
import re
from collections import Counter, OrderedDict
from dataclasses import dataclass
from typing import Iterable, List, Optional


@dataclass
class Failure:
    name: str
    schema: Optional[str]
    expectation: Optional[str]
    result: Optional[str]
    instance: Optional[str]


@dataclass
class CategorySummary:
    category: str
    count: int
    example: Failure


def parse_failures(log_text: str) -> List[Failure]:
    blocks = re.split(r"(?m)^error: '", log_text)[1:]
    failures: List[Failure] = []
    for block in blocks:
        name, rest = block.split("' failed: Reason:\n", 1)

        expected_schema = None
        schema_match = re.search(
            r"Expected Schema:\n([\s\S]*?)\nTo (REJECT|ACCEPT) Case:",
            rest,
        )
        if schema_match:
            expected_schema = schema_match.group(1).strip()

        case_match = re.search(
            r"To (REJECT|ACCEPT) Case:\n([\s\S]*?)\nBut it was (ACCEPTED|REJECTED)!",
            rest,
        )
        expectation = None
        instance = None
        result = None
        if case_match:
            expectation = case_match.group(1)
            instance = case_match.group(2).strip()
            result = case_match.group(3)

        failures.append(
            Failure(
                name=name.strip(),
                schema=expected_schema,
                expectation=expectation,
                result=result,
                instance=instance,
            )
        )

    return failures


def category_for_failure(failure: Failure) -> str:
    parts = failure.name.split(".")
    if len(parts) >= 3:
        return parts[2]
    return parts[0]


def summarize_failures(failures: Iterable[Failure]) -> List[CategorySummary]:
    counts: Counter = Counter()
    first_by_category: OrderedDict[str, Failure] = OrderedDict()
    for failure in failures:
        category = category_for_failure(failure)
        counts[category] += 1
        if category not in first_by_category:
            first_by_category[category] = failure

    summaries = [
        CategorySummary(
            category=cat, count=counts[cat], example=first_by_category[cat]
        )
        for cat in counts
    ]
    summaries.sort(key=lambda item: item.count, reverse=True)
    return summaries


def summarize_failure(failure: Failure) -> str:
    expectation = failure.expectation or "REJECT"
    result = failure.result or "ACCEPTED"
    if expectation == "REJECT" and result == "ACCEPTED":
        return "Expected rejection, but it was accepted."
    if expectation == "ACCEPT" and result == "REJECTED":
        return "Expected acceptance, but it was rejected."
    return f"Mismatch between expected {expectation} and observed {result.lower()}."


def format_checklist(summaries: Iterable[CategorySummary]) -> str:
    lines = []
    lines.append("# JSON Schema test suite failures")
    lines.append("")
    lines.append(
        "Checklist of features/bug fixes derived from test suite failures."
    )
    lines.append("")
    for summary in summaries:
        example = summary.example.name
        short_summary = summarize_failure(summary.example)
        lines.append(
            f"- [ ] `{summary.category}` ({summary.count}) — example: `{example}` — {short_summary}"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="Format JSON Schema test suite failures into markdown."
    )
    parser.add_argument(
        "log_path",
        nargs="?",
        default="wip/test-suite.log",
        help="Path to test suite log file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        default="src/json-schema/failures.md",
        help="Output markdown file path.",
    )
    parser.add_argument(
        "--json",
        dest="json_path",
        default=None,
        help="Optional path to write raw failure data as JSON.",
    )
    args = parser.parse_args()

    log_text = open(
        args.log_path, "r", encoding="utf-8", errors="replace"
    ).read()
    failures = parse_failures(log_text)
    summaries = summarize_failures(failures)

    markdown = format_checklist(summaries)
    with open(args.output, "w", encoding="utf-8") as handle:
        handle.write(markdown)

    if args.json_path:
        payload = [
            {
                "name": failure.name,
                "schema": failure.schema,
                "expectation": failure.expectation,
                "result": failure.result,
                "instance": failure.instance,
                "category": category_for_failure(failure),
            }
            for failure in failures
        ]
        with open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2)


if __name__ == "__main__":
    main()
