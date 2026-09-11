-- ============================================================================================
-- Chocoland Hils Cafe Management System - Correlated Mock Data
-- ============================================================================================
-- Run AFTER Database/DbQueries.sql has created the schema.
-- Safe to re-run: clears the tables below (child-to-parent order) before inserting fresh data.
--
-- Excluded on purpose (not populated here):
--   - UserActivityLog                              (no entity model in code, table is unused)
--   - SaleTranProdIngInvDeductionsRecords           (runtime FIFO inventory-deduction audit ledger,
--   - SaleTranComboMealIngInvDeductionsRecords        computed by the POS checkout algorithm at runtime,
--                                                      not meaningful as hand-authored mock data)
--
-- Time-series sections (attendance/payroll/POS) are generated relative to CURDATE(), so re-running
-- this script always produces a fresh "most recent completed month" of history.
-- ============================================================================================

USE ChocolandHilsCafeDb;

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- --------------------------------------------------------------------------------------
-- Reset (children before parents)
-- --------------------------------------------------------------------------------------
TRUNCATE TABLE CashRegisterCashOutTransactions;
TRUNCATE TABLE SalesTransactionComboMeals;
TRUNCATE TABLE SalesTransactionProducts;
TRUNCATE TABLE SalesTransactions;
TRUNCATE TABLE EmployeeGovernmentContributions;
TRUNCATE TABLE EmployeePayslipDeductions;
TRUNCATE TABLE EmployeePayslipBenefits;
TRUNCATE TABLE SpecificEmployeeDeductions;
TRUNCATE TABLE SpecificEmployeeBenefits;
TRUNCATE TABLE EmployeeCashAdvanceRequests;
TRUNCATE TABLE EmployeeAttendance;
TRUNCATE TABLE WorkforceSchedules;
TRUNCATE TABLE EmployeeLeaves;
TRUNCATE TABLE EmployeePayslips;
TRUNCATE TABLE ComboMealProducts;
TRUNCATE TABLE ComboMeals;
TRUNCATE TABLE ProductIngredients;
TRUNCATE TABLE Products;
TRUNCATE TABLE ProductCategories;
TRUNCATE TABLE IngInventoryTransactions;
TRUNCATE TABLE IngredientInventory;
TRUNCATE TABLE Ingredients;
TRUNCATE TABLE IngredientCategories;
TRUNCATE TABLE UserRoles;
TRUNCATE TABLE Users;
TRUNCATE TABLE Roles;
TRUNCATE TABLE EmployeeGovtIdCards;
TRUNCATE TABLE Employees;
TRUNCATE TABLE EmployeePositions;
TRUNCATE TABLE NumberOfWorkingDaysInMonth;
TRUNCATE TABLE Branches;
TRUNCATE TABLE Holidays;
TRUNCATE TABLE EmployeeShiftDays;
TRUNCATE TABLE EmployeeShifts;
TRUNCATE TABLE LeaveTypes;
TRUNCATE TABLE StoreTables;
TRUNCATE TABLE EmployeeDeductions;
TRUNCATE TABLE EmployeeBenefits;

-- --------------------------------------------------------------------------------------
-- Reference / lookup data
-- --------------------------------------------------------------------------------------
INSERT INTO Roles (rolekey) VALUES
('normal'), ('admin'), ('cashier'), ('manager');
-- ids: 1=normal, 2=admin, 3=cashier, 4=manager (matches StaticData.UserRole enum ordinals + 1)

INSERT INTO LeaveTypes (leaveType, numberOfDays, isActive) VALUES
('Vacation Leave', 15, 1),
('Sick Leave', 15, 1),
('Emergency Leave', 3, 1),
('Maternity/Paternity Leave', 105, 1);

INSERT INTO EmployeeShifts (shift, startTime, endTime, numberOfHrs, breakTime, breakTimeHrs, earlyTimeOut, lateTimeIn) VALUES
('Opening Shift',  '2000-01-01 06:00:00', '2000-01-01 14:00:00', 8.00, '2000-01-01 10:00:00', 1.00, NULL, NULL),
('Mid Shift',      '2000-01-01 10:00:00', '2000-01-01 18:00:00', 8.00, '2000-01-01 13:00:00', 1.00, NULL, NULL),
('Closing Shift',  '2000-01-01 14:00:00', '2000-01-01 22:00:00', 8.00, '2000-01-01 18:00:00', 1.00, NULL, NULL);
-- ids: 1=Opening, 2=Mid, 3=Closing

INSERT INTO EmployeeShiftDays (shiftId, dayName, orderNum) VALUES
(1, 'Mon', 1), (1, 'Tue', 2), (1, 'Wed', 3), (1, 'Thu', 4), (1, 'Fri', 5), (1, 'Sat', 6), -- Opening: off Sun
(2, 'Sun', 1), (2, 'Mon', 2), (2, 'Tue', 3), (2, 'Wed', 4), (2, 'Fri', 5), (2, 'Sat', 6), -- Mid: off Thu
(3, 'Tue', 1), (3, 'Wed', 2), (3, 'Thu', 3), (3, 'Fri', 4), (3, 'Sat', 5), (3, 'Sun', 6); -- Closing: off Mon

INSERT INTO Holidays (holiday, dayNum, monthAbbr, monthNum, holidayType) VALUES
('New Year''s Day', 1, 'Jan', 1, 0),
('Araw ng Kagitingan', 9, 'Apr', 4, 0),
('Labor Day', 1, 'May', 5, 0),
('Independence Day', 12, 'Jun', 6, 0),
('Ninoy Aquino Day', 21, 'Aug', 8, 1),
('National Heroes Day', 25, 'Aug', 8, 0),
('All Saints Day', 1, 'Nov', 11, 1),
('Bonifacio Day', 30, 'Nov', 11, 0),
('Christmas Day', 25, 'Dec', 12, 0),
('Rizal Day', 30, 'Dec', 12, 0);

INSERT INTO Branches (branchName, tellNo, address) VALUES
('Chocoland Hils Cafe - Poblacion Branch', '043-123-4567', 'Rizal Street, Poblacion, Batangas City'),
('Chocoland Hils Cafe - SM City Branch', '043-234-5678', 'SM City Batangas, Pallocan West, Batangas City'),
('Chocoland Hils Cafe - Robinsons Branch', '043-345-6789', 'Robinsons Place Batangas, Batangas City');

INSERT INTO NumberOfWorkingDaysInMonth (numberOfDays) VALUES (26.00);

