import configparser

import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host():
    subprocess.check_call(["docker", "build", "-t", "radicale-under-test", "."])
    docker_id = (
        subprocess.check_output(
            [
                "docker",
                "run",
                "-d",
                "--init",
                "-e",
                "RADICALE_WEB_TYPE=internal",
                "-e",
                "RADICALE_FOO_BAR=qix",
                "radicale-under-test",
            ]
        )
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + docker_id)

    # teardown
    subprocess.check_call(["docker", "rm", "-f", docker_id])


def test_config(host):
    config_content = host.check_output("cat /config/config")

    parser = configparser.ConfigParser()
    parser.read_string(config_content)

    assert parser.get("web", "type") == "internal"
    assert parser.get("foo", "bar") == "qix"
