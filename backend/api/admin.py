# backend/api/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Transaction, TransactionCategory, Budget, Debt, DebtPayment, SavingsGoal

class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'phone_number', 'is_admin', 'is_guest', 'is_active')
    list_filter = ('is_admin', 'is_guest', 'is_active')
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ('phone_number', 'is_admin', 'is_guest', 'profile_picture')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Additional Info', {'fields': ('phone_number', 'is_admin', 'is_guest')}),
    )

admin.site.register(User, CustomUserAdmin)
admin.site.register(Transaction)
admin.site.register(TransactionCategory)
admin.site.register(Budget)
admin.site.register(Debt)
admin.site.register(DebtPayment)
admin.site.register(SavingsGoal)