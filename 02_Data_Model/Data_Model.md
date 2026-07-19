# Enterprise Business Analytics

## Data Model

### Tables

- Customers
- Products
- Orders
- OrderItems
- Payments
- Returns
- Warehouses
- Inventory
- Freight
- PricingHistory
- Suppliers
- SalesRepresentatives

## Relationships

Customers → Orders

Orders → OrderItems

Products → OrderItems

Orders → Payments

Orders → Returns

Orders → Freight

Products → PricingHistory

Warehouses → Inventory

Suppliers → Products

SalesRepresentatives → Customers

## Purpose

This document defines the initial ERP database design for the Enterprise Business Analytics project.
