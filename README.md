# AWS Demo Project

A Django-based demo application integrating **MySQL** database with modern Material Design UI.  
This project demonstrates basic **CRUD operations**, database integration, and Django admin functionality.

---

## Features

- Django 5.x backend
- MySQL 8.0 database support
- Material Design-inspired UI
- CRUD operations (Create, Read, Update, Delete)
- Admin interface for managing data
- Responsive design with navbar, carousel, and footer

---

## Prerequisites

- Python 3.11+
- MySQL 8.0+
- pip
- Git (optional)

---

This README provides step-by-step instructions to deploy a Django application on **Ubuntu Server** and **Amazon Linux 2023**, including optional Python tarball installation and MySQL 8.0.x database configuration.

---

## Table of Contents
1. [Amazon Linux 2023 Deployment](#amazon-linux-2023-deployment)
    - [Update System](#1-update-system)
    - [Install Build Tools, Python 3.12, and Libraries](#2-install-build-tools-python-312-and-libraries)
    - [Verify Python 3.12](#3-verify-python-312)
    - [Clone Django App Repository](#4-clone-django-app-repository)
    - [Create and Activate Python Virtual Environment](#5-create-and-activate-python-virtual-environment)
    - [Upgrade pip and Install Python Dependencies](#6-upgrade-pip-and-install-python-dependencies)
    - [Database Configuration (MySQL 8.0.x)](#7-database-configuration-mysql-8042)
    - [Apply Database Migrations and Collect Static Files](#8-apply-database-migrations-and-collect-static-files)
    - [Optional: Create Superuser](#9-optional-create-superuser)
    - [Install Gunicorn and Test Run](#10-install-gunicorn-and-test-run)
    - [Configure Gunicorn systemd Service](#11-configure-gunicorn-systemd-service)
    - [Configure NGINX Reverse Proxy](#12-configure-nginx-reverse-proxy)
    - [Open Firewall for HTTP/HTTPS](#13-open-firewall-for-httphttps-if-firewalld-is-enabled)
    - [Verify Services](#14-verify-services)
    - [Access Your Django App](#15-access-your-django-app)
    - [Optional: Install Python 3.10 via Tarball](#optional-install-python-310-via-tarball)
2. [Ubuntu Server Deployment](#ubuntu-server-deployment)
    - [Update system and install dependencies](#1-update-system-and-install-dependencies)
    - [Install Python 3.10](#2-install-python-310)
    - [Verify Python](#3-verify-python)
    - [Setup your Django app directory](#4-setup-your-django-app-directory)
    - [Create virtual environment and activate](#5-create-virtual-environment-and-activate)
    - [Upgrade pip and install requirements](#6-upgrade-pip-and-install-requirements)
    - [Database Configuration (MySQL 8.0.x)](#7-database-configuration-mysql-8042-1)
    - [Apply database migrations](#8-apply-database-migrations)
    - [Create Django superuser (optional)](#9-create-django-superuser-optional)
    - [Collect static files](#10-collect-static-files)
    - [Run Django app (development mode)](#11-run-django-app-development-mode)
    - [For Production with Gunicorn + Nginx](#12-for-production-with-gunicorn--nginx)
    - [Enable Gunicorn as systemd service](#enable-gunicorn-as-systemd-service)
    - [Optional: Install Python 3.10 via Tarball](#optional-install-python-310-via-tarball-1)

---

## Setup Instructions
## Amazon Linux 2023 Deployment

### 1. Update System
```bash
dnf update -y
```

### 2. Install Build Tools, Python 3.12, and Libraries
```bash
dnf install -y git gcc gcc-c++ make pkgconfig openssl-devel bzip2-devel \
libffi-devel zlib-devel ncurses-devel readline-devel sqlite-devel tk-devel \
xz-devel gdbm-devel nginx python3.12 python3.12-devel python3.12-pip \
python3.12-setuptools python3.12-wheel mariadb105-devel
```

### 3. Verify Python 3.12
```bash
python3.12 -V
pip3.12 -V
```

### 4. Clone Django App Repository
```bash
cd /root
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django
```

### 5. Create and Activate Python Virtual Environment
```bash
python3.12 -m venv venv
source venv/bin/activate
```

### 6. Upgrade pip and Install Python Dependencies
```bash
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### 7. Database Configuration (MySQL 8.0.x)
```bash

# Download MySQL 8.0 repository package
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

# Install the repository
dnf install mysql80-community-release-el9-1.noarch.rpm -y

# Import MySQL GPG key
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# Install MySQL server
dnf install mysql-community-server -y

# Start and check MySQL service
systemctl enable --now mysqld
systemctl status mysqld

# Get the temporary password
grep -i "temporary password" /var/log/mysqld.log

# Secure MySQL installation
mysql_secure_installation # new password : thiS_!$-MyN3wPW


# Create a database and user for Django
mysql -u root -p
# SET GLOBAL validate.password_policy=LOW;
# SET GLOBAL validate.password_length=6;

SET GLOBAL validate_password.length=6;
SET GLOBAL validate_password.policy=LOW;

CREATE DATABASE django_db;
CREATE USER 'django_user'@'%' IDENTIFIED BY 'django_password'; 
GRANT ALL PRIVILEGES ON *.* TO 'django_user'@'%'; 
ALTER USER 'django_user' IDENTIFIED WITH mysql_native_password BY 'django_password';
FLUSH PRIVILEGES;
SHOW DATABASES;
SELECT USER, HOST FROM mysql.user;


# Update Django settings.py DATABASES section
# PATH : /root/aws-demo-django/aws_demo/settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'django_db',
        'USER': 'django_user',
        'PASSWORD': 'django_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### 8. Apply Database Migrations and Collect Static Files
```bash
python manage.py makemigrations
python manage.py migrate
# python manage.py collectstatic --noinput
```

### 9. (Optional) Create Superuser
```bash
python manage.py createsuperuser
```

### 10. Install Gunicorn and Test Run
```bash
pip install gunicorn
gunicorn --bind 0.0.0.0:8000 --pythonpath /root/aws-demo-django aws_demo.wsgi:application
```

### 11. Configure Gunicorn systemd Service
```bash
cat >/etc/systemd/system/gunicorn.service <<'EOF'
[Unit]
Description=Gunicorn service for Django app
After=network.target

[Service]
User=root
Group=nginx
WorkingDirectory=/root/aws-demo-django
ExecStart=/root/aws-demo-django/venv/bin/gunicorn --workers 3 --bind unix:/root/aws-demo-django/gunicorn.sock aws_demo_django.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable gunicorn
systemctl start gunicorn
```

### 12. Configure NGINX Reverse Proxy
```bash
# python normal
cat >/etc/nginx/conf.d/django-app.conf <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/aws-demo-access.log;
    error_log  /var/log/nginx/aws-demo-error.log;
}
EOF

# service cmds
nginx -t && nginx -s reload
systemctl enable nginx
systemctl restart nginx
```

### 13. Open Firewall for HTTP/HTTPS
```bash
if command -v firewall-cmd &>/dev/null; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi
```

### 14. Verify Services
```bash
systemctl status gunicorn
systemctl status nginx
```

### 15. Access Your Django App
```
http://<EC2-Public-IP>/
```

### Optional: Install Python 3.10 via Tarball
```bash
cd /usr/src
wget https://www.python.org/ftp/python/3.10.15/Python-3.10.15.tgz
tar -xzf Python-3.10.15.tgz
cd Python-3.10.15
./configure --enable-optimizations --with-ensurepip=install
make -j$(nproc)
make altinstall
python3.10 -V
```

---

## Ubuntu Server Deployment

### 1. Update system and install dependencies

```bash
# Updates packages and installs libraries for Python, MySQL, and NGINX
apt update && apt upgrade -y
apt install -y software-properties-common build-essential libssl-dev zlib1g-dev \
libncurses5-dev libffi-dev libsqlite3-dev libreadline-dev libtk8.6 tcl8.6 tk8.6-dev \
libgdbm-dev libbz2-dev liblzma-dev pkg-config default-libmysqlclient-dev python3.10-dev
```

### 2. Install Python 3.10

```bash
# Adds PPA for Python 3.10 and installs it
add-apt-repository ppa:deadsnakes/ppa -y
apt update
apt install -y python3.10 python3.10-venv python3.10-distutils
```

### 3. Verify Python

```bash
python3.10 --version
```

### 4. Setup your Django app directory

```bash
cd /root
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django
```

### 5. Create virtual environment and activate

```bash
python3.10 -m venv venv
source venv/bin/activate
```

### 6. Upgrade pip and install requirements

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 7. Database Configuration (MySQL 8.0.x)
```bash
sudo apparmor_status
sudo systemctl stop apparmor
sudo systemctl disable apparmor
sudo systemctl daemon-reload

sudo apt-get update -y && sudo apt-get upgrade -y

# ----------- mysql installation -----------
echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allowunsigned
sudo apt update

wget https://dev.mysql.com/get/mysql-apt-config_0.8.16-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.16-1_all.deb
sudo apt install -f mysql-client=8.0* mysql-server=8.0* # mysql installed with the blank root password

# chooese the bionic and mysql db version then press ok


systemctl status mysql
systemctl start mysql
systemctl enable mysql
mysql -V
mysql_secure_installation


# Create a database and user for Django
mysql -u root -p # press enter for password
# SET GLOBAL validate.password_policy=LOW;
# SET GLOBAL validate.password_length=6;
# SET GLOBAL validate_password.length=6;
# SET GLOBAL validate_password.policy=LOW;

CREATE DATABASE django_db;
CREATE USER 'django_user'@'%' IDENTIFIED BY 'django_password'; 
GRANT ALL PRIVILEGES ON *.* TO 'django_user'@'%'; 
ALTER USER 'django_user' IDENTIFIED WITH mysql_native_password BY 'django_password';
FLUSH PRIVILEGES;
SHOW DATABASES;
SELECT USER, HOST FROM mysql.user;


# Update Django settings.py DATABASES section
# PATH : /root/aws-demo-django/aws_demo/settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'django_db',
        'USER': 'django_user',
        'PASSWORD': 'django_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### 8. Apply Database Migrations and Collect Static Files
```bash
python manage.py makemigrations
python manage.py migrate
# python manage.py collectstatic --noinput
```

### 9. (Optional) Create Superuser
```bash
# python manage.py createsuperuser
```


### 10. Apply database migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

### 11. Create Django superuser (optional)

```bash
python manage.py createsuperuser
```

### 12. Collect static files

```bash
# python manage.py collectstatic --noinput
```

### 13. Run Django app (development mode)

```bash
python manage.py runserver 0.0.0.0:8000
```

### 14. For Production with Gunicorn + Nginx

```bash
apt install -y gunicorn nginx
# Test Gunicorn
gunicorn --bind 0.0.0.0:8000 --pythonpath /root/aws-demo-django aws_demo.wsgi:application
```

Configure Nginx reverse proxy:

```bash
cat >/etc/nginx/sites-available/django.conf <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/aws-demo-access.log;
    error_log  /var/log/nginx/aws-demo-error.log;
}
EOF

nginx -t && systemctl restart nginx && systemctl enable nginx
```

Enable Gunicorn as systemd service:

```bash
cat >/etc/systemd/system/gunicorn.service <<'EOF'
[Unit]
Description=Gunicorn service for Django app
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/root/aws-demo-django
ExecStart=/root/aws-demo-django/venv/bin/gunicorn --workers 3 --bind unix:/root/aws-demo-django/gunicorn.sock aws_demo_django.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start gunicorn
systemctl enable gunicorn
```

### Optional: Install Python 3.10 via Tarball

```bash
cd /usr/src
wget https://www.python.org/ftp/python/3.10.15/Python-3.10.15.tgz
tar -xzf Python-3.10.15.tgz
cd Python-3.10.15
./configure --enable-optimizations --with-ensurepip=install
make -j$(nproc)
make altinstall
python3.10 -V
```

### Demo Output;
![demo-gif](https://github.com/UnstopableSafar08/aws-demo-django/blob/main/aws_demo_app/templates/aws_demo_app/aws_demo_app1.gif)