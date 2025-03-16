import pytest
import subprocess
import testinfra


@pytest.fixture(scope="session")
def host():
    subprocess.check_call(
        [
            "docker",
            "build",
            "-t",
            "radicale-under-test",
            "--build-arg",
            "VERSION=3.4.1",
            "--build-arg",
            "BUILD_UID=6666",
            "--build-arg",
            "BUILD_GID=7777",
            ".",
        ]
    )
    docker_id = (
        subprocess.check_output(["docker", "run", "-d", "radicale-under-test"])
        .decode()
        .strip()
    )

    yield testinfra.get_host("docker://" + docker_id)

    # teardown
    subprocess.check_call(["docker", "rm", "-f", docker_id])


def test_process(host):
    process = host.process.get(comm="radicale")
    assert process.pid == 1
    assert process.user == "radicale"
    assert process.group == "radicale"


def test_port(host):
    assert host.socket("tcp://0.0.0.0:5232").is_listening


def test_version(host):
    assert host.check_output("/venv/bin/radicale --version") == "3.4.1"


def test_user(host):
    user = "radicale"
    assert host.user(user).uid == 6666
    assert host.user(user).gid == 7777
    assert host.user(user).shell == "/bin/false"
    assert "radicale L " in host.check_output("passwd --status radicale")


def test_data_folder_writable(host):
    folder = "/data"
    assert host.file(folder).user == "radicale"
    assert host.file(folder).group == "radicale"
    assert host.file(folder).mode == 0o770
