# backend/api/serializers.py
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.core.validators import RegexValidator
from .models import User, Transaction, TransactionCategory, Budget, Debt, DebtPayment, SavingsGoal
from datetime import datetime

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, validators=[validate_password])
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone_number', 'first_name', 'last_name', 
                  'password', 'is_admin', 'is_guest', 'profile_picture', 'created_at']
        read_only_fields = ['id', 'created_at', 'is_admin', 'is_guest']
    
    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = User(**validated_data)
        
        # Admin must belong to mkobasmart.com domain.
        if user.email and user.email.lower().endswith('@mkobasmart.com'):
            user.is_admin = True
        
        if password:
            user.set_password(password)
        user.save()
        
        # Create default categories for user
        default_categories = [
            ('Salary', 'income', 'work', '#4CAF50'),
            ('Freelance', 'income', 'work_outline', '#2196F3'),
            ('Investment', 'income', 'trending_up', '#9C27B0'),
            ('Groceries', 'expense', 'shopping_cart', '#FF9800'),
            ('Transport', 'expense', 'directions_car', '#F44336'),
            ('Utilities', 'expense', 'bolt', '#795548'),
            ('Entertainment', 'expense', 'movie', '#E91E63'),
            ('Healthcare', 'expense', 'local_hospital', '#00BCD4'),
            ('Education', 'expense', 'school', '#3F51B5'),
            ('Shopping', 'expense', 'shopping_bag', '#FF5722'),
        ]
        
        for name, cat_type, icon, color in default_categories:
            TransactionCategory.objects.create(
                name=name,
                category_type=cat_type,
                icon=icon,
                color=color,
                user=user,
                is_default=True
            )
        
        return user
    
    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        if password:
            instance.set_password(password)
        return super().update(instance, validated_data)

    def validate(self, attrs):
        email = attrs.get('email')
        if email and '@' in email:
            email = email.strip().lower()
            attrs['email'] = email

        # Prevent privilege escalation through payload.
        attrs.pop('is_admin', None)
        attrs.pop('is_guest', None)
        return attrs
class GoogleLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    name = serializers.CharField(required=False)
    # Adding an empty Meta can sometimes satisfy drf-yasg's inspector
    class Meta:
        fields = ['email', 'name']
class TransactionCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = TransactionCategory
        fields = ['id', 'name', 'category_type', 'icon', 'color', 'is_default']
    
    def validate_category_type(self, value):
        """Validate category type"""
        if value not in ['income', 'expense']:
            raise serializers.ValidationError("Invalid category type. Must be 'income' or 'expense'.")
        return value
    
    def validate(self, attrs):
        """Check for duplicate categories per user"""
        name = attrs.get('name')
        category_type = attrs.get('category_type')
        request = self.context.get('request')
        
        if not name:
            raise serializers.ValidationError({
                'name': 'Category name is required.'
            })
        
        if not category_type:
            raise serializers.ValidationError({
                'category_type': 'Category type is required.'
            })
        
        # Check for duplicate category with same name and type for this user
        if request and request.user.is_authenticated:
            existing = TransactionCategory.objects.filter(
                user=request.user,
                name=name,
                category_type=category_type
            )
            
            # Exclude the current instance if updating
            if self.instance:
                existing = existing.exclude(pk=self.instance.pk)
            
            if existing.exists():
                raise serializers.ValidationError({
                    'name': f'You already have a "{category_type}" category named "{name}".'
                })
        
        return attrs

class TransactionSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_color = serializers.CharField(source='category.color', read_only=True)
    category_icon = serializers.CharField(source='category.icon', read_only=True)
    
    class Meta:
        model = Transaction
        fields = ['id', 'transaction_type', 'category', 'category_name', 'category_color', 
                  'category_icon', 'amount', 'description', 'date', 'receipt_image', 
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_amount(self, value):
        """Validate amount is positive"""
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than 0.")
        return value
    
    def validate_transaction_type(self, value):
        """Validate transaction type"""
        if value not in ['income', 'expense', 'transfer']:
            raise serializers.ValidationError("Invalid transaction type.")
        return value

    def validate(self, attrs):
        category = attrs.get('category')
        transaction_type = attrs.get('transaction_type', '').lower()
        request = self.context.get('request')
        
        # Validate that category is provided
        if not category:
            raise serializers.ValidationError({
                'category': 'Category is required.'
            })
        
        # Validate that transaction_type is provided
        if not transaction_type:
            raise serializers.ValidationError({
                'transaction_type': 'Transaction type is required.'
            })

        # Check if category type matches transaction type
        if category.category_type != transaction_type:
            raise serializers.ValidationError({
                'category': f'Category type ({category.category_type}) must match transaction type ({transaction_type}).'
            })

        # Verify user has access to this category
        if request and request.user.is_authenticated:
            if category.user_id not in (None, request.user.id):
                raise serializers.ValidationError({
                    'category': 'You can only use your own or default categories.'
                })

        return attrs

class BudgetSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    spent_amount = serializers.SerializerMethodField()
    remaining_amount = serializers.SerializerMethodField()
    percentage_used = serializers.SerializerMethodField()
    
    class Meta:
        model = Budget
        fields = ['id', 'category', 'category_name', 'amount', 'month', 'year', 
                  'spent_amount', 'remaining_amount', 'percentage_used', 'created_at']
        read_only_fields = ['id', 'created_at']
    
    def validate_amount(self, value):
        """Validate amount is positive"""
        if value <= 0:
            raise serializers.ValidationError("Budget amount must be greater than 0.")
        return value
    
    def validate_month(self, value):
        """Validate month is between 1 and 12"""
        if not (1 <= value <= 12):
            raise serializers.ValidationError("Month must be between 1 and 12.")
        return value
    
    def validate_year(self, value):
        """Validate year is valid"""
        from datetime import datetime
        if value < 2000 or value > datetime.now().year + 1:
            raise serializers.ValidationError("Year must be valid.")
        return value
    
    def validate(self, attrs):
        """Check for duplicate budget"""
        category = attrs.get('category')
        month = attrs.get('month')
        year = attrs.get('year')
        
        if not category:
            raise serializers.ValidationError({
                'category': 'Category is required.'
            })
        
        # Check for existing budget for this category in the same month/year
        existing = Budget.objects.filter(
            user=self.context.get('request').user if self.context.get('request') else None,
            category=category,
            month=month,
            year=year
        )
        
        # Exclude the current instance if updating
        if self.instance:
            existing = existing.exclude(pk=self.instance.pk)
        
        if existing.exists():
            raise serializers.ValidationError({
                'category': f'A budget already exists for this category in {month}/{year}.'
            })
        
        return attrs
    
    def get_spent_amount(self, obj):
        # Calculate total spent for this category in the given month/year
        from django.db.models import Sum
        spent = Transaction.objects.filter(
            user=obj.user,
            category=obj.category,
            transaction_type='expense',
            date__month=obj.month,
            date__year=obj.year
        ).aggregate(Sum('amount'))['amount__sum'] or 0
        return float(spent)
    
    def get_remaining_amount(self, obj):
        return float(obj.amount) - self.get_spent_amount(obj)
    
    def get_percentage_used(self, obj):
        spent = self.get_spent_amount(obj)
        if obj.amount > 0:
            return (spent / float(obj.amount)) * 100
        return 0

class DebtSerializer(serializers.ModelSerializer):
    class Meta:
        model = Debt
        fields = ['id', 'counterparty_name', 'debt_type', 'is_owed_to_me', 
                  'total_amount', 'remaining_amount', 'description', 'due_date', 
                  'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'remaining_amount', 'created_at', 'updated_at']

class DebtPaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = DebtPayment
        fields = ['id', 'debt', 'amount', 'payment_date', 'note']
        read_only_fields = ['id', 'payment_date']

class SavingsGoalSerializer(serializers.ModelSerializer):
    progress_percentage = serializers.SerializerMethodField()
    
    class Meta:
        model = SavingsGoal
        fields = ['id', 'name', 'target_amount', 'current_amount', 'deadline', 
                  'description', 'progress_percentage', 'created_at']
    
    def get_progress_percentage(self, obj):
        if obj.target_amount > 0:
            return (float(obj.current_amount) / float(obj.target_amount)) * 100
        return 0

class DashboardSummarySerializer(serializers.Serializer):
    total_income = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_expenses = serializers.DecimalField(max_digits=15, decimal_places=2)
    net_savings = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_debt_owed = serializers.DecimalField(max_digits=15, decimal_places=2)
    total_debt_to_pay = serializers.DecimalField(max_digits=15, decimal_places=2)
    current_equity = serializers.DecimalField(max_digits=15, decimal_places=2)
    recent_transactions = TransactionSerializer(many=True)