INSERT INTO EmployeePositions (title, dailyRate, monthlyRate, isSingleEmployee) VALUES
('Branch Manager', 800.00, 20800.00, 1),
('Store Supervisor', 650.00, 16900.00, 0),
('Barista', 500.00, 13000.00, 0),
('Cashier', 480.00, 12480.00, 0),
('Kitchen Staff', 480.00, 12480.00, 0),
('Crew', 450.00, 11700.00, 0);
-- ids: 1=Manager, 2=Supervisor, 3=Barista, 4=Cashier, 5=Kitchen Staff, 6=Crew

INSERT INTO StoreTables (numberOfTables) VALUES (12);

INSERT INTO EmployeeBenefits (benefitTitle, amount) VALUES
('Meal Allowance', 1500.00),
('Transportation Allowance', 1000.00),
('Attendance Incentive', 500.00);

INSERT INTO EmployeeDeductions (deductionTitle, amount) VALUES
('Uniform Deduction', 300.00),
('Cash Shortage Deduction', 0.00),
('SSS Salary Loan', 500.00);

-- --------------------------------------------------------------------------------------
-- Employees (18 total: 6 per branch, one of each position per branch)
-- --------------------------------------------------------------------------------------
INSERT INTO Employees
(employeeNumber, firstName, lastName, middleName, address, birthdate, mobileNumber, emailAddress, dateHire, empNumYear, branchId, positionId, shiftId, isQuit) VALUES
-- Branch 1 - Poblacion
('20210001', 'Maria', 'Santos', 'Cruz', 'Blk 1 Lot 2, Poblacion, Batangas City', '1990-05-12', '09171234501', 'maria.santos@chocolandhils.com', '2021-03-01', '2021', 1, 1, 2, 0),
('20210002', 'Juan', 'Ramirez', 'Dela Cruz', 'Blk 2 Lot 5, Poblacion, Batangas City', '1988-11-23', '09171234502', 'juan.ramirez@chocolandhils.com', '2021-04-15', '2021', 1, 2, 1, 0),
('20220001', 'Ana', 'Reyes', 'Torres', 'Blk 3 Lot 1, Poblacion, Batangas City', '1995-02-10', '09171234503', 'ana.reyes@chocolandhils.com', '2022-01-10', '2022', 1, 3, 1, 0),
('20220002', 'Mark', 'Villanueva', 'Santos', 'Blk 4 Lot 8, Poblacion, Batangas City', '1997-07-19', '09171234504', 'mark.villanueva@chocolandhils.com', '2022-02-20', '2022', 1, 4, 1, 0),
('20220003', 'Liza', 'Garcia', 'Ramos', 'Blk 5 Lot 3, Poblacion, Batangas City', '1999-09-05', '09171234505', 'liza.garcia@chocolandhils.com', '2022-05-05', '2022', 1, 5, 3, 0),
('20230001', 'Paolo', 'Mendoza', 'Cruz', 'Blk 6 Lot 9, Poblacion, Batangas City', '1996-12-01', '09171234506', 'paolo.mendoza@chocolandhils.com', '2023-01-15', '2023', 1, 6, 3, 0),
-- Branch 2 - SM City
('20210003', 'Cristina', 'Aquino', 'Bautista', 'Blk 7 Lot 4, Pallocan West, Batangas City', '1989-03-22', '09171234507', 'cristina.aquino@chocolandhils.com', '2021-06-01', '2021', 2, 1, 2, 0),
('20220004', 'Ramon', 'Torres', 'Villareal', 'Blk 8 Lot 6, Pallocan West, Batangas City', '1993-08-14', '09171234508', 'ramon.torres@chocolandhils.com', '2022-03-10', '2022', 2, 2, 1, 0),
('20230002', 'Bea', 'Fernandez', 'Santos', 'Blk 9 Lot 2, Pallocan West, Batangas City', '1998-01-30', '09171234509', 'bea.fernandez@chocolandhils.com', '2023-02-01', '2023', 2, 3, 1, 0),
('20230003', 'Carlo', 'Ramos', 'Dela Cruz', 'Blk 10 Lot 7, Pallocan West, Batangas City', '2000-04-17', '09171234510', 'carlo.ramos@chocolandhils.com', '2023-04-01', '2023', 2, 4, 1, 0),
('20240001', 'Angel', 'Cruz', 'Reyes', 'Blk 11 Lot 3, Pallocan West, Batangas City', '2001-10-09', '09171234511', 'angel.cruz@chocolandhils.com', '2024-01-20', '2024', 2, 5, 3, 0),
('20240002', 'Miguel', 'Santos', 'Garcia', 'Blk 12 Lot 5, Pallocan West, Batangas City', '1994-06-26', '09171234512', 'miguel.santos@chocolandhils.com', '2024-05-15', '2024', 2, 6, 3, 0),
-- Branch 3 - Robinsons
('20220005', 'Grace', 'Lopez', 'Mercado', 'Blk 13 Lot 1, Batangas City', '1991-09-13', '09171234513', 'grace.lopez@chocolandhils.com', '2022-07-01', '2022', 3, 1, 2, 0),
('20230004', 'Vincent', 'Aguilar', 'Torres', 'Blk 14 Lot 4, Batangas City', '1995-12-25', '09171234514', 'vincent.aguilar@chocolandhils.com', '2023-03-10', '2023', 3, 2, 1, 0),
('20240003', 'Nicole', 'Bautista', 'Flores', 'Blk 15 Lot 8, Batangas City', '1999-05-08', '09171234515', 'nicole.bautista@chocolandhils.com', '2024-02-14', '2024', 3, 3, 1, 0),
('20240004', 'Kevin', 'Flores', 'Aquino', 'Blk 16 Lot 2, Batangas City', '2000-11-11', '09171234516', 'kevin.flores@chocolandhils.com', '2024-06-01', '2024', 3, 4, 3, 0),
('20250001', 'Samantha', 'Ramos', 'Cruz', 'Blk 17 Lot 6, Batangas City', '2002-03-19', '09171234517', 'samantha.ramos@chocolandhils.com', '2025-01-10', '2025', 3, 5, 1, 0),
('20250002', 'Joshua', 'Dizon', 'Santos', 'Blk 18 Lot 9, Batangas City', '1997-07-07', '09171234518', 'joshua.dizon@chocolandhils.com', '2025-08-01', '2025', 3, 6, 3, 0);
-- ids 1-18 in the order above (Branch1: 1-6, Branch2: 7-12, Branch3: 13-18)

