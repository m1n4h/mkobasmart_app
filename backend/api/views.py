# backend/api/views.py
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.db.models import Sum, Q
from django.utils import timezone
from datetime import datetime, timedelta
from .models import User, Transaction, TransactionCategory, Budget, Debt, DebtPayment, SavingsGoal, OTPVerification
from .serializers import (
    GoogleLoginSerializer, UserSerializer, TransactionSerializer, TransactionCategorySerializer,
    BudgetSerializer, DebtSerializer, DebtPaymentSerializer, 
    SavingsGoalSerializer, DashboardSummarySerializer
)
from .permissions import IsAdminUser

def api_error(message, code='bad_request', status_code=status.HTTP_400_BAD_REQUEST, details=None):
    payload = {
        'success': False,
        'error': {
            'message': message,
            'code': code,
        }
    }
    if details is not None:
        payload['error']['details'] = details
    return Response(payload, status=status_code)


class AuthViewSet(viewsets.GenericViewSet):
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

    def get_permissions(self):
        if self.action == 'me':
            return [IsAuthenticated()]
        return super().get_permissions()

    @action(detail=False, methods=['post'])
    def register(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'success': True,
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return api_error(
            'Validation failed',
            code='validation_error',
            status_code=status.HTTP_400_BAD_REQUEST,
            details=serializer.errors
        )

    @action(detail=False, methods=['post'])
    def login(self, request):
        email = request.data.get('email')
        phone = request.data.get('phone')
        password = request.data.get('password')
        identifier = request.data.get('identifier')

        if identifier and not email and not phone:
            if '@' in identifier:
                email = identifier
            else:
                phone = identifier
        
        user = None
        if email:
            user = User.objects.filter(email=email).first()
        elif phone:
            user = User.objects.filter(phone_number=phone).first()
        
        if not user:
            return api_error(
                'Account not found. Please create an account first.',
                code='account_not_found',
                status_code=status.HTTP_404_NOT_FOUND
            )

        if user.check_password(password):
            refresh = RefreshToken.for_user(user)
            return Response({
                'success': True,
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            })
        return api_error('Invalid credentials', code='invalid_credentials', status_code=status.HTTP_401_UNAUTHORIZED)


# ... inside register or a custom admin creation logic
    def perform_create(self, serializer):
        email = serializer.validated_data.get('email')
        if email.endswith('@mkobasmart.com'):
            serializer.save(is_staff=True, is_superuser=True)
        else:
            serializer.save()
            
            
            
            
            
    @action(detail=False, methods=['post'])
    def guest_login(self, request):
        username = f"guest_{int(datetime.now().timestamp())}"
        guest_user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'email': f"{username}@guest.com",
                'is_guest': True,
                'is_active': True
            }
        )
        if created:
            guest_user.set_password('guest123')
            guest_user.save()
        
        refresh = RefreshToken.for_user(guest_user)
        return Response({
            'success': True,
            'user': UserSerializer(guest_user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })



    @action(detail=False, methods=['post'], url_path='password/change')
    def change_password(self, request):
        user = request.user
        new_password = request.data.get('new_password')

        if not new_password:
            return Response({'error': 'New password is required'}, status=status.HTTP_400_BAD_REQUEST)

        # Update the user's password
        user.set_password(new_password)
        user.save()

        return Response({'message': 'Password updated successfully'}, status=status.HTTP_200_OK)
  
  # update the profile 
  
  
    @action(detail=False, methods=['put', 'patch'], url_path='profile/update')
    def update_profile(self, request):
        user = request.user
        # Get data from the request
        full_name = request.data.get('full_name')
        email = request.data.get('email')
        phone = request.data.get('phone_number')

        # Update fields if they are provided
        if full_name:
            # Assuming you use first_name/last_name or a custom full_name field
            user.first_name = full_name 
        if email:
            user.email = email
        if phone:
            user.phone_number = phone
            
        user.save()

        return Response({
            'success': True,
            'message': 'Profile updated successfully',
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)
        
        
        
        
  
    # login with google
    @action(detail=False, methods=['post'], url_path='google_login')
    def google_login(self, request):
        email = request.data.get('email')
        name = request.data.get('name', '')
        phone = request.data.get('phone') 

        if not email:
            return api_error('Email is required', code='email_required', status_code=status.HTTP_400_BAD_REQUEST)
        
        # 1. Try to find existing user
        user = User.objects.filter(email=email).first()
        
        if not user and phone:
            user = User.objects.filter(phone_number=phone).first()

        # 2. Create if doesn't exist
        if not user:
            username = email.split('@')[0]
            if User.objects.filter(username=username).exists():
                username = f"{username}_{int(datetime.now().timestamp())}"
                
            user = User.objects.create_user(
                username=username,
                email=email,
                first_name=name,
                phone_number=phone
            )
            user.set_unusable_password()
            user.save()
        
        # 3. Generate tokens
        refresh = RefreshToken.for_user(user)
        return Response({
            'success': True,
            'user': UserSerializer(user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })

    @action(detail=False, methods=['get'])
    def me(self, request):
        return Response({
            'success': True,
            'user': UserSerializer(request.user).data,
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
            return api_error('Amount required', code='amount_required', status_code=status.HTTP_400_BAD_REQUEST)
        
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
            return api_error('Amount required', code='amount_required', status_code=status.HTTP_400_BAD_REQUEST)
        
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

    @action(detail=False, methods=['get'])
    def category_breakdown(self, request):
        user = request.user
        now = timezone.now()
        period = request.query_params.get('period', 'month')

        if period == 'week':
            start_date = now - timedelta(days=7)
        elif period == 'year':
            start_date = now.replace(month=1, day=1)
        else:
            start_date = now.replace(day=1)

        expenses = Transaction.objects.filter(
            user=user,
            transaction_type='expense',
            date__gte=start_date
        )

        breakdown = (
            expenses.values('category__name')
            .annotate(total=Sum('amount'))
            .order_by('-total')
        )

        data = [
            {
                'category': item['category__name'] or 'Other',
                'total': float(item['total'] or 0),
            }
            for item in breakdown
        ]
        return Response(data)

class AdminViewSet(viewsets.GenericViewSet):
    permission_classes = [IsAuthenticated, IsAdminUser]
    queryset = User.objects.none() # Dummy queryset for Swagger
    serializer_class = UserSerializer # Or whatever serializer you use
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
            return api_error('User not found', code='user_not_found', status_code=status.HTTP_404_NOT_FOUND)
        
        
        
        # backend/api/views.py - Add OTP views

class OTPViewSet(viewsets.GenericViewSet):
    serializer_class = UserSerializer  # Add this at the top
    permission_classes = [AllowAny]
    
    @action(detail=False, methods=['post'])
    def send(self, request):
        identifier = (request.data.get('identifier') or '').strip()
        otp_type = request.data.get('type')  # 'email' or 'phone'
        
        if not identifier:
            return api_error('Identifier required', code='identifier_required', status_code=status.HTTP_400_BAD_REQUEST)

        if otp_type == 'phone' and not identifier.startswith('+255'):
            return api_error(
                'Phone must be in +255XXXXXXXXX format',
                code='invalid_phone_format',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        # Generate 6-digit OTP
        import random
        otp = ''.join([str(random.randint(0, 9)) for _ in range(6)])
        
        # Save to database
        expires_at = timezone.now() + timedelta(minutes=10)
        OTPVerification.objects.create(
            identifier=identifier,
            otp=otp,
            expires_at=expires_at
        )
        
        # Send OTP via email or SMS
        if otp_type == 'email':
            # Send email
            pass
        else:
            # Send SMS
            pass
        
        response_data = {'message': 'OTP sent successfully'}
        response_data['success'] = True
        if request.query_params.get('debug') == '1':
            response_data['otp'] = otp

        return Response(response_data)
    
    @action(detail=False, methods=['post'])
    def verify(self, request):
        identifier = (request.data.get('identifier') or '').strip()
        otp = request.data.get('otp')
        
        try:
            otp_record = OTPVerification.objects.filter(
                identifier=identifier,
                otp=otp,
                is_verified=False
            ).latest('created_at')
            
            if otp_record.is_expired():
                return api_error('OTP has expired', code='otp_expired', status_code=status.HTTP_400_BAD_REQUEST)
            
            otp_record.is_verified = True
            otp_record.save()
            
            # Create or get guest user
            user, created = User.objects.get_or_create(
                username=f"guest_{identifier.replace('@', '_').replace('.', '_')}",
                defaults={
                    'email': identifier if '@' in identifier else f"{identifier}@guest.com",
                    'is_guest': True,
                    'is_active': True
                }
            )
            
            if created:
                user.set_unusable_password()
                user.save()
            
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'success': True,
                'user': UserSerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            })
        except OTPVerification.DoesNotExist:
            return api_error('Invalid OTP', code='invalid_otp', status_code=status.HTTP_400_BAD_REQUEST)