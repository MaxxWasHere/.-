"""CLI for dotswitch."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

from dotswitch import __version__
from dotswitch.core import DotswitchConfig, State, apply_profile, create_profile, list_profiles


def cmd_init(cfg: DotswitchConfig, _: argparse.Namespace) -> int:
    cfg.ensure_dirs()
    if not cfg.state_path.exists():
        State().save(cfg.state_path)
    print(f"profiles directory: {cfg.profiles_root}")
    print(f"state file: {cfg.state_path}")
    print("Create a profile: dotswitch create NAME")
    return 0


def cmd_list(cfg: DotswitchConfig, _: argparse.Namespace) -> int:
    state = State.from_json(cfg.state_path)
    names = list_profiles(cfg)
    if not names:
        print("(no profiles yet)")
    else:
        for n in names:
            mark = " *" if state.active == n else ""
            print(f"{n}{mark}")
    return 0


def cmd_current(cfg: DotswitchConfig, _: argparse.Namespace) -> int:
    state = State.from_json(cfg.state_path)
    if state.active:
        print(state.active)
    else:
        print("(none)")
    return 0


def cmd_create(cfg: DotswitchConfig, args: argparse.Namespace) -> int:
    cfg.ensure_dirs()
    try:
        path = create_profile(cfg, args.name)
    except FileExistsError:
        print(f"profile already exists: {args.name}", file=sys.stderr)
        return 1
    print(path)
    return 0


def cmd_apply(cfg: DotswitchConfig, args: argparse.Namespace) -> int:
    cfg.ensure_dirs()
    ok, msgs = apply_profile(
        cfg,
        args.name,
        dry_run=args.dry_run,
        force=args.force,
    )
    for m in msgs:
        print(m, file=sys.stderr)
    if not ok:
        return 1
    if args.dry_run:
        print("(dry run; no changes written)")
    else:
        print(f"switched to profile: {args.name}")
    return 0


def cmd_clear(cfg: DotswitchConfig, args: argparse.Namespace) -> int:
    from dotswitch.core import clear_managed_paths

    cfg.ensure_dirs()
    ok, msgs = clear_managed_paths(cfg, dry_run=args.dry_run)
    for m in msgs:
        print(m, file=sys.stderr)
    if not ok:
        return 1
    if args.dry_run:
        print("(dry run)")
    else:
        print("cleared managed symlinks")
    return 0


def cmd_import(cfg: DotswitchConfig, args: argparse.Namespace) -> int:
    """Copy paths from HOME into a new or existing profile (real files, not symlinks)."""
    cfg.ensure_dirs()
    dest = cfg.profiles_root / args.name
    if dest.exists() and not dest.is_dir():
        print(f"refusing: {dest} exists and is not a directory", file=sys.stderr)
        return 1
    dest.mkdir(parents=True, exist_ok=True)

    copied = 0
    for rel in args.paths:
        src = (cfg.home / rel).resolve()
        if not src.exists() and not src.is_symlink():
            print(f"skip missing: {rel}", file=sys.stderr)
            continue
        out = dest / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        if out.exists():
            print(f"skip (exists in profile): {rel}", file=sys.stderr)
            continue
        if src.is_dir():
            shutil.copytree(src, out, symlinks=False, dirs_exist_ok=False)
        else:
            shutil.copy2(src, out, follow_symlinks=True)
        copied += 1
    print(f"imported {copied} path(s) into profile {args.name!r} at {dest}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="dotswitch",
        description="Switch symlinked dotfile profiles under $HOME",
    )
    p.add_argument("--version", action="version", version=f"%(prog)s {__version__}")

    sub = p.add_subparsers(dest="command", required=True)

    sub.add_parser("init", help="create XDG dirs and empty state")

    sub.add_parser("list", aliases=["ls"], help="list profiles (* = active)")

    sub.add_parser("current", help="print active profile name")

    c = sub.add_parser("create", help="create empty profile directory")
    c.add_argument("name", help="profile name")

    a = sub.add_parser("apply", help="switch to profile (symlink into HOME)")
    a.add_argument("name", help="profile name")
    a.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="show actions without changing files",
    )
    a.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="replace symlinks that point somewhere else",
    )

    cl = sub.add_parser("clear", help="remove managed symlinks; deactivate")
    cl.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
    )

    im = sub.add_parser(
        "import",
        help="copy dot paths from HOME into a profile (bootstrap)",
    )
    im.add_argument("name", help="profile name")
    im.add_argument(
        "paths",
        nargs="+",
        metavar="REL_PATH",
        help="paths relative to HOME (e.g. .bashrc .config/nvim)",
    )

    return p


def main() -> None:
    cfg = DotswitchConfig.load()
    parser = build_parser()
    args = parser.parse_args()

    cmds = {
        "init": cmd_init,
        "list": cmd_list,
        "ls": cmd_list,
        "current": cmd_current,
        "create": cmd_create,
        "apply": cmd_apply,
        "clear": cmd_clear,
        "import": cmd_import,
    }
    fn = cmds[args.command]
    raise SystemExit(fn(cfg, args))


if __name__ == "__main__":
    main()