INSERT INTO EmployeeGovtIdCards (employeeNumber, govtAgencyEnumVal, employeeIdNumber)
SELECT e.employeeNumber, a.agencyVal,
  CASE a.agencyVal
    WHEN 0 THEN CONCAT('34-', LPAD(MOD(e.id*137, 9999999), 7, '0'), '-', MOD(e.id, 9))
    WHEN 1 THEN CONCAT('12-', LPAD(MOD(e.id*211, 999999999), 9, '0'), '-', MOD(e.id, 9))
    WHEN 2 THEN CONCAT(LPAD(MOD(e.id*311, 9999), 4, '0'), '-', LPAD(MOD(e.id*97, 9999), 4, '0'), '-', LPAD(MOD(e.id*53, 9999), 4, '0'))
  END
FROM Employees e
CROSS JOIN (SELECT 0 AS agencyVal UNION ALL SELECT 1 UNION ALL SELECT 2) a;

-- --------------------------------------------------------------------------------------
-- Users & Roles (login accounts for managers, supervisors, cashiers + one system admin)
-- --------------------------------------------------------------------------------------
INSERT INTO Users (userName, fullName, passwordSha512, isActive) VALUES
('20210001', 'Maria Cruz Santos', SHA2('ChocolandHils@2024', 512), 1),
('20210003', 'Cristina Bautista Aquino', SHA2('ChocolandHils@2024', 512), 1),
('20220005', 'Grace Mercado Lopez', SHA2('ChocolandHils@2024', 512), 1),
('20210002', 'Juan Dela Cruz Ramirez', SHA2('ChocolandHils@2024', 512), 1),
('20220004', 'Ramon Villareal Torres', SHA2('ChocolandHils@2024', 512), 1),
('20230004', 'Vincent Torres Aguilar', SHA2('ChocolandHils@2024', 512), 1),
('20220002', 'Mark Santos Villanueva', SHA2('ChocolandHils@2024', 512), 1),
('20230003', 'Carlo Dela Cruz Ramos', SHA2('ChocolandHils@2024', 512), 1),
('20240004', 'Kevin Aquino Flores', SHA2('ChocolandHils@2024', 512), 1),
('admin01', 'System Administrator', SHA2('ChocolandHils@2024', 512), 1);
-- ids: 1-3 branch managers, 4-6 supervisors, 7-9 cashiers, 10 admin (default mock password: ChocolandHils@2024)

INSERT INTO UserRoles (userId, roleId) VALUES
(1, 4), (2, 4), (3, 4), -- managers -> manager role
(4, 4), (5, 4), (6, 4), -- supervisors -> manager role
(7, 3), (8, 3), (9, 3), -- cashiers -> cashier role
(10, 2); -- admin -> admin role

-- --------------------------------------------------------------------------------------
-- Inventory: categories, ingredients, batches, transactions
-- --------------------------------------------------------------------------------------
INSERT INTO IngredientCategories (category) VALUES
('Coffee Beans & Powders'), ('Dairy & Milk Products'), ('Syrups & Sweeteners'),
('Bread & Pastry Base'), ('Meat & Protein'), ('Vegetables & Fruits'), ('Packaging & Disposables');
-- ids 1-7

INSERT INTO Ingredients (categoryId, ingName, uom) VALUES
(1, 'Arabica Coffee Beans', 'kg'),
(1, 'Robusta Coffee Beans', 'kg'),
(1, 'Cocoa Powder', 'kg'),
(2, 'Fresh Milk', 'L'),
(2, 'Evaporated Milk', 'L'),
(2, 'Whipped Cream', 'L'),
(3, 'Caramel Syrup', 'L'),
(3, 'Vanilla Syrup', 'L'),
(3, 'White Sugar', 'kg'),
(4, 'Bread Flour', 'kg'),
(4, 'Butter', 'kg'),
(5, 'Chicken Fillet', 'kg'),
(5, 'Beef Patty', 'pcs'),
(6, 'Lettuce', 'kg'),
(6, 'Tomato', 'kg'),
(7, 'Paper Cup 16oz', 'pcs'),
(7, 'Takeout Box', 'pcs');
-- ids 1-17

INSERT INTO IngredientInventory (ingredientId, initialQtyValue, remainingQtyValue, unitCost, expirationDate, isSoldOut) VALUES
(1, 20, 6.5, 850.00, '2026-12-31', 0),
(2, 15, 4.0, 650.00, '2026-12-31', 0),
(3, 10, 3.2, 420.00, '2027-01-15', 0),
(4, 60, 18.0, 95.00, '2026-10-05', 0),
(5, 24, 9.0, 110.00, '2026-11-20', 0),
(6, 10, 2.5, 180.00, '2026-10-10', 0),
(7, 12, 5.0, 220.00, '2027-02-01', 0),
(8, 12, 4.5, 210.00, '2027-02-01', 0),
(9, 25, 9.0, 60.00, '2027-06-01', 0),
(10, 20, 7.0, 55.00, '2026-12-01', 0),
(11, 10, 3.0, 380.00, '2026-10-15', 0),
(12, 30, 8.0, 210.00, '2026-09-25', 0),
(13, 200, 60.0, 35.00, '2026-09-30', 0),
(14, 8, 1.5, 90.00, '2026-09-18', 0),
(15, 10, 2.0, 70.00, '2026-09-20', 0),
(16, 2000, 850.0, 4.50, NULL, 0),
(17, 1000, 420.0, 6.00, NULL, 0);
-- ids 1-17 (1 batch per ingredient, same id sequence as Ingredients since inserted 1:1 in order)

