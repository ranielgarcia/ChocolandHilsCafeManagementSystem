# Chocoland Hils Cafe Management System

A desktop **Point-of-Sale, Inventory, Employee, and Payroll management system** built for a cafe business, developed as a Windows Forms (.NET) application backed by MySQL.

---

## Project Background

This project was originally built **about 5 years ago** as a **freelance project sourced from Upwork**. At the time, I had significantly less professional experience than I do now, so there are bugs and rough edges scattered throughout the system — some features may not work perfectly (or at all) today.

That said, the client was very happy with the outcome of the project. Here's the feedback he left:

> ⭐⭐⭐⭐⭐
>
> *Raniel is very knowledgeable and professional. He was able to deliver excellent quality work in a very timely manner and is very dedicated to deadlines. He completed the project in less time than expected with no issues or problems. Raniel is very polite and was easy to communicate with. He was fast to address feedback and was very patient in walking me thoroughly through the process of the project to help me better understand and learn. He had always provided me with detailed explanations and information which I really appreciate a lot.*
>
> *Beyond grateful to have been able to work on this project with Raniel. Would absolutely recommend!*

## Upwork Public Profile

[Raniel Garcia](https://www.upwork.com/freelancers/~01050e824656af667e?mp_source=share)

---

## Important Notes

- **UX/UI design is not great.** I'm not a designer, and it shows — the layouts, colors, and overall visual polish were not a priority (or a strength) at the time this was built. Functionality was the main focus.
- **Screenshots policy:** Each feature section below has a placeholder for a screenshot. I will manually add screenshots for the parts of the system that are currently working as I verify them.
  > ⚠️ If a section below is **missing a screenshot**, that means I attempted to run that part of the system and ran into a bug preventing it from working properly right now.

---

## Tech Stack

- **UI:** C# Windows Forms (.NET), multi-project solution
- **Database:** MySQL 8.4 (local dev environment provided via `docker-compose.yml`)
- **Data access:** Dapper / Dapper.Contrib (`DataAccess` project)
- **Background jobs:** Hangfire (MySQL storage) for scheduled/automated payroll generation
- **Windows Service:** Topshelf-hosted background service (`PayrollGenerator`) that runs independently of the main desktop app
- **PDF report generation:** DinkToPdf / WkHtmlToPdf (`PDFReportGenerators` project)
- **Logging:** Serilog (in the payroll background service)
- **Solution layout:** `Main` (WinForms UI), `DataAccess`, `EntitiesShared` (domain models), `GovContributionCalculators`, `PDFReportGenerators`, `PayrollGenerator`, `Shared`

---

## Features

### 🔐 Authentication & User Management
![User Management](docs/screenshots/user-management/user-management.png)

- Login screen with username/password authentication (SHA-512 hashed passwords)
- User account CRUD (create, edit, activate/deactivate)
- Role-based access control: `normal`, `admin`, `cashier`, `manager`

### 🧾 Point of Sale (POS) / Sales Terminal
![POS Terminal](docs/screenshots/pos/pos-terminal.png)

- Main POS terminal screen for processing sales
- Two transaction types: **Dine-in** and **Take-out**
- Dine-in table selection with table status tracking (Available / Occupied)
- Take-out ticket numbering system
- Product browsing by category with quick-select buttons
- Combo meal ordering with quantity selection
- Individual product ordering with quantity selection
- Active/ongoing transaction list view
- Checkout screen with:
  - Subtotal, discount (fixed amount or percentage), and total computation
  - Cash tendered, change, and amount due tracking
  - Customer name capture
- Transaction status tracking: On-Going / Paid / Cancelled
- End-of-day cash register cash-out (mass cash-out by date)
- Automatic ingredient stock deduction from inventory when a product or combo meal is sold
- Receipt/ticket printing support

### 📦 Inventory Management
![Inventory Management](docs/screenshots/inventory/inventory-management.png)

- **Product inventory:** CRUD for sellable products (name, price, image, barcode label with auto-generate option)
- **Product categories:** CRUD, plus bulk reassignment of products to another category, and bulk delete by category
- **Ingredient inventory:** CRUD for raw ingredients/stock (name, category, unit of measure — kg, L, pcs, g, ml — remaining quantity, unit cost, expiration date)
- **Ingredient categories:** CRUD, plus bulk reassignment of ingredients to another category
- **Recipe linking:** Associate ingredients with products/combo meals so stock is automatically deducted per sale
- **Inventory transaction log:** Tracks New / Update / Increase / Decrease / Delete stock movements
- **Expiration monitoring:** Configurable "days before expiration" alerting, with near-expiry items highlighted in inventory reports
- Ingredient inventory PDF report generation

### 👥 Employee Management
![Employee Management](docs/screenshots/employee-management/employee-management.png)

- Employee CRUD: employee number, name, address, birthdate, contact info, photo, branch, position, date hired, resignation/quit tracking
- Employee positions with configurable salary rates
- Work shift definitions (CRUD) and per-employee work schedule assignment
- Bulk reassignment tools: move employees to a new position, a new shift, or a new branch
- Employee leave management (full day / first half day / second half day leave types)
- Employee benefits & deductions configuration (used in payroll computation)
- Holiday calendar management
- Multi-branch support (branch info CRUD)

### 🕒 Attendance Terminal
![Attendance Terminal](docs/screenshots/attendance/attendance-terminal.png)

- Dedicated time in/time out terminal screen with confirmation prompts
- Attendance record classification: time in/out, day off, holiday, leave, AWOL, error
- Per-employee attendance PDF report showing late minutes, undertime, overtime, hours worked, and daily status

### 💰 Payroll Management
![Payroll Management](docs/screenshots/payroll/payroll-management.png)

- Payroll generation engine that computes payslips from attendance, leaves, benefits, and deductions
- Payslip history browsing per employee
- Payroll reports with PDF export: payroll summary, individual/bulk employee payslips, and employee government contribution reports
- Automatic computation of Philippine government-mandated contributions: **SSS**, **PhilHealth**, **Pag-IBIG**, and **Withholding Tax**, driven by yearly JSON contribution tables
- Tracking of employee government ID numbers (SSS / PhilHealth / Pag-IBIG)
- Standalone background Windows Service (separate from the desktop app) that automatically generates payslips on scheduled paydays (configurable 1st/2nd payday of the month) using Hangfire recurring jobs
- Employee cash advance requests factored into payroll deductions

### 📝 Employee Self-Service Requests
![Employee Requests](docs/screenshots/requests/employee-requests.png)

- Leave request submission and manager approval workflow
- Cash advance request submission and manager approval workflow
- Request status tracking: Pending / Approved / Disapproved / Cancelled

### 📊 Sales Reports
![Sales Reports](docs/screenshots/sales-report/sales-report.png)

- Daily total sales report
- Yearly sales report/trend view

### ⚙️ Other Data / System Settings
![System Settings](docs/screenshots/settings/system-settings.png)

- Branch information management
- Government agencies CRUD (used for contribution/report mapping)
- Leave type CRUD

### 🔔 Notifications & Alerts
![Notifications](docs/screenshots/notifications/notifications.png)

- In-app notification list (e.g., ingredients nearing expiration)
- Alert/confirmation dialogs across the app for important actions
