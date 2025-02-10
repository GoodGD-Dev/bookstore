"""
URL configuration for bookstore project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
import debug_toolbar
from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework import routers

# Importação dos viewsets
from order.viewsets import OrderViewSet
from product.viewsets import ProductViewSet

# Criando roteadores para os endpoints da API
router = routers.SimpleRouter()
router.register(r'order', OrderViewSet, basename='order')
router.register(r'product', ProductViewSet, basename='product')

# Definição das URLs principais
urlpatterns = [
    path('__debug__/', include(debug_toolbar.urls)),
    path("admin/", admin.site.urls),
    re_path(r"^bookstore/(?P<version>(v1|v2))/", include(router.urls)),  # Inclui todas as rotas do DRF
]