INSERT INTO IngInventoryTransactions (ingredientId, transType, qtyVal, unitCost, expirationDate, userId, remarks, createdAt) VALUES
(1, 0, 20, 850.00, '2026-12-31', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (1, 3, 13.5, 850.00, '2026-12-31', 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(2, 0, 15, 650.00, '2026-12-31', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (2, 3, 11.0, 650.00, '2026-12-31', 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(3, 0, 10, 420.00, '2027-01-15', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (3, 3, 6.8, 420.00, '2027-01-15', 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(4, 0, 60, 95.00, '2026-10-05', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (4, 3, 42.0, 95.00, '2026-10-05', 5, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(5, 0, 24, 110.00, '2026-11-20', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (5, 3, 15.0, 110.00, '2026-11-20', 5, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(6, 0, 10, 180.00, '2026-10-10', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (6, 3, 7.5, 180.00, '2026-10-10', 5, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(7, 0, 12, 220.00, '2027-02-01', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (7, 3, 7.0, 220.00, '2027-02-01', 6, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(8, 0, 12, 210.00, '2027-02-01', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (8, 3, 7.5, 210.00, '2027-02-01', 6, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(9, 0, 25, 60.00, '2027-06-01', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (9, 3, 16.0, 60.00, '2027-06-01', 6, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(10, 0, 20, 55.00, '2026-12-01', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (10, 3, 13.0, 55.00, '2026-12-01', 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(11, 0, 10, 380.00, '2026-10-15', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (11, 3, 7.0, 380.00, '2026-10-15', 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(12, 0, 30, 210.00, '2026-09-25', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (12, 3, 22.0, 210.00, '2026-09-25', 5, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(13, 0, 200, 35.00, '2026-09-30', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (13, 3, 140.0, 35.00, '2026-09-30', 5, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(14, 0, 8, 90.00, '2026-09-18', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (14, 3, 6.5, 90.00, '2026-09-18', 6, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(15, 0, 10, 70.00, '2026-09-20', 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (15, 3, 8.0, 70.00, '2026-09-20', 6, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(16, 0, 2000, 4.50, NULL, 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (16, 3, 1150.0, 4.50, NULL, 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY),
(17, 0, 1000, 6.00, NULL, 10, 'Initial stock', CURDATE() - INTERVAL 35 DAY), (17, 3, 580.0, 6.00, NULL, 4, 'Monthly usage adjustment', CURDATE() - INTERVAL 10 DAY);

-- --------------------------------------------------------------------------------------
-- Products, ingredients-per-product, combo meals
-- --------------------------------------------------------------------------------------
INSERT INTO ProductCategories (prodCategory) VALUES
('Hot Coffee'), ('Cold Coffee / Frappe'), ('Non-Coffee Drinks'),
('Rice Meals'), ('Sandwiches & Burgers'), ('Pastries & Desserts'), ('Add-ons');
-- ids 1-7

INSERT INTO Products (barcodeLbl, categoryId, prodName, pricePerOrder) VALUES
('PRD-0001', 1, 'Cafe Americano', 89.00),
('PRD-0002', 1, 'Cappuccino', 99.00),
('PRD-0003', 1, 'Cafe Latte', 99.00),
('PRD-0004', 1, 'Spanish Latte', 109.00),
('PRD-0005', 1, 'Cafe Mocha', 109.00),
('PRD-0006', 2, 'Iced Caramel Macchiato', 129.00),
('PRD-0007', 2, 'Coffee Frappe', 135.00),
('PRD-0008', 2, 'Mocha Frappe', 135.00),
('PRD-0009', 2, 'Vanilla Frappe', 125.00),
('PRD-0010', 3, 'Hot Chocolate', 95.00),
('PRD-0011', 3, 'Choco Frappe', 130.00),
('PRD-0012', 3, 'Fresh Milk Tea', 99.00),
('PRD-0013', 4, 'Chicken Fillet Rice Meal', 159.00),
('PRD-0014', 4, 'Beef Sisig Rice Meal', 169.00),
('PRD-0015', 4, 'Sweet & Sour Chicken Rice Meal', 159.00),
('PRD-0016', 5, 'Classic Beef Burger', 129.00),
('PRD-0017', 5, 'Chicken Fillet Sandwich', 119.00),
('PRD-0018', 6, 'Chocolate Cake Slice', 89.00),
('PRD-0019', 6, 'Blueberry Cheesecake', 99.00),
('PRD-0020', 6, 'Choco Chip Cookie', 45.00),
('PRD-0021', 7, 'Extra Whipped Cream', 20.00),
('PRD-0022', 7, 'Extra Shot', 30.00);
-- ids 1-22

-- uom values reference StaticData.UOM: kg=0, L=1, pcs=2, pc=3, g=4, ml=5
INSERT INTO ProductIngredients (productId, ingredientId, uom, qtyValue) VALUES
(1, 1, 4, 18),   -- Americano: Arabica beans 18g
(2, 1, 4, 16), (2, 4, 5, 120),  -- Cappuccino: beans + milk
(3, 1, 4, 16), (3, 4, 5, 150),  -- Latte
(4, 1, 4, 16), (4, 5, 5, 100), (4, 9, 0, 0.02), -- Spanish Latte: beans + evap milk + sugar
(5, 1, 4, 16), (5, 3, 0, 0.02), (5, 4, 5, 100), -- Mocha: beans + cocoa + milk
(6, 2, 4, 18), (6, 4, 5, 150), (6, 7, 5, 30),   -- Iced Caramel Macchiato
(7, 1, 4, 20), (7, 4, 5, 150), (7, 6, 5, 30),   -- Coffee Frappe
(8, 1, 4, 18), (8, 3, 0, 0.03), (8, 6, 5, 30),  -- Mocha Frappe
(9, 1, 4, 16), (9, 8, 5, 30), (9, 4, 5, 150),   -- Vanilla Frappe
(10, 3, 0, 0.04), (10, 4, 5, 180),               -- Hot Chocolate
(11, 3, 0, 0.05), (11, 6, 5, 30), (11, 4, 5, 150), -- Choco Frappe
(12, 9, 0, 0.03), (12, 4, 5, 180),               -- Fresh Milk Tea
(13, 12, 0, 0.15),                               -- Chicken Fillet Rice Meal
(14, 12, 0, 0.18),                               -- Beef Sisig Rice Meal (using chicken/beef stand-in ingredient)
(15, 12, 0, 0.15),                               -- Sweet & Sour Chicken Rice Meal
(16, 13, 2, 1), (16, 10, 0, 0.08), (16, 14, 0, 0.02), (16, 15, 0, 0.02), -- Beef Burger: patty + bun flour + lettuce + tomato
(17, 12, 0, 0.12), (17, 10, 0, 0.06), (17, 14, 0, 0.01),                 -- Chicken Sandwich
(18, 3, 0, 0.06), (18, 11, 0, 0.03),                                     -- Chocolate Cake Slice
(19, 10, 0, 0.05), (19, 11, 0, 0.04),                                    -- Blueberry Cheesecake
(20, 10, 0, 0.03), (20, 11, 0, 0.02),                                    -- Choco Chip Cookie
(21, 6, 5, 20),                                                          -- Extra Whipped Cream
(22, 1, 4, 9);                                                           -- Extra Shot

INSERT INTO ComboMeals (barcodeLbl, title, price) VALUES
('COMBO-0001', 'Rice Meal + Milk Tea Combo', 179.00),
('COMBO-0002', 'Burger + Frappe Combo', 199.00),
('COMBO-0003', 'Coffee + Cookie Combo', 129.00);
-- ids 1-3

INSERT INTO ComboMealProducts (comboMealId, productId, quantity) VALUES
(1, 13, 1), (1, 12, 1),  -- Chicken Fillet Rice Meal + Fresh Milk Tea
(2, 16, 1), (2, 11, 1),  -- Classic Beef Burger + Choco Frappe
(3, 2, 1), (3, 20, 1);   -- Cappuccino + Choco Chip Cookie

-- --------------------------------------------------------------------------------------
-- Leave requests & cash advance requests (hand-picked sample, dates relative to CURDATE())
-- --------------------------------------------------------------------------------------
INSERT INTO EmployeeLeaves (leaveId, employeeNumber, reason, startDate, endDate, numberOfDays, remainingDays, currentYear, isPaid, DurationType, approvalStatus, employerRemarks) VALUES
(2, '20220001', 'Flu / fever', CURDATE() - INTERVAL 20 DAY, CURDATE() - INTERVAL 19 DAY, 2, 13, YEAR(CURDATE()), 1, 0, 1, 'Approved, medical certificate on file'),
(1, '20230002', 'Family vacation', CURDATE() - INTERVAL 12 DAY, CURDATE() - INTERVAL 10 DAY, 3, 12, YEAR(CURDATE()), 1, 0, 1, 'Approved'),
(3, '20240003', 'Personal emergency', CURDATE() - INTERVAL 5 DAY, CURDATE() - INTERVAL 5 DAY, 1, 2, YEAR(CURDATE()), 0, 0, 1, 'Approved'),
(2, '20240001', 'Not feeling well', CURDATE() - INTERVAL 3 DAY, CURDATE() - INTERVAL 3 DAY, 1, 14, YEAR(CURDATE()), 0, 1, 0, NULL),
(1, '20250001', 'Sister''s wedding', CURDATE() + INTERVAL 5 DAY, CURDATE() + INTERVAL 6 DAY, 2, 13, YEAR(CURDATE()), 0, 0, 0, NULL),
(3, '20230001', 'Urgent house repair', CURDATE() - INTERVAL 8 DAY, CURDATE() - INTERVAL 8 DAY, 1, 2, YEAR(CURDATE()), 0, 2, 2, 'Disapproved - insufficient notice');

INSERT INTO EmployeeCashAdvanceRequests (employeeNumber, amount, needOnDate, employeeRemarks, approvalStatus, employerRemarks, cashReleaseDate) VALUES
('20220002', 2000.00, CURDATE() - INTERVAL 15 DAY, 'Emergency medical expense', 1, 'Approved', CURDATE() - INTERVAL 14 DAY),
('20230003', 1500.00, CURDATE() - INTERVAL 9 DAY, 'School enrollment', 1, 'Approved', CURDATE() - INTERVAL 8 DAY),
('20240002', 1000.00, CURDATE() - INTERVAL 2 DAY, 'Personal expense', 0, NULL, NULL),
('20220003', 800.00, CURDATE() + INTERVAL 3 DAY, 'Bill payment', 0, NULL, NULL),
('20250002', 1200.00, CURDATE() - INTERVAL 25 DAY, 'Repair motorcycle', 2, 'Disapproved - already availed this month', NULL);

-- ============================================================================================
-- Generated time-series data: attendance, payroll and POS sales for the most recently
-- completed calendar month (relative to CURDATE()), so this file stays "fresh" on every run.
-- ============================================================================================

DROP TEMPORARY TABLE IF EXISTS CalendarPrevMonth;
CREATE TEMPORARY TABLE CalendarPrevMonth (dt DATE PRIMARY KEY);
INSERT INTO CalendarPrevMonth (dt)
WITH RECURSIVE cal AS (
    SELECT DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01') AS dt
    UNION ALL
    SELECT dt + INTERVAL 1 DAY FROM cal WHERE dt + INTERVAL 1 DAY <= LAST_DAY(CURDATE() - INTERVAL 1 MONTH)
)
SELECT dt FROM cal;

-- --------------------------------------------------------------------------------------
-- Workforce schedules: one row per employee per scheduled shift-day in the previous month
-- --------------------------------------------------------------------------------------
INSERT INTO WorkforceSchedules (employeeNumber, workDate, isDone)
SELECT e.employeeNumber, c.dt, 1
FROM Employees e
JOIN CalendarPrevMonth c
JOIN EmployeeShiftDays sd ON sd.shiftId = e.shiftId AND sd.dayName = DATE_FORMAT(c.dt, '%a')
WHERE e.isQuit = 0;

-- --------------------------------------------------------------------------------------
-- Attendance: derived from each employee's shift + scheduled days, skipping approved leave days
-- --------------------------------------------------------------------------------------
INSERT INTO EmployeeAttendance (
    employeeNumber, shiftId, workDate, firstTimeIn, firstTimeOut, firstHalfHrs, firstHalfLateMins, firstHalfUnderTimeMins,
    secondTimeIn, secondTimeOut, secondHalfHrs, secondHalfLateMins, secondHalfUnderTimeMins, overTimeMins,
    isTimeOutProvided, lateTotalDeduction, underTimeTotalDeduction, overTimeTotal, totalDailySalary, isPaid, payslipId,
    isUserDayOffToday, isHolidayToday, holidayId, OverTimeHrlyRate, overTimeDailySalaryAdjustment, overTimeType
)
SELECT
    t.employeeNumber, t.shiftId, t.workDate,
    t.workDate + t.shiftStart + INTERVAL t.lateMins MINUTE,
    t.workDate + t.breakStart,
    TIMESTAMPDIFF(MINUTE, t.workDate + t.shiftStart + INTERVAL t.lateMins MINUTE, t.workDate + t.breakStart),
    t.lateMins, 0,
    t.workDate + t.breakStart + INTERVAL t.breakMins MINUTE,
    t.workDate + t.shiftEnd - INTERVAL t.underMins MINUTE + INTERVAL t.otMins MINUTE,
    TIMESTAMPDIFF(MINUTE, t.workDate + t.breakStart + INTERVAL t.breakMins MINUTE, t.workDate + t.shiftEnd - INTERVAL t.underMins MINUTE + INTERVAL t.otMins MINUTE),
    0, t.underMins, t.otMins,
    1,
    ROUND(t.lateMins * t.perMinRate, 2),
    ROUND(t.underMins * t.perMinRate, 2),
    ROUND((t.otMins / 60) * t.otHrlyRate, 2),
    ROUND(t.dailyRate - (t.lateMins * t.perMinRate) - (t.underMins * t.perMinRate) + ((t.otMins / 60) * t.otHrlyRate), 2),
    0, 0,
    0, t.isHoliday, t.holidayId, ROUND(t.otHrlyRate, 2), 0,
    CASE WHEN t.otMins > 0 THEN 0 ELSE 6 END
FROM (
    SELECT
        e.employeeNumber, e.shiftId, c.dt AS workDate,
        TIME(sh.startTime) AS shiftStart, TIME(sh.endTime) AS shiftEnd, TIME(sh.breakTime) AS breakStart,
        sh.breakTimeHrs * 60 AS breakMins,
        ep.dailyRate AS dailyRate,
        ep.dailyRate / (sh.numberOfHrs * 60) AS perMinRate,
        (ep.dailyRate / sh.numberOfHrs) * 1.25 AS otHrlyRate,
        (FLOOR(RAND() * 20)) * (RAND() < 0.25) AS lateMins,
        (FLOOR(RAND() * 15)) * (RAND() < 0.15) AS underMins,
        (FLOOR(RAND() * 60) + 15) * (RAND() < 0.10) AS otMins,
        EXISTS(SELECT 1 FROM Holidays h WHERE h.dayNum = DAY(c.dt) AND h.monthNum = MONTH(c.dt)) AS isHoliday,
        (SELECT h2.id FROM Holidays h2 WHERE h2.dayNum = DAY(c.dt) AND h2.monthNum = MONTH(c.dt) LIMIT 1) AS holidayId
    FROM Employees e
    JOIN EmployeeShifts sh ON sh.id = e.shiftId
    JOIN EmployeePositions ep ON ep.id = e.positionId
    JOIN CalendarPrevMonth c
    JOIN EmployeeShiftDays sd ON sd.shiftId = e.shiftId AND sd.dayName = DATE_FORMAT(c.dt, '%a')
    WHERE e.isQuit = 0
      AND NOT EXISTS (
          SELECT 1 FROM EmployeeLeaves el
          WHERE el.employeeNumber = e.employeeNumber
            AND el.approvalStatus = 1
            AND c.dt BETWEEN el.startDate AND el.endDate
      )
) t;

-- --------------------------------------------------------------------------------------
-- Payslips: 2 semi-monthly cutoffs for the previous month, aggregated from EmployeeAttendance
-- --------------------------------------------------------------------------------------
INSERT INTO EmployeePayslips (
    employeeNumber, startShiftDate, endShiftDate, payDate, dailyRate, numOfDays, late, lateTotalDeduction,
    underTime, underTimeTotalDeduction, overTime, overTimeTotalRate, netBasicSalary, benefitsTotal, totalIncome,
    deductionTotal, netTakeHomePay, paydaySequence, isCancel
)
SELECT
    e.employeeNumber,
    DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01'),
    DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-15'),
    DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-16'),
    ep.dailyRate, 13,
    CAST(COALESCE(SUM(att.firstHalfLateMins + att.secondHalfLateMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.lateTotalDeduction), 0), 2),
    CAST(COALESCE(SUM(att.firstHalfUnderTimeMins + att.secondHalfUnderTimeMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.underTimeTotalDeduction), 0), 2),
    CAST(COALESCE(SUM(att.overTimeMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.overTimeTotal), 0), 2),
    ROUND(COALESCE(SUM(att.totalDailySalary), 0), 2), 0, 0, 0, 0,
    1, 0
FROM Employees e
JOIN EmployeePositions ep ON ep.id = e.positionId
LEFT JOIN EmployeeAttendance att ON att.employeeNumber = e.employeeNumber
    AND att.workDate BETWEEN DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01') AND DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-15')
WHERE e.isQuit = 0
GROUP BY e.employeeNumber, ep.dailyRate;

INSERT INTO EmployeePayslips (
    employeeNumber, startShiftDate, endShiftDate, payDate, dailyRate, numOfDays, late, lateTotalDeduction,
    underTime, underTimeTotalDeduction, overTime, overTimeTotalRate, netBasicSalary, benefitsTotal, totalIncome,
    deductionTotal, netTakeHomePay, paydaySequence, isCancel
)
SELECT
    e.employeeNumber,
    DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-16'),
    LAST_DAY(CURDATE() - INTERVAL 1 MONTH),
    DATE_FORMAT(CURDATE(), '%Y-%m-01'),
    ep.dailyRate, 13,
    CAST(COALESCE(SUM(att.firstHalfLateMins + att.secondHalfLateMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.lateTotalDeduction), 0), 2),
    CAST(COALESCE(SUM(att.firstHalfUnderTimeMins + att.secondHalfUnderTimeMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.underTimeTotalDeduction), 0), 2),
    CAST(COALESCE(SUM(att.overTimeMins), 0) AS CHAR), ROUND(COALESCE(SUM(att.overTimeTotal), 0), 2),
    ROUND(COALESCE(SUM(att.totalDailySalary), 0), 2), 0, 0, 0, 0,
    2, 0
FROM Employees e
JOIN EmployeePositions ep ON ep.id = e.positionId
LEFT JOIN EmployeeAttendance att ON att.employeeNumber = e.employeeNumber
    AND att.workDate BETWEEN DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-16') AND LAST_DAY(CURDATE() - INTERVAL 1 MONTH)
WHERE e.isQuit = 0
GROUP BY e.employeeNumber, ep.dailyRate;

-- link attendance rows back to the payslip that paid them
UPDATE EmployeeAttendance att
JOIN EmployeePayslips p ON p.employeeNumber = att.employeeNumber AND att.workDate BETWEEN p.startShiftDate AND p.endShiftDate
SET att.payslipId = p.id, att.isPaid = 1;

-- Meal Allowance (all employees, both cutoffs) + Transportation Allowance (managers/supervisors, both cutoffs)
INSERT INTO SpecificEmployeeBenefits (employeeNumber, employeeName, benefitTitle, amount, isPaid, paymentDate, payslipId)
SELECT p.employeeNumber, CONCAT(e.firstName, ' ', e.lastName), 'Meal Allowance', 750.00, 1, p.payDate, p.id
FROM EmployeePayslips p JOIN Employees e ON e.employeeNumber = p.employeeNumber;

INSERT INTO SpecificEmployeeBenefits (employeeNumber, employeeName, benefitTitle, amount, isPaid, paymentDate, payslipId)
SELECT p.employeeNumber, CONCAT(e.firstName, ' ', e.lastName), 'Transportation Allowance', 500.00, 1, p.payDate, p.id
FROM EmployeePayslips p JOIN Employees e ON e.employeeNumber = p.employeeNumber
WHERE e.positionId IN (1, 2);

INSERT INTO EmployeePayslipBenefits (payslipId, employeeNumber, benefitTitle, amount, displayType, multiplier)
SELECT payslipId, employeeNumber, benefitTitle, amount, 1, '1' FROM SpecificEmployeeBenefits;

-- Uniform deduction (one-time, first cutoff only, subset of employees)
INSERT INTO SpecificEmployeeDeductions (employeeNumber, employeeName, deductionTitle, amount, isDeducted, deductedDate, payslipId)
SELECT p.employeeNumber, CONCAT(e.firstName, ' ', e.lastName), 'Uniform Deduction', 300.00, 1, p.payDate, p.id
FROM EmployeePayslips p JOIN Employees e ON e.employeeNumber = p.employeeNumber
WHERE p.paydaySequence = 1 AND MOD(e.id, 3) = 0;

INSERT INTO EmployeePayslipDeductions (payslipId, employeeNumber, deductionTitle, amount)
SELECT payslipId, employeeNumber, deductionTitle, amount FROM SpecificEmployeeDeductions;

-- Government contributions (SSS / PhilHealth / Pag-IBIG), deducted once a month on the 2nd cutoff
INSERT INTO EmployeeGovernmentContributions (payslipId, employeeNumber, agency, govContributionEnumVal, employeeContribution, employerContribution, IdNumber)
SELECT p.id, p.employeeNumber, 'SSS', 0, ROUND(ep.dailyRate * 26 * 0.045, 2), ROUND(ep.dailyRate * 26 * 0.095, 2), gc.employeeIdNumber
FROM EmployeePayslips p
JOIN Employees e ON e.employeeNumber = p.employeeNumber
JOIN EmployeePositions ep ON ep.id = e.positionId
JOIN EmployeeGovtIdCards gc ON gc.employeeNumber = p.employeeNumber AND gc.govtAgencyEnumVal = 0
WHERE p.paydaySequence = 2
UNION ALL
SELECT p.id, p.employeeNumber, 'PhilHealth', 1, ROUND(ep.dailyRate * 26 * 0.02, 2), ROUND(ep.dailyRate * 26 * 0.02, 2), gc.employeeIdNumber
FROM EmployeePayslips p
JOIN Employees e ON e.employeeNumber = p.employeeNumber
JOIN EmployeePositions ep ON ep.id = e.positionId
JOIN EmployeeGovtIdCards gc ON gc.employeeNumber = p.employeeNumber AND gc.govtAgencyEnumVal = 1
WHERE p.paydaySequence = 2
UNION ALL
SELECT p.id, p.employeeNumber, 'Pag-IBIG', 2, 100.00, 100.00, gc.employeeIdNumber
FROM EmployeePayslips p
JOIN Employees e ON e.employeeNumber = p.employeeNumber
JOIN EmployeePositions ep ON ep.id = e.positionId
JOIN EmployeeGovtIdCards gc ON gc.employeeNumber = p.employeeNumber AND gc.govtAgencyEnumVal = 2
WHERE p.paydaySequence = 2;

INSERT INTO EmployeePayslipDeductions (payslipId, employeeNumber, deductionTitle, amount, employerGovtContributionAmount)
SELECT payslipId, employeeNumber, CONCAT(agency, ' Contribution'), employeeContribution, employerContribution
FROM EmployeeGovernmentContributions;

-- reconcile payslip totals from the benefit/deduction ledgers now that they exist
UPDATE EmployeePayslips p
SET
    benefitsTotal = ROUND(COALESCE((SELECT SUM(amount) FROM EmployeePayslipBenefits b WHERE b.payslipId = p.id), 0), 2),
    deductionTotal = ROUND(COALESCE((SELECT SUM(amount) FROM EmployeePayslipDeductions d WHERE d.payslipId = p.id), 0), 2);

UPDATE EmployeePayslips
SET totalIncome = ROUND(netBasicSalary + benefitsTotal, 2),
    netTakeHomePay = ROUND(netBasicSalary + benefitsTotal - deductionTotal, 2);

-- --------------------------------------------------------------------------------------
-- POS sales: ~4 transactions/day for the previous month (3 single-product + 1 combo)
-- --------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS Numbers4;
CREATE TEMPORARY TABLE Numbers4 (i INT PRIMARY KEY);
INSERT INTO Numbers4 (i) VALUES (1), (2), (3), (4);

DROP TEMPORARY TABLE IF EXISTS SalesSeedProducts;
CREATE TEMPORARY TABLE SalesSeedProducts (dt DATE, n INT, seed INT, productIdx INT, qty INT, PRIMARY KEY (dt, n));
INSERT INTO SalesSeedProducts (dt, n, seed, productIdx, qty)
SELECT c.dt, nn.i, DAY(c.dt) * 10 + nn.i, 1 + MOD((DAY(c.dt) * 10 + nn.i) * 7, 22), 1 + MOD(DAY(c.dt) * 10 + nn.i, 3)
FROM CalendarPrevMonth c JOIN Numbers4 nn ON nn.i BETWEEN 1 AND 3;

DROP TEMPORARY TABLE IF EXISTS SalesSeedCombos;
CREATE TEMPORARY TABLE SalesSeedCombos (dt DATE, n INT, seed INT, comboIdx INT, qty INT, PRIMARY KEY (dt, n));
INSERT INTO SalesSeedCombos (dt, n, seed, comboIdx, qty)
SELECT c.dt, 4, DAY(c.dt) * 10 + 4, 1 + MOD((DAY(c.dt) * 10 + 4) * 5, 3), 1
FROM CalendarPrevMonth c;

-- single-product transactions
INSERT INTO SalesTransactions (
    transactionType, ticketNumber, customerName, subTotalAmount, discountAmount, discountIsPercentage, discountPercent,
    totalAmount, customerCashAmount, customerChangeAmount, customerDueAmount, tableNumber, transStatus, currentUser,
    isCashOut, TakeOutNumber, IsCustomerDone, createdAt
)
SELECT
    CASE WHEN MOD(s.seed, 2) = 0 THEN 1 ELSE 2 END,
    CONCAT('TCK-', DATE_FORMAT(s.dt, '%Y%m%d'), '-P', s.n),
    CASE MOD(s.seed, 5)
        WHEN 0 THEN 'Juan Dela Cruz' WHEN 1 THEN 'Maria Clara' WHEN 2 THEN 'Pedro Penduko'
        WHEN 3 THEN 'Walk-in Customer' ELSE 'Rosa Santos' END,
    p.pricePerOrder * s.qty,
    CASE WHEN MOD(s.seed, 10) = 0 THEN ROUND(p.pricePerOrder * s.qty * 0.20, 2) ELSE 0 END,
    CASE WHEN MOD(s.seed, 10) = 0 THEN 1 ELSE 0 END,
    CASE WHEN MOD(s.seed, 10) = 0 THEN 20 ELSE 0 END,
    ROUND(p.pricePerOrder * s.qty - (CASE WHEN MOD(s.seed, 10) = 0 THEN ROUND(p.pricePerOrder * s.qty * 0.20, 2) ELSE 0 END), 2),
    CEIL(ROUND(p.pricePerOrder * s.qty - (CASE WHEN MOD(s.seed, 10) = 0 THEN ROUND(p.pricePerOrder * s.qty * 0.20, 2) ELSE 0 END), 2) / 50) * 50,
    CEIL(ROUND(p.pricePerOrder * s.qty - (CASE WHEN MOD(s.seed, 10) = 0 THEN ROUND(p.pricePerOrder * s.qty * 0.20, 2) ELSE 0 END), 2) / 50) * 50
        - ROUND(p.pricePerOrder * s.qty - (CASE WHEN MOD(s.seed, 10) = 0 THEN ROUND(p.pricePerOrder * s.qty * 0.20, 2) ELSE 0 END), 2),
    0,
    CASE WHEN MOD(s.seed, 2) = 0 THEN 1 + MOD(s.seed * 3, 12) ELSE NULL END,
    CASE WHEN MOD(s.seed, 17) = 0 THEN 3 ELSE 2 END,
    CASE MOD(s.seed, 3) WHEN 0 THEN '20220002' WHEN 1 THEN '20230003' ELSE '20240004' END,
    CASE WHEN MOD(s.seed, 17) = 0 THEN 0 ELSE 1 END,
    CASE WHEN MOD(s.seed, 2) = 1 THEN s.n ELSE NULL END,
    CASE WHEN MOD(s.seed, 17) = 0 THEN 0 ELSE 1 END,
    s.dt + INTERVAL (8 + MOD(s.seed, 10)) HOUR + INTERVAL MOD(s.seed * 13, 60) MINUTE
FROM SalesSeedProducts s
JOIN Products p ON p.id = s.productIdx;

-- combo transactions
INSERT INTO SalesTransactions (
    transactionType, ticketNumber, customerName, subTotalAmount, discountAmount, discountIsPercentage, discountPercent,
    totalAmount, customerCashAmount, customerChangeAmount, customerDueAmount, tableNumber, transStatus, currentUser,
    isCashOut, TakeOutNumber, IsCustomerDone, createdAt
)
SELECT
    CASE WHEN MOD(s.seed, 2) = 0 THEN 1 ELSE 2 END,
    CONCAT('TCK-', DATE_FORMAT(s.dt, '%Y%m%d'), '-C', s.n),
    'Walk-in Customer',
    cm.price * s.qty,
    0, 0, 0,
    cm.price * s.qty,
    CEIL((cm.price * s.qty) / 50) * 50,
    (CEIL((cm.price * s.qty) / 50) * 50) - (cm.price * s.qty),
    0,
    CASE WHEN MOD(s.seed, 2) = 0 THEN 1 + MOD(s.seed * 3, 12) ELSE NULL END,
    CASE WHEN MOD(s.seed, 19) = 0 THEN 3 ELSE 2 END,
    CASE MOD(s.seed, 3) WHEN 0 THEN '20220002' WHEN 1 THEN '20230003' ELSE '20240004' END,
    CASE WHEN MOD(s.seed, 19) = 0 THEN 0 ELSE 1 END,
    CASE WHEN MOD(s.seed, 2) = 1 THEN s.n ELSE NULL END,
    CASE WHEN MOD(s.seed, 19) = 0 THEN 0 ELSE 1 END,
    s.dt + INTERVAL (8 + MOD(s.seed, 10)) HOUR + INTERVAL MOD(s.seed * 13, 60) MINUTE
FROM SalesSeedCombos s
JOIN ComboMeals cm ON cm.id = s.comboIdx;

-- line items for single-product transactions
INSERT INTO SalesTransactionProducts (salesTransId, productId, productCurrentPrice, qty, totalAmount)
SELECT st.id, p.id, p.pricePerOrder, s.qty, p.pricePerOrder * s.qty
FROM SalesSeedProducts s
JOIN Products p ON p.id = s.productIdx
JOIN SalesTransactions st ON st.ticketNumber = CONCAT('TCK-', DATE_FORMAT(s.dt, '%Y%m%d'), '-P', s.n);

-- line items for combo transactions
INSERT INTO SalesTransactionComboMeals (salesTransId, comboMealId, comboMealCurrentPrice, qty, totalAmount)
SELECT st.id, cm.id, cm.price, s.qty, cm.price * s.qty
FROM SalesSeedCombos s
JOIN ComboMeals cm ON cm.id = s.comboIdx
JOIN SalesTransactions st ON st.ticketNumber = CONCAT('TCK-', DATE_FORMAT(s.dt, '%Y%m%d'), '-C', s.n);

-- --------------------------------------------------------------------------------------
-- End-of-day cash register close-outs, aggregated from that day's paid sales
-- --------------------------------------------------------------------------------------
INSERT INTO CashRegisterCashOutTransactions (totalSales, cashOut, remainingCash, currentUser, createdAt)
SELECT
    SUM(st.totalAmount),
    ROUND(SUM(st.totalAmount) * 0.85, 2),
    ROUND(SUM(st.totalAmount) * 0.15, 2),
    '20220002',
    ANY_VALUE(DATE(st.createdAt)) + INTERVAL 22 HOUR
FROM SalesTransactions st
WHERE st.transStatus = 2
GROUP BY DATE(st.createdAt);

DROP TEMPORARY TABLE IF EXISTS SalesSeedCombos;
DROP TEMPORARY TABLE IF EXISTS SalesSeedProducts;
DROP TEMPORARY TABLE IF EXISTS Numbers4;
DROP TEMPORARY TABLE IF EXISTS CalendarPrevMonth;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
