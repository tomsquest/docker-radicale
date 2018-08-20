import os
import pytest
import subprocess
import testinfra

@pytest.fixture(scope='session')
def host(request):
    subprocess.check_call(['docker', 'build', '-t', 'radicale', '.'])
    docker_id = subprocess.check_output(['docker', 'run', '-d', 'radicale']).decode().strip()
    
    yield testinfra.get_host("docker://" + docker_id)
    
    # teardown
    subprocess.check_call(['docker', 'rm', '-f', docker_id])

def test_system(host):
    assert host.system_info.distribution == 'alpine'
    assert host.system_info.release == '3.7.0'

def test_entrypoint(host):
    entrypoint = '/usr/local/bin/docker-entrypoint.sh'
    assert host.file(entrypoint).exists
    assert oct(host.file(entrypoint).mode) == '0o555'

def test_pid1(host):
    assert host.file('/proc/1/cmdline').content_string.replace('\x00','') == '/usr/bin/python3/usr/bin/radicale--config/config/config'

def test_port(host):
    assert host.socket("tcp://0.0.0.0:5232").is_listening

def test_radicale_version(host):
    assert host.check_output("/usr/bin/pip3 --disable-pip-version-check show radicale | grep Version | awk -F ' ' '{print $2}' | tr -d '\n'") == os.environ.get('VERSION','2.1.9')

def test_radicale_user(host):
    assert host.user('radicale').uid == 2999
    assert host.user('radicale').gid == 2999

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
