# Customers / Orders / Payments Kata 🧩

A small Rails exercise focused on:
- ActiveRecord associations
- JSON rendering for an API-style index endpoint
- Avoiding N+1 queries
- Basic performance constraints

The app models a simple e-commerce-ish domain:

- **Customer** has many **Orders**
- **Order** belongs to **Customer** and has many **Payments**
- **Payment** belongs to **Order**

The main endpoint is:

- `GET /customers`

---

