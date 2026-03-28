"""Core dotfile profile switching: symlinks, manifest, XDG paths."""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path


def xdg_config_home() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


def xdg_data_home() -> Path:
    return Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share"))


@dataclass
class DotswitchConfig:
    """Resolved layout for profiles and state."""

    home: Path
    config_dir: Path
    data_dir: Path
    profiles_root: Path
    state_path: Path

    @classmethod
    def load(cls) -> DotswitchConfig:
        home = Path.home()
        cfg_root = xdg_config_home() / "dotswitch"
        data_root = xdg_data_home() / "dotswitch"
        profiles_root = data_root / "profiles"
        state_path = cfg_root / "state.json"

        override = cfg_root / "config.json"
        if override.is_file():
            raw = json.loads(override.read_text(encoding="utf-8"))
            if "profiles_dir" in raw:
                profiles_root = Path(raw["profiles_dir"]).expanduser()
            if "home" in raw:
                home = Path(raw["home"]).expanduser()

        return cls(
            home=home,
            config_dir=cfg_root,
            data_dir=data_root,
            profiles_root=profiles_root,
            state_path=state_path,
        )

    def ensure_dirs(self) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.profiles_root.mkdir(parents=True, exist_ok=True)


@dataclass
class State:
    active: str | None = None
    managed_paths: list[str] = field(default_factory=list)

    @classmethod
    def from_json(cls, path: Path) -> State:
        if not path.is_file():
            return cls()
        data = json.loads(path.read_text(encoding="utf-8"))
        return cls(
            active=data.get("active"),
            managed_paths=list(data.get("managed_paths", [])),
        )

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps(
                {"active": self.active, "managed_paths": self.managed_paths},
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )


def _is_under(path: Path, root: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except ValueError:
        return False


def clear_managed(
    state: State,
    cfg: DotswitchConfig,
    *,
    dry_run: bool,
) -> list[str]:
    """Remove symlinks listed in state if they still point into profiles_root."""
    errors: list[str] = []
    remaining: list[str] = []
    root_resolved = cfg.profiles_root.resolve()

    for pstr in state.managed_paths:
        p = Path(pstr)
        if not p.is_symlink():
            if p.exists():
                remaining.append(pstr)
                errors.append(f"skip remove (not a symlink): {p}")
            continue
        target = p.resolve()
        if _is_under(target, root_resolved):
            if dry_run:
                print(f"would unlink {p}")
            else:
                p.unlink()
        else:
            errors.append(f"skip unlink (points outside profiles dir): {p}")
            remaining.append(pstr)

    state.managed_paths = remaining
    state.active = None
    return errors


def clear_managed_paths(cfg: DotswitchConfig, *, dry_run: bool) -> tuple[bool, list[str]]:
    """Load state, clear managed symlinks; save manifest unless dry_run."""
    state = State.from_json(cfg.state_path)
    errs = clear_managed(state, cfg, dry_run=dry_run)
    if not dry_run:
        state.save(cfg.state_path)
    if state.managed_paths:
        return False, errs + ["cannot finish clear: paths still listed as managed"]
    return True, errs


def _iter_profile_files(profile_dir: Path) -> list[Path]:
    """All files under profile_dir, relative paths as Path parts from profile root."""
    if not profile_dir.is_dir():
        return []
    out: list[Path] = []
    for root, _, files in os.walk(profile_dir, topdown=True):
        r = Path(root)
        for f in files:
            out.append(r / f)
    return out


def apply_profile(
    cfg: DotswitchConfig,
    name: str,
    *,
    dry_run: bool = False,
    force: bool = False,
) -> tuple[bool, list[str]]:
    """
    Switch to profile `name`: clear previous managed links, symlink files from
    profiles_root/name into cfg.home mirroring relative paths.
    """
    messages: list[str] = []
    profile_dir = (cfg.profiles_root / name).resolve()
    if not profile_dir.is_dir():
        return False, [f"profile not found: {name} (expected {profile_dir})"]

    state = State.from_json(cfg.state_path)
    for err in clear_managed(state, cfg, dry_run=dry_run):
        messages.append(err)

    if state.managed_paths:
        messages.append(
            "abort: resolve or clear remaining managed paths before switching"
        )
        if not dry_run:
            state.save(cfg.state_path)
        return False, messages

    new_managed: list[str] = []

    for src in sorted(_iter_profile_files(profile_dir)):
        rel = src.relative_to(profile_dir)
        dest = (cfg.home / rel).resolve()
        home_res = cfg.home.resolve()

        if not _is_under(dest, home_res) and dest != home_res:
            messages.append(f"refusing path outside HOME: {dest}")
            return False, messages

        dest.parent.mkdir(parents=True, exist_ok=True)

        if dest.exists() or dest.is_symlink():
            if dest.is_symlink():
                if not force and dest.resolve() != src.resolve():
                    cur = dest.readlink()
                    if cur.is_absolute() and cur.resolve() != src.resolve():
                        messages.append(
                            f"refused: {dest} already links elsewhere (use --force)"
                        )
                        return False, messages
                if dry_run:
                    print(f"would replace symlink {dest} -> {src}")
                else:
                    dest.unlink()
            else:
                messages.append(f"refused: {dest} exists and is not a symlink")
                return False, messages

        if dry_run:
            print(f"would symlink {dest} -> {src}")
        else:
            dest.symlink_to(src)
        new_managed.append(str(dest))

    state.managed_paths = new_managed
    state.active = name
    if not dry_run:
        state.save(cfg.state_path)

    return True, messages


def list_profiles(cfg: DotswitchConfig) -> list[str]:
    if not cfg.profiles_root.is_dir():
        return []
    names = []
    for p in sorted(cfg.profiles_root.iterdir()):
        if p.is_dir() and not p.name.startswith("."):
            names.append(p.name)
    return names


def create_profile(cfg: DotswitchConfig, name: str) -> Path:
    d = cfg.profiles_root / name
    d.mkdir(parents=True, exist_ok=False)
    return d
