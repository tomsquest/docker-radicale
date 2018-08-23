import os
import pytest
import subprocess
import testinfra

@pytest.fixture(scope='session')
def host(request):
    subprocess.check_call(['docker', 'build', '-t', 'image-under-test', '.'])
    docker_id = subprocess.check_output(['docker', 'run', '-d', 'image-under-test']).decode().strip()
    
    yield testinfra.get_host("docker://" + docker_id)
    
    # teardown
    subprocess.check_call(['docker', 'rm', '-f', docker_id])

def test_process(host):
    process = host.process.get(comm='radicale')
    assert process.pid == 1
    assert process.user == 'radicale'
    assert '/usr/bin/radicale --config /config/config' in process.args

def test_port(host):
    assert host.socket('tcp://0.0.0.0:5232').is_listening

def test_radicale_version(host):
    assert host.check_output('radicale --version') == os.environ.get('VERSION','2.1.9')

def test_radicale_user(host):
    user = 'radicale'
    assert host.user(user).uid == 2999
    assert host.user(user).gid == 2999
    assert host.user(user).shell == '/bin/false'

def test_user_is_locked(host):
    assert 'radicale L ' in host.check_output('passwd --status radicale')

def test_config_folder(host):
    folder = '/config'
    assert host.file(folder).exists
    assert host.file(folder).user == 'radicale'
    assert oct(host.file(folder).mode) == '0o700'

def test_data_folder(host):
    folder = '/data'
    assert host.file(folder).exists
    assert host.file(folder).user == 'radicale'
    assert oct(host.file(folder).mode) == '0o700'

@pytest.mark.parametrize('package', [
    ('curl'),
    ('git'),
    ('shadow'),
    ('su-exec'),
])
def test_installed_dependencies(host, package):
    assert host.package(package).is_installed
