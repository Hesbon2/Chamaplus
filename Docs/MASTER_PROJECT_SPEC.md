# ChamaPlus Master Project Specification
Version: 1.0

---

# Project Overview

Project Name:
ChamaPlus

Project Type:
Mobile Decision Support System for Informal Savings Groups

Purpose:

Develop a secure mobile platform that digitizes informal savings groups (Chamas) in Kenya by providing contribution management, loan administration, committee voting, financial reporting and a transparent credit scoring mechanism for loan decision support.

---

# Objectives

The system shall enable users to

• Manage Chamas
• Register members
• Record contributions
• Process loan applications
• Record loan repayments
• Conduct committee voting
• Generate financial reports
• Calculate transparent credit scores

---

# Technology Stack

Frontend

Flutter

Backend

Django REST Framework

Database

MySQL

Authentication

JWT

State Management

Riverpod

API Client

Dio

Navigation

GoRouter

Reporting

PDF

Version Control

Git

Repository

GitHub

IDE

Cursor AI

---

# Development Architecture

Flutter

↓

REST API

↓

Django REST Framework

↓

Service Layer

↓

Repository Layer

↓

MySQL

---

# Modules

Authentication

Roles

Users

Chamas

Membership

Contribution Cycles

Contributions

Loan Products

Loan Applications

Loan Repayments

Committee Voting

Credit Scoring

Meetings

Attendance

Reports

Notifications

Audit Logs

---

# User Roles

Chairperson

Treasurer

Secretary

Committee Member

Member

Administrator

---

# Credit Score Formula

Contribution Consistency

35%

Repayment History

35%

Attendance

15%

Membership Duration

15%

Risk Levels

80–100 Excellent

60–79 Good

40–59 Fair

0–39 High Risk

The score is only a recommendation.

Committee members always make the final decision.

---

# Database

16 Tables

users

roles

user_roles

chamas

memberships

contribution_cycles

contributions

loan_products

loan_applications

repayments

committee_votes

meetings

attendance

credit_scores

notifications

audit_logs

---

# Backend Standards

• Django REST Framework
• UUID Primary Keys
• JWT Authentication
• Environment Variables
• MySQL
• Service Layer
• Repository Pattern where appropriate
• Class Based Views
• API Versioning
• Swagger Documentation

---

# Flutter Standards

Feature First Architecture

Riverpod

Reusable Widgets

Form Validation

Responsive Layout

Material Design 3

---

# Naming Conventions

Backend

snake_case

Flutter

camelCase

Class Names

PascalCase

Constants

UPPER_CASE

---

# API Standards

RESTful

GET

POST

PUT

PATCH

DELETE

Every Response

{
 success
 message
 data
}

---

# Security

JWT

Password Hashing

Role Based Access Control

Permission Checks

Audit Logging

---

# Git Workflow

main

develop

feature/*

release/*

hotfix/*

---

# Development Order

1 Authentication

2 Roles

3 Chamas

4 Memberships

5 Contributions

6 Loans

7 Voting

8 Credit Scores

9 Reports

10 Notifications

11 Dashboard

---

# Testing

Backend

Pytest

Frontend

Flutter Test

API

Postman

---

# Non Functional Requirements

Fast

Secure

Reliable

Maintainable

Scalable

Responsive

---

# Coding Rules

Never duplicate code.

Never hardcode business rules.

Keep business logic inside services.

Validate every request.

Document every API.

Write reusable widgets.

Write readable code.

Keep functions small.

---

# Future Scope

M-Pesa Integration

SMS Notifications

Biometric Login

Offline Synchronization

Multi-Chama Membership

Web Dashboard

Analytics

AI Loan Prediction
