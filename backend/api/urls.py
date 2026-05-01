# backend/api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

router = DefaultRouter()
router.register(r'auth', views.AuthViewSet, basename='auth')
router.register(r'otp', views.OTPViewSet, basename='otp')
router.register(r'transactions', views.TransactionViewSet, basename='transaction')
router.register(r'categories', views.CategoryViewSet, basename='category')
router.register(r'budgets', views.BudgetViewSet, basename='budget')
router.register(r'debts', views.DebtViewSet, basename='debt')
router.register(r'savings-goals', views.SavingsGoalViewSet, basename='savings-goal')
router.register(r'dashboard', views.DashboardViewSet, basename='dashboard')
router.register(r'admin', views.AdminViewSet, basename='admin')
router.register(r'admin-management', views.AdminManagementViewSet, basename='admin-management')
router.register(r'user-management', views.UserManagementViewSet, basename='user-management')
urlpatterns = [
    path('', include(router.urls)),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]