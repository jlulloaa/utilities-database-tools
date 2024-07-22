CREATE TABLE Customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firebaseUid VARCHAR(128) NOT NULL UNIQUE, -- Firebase UID, unique for each user
    email VARCHAR(255) NOT NULL UNIQUE, -- Email associated with the Firebase account
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    StreetName VARCHAR(100) NOT NULL,
    StreetNumber VARCHAR(10) NOT NULL,
    Unit VARCHAR(50), -- This can be used for house/apt/office number
    Town VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100), -- Optional, depending on your needs
    Country VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(50) NOT NULL, -- It's also useful to have a postal/zip code
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Utilities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UtilityName VARCHAR(100) NOT NULL,
    UtilityUnits VARCHAR(20),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Providers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UtilityID INT,
    ProviderName VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UtilityID) REFERENCES Utilities(id)
);

CREATE TABLE Meters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    UtilityID INT,
    SerialNro VARCHAR(200),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UtilityID) REFERENCES Utilities(id)
);

CREATE TABLE CustomerProviderUtility (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    ProviderID INT,
    UtilityID INT,
    MeterID INT,
    CustomerNumber VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(id),
    FOREIGN KEY (ProviderID) REFERENCES Providers(id),
    FOREIGN KEY (UtilityID) REFERENCES Utilities(id),
    FOREIGN KEY (MeterID) REFERENCES Meters(id)
);

CREATE TABLE Bills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CustomerProviderUtilityID INT,
    IssueDate DATE NOT NULL,
    AmountBilled DECIMAL(10, 2) NOT NULL,
    AmountConsumed DECIMAL(10, 2) NOT NULL,
    PaymentDeadline DATE NOT NULL,
    PaymentDate DATE,
    Status ENUM('Paid', 'Unpaid', 'Sumario') DEFAULT 'Unpaid',
    StartPeriod DATE NOT NULL,
    EndPeriod DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerProviderUtilityID) REFERENCES CustomerProviderUtility(id)
);