#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, cast

ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "learnjsonschema"
SITEMAP_URL = "https://www.learnjsonschema.com/sitemap.xml"
UPSTREAM_RAW_BASE = "https://raw.githubusercontent.com/sourcemeta/learnjsonschema.com/main/content"
UPSTREAM_API_BASE = "https://api.github.com/repos/sourcemeta/learnjsonschema.com/contents/content"
SITE_BASE = "https://www.learnjsonschema.com"
DIALECTS = ["2020-12", "2019-09", "draft7", "draft6", "draft4", "draft3"]


def fetch_text(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "jsonls-learnjsonschema-generator"})
    with urllib.request.urlopen(request) as response:
        return response.read().decode("utf-8")


def fetch_json(url: str) -> object:
    return json.loads(fetch_text(url))


@dataclass(frozen=True)
class Page:
    url: str
    dialect: str
    rel_path: str
    source_url: str

    @property
    def output_path(self) -> Path:
        return OUTPUT_ROOT / self.dialect / self.rel_path / "index.md"

    @property
    def title_hint(self) -> str:
        parts = [part for part in self.rel_path.split("/") if part]
        if not parts:
            return self.dialect
        return parts[-1]


def normalize_route_segment(value: str) -> str:
    return value.lower()


def build_source_lookup() -> dict[str, str]:
    lookup: dict[str, str] = {}
    for dialect in DIALECTS:
        dialect_entries = fetch_json(f"{UPSTREAM_API_BASE}/{dialect}")
        if not isinstance(dialect_entries, list):
            raise RuntimeError(f"Unexpected GitHub API response for dialect {dialect}")

        for entry_value in dialect_entries:
            if not isinstance(entry_value, dict):
                continue
            entry = cast(dict[str, Any], entry_value)
            entry_name = entry.get("name")
            entry_type = entry.get("type")
            if entry_name == "_index.markdown" and entry_type == "file":
                lookup[dialect] = str(entry.get("download_url"))
                continue
            if entry_type != "dir":
                continue

            vocabulary = str(entry_name)
            vocabulary_route = f"{dialect}/{vocabulary}"
            vocabulary_entries = fetch_json(f"{UPSTREAM_API_BASE}/{dialect}/{vocabulary}")
            if not isinstance(vocabulary_entries, list):
                raise RuntimeError(f"Unexpected GitHub API response for vocabulary {vocabulary_route}")

            for vocabulary_entry_value in vocabulary_entries:
                if not isinstance(vocabulary_entry_value, dict):
                    continue
                vocabulary_entry = cast(dict[str, Any], vocabulary_entry_value)
                vocabulary_name = str(vocabulary_entry.get("name"))
                vocabulary_type = vocabulary_entry.get("type")
                if vocabulary_name == "_index.markdown" and vocabulary_type == "file":
                    lookup[vocabulary_route] = str(vocabulary_entry.get("download_url"))
                    continue
                if vocabulary_type != "file" or not vocabulary_name.endswith(".markdown"):
                    continue
                keyword_stem = vocabulary_name[: -len(".markdown")]
                keyword_route = f"{vocabulary_route}/{normalize_route_segment(keyword_stem)}"
                lookup[keyword_route] = str(vocabulary_entry.get("download_url"))
    return lookup


def parse_sitemap(xml: str, source_lookup: dict[str, str]) -> list[Page]:
    urls = re.findall(r"<loc>(.*?)</loc>", xml)
    pages: list[Page] = []
    for url in urls:
        for dialect in DIALECTS:
            prefix = f"{SITE_BASE}/{dialect}/"
            if not url.startswith(prefix):
                continue
            rel = url[len(prefix) :].strip("/")
            route = "/".join(part for part in [dialect, rel] if part)
            source_url = source_lookup.get(route)
            if source_url is None:
                raise RuntimeError(f"No upstream source found for {url} ({route})")
            pages.append(Page(url=url, dialect=dialect, rel_path=rel, source_url=source_url))
            break
    pages.sort(key=lambda page: (DIALECTS.index(page.dialect), page.rel_path))
    return pages


def split_front_matter(text: str) -> tuple[str, str]:
    if not text.startswith("---\n"):
        return "", text
    parts = text.split("\n---\n", 1)
    if len(parts) != 2:
        return "", text
    return parts[0][4:], parts[1]


def parse_scalar(front_matter: str, key: str) -> str | None:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*(.+)$", front_matter)
    if not match:
        return None
    value = match.group(1).strip()
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    return value


def slug_to_title(slug: str) -> str:
    if slug == "meta-data":
        return "Meta Data"
    if slug == "format-annotation":
        return "Format Annotation"
    if slug == "format-assertion":
        return "Format Assertion"
    mapping = {
        "draft7": "Draft 7",
        "draft6": "Draft 6",
        "draft4": "Draft 4",
        "draft3": "Draft 3",
        "2019-09": "2019-09",
        "2020-12": "2020-12",
    }
    if slug in mapping:
        return mapping[slug]
    return " ".join(part.capitalize() for part in slug.split("-"))


def route_to_output(route: str) -> str:
    route = route.strip("/")
    if not route:
        return "index.md"
    return "/".join(route.split("/")) + "/index.md"


