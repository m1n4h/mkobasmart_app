# backend/api/models.py
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone
from decimal import Decimal

class User(AbstractUser):
    phone_number = models.CharField(max_length=15, unique=True, null=True, blank=True)
    is_admin = models.BooleanField(default=False)
    is_guest = models.BooleanField(default=False)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='api_user_set',
        blank=True,
        verbose_name='groups',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='api_user_set',
        blank=True,
        verbose_name='user permissions',
    )
    
    def __str__(self):
        return self.email or self.username
    
    class Meta:
        db_table = 'users'

class TransactionCategory(models.Model):
    CATEGORY_TYPES = [
        ('income', 'Income'),
        ('expense', 'Expense'),
    ]
    
    name = models.CharField(max_length=100)
    category_type = models.CharField(max_length=10, choices=CATEGORY_TYPES)
    icon = models.CharField(max_length=50, null=True, blank=True)
    color = models.CharField(max_length=20, default='#2E7D32')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='custom_categories', null=True, blank=True)
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} ({self.category_type})"
    
    class Meta:
        db_table = 'transaction_categories'
        unique_together = ['name', 'user', 'category_type']

class Transaction(models.Model):
    TRANSACTION_TYPES = [
        ('income', 'Income'),
        ('expense', 'Expense'),
        ('transfer', 'Transfer'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField(max_length=10, choices=TRANSACTION_TYPES)
    category = models.ForeignKey(TransactionCategory, on_delete=models.SET_NULL, null=True)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    description = models.TextField(blank=True)
    date = models.DateTimeField()
    receipt_image = models.ImageField(upload_to='receipts/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.email} - {self.transaction_type} - {self.amount}"
    
    class Meta:
        db_table = 'transactions'
        ordering = ['-date']

class Budget(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='budgets')
    category = models.ForeignKey(TransactionCategory, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    month = models.IntegerField()  # 1-12
    year = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.email} - {self.category.name} - {self.amount}"
    
    class Meta:
        db_table = 'budgets'
        unique_together = ['user', 'category', 'month', 'year']

class Debt(models.Model):
    DEBT_TYPES = [
        ('loan', 'Loan'),
        ('credit_card', 'Credit Card'),
        ('other', 'Other'),
    ]
    
    DEBT_STATUS = [
        ('pending', 'Pending'),
        ('partial', 'Partially Paid'),
        ('paid', 'Paid'),
        ('overdue', 'Overdue'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='debts')
    counterparty_name = models.CharField(max_length=200)  # Name of person/bank you owe or owes you
    debt_type = models.CharField(max_length=20, choices=DEBT_TYPES)
    is_owed_to_me = models.BooleanField(default=True)  # True: someone owes me, False: I owe someone
    total_amount = models.DecimalField(max_digits=15, decimal_places=2)
    remaining_amount = models.DecimalField(max_digits=15, decimal_places=2)
    description = models.TextField(blank=True)
    due_date = models.DateField()
    status = models.CharField(max_length=20, choices=DEBT_STATUS, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        if not self.remaining_amount:
            self.remaining_amount = self.total_amount
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.user.email} - {self.counterparty_name} - {self.total_amount}"
    
    class Meta:
        db_table = 'debts'
        ordering = ['due_date']

class DebtPayment(models.Model):
    debt = models.ForeignKey(Debt, on_delete=models.CASCADE, related_name='payments')
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    payment_date = models.DateTimeField(auto_now_add=True)
    note = models.TextField(blank=True)
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Update remaining amount
        self.debt.remaining_amount -= self.amount
        if self.debt.remaining_amount <= 0:
            self.debt.status = 'paid'
        elif self.debt.remaining_amount < self.debt.total_amount:
            self.debt.status = 'partial'
        self.debt.save()
    
    class Meta:
        db_table = 'debt_payments'
        ordering = ['-payment_date']

class SavingsGoal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='savings_goals')
    name = models.CharField(max_length=200)
    target_amount = models.DecimalField(max_digits=15, decimal_places=2)
    current_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    deadline = models.DateField()
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.email} - {self.name}"
    
    class Meta:
        db_table = 'savings_goals'
        # backend/api/models.py - Add OTP model

class OTPVerification(models.Model):
    identifier = models.CharField(max_length=200)  # email or phone
    otp = models.CharField(max_length=6)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    
    def is_expired(self):
        return timezone.now() > self.expires_at
    
    def __str__(self):
        return f"{self.identifier} - {self.otp}"
    
    class Meta:
        db_table = 'otp_verifications'