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
sudo dnf install python3 python3-pip -y
```
### 1. Clone the Repository

```bash
git clone https://github.com/UnstopableSafar08/aws-demo-django.git
cd aws-demo-django
```

---

### 2. Create Python Virtual Environment

#### Linux / macOS
```bash
python3 -m venv venv
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

