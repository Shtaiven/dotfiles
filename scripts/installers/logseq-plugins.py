#!/usr/bin/env python3
"""Install the Logseq plugins that stow/logseq already has settings for.

Logseq's marketplace writes ~/.logseq/config/plugins.edn as you install
plugins, recording each one's id, pinned version and GitHub repo. That file is
tracked in the logseq stow package, so the dotfiles already carry the plugin
list — but Logseq won't act on it, and a fresh machine gets the settings under
~/.logseq/settings/ with none of the plugins they configure.

This reads plugins.edn back and fetches whatever is missing from
~/.logseq/plugins/, which is where Logseq looks (the Flathub build is granted
filesystems=home, so it reads the real ~/.logseq rather than a sandbox copy).

Called by stow/logseq/.dots-install.toml, but usable on its own:

    logseq-plugins.py --list         # what's recorded vs. what's installed
    logseq-plugins.py --dry-run      # what would be fetched
    logseq-plugins.py                # fetch anything missing
    logseq-plugins.py --force        # refetch everything at the pinned version
    logseq-plugins.py --check        # exit 1 if any are missing (the manifest probe)
"""

import argparse
import io
import json
import os
import re
import shutil
import sys
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

DOTFILES_DIR = Path(os.environ.get("DOTFILES_DIR", Path(__file__).resolve().parents[2]))
PLUGINS_EDN = DOTFILES_DIR / "stow/logseq/.logseq/config/plugins.edn"
PLUGINS_DIR = Path.home() / ".logseq/plugins"
API = "https://api.github.com/repos/{repo}/releases/tags/{tag}"

# plugins.edn is EDN, not JSON, but the marketplace writes one flat shape:
#   :plugin-id {:version "v1.2.3", :repo "owner/name", :effect true, ...}
# so a targeted scan beats pulling in an EDN parser for four keys.
ENTRY_RE = re.compile(r":([A-Za-z0-9_-]+)\s*\{([^}]*)\}")
FIELD_RE = re.compile(r':(\w+)\s+"([^"]*)"')


def parse_plugins(path: Path) -> list[dict]:
    """Extract (id, version, repo) for every plugin recorded in plugins.edn."""
    if not path.is_file():
        sys.exit(f"error: {path} not found — is the logseq package in this repo?")
    text = path.read_text()
    plugins = []
    for pid, body in ENTRY_RE.findall(text):
        fields = dict(FIELD_RE.findall(body))
        repo, version = fields.get("repo"), fields.get("version")
        if not repo or not version:
            print(f"  {pid}: no repo/version recorded — skipping", file=sys.stderr)
            continue
        plugins.append({"id": pid, "repo": repo, "version": version})
    if not plugins:
        sys.exit(f"error: no plugins found in {path}")
    return sorted(plugins, key=lambda p: p["id"])


def norm(version: str) -> str:
    """Strip the leading v / v. so a pinned tag compares to a package.json version.

    plugins.edn records the git tag verbatim, which authors spell inconsistently
    (v1.19.4, 2.2.11, even v.1.2.0), while package.json mostly repeats it.
    """
    return version.lstrip("v.") if version else ""


def installed_version(dest: Path) -> str | None:
    """Version from an installed plugin's package.json, if it has one."""
    pkg = dest / "package.json"
    if not pkg.is_file():
        return None
    try:
        return json.loads(pkg.read_text()).get("version")
    except (OSError, json.JSONDecodeError):
        return None


def _request(url: str) -> urllib.request.Request:
    headers = {
        "User-Agent": "dots-logseq-plugins/1.0",
        "Accept": "application/vnd.github+json",
    }
    # Unauthenticated GitHub allows 60 requests/hour, which a 15-plugin run can
    # exhaust if it's re-run a few times. Use a token when one is around.
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return urllib.request.Request(url, headers=headers)


def release_zip_url(plugin: dict) -> str | None:
    """The .zip asset attached to the plugin's pinned release tag."""
    url = API.format(repo=plugin["repo"], tag=plugin["version"])
    try:
        with urllib.request.urlopen(_request(url), timeout=20) as resp:
            release = json.loads(resp.read())
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            print(f"    no release tagged {plugin['version']} in {plugin['repo']}")
        elif exc.code in (403, 429):
            print("    GitHub rate limit hit — set GITHUB_TOKEN and re-run")
        else:
            print(f"    GitHub returned HTTP {exc.code}")
        return None
    except (urllib.error.URLError, TimeoutError) as exc:
        print(f"    could not reach GitHub: {exc}")
        return None
    zips = [
        a["browser_download_url"]
        for a in release.get("assets", [])
        if a.get("name", "").endswith(".zip")
    ]
    if not zips:
        print("    release has no .zip asset")
        return None
    return zips[0]


