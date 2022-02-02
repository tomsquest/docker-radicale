import subprocess

import pytest
import testinfra


@pytest.fixture(scope='session')
def host():
    subprocess.check_call(['docker', 'build', '-t', 'radicale-under-test', '.'])
    docker_id = subprocess.check_output([
        'docker', 'run', '-d',
        '--init',
        '--read-only',
        '--security-opt=no-new-privileges:true',
        # Not able to use cap-drop=all and make the container start
        # '--cap-drop', 'ALL',
        # '--cap-add', 'SYS_ADMIN',
        # '--cap-add', 'CHOWN',
        # '--cap-add', 'SETUID',
        # '--cap-add', 'SETGID',
        # '--cap-add', 'KILL',
        '--pids-limit', '50',
        '--memory', '256M',
        'radicale-under-test'
    ]).decode().strip()

    yield testinfra.get_host("docker://" + docker_id)

    # teardown
    subprocess.check_call(['docker', 'rm', '-f', docker_id])


def test_process(host):
    process = host.process.get(comm='radicale')
    assert process.pid != 1
    assert process.user == 'radicale'
    assert process.group == 'radicale'


def test_port(host):
    assert host.socket('tcp://0.0.0.0:5232').is_listening


def test_version(host):
    assert host.check_output('radicale --version') == '3.1.4'


def test_user(host):
    user = 'radicale'
    assert host.user(user).uid == 2999
    assert host.user(user).gid == 2999
    assert host.user(user).shell == '/bin/false'
    assert 'radicale L ' in host.check_output('passwd --status radicale')


def test_data_folder_writable(host):
    folder = '/data'
    assert host.file(folder).user == 'radicale'
    assert host.file(folder).group == 'radicale'
    assert host.file(folder).mode == 0o770