def relative_link(from_path: Path, target_route: str) -> str:
    target_path = OUTPUT_ROOT / route_to_output(target_route)
    return __import__("os").path.relpath(target_path, from_path.parent).replace("\\", "/")


def replace_ref_shortcodes(body: str, current_route: str, output_path: Path) -> str:
    def replacer(match: re.Match[str]) -> str:
        route = match.group(1).strip().strip('"').strip("'")
        return relative_link(output_path, route)

    return re.sub(r"\{\{<\s*ref\s+([^>]+?)\s*>\}\}", replacer, body, flags=re.DOTALL)


def parse_link_shortcode_arguments(argument_text: str) -> dict[str, str]:
    arguments: dict[str, str] = {}
    for key, value in re.findall(r'(\w+)\s*=\s*"([^"]+)"', argument_text):
        arguments[key] = value
    return arguments


def replace_link_shortcodes(body: str, current_route: str, output_path: Path) -> str:
    current_parts = [part for part in current_route.split("/") if part]
    current_dialect = current_parts[0] if current_parts else ""
    current_vocabulary = current_parts[1] if len(current_parts) > 1 else ""

    def replacer(match: re.Match[str]) -> str:
        arguments = parse_link_shortcode_arguments(match.group(1))
        keyword = arguments.get("keyword", "link")
        dialect = arguments.get("dialect", current_dialect)
        vocabulary = arguments.get("vocabulary", current_vocabulary)
        route = "/".join(part for part in [dialect, vocabulary, slugify_keyword(keyword)] if part)
        link = relative_link(output_path, route)
        return f"[`{keyword}`]({link})"

    return re.sub(r"\{\{<\s*link\s+(.+?)\s*>\}\}", replacer, body)


def slugify_keyword(keyword: str) -> str:
    stripped = keyword.strip()
    if stripped.startswith("$"):
        stripped = stripped[1:]
    return stripped.replace("$", "").replace("_", "").replace(" ", "").replace("-", "").lower()


def replace_constraint_warning(body: str, current_route: str, output_path: Path) -> str:
    current_parts = [part for part in current_route.split("/") if part]
    type_route = "/".join(part for part in [current_parts[0], current_parts[1] if len(current_parts) > 1 else "", "type"] if part)
    type_link = relative_link(output_path, type_route)

    def replacer(match: re.Match[str]) -> str:
        target_type = match.group(1)
        return (
            f"> **Type constraint:** Non-`{target_type}` instances also validate against this keyword. "
            f"Use [`type`]({type_link}) if you need to restrict the accepted type."
        )

    return re.sub(r"\{\{<\s*constraint-warning\s+[`\"]([^`\"]+)[`\"]\s*>\}\}", replacer, body)


def replace_admonitions(body: str) -> str:
    labels = {
        "best-practice": "Best Practice",
        "common-pitfall": "Common Pitfall",
        "learning-more": "Digging Deeper",
    }
    for shortcode, label in labels.items():
        pattern = re.compile(rf"\{{\{{<\s*{re.escape(shortcode)}\s*>\}}\}}(.*?)\{{\{{</\s*{re.escape(shortcode)}\s*>\}}\}}", re.DOTALL)

        def replacer(match: re.Match[str], heading: str = label) -> str:
            inner = match.group(1).strip("\n")
            lines = [f"> **{heading}:**"]
            for line in inner.splitlines():
                lines.append(">" if not line.strip() else f"> {line}")
            return "\n".join(lines)

        body = pattern.sub(replacer, body)
    return body


def replace_example_blocks(body: str) -> str:
    variants = {
        "schema": "Schema",
        "instance-pass": "Valid instance",
        "instance-fail": "Invalid instance",
        "instance-annotation": "Annotation",
    }
    for shortcode, heading in variants.items():
        pattern = re.compile(
            rf"\{{\{{<\s*{re.escape(shortcode)}(?:\s+[`\"]([^`\"]+)[`\"])?\s*>\}}\}}\s*(.*?)\s*\{{\{{<\s*/\s*{re.escape(shortcode)}\s*>\}}\}}",
            re.DOTALL,
        )

        def replacer(match: re.Match[str], prefix: str = heading) -> str:
            caption = match.group(1)
            code = match.group(2).strip("\n")
            heading_line = f"### {prefix}"
            if caption:
                heading_line += f": {caption}"
            return f"{heading_line}\n\n```json\n{code}\n```"

        body = pattern.sub(replacer, body)
    return body


def clean_body(body: str, current_route: str, output_path: Path) -> str:
    body = replace_ref_shortcodes(body, current_route, output_path)
    body = replace_link_shortcodes(body, current_route, output_path)
    body = replace_constraint_warning(body, current_route, output_path)
    body = replace_admonitions(body)
    body = replace_example_blocks(body)
    body = re.sub(r"\n{3,}", "\n\n", body).strip() + "\n"
    return body


def read_generated_title(path: Path) -> str:
    if not path.exists():
        return slug_to_title(path.parent.name)
    with path.open(encoding="utf-8") as file:
        first_line = file.readline().strip()
    if first_line.startswith("# "):
        return first_line[2:]
    return slug_to_title(path.parent.name)


