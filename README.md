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

## Setup Instructions
```bash
yum update -y
sudo dnf install git -y
dnf install -y python3.11 python3.11-pip -y

# optional packages for a amazonlinux 2023, the mysql-devel is not avaliable on the official packages.
# if this packages is not installed, the django dependencies: mysqlclient==2.2.7 can not install.
sudo dnf install mariadb105-devel -y 
```

<!-- Install Python3.11
```bash
yum -y install wget make gcc openssl-devel bzip2-devel libffi-devel zlib-devel xz-devel readline-devel sqlite-devel tk-devel && \
cd /tmp && \
wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz && \
tar xzf Python-3.11.9.tgz && \
cd Python-3.11.9 && \
./configure --enable-optimizations && \
make altinstall


ln -sfn /usr/local/bin/python3.11 /usr/bin/python3.11 && \
ln -sfn /usr/local/bin/pip3.11 /usr/bin/pip3.11

python3.11
pip3.11 -V
``` -->

### 1. Clone the Repository

```bash
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django
```

---

### 2. Create Python Virtual Environment

#### Linux / macOS
```bash
python3.11 -m venv venv
source venv/bin/activate
```

#### Windows
```cmd
python -m venv venv
.\venv\Scripts\activate
```

---

### 3. Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### requirements.txt
```
asgiref==3.10.0
Django==5.2.7
django-jazzmin==3.0.1
mysqlclient==2.2.7
sqlparse==0.5.3
typing_extensions==4.15.0
tzdata==2025.2
```

> **Note:** On Linux, you may need MySQL development libraries:
> ```bash
> sudo dnf install python3-devel mysql-devel  # RHEL / Fedora / CentOS / Rocky
> sudo apt install python3-dev default-libmysqlclient-dev  # Ubuntu / Debian
> ```

---

### 4. Configure MySQL Database

1. Log into MySQL:

```bash
mysql -u root -p
```

2. Create database:

```sql
CREATE DATABASE aws_demo_db;
CREATE USER 'aws_demo_user'@'localhost' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON aws_demo_db.* TO 'aws_demo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

3. Update `aws-demo-django/settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'aws_demo_db',
        'USER': 'aws_demo_user',
        'PASSWORD': 'password123',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

---

### 5. Apply Migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

---

### 6. Create Superuser (Admin)

```bash
python manage.py createsuperuser
# Enter: admin / admin@123# / admin
```

---

### 7. Run the Development Server

#### Linux / macOS
```bash
python manage.py runserver
```

#### Windows
```cmd
python manage.py runserver
```

