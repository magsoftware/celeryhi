# Deployment of Celery and Celery Beat as native services

## Assumptions
1. Operating system:   CentOS 7.9
1. Firmware user name: firmware
1. Application name:   celeryhi
1. Redis as Celery backend running on localhost port 6379

## Installation instructions

### Install python, git and pipenv
```bash
sudo -i
yum update -y
yum install -y python3 git
python3 -V
```

### Create user for the application runtime
```bash
useradd firmware
```

### Clone Git repo, create virtual environment and install dependencies
```bash
su - firmware
pip3 install --user pipenv
git clone https://github.com/magsoftware/celeryhi.git
cd celeryhi
pipenv shell
pipenv install --ignore-pipfile
exit
```

### Install, start and enable systemd service unit file (as root user)
```bash
exit
cp /home/firmware/celeryhi/scripts/celery.service /etc/systemd/system/
chmod 644 /etc/systemd/system/celery.service
systemctl daemon-reload
systemctl start celery
systemctl status celery
systemctl enable celery

cp /home/firmware/celeryhi/scripts/celerybeat.service /etc/systemd/system/
chmod 644 /etc/systemd/system/celerybeat.service
systemctl daemon-reload
systemctl start celerybeat
systemctl status celerybeat
systemctl enable celerybeat
```
