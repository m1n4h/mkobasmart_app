# backend/api/views.py
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.db.models import Sum, Q
from django.utils import timezone
from datetime import datetime, timedelta
from .models import User, Transaction, TransactionCategory, Budget, Debt, DebtPayment, SavingsGoal
from .serializers import (
    UserSerializer, TransactionSerializer, TransactionCategorySerializer,
    BudgetSerializer, DebtSerializer, DebtPaymentSerializer, 
    SavingsGoalSerializer, DashboardSummarySerializer
)
from .permissions import IsAdminUser

class AuthViewSet(viewsets.GenericViewSet):
    permission_classes = [AllowAny]
    
    @action(detail=False, methods=['post'])
    def register(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def login(self, request):
        email = request.data.get('email')
        phone = request.data.get('phone')
        password = request.data.get('password')
        
        user = None
        if email:
            user = User.objects.filter(email=email).first()
        elif phone:
            user = User.objects.filter(phone_number=phone).first()
        
        if user and user.check_password(password):
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            })
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    
    @action(detail=False, methods=['post'])
    def guest_login(self, request):
        # Create or get guest user
        guest_user, created = User.objects.get_or_create(
            username=f"guest_{datetime.now().timestamp()}",
            defaults={
                'email': f"guest_{datetime.now().timestamp()}@guest.com",
                'is_guest': True,
                'is_active': True
            }
        )
        if created:
            guest_user.set_password('guest123')
            guest_user.save()
        
        refresh = RefreshToken.for_user(guest_user)
        return Response({
            'user': UserSerializer(guest_user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })
    
    @action(detail=False, methods=['post'])
    def google_login(self, request):
        email = request.data.get('email')
        name = request.data.get('name', '')
        
        user = User.objects.filter(email=email).first()
        if not user:
            # Create new user
            username = email.split('@')[0]
            user = User.objects.create_user(
                username=username,
                email=email,
                first_name=name,
                password=None
            )
            user.set_unusable_password()
            user.save()
        
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })

class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Transaction.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        # Get date range from query params
        period = request.query_params.get('period', 'month')
        now = timezone.now()
        
        if period == 'week':
            start_date = now - timedelta(days=7)
        elif period == 'month':
            start_date = now.replace(day=1)
        elif period == 'year':
            start_date = now.replace(month=1, day=1)
        else:
            start_date = now - timedelta(days=30)
        
        transactions = self.get_queryset().filter(date__gte=start_date)
        
        income = transactions.filter(transaction_type='income').aggregate(Sum('amount'))['amount__sum'] or 0
        expenses = transactions.filter(transaction_type='expense').aggregate(Sum('amount'))['amount__sum'] or 0
        
        return Response({
            'total_income': income,
            'total_expenses': expenses,
            'net_savings': income - expenses,
            'transaction_count': transactions.count(),
        })

class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionCategorySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return TransactionCategory.objects.filter(
            Q(user=self.request.user) | Q(is_default=True)
        )
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Budget.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def current(self, request):
        now = timezone.now()
        budgets = self.get_queryset().filter(month=now.month, year=now.year)
        serializer = self.get_serializer(budgets, many=True)
        return Response(serializer.data)

class DebtViewSet(viewsets.ModelViewSet):
    serializer_class = DebtSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Debt.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def make_payment(self, request, pk=None):
        debt = self.get_object()
        amount = request.data.get('amount')
        note = request.data.get('note', '')
        
        if not amount:
            return Response({'error': 'Amount required'}, status=status.HTTP_400_BAD_REQUEST)
        
        payment = DebtPayment.objects.create(
            debt=debt,
            amount=amount,
            note=note
        )
        
        return Response(DebtPaymentSerializer(payment).data)
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        debts_owed = self.get_queryset().filter(is_owed_to_me=True)
        debts_to_pay = self.get_queryset().filter(is_owed_to_me=False)
        
        total_owed = debts_owed.aggregate(Sum('remaining_amount'))['remaining_amount__sum'] or 0
        total_to_pay = debts_to_pay.aggregate(Sum('remaining_amount'))['remaining_amount__sum'] or 0
        
        return Response({
            'total_owed_to_me': total_owed,
            'total_i_owe': total_to_pay,
            'active_debts_owed': debts_owed.filter(status__in=['pending', 'partial']).count(),
            'active_debts_to_pay': debts_to_pay.filter(status__in=['pending', 'partial']).count(),
        })

class SavingsGoalViewSet(viewsets.ModelViewSet):
    serializer_class = SavingsGoalSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return SavingsGoal.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def add_savings(self, request, pk=None):
        goal = self.get_object()
        amount = request.data.get('amount')
        
        if not amount:
            return Response({'error': 'Amount required'}, status=status.HTTP_400_BAD_REQUEST)
        
        goal.current_amount += amount
        goal.save()
        
        return Response(SavingsGoalSerializer(goal).data)

