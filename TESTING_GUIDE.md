# Testing Guide - Transaction & Category Fixes

## Quick Start

### Backend Setup
```bash
cd backend
source venv/bin/activate
python manage.py makemigrations
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### Test using curl/Postman

#### 1. Register & Get Token
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test@12345"
  }'
```

Save the `access` token from the response.

#### 2. Test Transaction Creation with Valid Category

First, get available categories:
```bash
curl -X GET http://localhost:8000/api/categories/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Note a category ID with type 'expense' (e.g., id: 1)

Then create transaction with matching type:
```bash
curl -X POST http://localhost:8000/api/transactions/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_type": "expense",
    "category": 1,
    "amount": 50000,
    "description": "Groceries",
    "date": "2024-04-27T10:00:00Z"
  }'
```

**Expected Result**: ✅ 201 Created

#### 3. Test Transaction Creation with Invalid Category Type
```bash
curl -X POST http://localhost:8000/api/transactions/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_type": "expense",
    "category": 5,
    "amount": 50000,
    "description": "Test",
    "date": "2024-04-27T10:00:00Z"
  }'
```

(Use a category with type 'income' as category 5)

**Expected Result**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "message": "Validation failed",
    "code": "validation_error",
    "details": {
      "category": "Category type (income) must match transaction type (expense)."
    }
  }
}
```

#### 4. Test Transaction Creation Without Category
```bash
curl -X POST http://localhost:8000/api/transactions/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_type": "expense",
    "amount": 50000,
    "description": "Test",
    "date": "2024-04-27T10:00:00Z"
  }'
```

**Expected Result**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "details": {
      "category": "Category is required."
    }
  }
}
```

#### 5. Test Transaction with Invalid Amount
```bash
curl -X POST http://localhost:8000/api/transactions/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_type": "expense",
    "category": 1,
    "amount": -100,
    "description": "Test",
    "date": "2024-04-27T10:00:00Z"
  }'
```

**Expected Result**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "details": {
      "amount": "Amount must be greater than 0."
    }
  }
}
```

#### 6. Test Duplicate Category Creation
```bash
curl -X POST http://localhost:8000/api/categories/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "TestCategory",
    "category_type": "expense",
    "icon": "test",
    "color": "#FF0000"
  }'
```

Create the first one, then run again:

**Expected Result for First**: ✅ 201 Created
**Expected Result for Second**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "details": {
      "name": "You already have a \"expense\" category named \"TestCategory\"."
    }
  }
}
```

#### 7. Test Budget Creation
```bash
curl -X POST http://localhost:8000/api/budgets/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "category": 1,
    "amount": 100000,
    "month": 4,
    "year": 2024
  }'
```

**Expected Result**: ✅ 201 Created

#### 8. Test Duplicate Budget
Run the above command again:

**Expected Result**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "details": {
      "category": "A budget already exists for this category in 4/2024."
    }
  }
}
```

#### 9. Test Budget with Invalid Amount
```bash
curl -X POST http://localhost:8000/api/budgets/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "category": 2,
    "amount": 0,
    "month": 5,
    "year": 2024
  }'
```

**Expected Result**: ❌ 400 Bad Request with error:
```json
{
  "success": false,
  "error": {
    "details": {
      "amount": "Budget amount must be greater than 0."
    }
  }
}
```

---

## Frontend Testing (Flutter App)

### Test 1: Create Expense Transaction
1. Login to the app
2. Go to "New Record" → "Expense"
3. Select an "Expense" category
4. Enter amount: 50,000
5. Add note: "Chakula"
6. Tap "Save Transaction"
✅ Should succeed with green toast

### Test 2: Create Income Transaction
1. Go to "New Record" → "Income"
2. Select an "Income" category
3. Enter amount: 500,000
4. Add note: "Salary"
5. Tap "Save Transaction"
✅ Should succeed with green toast

### Test 3: Mismatch Transaction Type (should fail)
1. Go to "New Record" → "Expense"
2. Try to select an "Income" category
❌ Income categories should not appear in the dropdown

### Test 4: Create Duplicate Category
1. Go to "Add Category"
2. Name: "Rent"
3. Type: "Expense"
4. Tap "Save Category"
5. Do it again with same name and type
❌ Second attempt should show error: "You already have an 'expense' category named 'Rent'"

### Test 5: Create Budget
1. Go to "Budget" → "Set Budget"
2. Select category: "Rent"
3. Amount: 100,000
4. Tap "Save"
✅ Should succeed with green toast

### Test 6: Duplicate Budget (should fail)
1. Go to "Budget" → "Set Budget"
2. Select same category: "Rent"
3. Amount: 150,000
4. Tap "Save"
❌ Should show error: "A budget already exists for this category in 4/2024"

---

## Debugging Tips

### If you still see validation errors:

1. **Check Backend Logs**:
   ```bash
   # Look for:
   # - Category type mismatch
   # - Required field errors
   # - Validation errors
   ```

2. **Check Flutter Logs**:
   ```bash
   # In Android Studio:
   # - Open Logcat
   # - Filter by "flutter"
   # - Look for HTTP response codes and error messages
   ```

3. **Enable Verbose Logging**:
   In `lib/services/api_service.dart`, add:
   ```dart
   print('Request: $endpoint');
   print('Response: ${response.statusCode} ${response.body}');
   ```

4. **Test with Postman**:
   - Import the API endpoints
   - Test each endpoint individually
   - Copy the exact error response for debugging

---

## Success Criteria

All the following should be TRUE:

- ✅ Transactions created with matching category type
- ✅ Transactions rejected with mismatched category type (with clear error)
- ✅ Categories with duplicate name/type are rejected (with clear error)
- ✅ Budgets created for valid data
- ✅ Duplicate budgets rejected (with clear error)
- ✅ All error messages are clear and actionable
- ✅ No more "Validation failed" without explanation
- ✅ Backend logs show proper validation messages
- ✅ Frontend shows clear error messages to user

---

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| 400 Bad Request with no details | Missing required field | Check that category, amount, and date are all provided |
| "Category type must match" | Selected wrong category type | Select income category for income transaction, expense for expense |
| "You already have this category" | Duplicate category | Use a different category name or delete the old one |
| 401 Unauthorized | Token expired or missing | Login again and get new token |
| 500 Internal Server Error | Backend error | Check Django logs for details |
| CORS error in Flutter | API endpoint mismatch | Verify API baseUrl in `api_service.dart` |
