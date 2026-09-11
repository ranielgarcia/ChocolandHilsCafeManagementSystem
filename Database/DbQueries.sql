CREATE DATABASE ChocolandHilsCafeDb;
USE ChocolandHilsCafeDb;

-- https://www.khanacademy.org/math/cc-third-grade-math/imp-measurement-and-data/imp-mass/v/intuition-for-grams#:~:text=.%20...%E2%80%9D-,To%20convert%20grams%20to%20kilograms%2C%20divide%20by%201%2C000.,30%2C000%20grams%20is%2030%20kilograms.

-- --------------------------------------------------------------------------------------
-- Employee management, attendance and payroll related tables:
-- --------------------------------------------------------------------------------------

-- if the employer decided to change/increase or decrease days on specific leave
-- just add new entry to retain the current records and deactivate the old one
CREATE TABLE IF NOT EXISTS LeaveTypes(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    leaveType VARCHAR(50),
    numberOfDays INT,
    isActive BOOLEAN DEFAULT True,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeShifts(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    shift VARCHAR(50),
    startTime DATETIME, -- we only need the time (ignore the date)
    endTime DATETIME, -- same with this column
    numberOfHrs DECIMAL(5,2), -- can be 7.5 hrs
    breakTime DATETIME,
    breakTimeHrs DECIMAL(5,2), -- 1 is hr, 0.5 is 30mins
    earlyTimeOut DATETIME, -- half day for first 4 or 6 hrs
    lateTimeIn DATETIME, -- half day for last 4 or 6 hrs
    isActive BOOLEAN DEFAULT True,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeShiftDays(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    shiftId BIGINT NOT NULL,
    dayName CHAR(3),
    orderNum INT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (shiftId) REFERENCES EmployeeShifts (id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Holidays(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    holiday VARCHAR(255),
    dayNum INT,
    monthAbbr CHAR(3),
    monthNum INT,
    holidayType INT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Branches(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    branchName VARCHAR(255),
    tellNo VARCHAR(100),
    address VARCHAR(255),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS NumberOfWorkingDaysInMonth(
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numberOfDays DECIMAL(9,2)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeePositions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    dailyRate DECIMAL(9,2),
    monthlyRate DECIMAL(9,2),
    isSingleEmployee BOOLEAN DEFAULT False,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Employees(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8) UNIQUE, -- 20210001, 02, 03 (will always change the first 4 numbers, based on current year)
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    middleName VARCHAR(100),
    address VARCHAR(255),
    birthdate DATE,
    mobileNumber VARCHAR(100),
    emailAddress VARCHAR(100),
    dateHire DATE NOT NULL,
    empNumYear CHAR(4),
    branchId BIGINT,
    positionId BIGINT,
    shiftId BIGINT NOT NULL,
    isQuit BOOLEAN DEFAULT False,
    quitDate DATE,
    imageFileName VARCHAR(250),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (shiftId) REFERENCES EmployeeShifts(id),
    FOREIGN KEY (branchId) REFERENCES Branches(id),
    FOREIGN KEY (positionId) REFERENCES EmployeePositions(id)
)ENGINE=INNODB;

-- Uses govtAgencyEnumVal (StaticData.cs enum) instead of a GovernmentAgencies FK, since each agency needs different contribution computation
CREATE TABLE IF NOT EXISTS EmployeeGovtIdCards(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    govtAgencyEnumVal INT,
    employeeIdNumber VARCHAR(50),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeLeaves(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    leaveId BIGINT NOT NULL,
    employeeNumber CHAR(8),
    reason TEXT,
    startDate DATE,
    endDate DATE,
    numberOfDays DECIMAL, -- 1=day, 0.5 = halfday
    remainingDays DECIMAL, -- can leave whole day or halfday
    currentYear INT,
    isPaid BOOLEAN DEFAULT false,
    payslipId BIGINT DEFAULT 0, -- for easy retrieval of payslip data
    DurationType INT,
    approvalStatus INT DEFAULT 0,
    employerRemarks VARCHAR(255),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (leaveId) REFERENCES LeaveTypes(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS WorkforceSchedules(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    workDate DATE,
    isDone BOOLEAN DEFAULT False,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeAttendance(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    shiftId BIGINT NOT NULL,
    workDate DATE NOT NULL,
    firstTimeIn DATETIME,
    firstTimeOut DATETIME,
    firstHalfHrs DECIMAL, -- in minutes
    firstHalfLateMins DECIMAL, -- put value upon time-in
    firstHalfUnderTimeMins DECIMAL, -- put value upon time-out
    secondTimeIn DATETIME,
    secondTimeOut DATETIME,
    secondHalfHrs DECIMAL, -- in minutes
    secondHalfLateMins DECIMAL,
    secondHalfUnderTimeMins DECIMAL,
    overTimeMins DECIMAL,
    isTimeOutProvided BOOLEAN DEFAULT false,
    lateTotalDeduction DECIMAL(9,2),
    underTimeTotalDeduction DECIMAL(9,2),
    overTimeTotal DECIMAL(9,2),
    totalDailySalary DECIMAL(9,2),
    isPaid BOOLEAN DEFAULT false,
    payslipId BIGINT DEFAULT 0, -- for easy retrieval of payslip data
    isUserDayOffToday BOOLEAN DEFAULT False, -- holiday is considered as overtime
    isHolidayToday BOOLEAN DEFAULT False,
    holidayId BIGINT,
    OverTimeHrlyRate DECIMAL(9,2),
    overTimeDailySalaryAdjustment DECIMAL(9,2),
    overTimeType INT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(shiftId) REFERENCES EmployeeShifts(id)
)ENGINE=INNODB;

-- possible enhancement: add employee type to grant additional benefits per employee type
CREATE TABLE IF NOT EXISTS EmployeeBenefits(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    benefitTitle VARCHAR(255),
    amount DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SpecificEmployeeBenefits(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    employeeName VARCHAR(50),
    benefitTitle VARCHAR(255),
    amount DECIMAL(9,2),
    isPaid BOOLEAN DEFAULT False,
    paymentDate DATETIME,
    payslipId BIGINT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

-- possible enhancement: add employee type to apply conditional/special deductions per employee type
CREATE TABLE IF NOT EXISTS EmployeeDeductions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    deductionTitle VARCHAR(255),
    amount DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SpecificEmployeeDeductions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    employeeName VARCHAR(50),
    deductionTitle VARCHAR(255),
    amount DECIMAL(9,2),
    isDeducted BOOLEAN DEFAULT False,
    deductedDate DATETIME,
    payslipId BIGINT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeCashAdvanceRequests(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    amount DECIMAL(9,2),
    needOnDate DATETIME,
    employeeRemarks VARCHAR(255),
    approvalStatus INT,
    employerRemarks VARCHAR(255),
    cashReleaseDate DATE,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeePayslips(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    employeeNumber CHAR(8),
    startShiftDate DATE,
    endShiftDate DATE,
    payDate DATE,
    dailyRate DECIMAL(9,2),
    numOfDays INT,
    late VARCHAR(50),
    lateTotalDeduction DECIMAL(9,2),
    underTime VARCHAR(50),
    underTimeTotalDeduction DECIMAL(9,2),
    overTime VARCHAR(50),
    overTimeTotalRate DECIMAL(9,2),
    netBasicSalary DECIMAL(9,2),
    benefitsTotal DECIMAL(9,2),
    totalIncome DECIMAL(9,2),
    deductionTotal DECIMAL(9,2),
    netTakeHomePay DECIMAL(9,2),
    paydaySequence INT NOT NULL, -- 1 and 2
    isCancel BOOLEAN DEFAULT False,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

-- employee benefits inventory per payday/payslip
CREATE TABLE IF NOT EXISTS EmployeePayslipBenefits(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    payslipId BIGINT,
    employeeNumber CHAR(8),
    benefitTitle VARCHAR(255),
    amount DECIMAL(9,2),
    displayType INT,
    multiplier VARCHAR(50),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(payslipId) REFERENCES EmployeePayslips(Id)
)ENGINE=INNODB;

-- employee deductions inventory per payday/payslip; leave, absences (from attendance) and government contributions can be added here
CREATE TABLE IF NOT EXISTS EmployeePayslipDeductions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    payslipId BIGINT,
    employeeNumber CHAR(8),
    deductionTitle VARCHAR(255),
    amount DECIMAL(9,2),
    employerGovtContributionAmount DECIMAL(9,2) DEFAULT 0,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(payslipId) REFERENCES EmployeePayslips(Id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS EmployeeGovernmentContributions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    payslipId BIGINT,
    employeeNumber CHAR(8),
    agency VARCHAR(255),
    govContributionEnumVal INT,
    employeeContribution DECIMAL(9,2),
    employerContribution DECIMAL(9,2),
    IdNumber VARCHAR(50),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(payslipId) REFERENCES EmployeePayslips(Id)
)ENGINE=INNODB;

-- --------------------------------------------------------------------------------------
-- User related tables:
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Roles(
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    rolekey VARCHAR(50),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

-- you can store employee number as userName
CREATE TABLE IF NOT EXISTS Users(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userName CHAR(20) UNIQUE,
    fullName VARCHAR(50),
    passwordSha512 VARCHAR(255),
    isActive BOOLEAN DEFAULT True,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS UserActivityLog(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userName CHAR(20),
    activity VARCHAR(255),
    createdAt DATETIME DEFAULT NOW()
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS UserRoles(
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userId BIGINT NOT NULL,
    roleId INT NOT NULL,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (userId) REFERENCES Users(id),
    FOREIGN KEY (roleId) REFERENCES Roles(id)
)ENGINE=INNODB;

-- --------------------------------------------------------------------------------------
-- Inventory and POS related tables:
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS IngredientCategories(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Ingredients(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    categoryId BIGINT NOT NULL,
    ingName VARCHAR(255),
    uom CHAR(3), -- kg(gram), L(ml), pcs(pc)
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(categoryId) REFERENCES IngredientCategories(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS IngredientInventory(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ingredientId BIGINT NOT NULL,
    initialQtyValue DECIMAL, -- in grams, ml, or pcs
    remainingQtyValue DECIMAL,
    unitCost DECIMAL(9,2), -- unit cost based on unit of measurement
    expirationDate DATE,
    isSoldOut BOOLEAN DEFAULT False,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(ingredientId) REFERENCES Ingredients(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS IngInventoryTransactions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ingredientId BIGINT NOT NULL,
    transType INT, -- See StaticData.cs file under EntitiesShared Project
    qtyVal DECIMAL,
    unitCost DECIMAL(9,2),
    expirationDate DATE,
    userId BIGINT NOT NULL,
    remarks VARCHAR(255),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(ingredientId) REFERENCES Ingredients(id),
    FOREIGN KEY(userId) REFERENCES Users(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ProductCategories(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prodCategory VARCHAR(255),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Products(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    barcodeLbl VARCHAR(250),
    categoryId BIGINT NOT NULL,
    prodName VARCHAR(255),
    pricePerOrder DECIMAL(9,2),
    imageFileName VARCHAR(250),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(categoryId) REFERENCES ProductCategories(id)
)ENGINE=INNODB;

-- Per order
CREATE TABLE IF NOT EXISTS ProductIngredients(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    productId BIGINT NOT NULL,
    ingredientId BIGINT NOT NULL,
    uom INT,
    qtyValue DECIMAL,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(productId) REFERENCES Products(id),
    FOREIGN KEY(ingredientId) REFERENCES Ingredients(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ComboMeals(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    barcodeLbl VARCHAR(250),
    title VARCHAR(255),
    price DECIMAL(9,2),
    imageFileName VARCHAR(250),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ComboMealProducts(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    comboMealId BIGINT NOT NULL,
    productId BIGINT NOT NULL,
    quantity INT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(comboMealId) REFERENCES ComboMeals(id),
    FOREIGN KEY(productId) REFERENCES Products(id)
)ENGINE=INNODB;

-- --------------------------------------------------------------------------------------
-- Point of sale tables:
-- --------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS StoreTables(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numberOfTables INT,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SalesTransactions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    transactionType INT, -- Dine-in or Take-out (Enum values)
    ticketNumber VARCHAR(100), -- generate after new transaction created
    customerName VARCHAR(255), -- provided upon initialization
    subTotalAmount DECIMAL(9,2),
    discountAmount DECIMAL(9,2), -- zero upon initialization
    discountIsPercentage BOOLEAN DEFAULT FALSE,
    discountPercent DECIMAL,
    totalAmount DECIMAL(9,2), -- zero upon initialization
    customerCashAmount DECIMAL(9,2), -- zero upon initialization
    customerChangeAmount DECIMAL(9,2), -- zero upon initialization
    customerDueAmount DECIMAL(9,2), -- zero upon initialization
    tableNumber INT, -- provided upon initialization
    transStatus INT, -- OnGoing, Paid or cancelled (Enum values)
    currentUser VARCHAR(255), -- upon initialization
    isCashOut BOOLEAN DEFAULT false,
    TakeOutNumber INT,
    IsCustomerDone BOOLEAN DEFAULT False,
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SalesTransactionProducts(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    salesTransId BIGINT NOT NULL,
    productId BIGINT NOT NULL,
    productCurrentPrice DECIMAL(9,2),
    qty INT,
    totalAmount DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (salesTransId) REFERENCES SalesTransactions(id),
    FOREIGN KEY (productId) REFERENCES Products (id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SalesTransactionComboMeals(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    salesTransId BIGINT NOT NULL,
    comboMealId BIGINT NOT NULL,
    comboMealCurrentPrice DECIMAL(9,2),
    qty INT,
    totalAmount DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY (salesTransId) REFERENCES SalesTransactions(id),
    FOREIGN KEY (comboMealId) REFERENCES ComboMeals (id)
)ENGINE=INNODB;

-- Sale Transaction's Product's Ingredient's Inventory deduction history: we store the ingredients used per
-- product and which inventory record we deduct the required qty value from, since a single ingredient can
-- have multiple inventory records
CREATE TABLE IF NOT EXISTS SaleTranProdIngInvDeductionsRecords(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    saleTransProductId BIGINT NOT NULL,
    ingredientId BIGINT NOT NULL,
    ingredientInventoryId BIGINT NOT NULL,
    ingredientUOM INT,
    deductionSequence INT DEFAULT 0,
    usedUOM INT,
    deductedQtyValue DECIMAL,
    ingInvCurrentUnitCost DECIMAL,
    totalCost DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(saleTransProductId) REFERENCES SalesTransactionProducts(id),
    FOREIGN KEY(ingredientId) REFERENCES Ingredients(id),
    FOREIGN KEY(ingredientInventoryId) REFERENCES IngredientInventory(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SaleTranComboMealIngInvDeductionsRecords(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    saleTransComboMealId BIGINT NOT NULL,
    productId BIGINT NOT NULL,
    ingredientId BIGINT NOT NULL,
    ingredientInventoryId BIGINT NOT NULL,
    ingredientUOM INT,
    deductionSequence INT DEFAULT 0,
    usedUOM INT,
    deductedQtyValue DECIMAL,
    ingInvCurrentUnitCost DECIMAL,
    totalCost DECIMAL(9,2),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False,
    FOREIGN KEY(saleTransComboMealId) REFERENCES SalesTransactionComboMeals(id),
    FOREIGN KEY(productId) REFERENCES Products(id),
    FOREIGN KEY(ingredientId) REFERENCES Ingredients(id),
    FOREIGN KEY(ingredientInventoryId) REFERENCES IngredientInventory(id)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS CashRegisterCashOutTransactions(
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    totalSales DECIMAL(9,2),
    cashOut DECIMAL(9,2),
    remainingCash DECIMAL(9,2),
    currentUser VARCHAR(100),
    createdAt DATETIME DEFAULT NOW(),
    updatedAt DATETIME DEFAULT NOW() ON UPDATE NOW(),
    deletedAt DATETIME,
    isDeleted BOOLEAN DEFAULT False
)ENGINE=INNODB;
