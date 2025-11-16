from configparser import ConfigParser
from pathlib import Path
from textwrap import dedent

from update_config_from_env import update_config_from_env


def test_no_env_var(tmp_path: Path, monkeypatch) -> None:
    original_config = dedent("""
        [server]
        hosts = localhost:5232
        ssl = True
        
        [auth]
        type = denyall
        """).strip()
    config_file = tmp_path / "config"
    config_file.write_text(original_config)

    update_config_from_env(str(config_file))

    actual_config = config_file.read_text()
    assert actual_config == original_config


def test_some_env_vars(tmp_path: Path, monkeypatch) -> None:
    config_file = tmp_path / "config"
    config_file.write_text(
        dedent("""
        [server]
        hosts = localhost:5232
        ssl = True
        timeout = 30
        
        [auth]
        type = denyall
        """).strip()
    )

    monkeypatch.setenv("RADICALE_SERVER_HOSTS", "0.0.0.0:5232")
    monkeypatch.setenv("RADICALE_SERVER_SSL", "False")
    monkeypatch.setenv("RADICALE_SERVER_TIMEOUT", "45")
    monkeypatch.setenv("RADICALE_AUTH_TYPE", "none")

    update_config_from_env(str(config_file))

    config = ConfigParser()
    config.read(config_file)
    assert config.get("server", "hosts") == "0.0.0.0:5232"
    assert config.get("server", "ssl") == "False"
    assert config.get("server", "timeout") == "45"
    assert config.get("auth", "type") == "none"


def test_new_section(tmp_path: Path, monkeypatch) -> None:
    config_file = tmp_path / "config"
    config_file.write_text(
        dedent("""
        [any]
        anykey = 42
        """).strip()
    )

    monkeypatch.setenv("RADICALE_MYSECTION_MYKEY", "myvalue")

    update_config_from_env(str(config_file))

    config = ConfigParser()
    config.read(config_file)
    assert config.get("any", "anykey") == "42"
    assert config.get("mysection", "mykey") == "myvalue"
