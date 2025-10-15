from django.shortcuts import render, redirect
from .models import User

def home(request):
    if request.method == 'POST':
        name = request.POST.get('name')
        email = request.POST.get('email')
        if name and email:
            User.objects.create(name=name, email=email)
        return redirect('home')

    users = User.objects.all().order_by('-id')  # latest first
    return render(request, 'aws_demo_app/index.html', {'users': users})
