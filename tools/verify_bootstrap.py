from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL_BIN = Path(os.environ.get("USERPROFILE", "")) / ".rokit" / "bin"
REQUIRED_DIRS = [
    ROOT / "src" / "shared",
    ROOT / "src" / "server",
    ROOT / "src" / "client",
    ROOT / "tests",
    ROOT / ".agents" / "skills",
]
REQUIRED_SKILLS = [
    "abyss-director",
    "abyss-task-planner",
    "roblox-combat-authority",
    "roblox-mobile-controls",
    "roblox-security-review",
    "roblox-test-evidence",
    "abyss-git-checkpoint",
    "abyss-status-report",
]

def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)

def run(name: str, args: list[str]) -> None:
    suffix = ".exe" if os.name == "nt" else ""
    executable = TOOL_BIN / f"{name}{suffix}"
    if not executable.exists():
        fail(f"tool missing: {executable}")
    command = [str(executable), *args]
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    print(f"$ {' '.join(command)}")
    if result.stdout:
        print(result.stdout.rstrip())
    if result.stderr:
        print(result.stderr.rstrip(), file=sys.stderr)
    if result.returncode:
        fail(f"{name} exited {result.returncode}")

def validate_skill(path: Path, expected_name: str) -> None:
    text = path.read_text(encoding="utf-8-sig")
    if not text.startswith("---\n"):
        fail(f"frontmatter missing: {path}")
    parts = text.split("---", 2)
    if len(parts) < 3:
        fail(f"frontmatter not closed: {path}")
    metadata = parts[1]
    if f"name: {expected_name}" not in metadata:
        fail(f"name mismatch: {path}")
    if "description:" not in metadata:
        fail(f"description missing: {path}")
    if len(parts[2].strip()) < 80:
        fail(f"instructions too short: {path}")

def main() -> None:
    project = json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
    if project.get("name") != "PROJECT_ABYSS":
        fail("project name mismatch")
    for path in REQUIRED_DIRS:
        if not path.is_dir():
            fail(f"directory missing: {path}")
    for name in REQUIRED_SKILLS:
        validate_skill(ROOT / ".agents" / "skills" / name / "SKILL.md", name)
    build = ROOT / "build"
    build.mkdir(exist_ok=True)
    run("rojo", ["build", "default.project.json", "-o", str(build / "bootstrap.rbxlx")])
    run("rojo", ["sourcemap", "default.project.json", "-o", str(build / "sourcemap.json")])
    run("stylua", ["--check", "src"])
    run("selene", ["src"])
    print(f"PASS: bootstrap verified with {len(REQUIRED_SKILLS)} skills")

if __name__ == "__main__":
    main()