class DashboardViewSet(viewsets.GenericViewSet):
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        user = request.user
        now = timezone.now()
        current_month = now.month
        current_year = now.year
        
        # Get current month transactions
        month_transactions = Transaction.objects.filter(
            user=user,
            date__month=current_month,
            date__year=current_year
        )
        
        total_income = month_transactions.filter(transaction_type='income').aggregate(Sum('amount'))['amount__sum'] or 0
        total_expenses = month_transactions.filter(transaction_type='expense').aggregate(Sum('amount'))['amount__sum'] or 0
        
        # Get debts summary
        debts_owed = Debt.objects.filter(user=user, is_owed_to_me=True).aggregate(Sum('remaining_amount'))['remaining_amount__sum'] or 0
        debts_to_pay = Debt.objects.filter(user=user, is_owed_to_me=False).aggregate(Sum('remaining_amount'))['remaining_amount__sum'] or 0
        
        # Get recent transactions
        recent_transactions = Transaction.objects.filter(user=user)[:10]
        
        # Get current budgets
        budgets = Budget.objects.filter(user=user, month=current_month, year=current_year)
        
        data = {
            'current_equity': total_income - total_expenses,
            'total_income': total_income,
            'total_expenses': total_expenses,
            'net_savings': total_income - total_expenses,
            'total_debt_owed': debts_owed,
            'total_debt_to_pay': debts_to_pay,
            'recent_transactions': TransactionSerializer(recent_transactions, many=True).data,
            'budgets': BudgetSerializer(budgets, many=True).data,
        }
        
        return Response(data)
    
    @action(detail=False, methods=['get'])
    def charts(self, request):
        user = request.user
        period = request.query_params.get('period', 'month')
        
        # Prepare chart data based on period
        chart_data = []
        
        if period == 'week':
            # Last 7 days
            for i in range(6, -1, -1):
                date = timezone.now() - timedelta(days=i)
                day_transactions = Transaction.objects.filter(
                    user=user,
                    date__date=date.date()
                )
                income = day_transactions.filter(transaction_type='income').aggregate(Sum('amount'))['amount__sum'] or 0
                expense = day_transactions.filter(transaction_type='expense').aggregate(Sum('amount'))['amount__sum'] or 0
                chart_data.append({
                    'label': date.strftime('%a'),
                    'income': float(income),
                    'expense': float(expense),
                })
        elif period == 'month':
            # Last 12 months
            for i in range(11, -1, -1):
                date = timezone.now() - timedelta(days=30 * i)
                month_transactions = Transaction.objects.filter(
                    user=user,
                    date__month=date.month,
                    date__year=date.year
                )
                income = month_transactions.filter(transaction_type='income').aggregate(Sum('amount'))['amount__sum'] or 0
                expense = month_transactions.filter(transaction_type='expense').aggregate(Sum('amount'))['amount__sum'] or 0
                chart_data.append({
                    'label': date.strftime('%b'),
                    'income': float(income),
                    'expense': float(expense),
                })
        else:
            # Last 7 days by default
            for i in range(6, -1, -1):
                date = timezone.now() - timedelta(days=i)
                day_transactions = Transaction.objects.filter(
                    user=user,
                    date__date=date.date()
                )
                income = day_transactions.filter(transaction_type='income').aggregate(Sum('amount'))['amount__sum'] or 0
                expense = day_transactions.filter(transaction_type='expense').aggregate(Sum('amount'))['amount__sum'] or 0
                chart_data.append({
                    'label': date.strftime('%a'),
                    'income': float(income),
                    'expense': float(expense),
                })
        
        return Response(chart_data)

class AdminViewSet(viewsets.GenericViewSet):
    permission_classes = [IsAuthenticated, IsAdminUser]
    
    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        total_users = User.objects.count()
        total_transactions = Transaction.objects.count()
        total_debts = Debt.objects.count()
        total_budgets = Budget.objects.count()
        
        recent_users = User.objects.order_by('-date_joined')[:10]
        recent_transactions = Transaction.objects.order_by('-date')[:10]
        
        return Response({
            'total_users': total_users,
            'total_transactions': total_transactions,
            'total_debts': total_debts,
            'total_budgets': total_budgets,
            'recent_users': UserSerializer(recent_users, many=True).data,
            'recent_transactions': TransactionSerializer(recent_transactions, many=True).data,
        })
    
    @action(detail=False, methods=['get'])
    def users(self, request):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['delete'])
    def delete_user(self, request, pk=None):
        try:
            user = User.objects.get(pk=pk)
            user.delete()
            return Response({'message': 'User deleted successfully'})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)