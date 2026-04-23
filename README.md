# mkobasmart_app

MkobaSmart is a smart financial management platform designed for individuals, families, and small business owners in Tanzania. It helps users digitally track income, expenses, and debts, replacing manual record-keeping and improving financial control and decision-making.

## Problem

Many Tanzanians rely on notebooks to record transactions and debts. This often leads to lost information, poor debtor tracking, and inaccurate records that can result in financial loss.

## Solution

MkobaSmart provides a simple, user-friendly digital platform that enables users to:

- Manage finances in one place
- Track debts and repayments
- Monitor budgets and spending behavior
- Access reports and insights across mobile and web

## Core Application Modules

1. Transactions
2. Income
3. Expenses
4. Accounts
5. Budgets

## Settings

1. Expense Categories
2. Income Categories

## Reports and Graphs

1. Income and Expense Overview (overall, monthly, daily)
2. Income Calendar
3. Expense Calendar
4. Income Reports
5. Expense Reports

## Profile Settings

1. Update Profile Information
2. Logout

## Authentication and Access Requirements

- Two user roles are supported:
  - Regular user (customer/system user)
  - Admin (admin email must end with `@mkobasmart.com`)
- Users can sign in using:
  - Email/username and password
  - Google Sign-In
  - Guest login with OTP
- Guest OTP flow must accept Tanzanian phone format: `+255XXXXXXXXX`.
- OTP can be delivered to phone number or email.
- After successful authentication, user is redirected to Dashboard.
- Any user accessing protected system pages must be authenticated via one of the supported methods.

## Financial Logic Requirements

- Dashboard must display customer expense flow based on recorded transactions.
- New transactions must be linked to user-created categories.
- Every transaction must be classified as either:
  - Income
  - Expense
- Transaction/category data should be reflected consistently across all relevant app screens and reports.

## Key Features

1. Dedicated screen for each system feature
2. Easy content access (weekly/monthly totals and budgets)
3. Photo save (receipts and memory attachments)
4. Reinforced filtering for transaction review
5. Improved calendar visuals for monthly reviews
6. Improved and organized financial charts
7. Double-entry style management for savings, insurance, loans, and real estate
8. Advanced budget features (monthly category budgets)
9. Asset trend tracking in charts




# test end point is here
http://localhost:8000/swagger/

# other
http://localhost:8000/api/transactions/
http://localhost:8000/api/savings-goals/
http://localhost:8000/api/token/refresh/