def extract(blob: bytes, dest: Path) -> None:
    """Unpack a plugin zip into dest.

    Most plugins zip their build flat (package.json at the root), but some wrap
    everything in a single directory; strip that so dest/package.json lands
    where Logseq expects it either way.
    """
    with zipfile.ZipFile(io.BytesIO(blob)) as zf:
        names = [n for n in zf.namelist() if not n.startswith("__MACOSX/")]
        roots = {n.split("/")[0] for n in names}
        flat = any(n == "package.json" for n in names)
        strip = ""
        if not flat and len(roots) == 1:
            strip = roots.pop() + "/"

        if dest.exists():
            shutil.rmtree(dest)
        for name in names:
            if name.endswith("/"):
                continue
            rel = name[len(strip) :] if strip and name.startswith(strip) else name
            if not rel:
                continue
            # Never let a crafted archive escape the plugin directory.
            target = (dest / rel).resolve()
            if not str(target).startswith(str(dest.resolve()) + os.sep):
                print(f"    skipping unsafe path in archive: {name}")
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(name) as src, target.open("wb") as out:
                shutil.copyfileobj(src, out)


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Install the Logseq plugins recorded in stow/logseq's plugins.edn.",
        epilog="Plugins are written to ~/.logseq/plugins/, where Logseq loads them from.",
    )
    ap.add_argument(
        "--list", action="store_true", help="Show recorded vs. installed, then exit"
    )
    ap.add_argument(
        "--check",
        action="store_true",
        help="Exit 0 if every recorded plugin is installed, 1 otherwise "
        "(used as the presence probe in stow/logseq's .dots-install.toml)",
    )
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="Say what would be fetched, fetch nothing",
    )
    ap.add_argument(
        "--force",
        action="store_true",
        help="Refetch plugins that are already installed, re-pinning them to plugins.edn",
    )
    args = ap.parse_args()

    plugins = parse_plugins(PLUGINS_EDN)

    if args.check:
        missing = [p["id"] for p in plugins if not (PLUGINS_DIR / p["id"]).exists()]
        if missing:
            print(f"missing {len(missing)}: {', '.join(missing)}")
            return 1
        return 0

    if args.list:
        print(f"{len(plugins)} plugin(s) recorded in {PLUGINS_EDN.name}:")
        for p in plugins:
            dest = PLUGINS_DIR / p["id"]
            if not dest.exists():
                state = "not installed"
            else:
                have = installed_version(dest)
                if have and norm(have) != norm(p["version"]):
                    state = f"installed, but at {have}"
                else:
                    state = "installed"
            print(f"  {p['id']:<28} {p['version']:<12} {state}")
        return 0

    todo = [p for p in plugins if args.force or not (PLUGINS_DIR / p["id"]).exists()]
    skipped = len(plugins) - len(todo)
    if skipped:
        print(f"  {skipped} plugin(s) already installed")
    if not todo:
        return 0

    if args.dry_run:
        print(f"  would fetch {len(todo)} plugin(s):")
        for p in todo:
            print(f"    {p['id']} {p['version']}  ({p['repo']})")
        return 0

    PLUGINS_DIR.mkdir(parents=True, exist_ok=True)
    failed = []
    for p in todo:
        print(f"  {p['id']} {p['version']} ...")
        url = release_zip_url(p)
        if not url:
            failed.append(p["id"])
            continue
        try:
            with urllib.request.urlopen(_request(url), timeout=60) as resp:
                blob = resp.read()
            extract(blob, PLUGINS_DIR / p["id"])
        except (
            urllib.error.URLError,
            TimeoutError,
            zipfile.BadZipFile,
            OSError,
        ) as exc:
            print(f"    failed: {exc}")
            failed.append(p["id"])
            continue
        print("    installed")

    if failed:
        print(f"  {len(failed)} failed: {', '.join(failed)}")
        return 1
    print("  restart Logseq to load the new plugins")
    return 0


if __name__ == "__main__":
    sys.exit(main())