def build_index_pages(pages: Iterable[Page]) -> None:
    by_dialect: dict[str, list[Page]] = {dialect: [] for dialect in DIALECTS}
    for page in pages:
        by_dialect[page.dialect].append(page)

    root_lines = [
        "# Learn JSON Schema index",
        "",
        "Generated from [learnjsonschema.com](https://www.learnjsonschema.com/) with backlinks to the original pages.",
        "",
        "## Dialects",
        "",
    ]
    for dialect in DIALECTS:
        root_lines.append(f"- [{slug_to_title(dialect)}]({dialect}/index.md)")
    root_lines.append("")
    (OUTPUT_ROOT / "index.md").write_text("\n".join(root_lines), encoding="utf-8")

    for dialect, dialect_pages in by_dialect.items():
        vocabulary_groups: dict[str, list[Page]] = {}
        for page in dialect_pages:
            parts = [part for part in page.rel_path.split("/") if part]
            if not parts:
                continue
            vocabulary = parts[0]
            vocabulary_groups.setdefault(vocabulary, []).append(page)

        lines = [
            f"# {slug_to_title(dialect)}",
            "",
            f"- Original: [{SITE_BASE}/{dialect}/]({SITE_BASE}/{dialect}/)",
            f"- Upstream source: [{UPSTREAM_RAW_BASE}/{dialect}/_index.markdown]({UPSTREAM_RAW_BASE}/{dialect}/_index.markdown)",
            "",
            "## Vocabularies",
            "",
        ]
        for vocabulary in sorted(vocabulary_groups):
            lines.append(f"- [{slug_to_title(vocabulary)}]({vocabulary}/index.md)")
        lines.append("")
        dialect_index = OUTPUT_ROOT / dialect / "index.md"
        dialect_index.parent.mkdir(parents=True, exist_ok=True)
        dialect_index.write_text("\n".join(lines), encoding="utf-8")

        for vocabulary, vocabulary_pages in vocabulary_groups.items():
            vocab_lines = [
                f"# {slug_to_title(vocabulary)}",
                "",
                f"- Dialect: [{slug_to_title(dialect)}](../index.md)",
                f"- Original: [{SITE_BASE}/{dialect}/{vocabulary}/]({SITE_BASE}/{dialect}/{vocabulary}/)",
                f"- Upstream source: [{UPSTREAM_RAW_BASE}/{dialect}/{vocabulary}/_index.markdown]({UPSTREAM_RAW_BASE}/{dialect}/{vocabulary}/_index.markdown)",
                "",
                "## Pages",
                "",
            ]
            keyword_pages = [page for page in vocabulary_pages if page.rel_path != vocabulary]
            for page in sorted(keyword_pages, key=lambda item: item.rel_path):
                title = read_generated_title(page.output_path)
                vocab_lines.append(f"- [{title}]({page.title_hint}/index.md)")
            vocab_lines.append("")
            vocab_index = OUTPUT_ROOT / dialect / vocabulary / "index.md"
            vocab_index.parent.mkdir(parents=True, exist_ok=True)
            vocab_index.write_text("\n".join(vocab_lines), encoding="utf-8")


def render_page(page: Page, source_text: str) -> str:
    front_matter, body = split_front_matter(source_text)
    route = "/".join(part for part in [page.dialect, page.rel_path] if part)

    title = parse_scalar(front_matter, "title") or parse_scalar(front_matter, "keyword") or slug_to_title(page.title_hint)
    summary = parse_scalar(front_matter, "summary")
    specification = parse_scalar(front_matter, "specification")
    metaschema = parse_scalar(front_matter, "metaschema")
    introduced_in = parse_scalar(front_matter, "introduced_in")

    metadata_lines = [
        f"# {title}",
        "",
        f"- Original: [{page.url}]({page.url})",
        f"- Upstream source: [{page.source_url}]({page.source_url})",
    ]
    if specification:
        metadata_lines.append(f"- Specification: [{specification}]({specification})")
    if metaschema:
        metadata_lines.append(f"- Metaschema: `{metaschema}`")
    if introduced_in:
        metadata_lines.append(f"- Introduced in: `{introduced_in}`")
    if summary:
        metadata_lines.extend(["", summary])

    cleaned_body = clean_body(body, route, page.output_path)
    if cleaned_body.strip():
        return "\n".join(metadata_lines).rstrip() + "\n\n" + cleaned_body
    return "\n".join(metadata_lines).rstrip() + "\n"


def main() -> int:
    sitemap = fetch_text(SITEMAP_URL)
    source_lookup = build_source_lookup()
    pages = parse_sitemap(sitemap, source_lookup)
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)

    for page in pages:
        source_text = fetch_text(page.source_url)
        output = render_page(page, source_text)
        page.output_path.parent.mkdir(parents=True, exist_ok=True)
        page.output_path.write_text(output, encoding="utf-8")
        print(page.output_path.relative_to(ROOT))

    build_index_pages(pages)
    return 0


if __name__ == "__main__":
    sys.exit(main())