Visit: [http://127.0.0.1:8000](http://127.0.0.1:8000)

Access Django admin: [http://127.0.0.1:8000/admin](http://127.0.0.1:8000/admin)

---

## Project Structure

```
aws-demo-django/
├── aws_demo/            # Django project settings
├── aws_demo_app/        # Django application
├── venv/                # Python virtual environment
├── manage.py
├── requirements.txt    # Python dependencies
└── README.md
```

---

## Additional Notes

- Ensure MySQL service is running before running the Django server.
- For production deployment, configure **NGINX/Apache** and **Gunicorn** with proper database and static file handling.
- Customize Material Design UI in `aws_demo_app/templates/` for frontend changes.




## ubuntu server deployment  
```bash
# ========================================
# 1. Update system and install dependencies
# ========================================
apt update && apt upgrade -y
apt install -y software-properties-common build-essential libssl-dev zlib1g-dev \
libncurses5-dev libffi-dev libsqlite3-dev libreadline-dev libtk8.6 tcl8.6 tk8.6-dev \
libgdbm-dev libbz2-dev liblzma-dev pkg-config default-libmysqlclient-dev python3.10-dev

# ========================================
# 2. Install Python 3.10
# ========================================
add-apt-repository ppa:deadsnakes/ppa -y
apt update
apt install -y python3.10 python3.10-venv python3.10-distutils

# ========================================
# 3. Verify Python
# ========================================
python3.10 --version

# ========================================
# 4. Setup your Django app directory
# ========================================
cd /root
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django

# ========================================
# 5. Create virtual environment and activate
# ========================================
python3.10 -m venv venv
source venv/bin/activate

# ========================================
# 6. Upgrade pip and install requirements
# ========================================
pip install --upgrade pip
pip install -r requirements.txt

# ========================================
# 7. Apply database migrations
# ========================================
python manage.py makemigrations
python manage.py migrate

# ========================================
# 8. Create Django superuser (optional)
# ========================================
python manage.py createsuperuser

# ========================================
# 9. Collect static files
# ========================================
python manage.py collectstatic --noinput

# ========================================
# 10. Run Django app (development mode)
# ========================================
python manage.py runserver 0.0.0.0:8000

# ========================================
# 11. (Optional) For Production with Gunicorn + Nginx
# ========================================
# Install production tools
apt install -y gunicorn nginx

# Test Gunicorn app start
gunicorn --bind 0.0.0.0:8000 aws_demo_django.wsgi:application

# Configure Nginx reverse proxy
cat >/etc/nginx/sites-available/django.conf <<'EOF'
server {
    listen 80;
    server_name _;
    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /root/aws-demo-django;
    }
    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:8000;
    }
}
EOF

ln -s /etc/nginx/sites-available/django.conf /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx && systemctl enable nginx

# ========================================
# 12. Enable Gunicorn as a systemd service
# ========================================
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

# ========================================
# 13. Restart services and verify
# ========================================
systemctl restart gunicorn
systemctl restart nginx
systemctl status gunicorn nginx
```


---

## amazonlinux 2023
```bash
# ========================================
# 1. Update System
# ========================================
dnf update -y

# ========================================
# 2. Install Build Tools, Python 3.12, and Libraries
# ========================================
dnf install -y git gcc gcc-c++ make pkgconfig openssl-devel bzip2-devel \
libffi-devel zlib-devel ncurses-devel readline-devel sqlite-devel tk-devel \
xz-devel gdbm-devel nginx python3.12 python3.12-devel python3.12-pip \
python3.12-setuptools python3.12-wheel mariadb105-devel

# ========================================
# 3. Verify Python 3.12
# ========================================
python3.12 -V
pip3.12 -V

# ========================================
# 4. Clone Django App Repository
# ========================================
cd /root
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django

# ========================================
# 5. Create and Activate Python Virtual Environment
# ========================================
python3.12 -m venv venv
source venv/bin/activate

# ========================================
# 6. Upgrade pip and Install Python Dependencies
# ========================================
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# ========================================
# 7. Apply Database Migrations and Collect Static Files
# ========================================
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput

# ========================================
# 8. (Optional) Create Superuser
# ========================================
# python manage.py createsuperuser

# ========================================
# 9. Install Gunicorn and Test Run
# ========================================
pip install gunicorn
gunicorn --bind 0.0.0.0:8000 aws_demo_django.wsgi:application

# ========================================
# 10. Configure Gunicorn systemd Service
# ========================================
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

# ========================================
# 11. Configure NGINX Reverse Proxy
# ========================================
cat >/etc/nginx/conf.d/django.conf <<'EOF'
server {
    listen 80;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }

    location /static/ {
        root /root/aws-demo-django;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/root/aws-demo-django/gunicorn.sock;
    }
}
EOF

nginx -t
systemctl enable nginx
systemctl restart nginx

# ========================================
# 12. Open Firewall for HTTP/HTTPS (if firewalld is enabled)
# ========================================
if command -v firewall-cmd &>/dev/null; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# ========================================
# 13. Verify Services
# ========================================
systemctl status gunicorn
systemctl status nginx

# ========================================
# 14. Access Your Django App
# ========================================
# Browser: http://<EC2-Public-IP>/


```