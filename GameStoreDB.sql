-- =============================================
-- DATABASE: GameStoreDB
-- SHOP: FARM OF PHAM
-- =============================================
USE master;
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'GameStoreDB')
    CREATE DATABASE GameStoreDB;
GO
USE GameStoreDB;
GO

-- 1. USER-DEFINED TABLE TYPES
IF TYPE_ID(N'dbo.OrderItemType') IS NULL
    CREATE TYPE dbo.OrderItemType AS TABLE (
        ProductID INT NOT NULL,
        Quantity  INT NOT NULL
    );
GO

-- TABLE: Platforms
IF OBJECT_ID('dbo.Platforms', 'U') IS NOT NULL DROP TABLE dbo.Platforms;

-- TABLE: Brands
IF OBJECT_ID('dbo.Brands', 'U') IS NOT NULL DROP TABLE dbo.Brands;

-- TABLE: Genres
IF OBJECT_ID('dbo.Genres', 'U') IS NOT NULL DROP TABLE dbo.Genres;

-- TABLE: Suppliers
IF OBJECT_ID('dbo.Suppliers', 'U') IS NOT NULL DROP TABLE dbo.Suppliers;

-- TABLE: Categories
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;

-- TABLE: Stores
IF OBJECT_ID('dbo.Stores', 'U') IS NOT NULL DROP TABLE dbo.Stores;

-- TABLE: Products
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;

-- TABLE: ProductImages
IF OBJECT_ID('dbo.ProductImages', 'U') IS NOT NULL DROP TABLE dbo.ProductImages;

-- TABLE: Inventory
IF OBJECT_ID('dbo.Inventory', 'U') IS NOT NULL DROP TABLE dbo.Inventory;

-- TABLE: InstallmentPlans
IF OBJECT_ID('dbo.InstallmentPlans', 'U') IS NOT NULL DROP TABLE dbo.InstallmentPlans;

-- TABLE: Coupons
IF OBJECT_ID('dbo.Coupons', 'U') IS NOT NULL DROP TABLE dbo.Coupons;

-- TABLE: Customers
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;

-- TABLE: CustomerAddresses
IF OBJECT_ID('dbo.CustomerAddresses', 'U') IS NOT NULL DROP TABLE dbo.CustomerAddresses;

-- TABLE: Employees
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;

-- TABLE: Carts
IF OBJECT_ID('dbo.Carts', 'U') IS NOT NULL DROP TABLE dbo.Carts;

-- TABLE: CartItems
IF OBJECT_ID('dbo.CartItems', 'U') IS NOT NULL DROP TABLE dbo.CartItems;

-- TABLE: Orders
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;

-- TABLE: OrderDetails
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;

-- TABLE: OrderStatusHistory
IF OBJECT_ID('dbo.OrderStatusHistory', 'U') IS NOT NULL DROP TABLE dbo.OrderStatusHistory;

-- TABLE: Reviews
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL DROP TABLE dbo.Reviews;

-- TABLE: Banners
IF OBJECT_ID('dbo.Banners', 'U') IS NOT NULL DROP TABLE dbo.Banners;

-- TABLE: TradeIns
IF OBJECT_ID('dbo.TradeIns', 'U') IS NOT NULL DROP TABLE dbo.TradeIns;

-- 2. CREATE TABLES
CREATE TABLE dbo.Platforms (
    PlatformID INT IDENTITY(1,1) PRIMARY KEY,
    PlatformName NVARCHAR(50) NOT NULL,
    Slug VARCHAR(60) NOT NULL UNIQUE
);
GO
CREATE TABLE dbo.Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(100) NOT NULL,
    Slug VARCHAR(120) NOT NULL UNIQUE,
    LogoUrl VARCHAR(255) NULL
);
GO
CREATE TABLE dbo.Genres (
    GenreID INT IDENTITY(1,1) PRIMARY KEY,
    GenreName NVARCHAR(100) NOT NULL
);
GO
CREATE TABLE dbo.Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(150) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Address NVARCHAR(255) NULL
);
GO
CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ParentCategoryID INT NULL REFERENCES dbo.Categories(CategoryID),
    CategoryName NVARCHAR(100) NOT NULL,
    Slug VARCHAR(120) NOT NULL UNIQUE,
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
CREATE TABLE dbo.Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName NVARCHAR(150) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NULL,
    OpenHours NVARCHAR(100) NULL,
    IsWarehouse BIT NOT NULL DEFAULT 0
);
GO
CREATE TABLE dbo.Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    SKU VARCHAR(40) NOT NULL UNIQUE,
    ProductName NVARCHAR(200) NOT NULL,
    Slug VARCHAR(220) NOT NULL UNIQUE,
    CategoryID INT NOT NULL REFERENCES dbo.Categories(CategoryID),
    PlatformID INT NOT NULL REFERENCES dbo.Platforms(PlatformID),
    BrandID INT NOT NULL REFERENCES dbo.Brands(BrandID),
    GenreID INT NULL REFERENCES dbo.Genres(GenreID),
    SupplierID INT NOT NULL REFERENCES dbo.Suppliers(SupplierID),
    ListPrice DECIMAL(12,0) NOT NULL,
    SalePrice DECIMAL(12,0) NULL,
    CostPrice DECIMAL(12,0) NOT NULL DEFAULT 0,
    CurrentPrice AS (ISNULL(SalePrice, ListPrice)),
    DiscountPercent AS (CASE WHEN SalePrice IS NOT NULL AND ListPrice > 0 THEN CONVERT(INT, ROUND(((ListPrice - SalePrice) * 100.0) / ListPrice, 0)) ELSE 0 END),
    ShortDescription NVARCHAR(500) NULL,
    Description NVARCHAR(MAX) NULL,
    ReleaseDate DATE NULL,
    AgeRating INT NULL,
    WarrantyMonths INT NOT NULL DEFAULT 0,
    IsFeatured BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TABLE dbo.ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL REFERENCES dbo.Products(ProductID) ON DELETE CASCADE,
    ImageUrl VARCHAR(255) NOT NULL,
    IsPrimary BIT NOT NULL DEFAULT 0,
    DisplayOrder INT NOT NULL DEFAULT 0
);
GO
CREATE TABLE dbo.Inventory (
    ProductID INT NOT NULL REFERENCES dbo.Products(ProductID),
    StoreID INT NOT NULL REFERENCES dbo.Stores(StoreID),
    Quantity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (ProductID, StoreID)
);
GO
CREATE TABLE dbo.InstallmentPlans (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    PlanName NVARCHAR(100) NOT NULL,
    Months INT NOT NULL,
    InterestRatePercent DECIMAL(5,2) NOT NULL DEFAULT 0,
    MinOrderAmount DECIMAL(12,0) NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
CREATE TABLE dbo.Coupons (
    CouponID INT IDENTITY(1,1) PRIMARY KEY,
    Code VARCHAR(30) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    DiscountType NVARCHAR(10) NOT NULL,
    DiscountValue DECIMAL(12,2) NOT NULL,
    MinOrderAmount DECIMAL(12,0) NOT NULL DEFAULT 0,
    MaxDiscountAmount DECIMAL(12,0) NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    UsageLimit INT NULL,
    UsedCount INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
CREATE TABLE dbo.Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    LastLoginAt DATETIME NULL
);
GO
CREATE TABLE dbo.CustomerAddresses (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID) ON DELETE CASCADE,
    RecipientName NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Province NVARCHAR(100) NOT NULL,
    District NVARCHAR(100) NOT NULL,
    Ward NVARCHAR(100) NULL,
    StreetAddress NVARCHAR(255) NOT NULL,
    IsDefault BIT NOT NULL DEFAULT 0
);
GO
CREATE TABLE dbo.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
    Phone VARCHAR(20) NULL,
    StoreID INT NULL REFERENCES dbo.Stores(StoreID),
    HireDate DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
CREATE TABLE dbo.Carts (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL UNIQUE REFERENCES dbo.Customers(CustomerID) ON DELETE CASCADE,
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TABLE dbo.CartItems (
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,
    CartID INT NOT NULL REFERENCES dbo.Carts(CartID) ON DELETE CASCADE,
    ProductID INT NOT NULL REFERENCES dbo.Products(ProductID),
    Quantity INT NOT NULL DEFAULT 1,
    AddedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Cart_Product UNIQUE (CartID, ProductID)
);
GO
CREATE TABLE dbo.Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderCode AS ('DH' + RIGHT('0000000' + CONVERT(VARCHAR(10), OrderID), 7)),
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    EmployeeID INT NULL REFERENCES dbo.Employees(EmployeeID),
    CouponID INT NULL REFERENCES dbo.Coupons(CouponID),
    InstallmentPlanID INT NULL REFERENCES dbo.InstallmentPlans(PlanID),
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT N'Pending',
    PaymentMethod NVARCHAR(30) NOT NULL,
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT N'Unpaid',
    RecipientName NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    ShippingAddress NVARCHAR(255) NOT NULL,
    ShippingFee DECIMAL(12,0) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(12,0) NOT NULL DEFAULT 0,
    SubTotal DECIMAL(14,0) NOT NULL DEFAULT 0,
    TotalAmount DECIMAL(14,0) NOT NULL DEFAULT 0,
    Note NVARCHAR(500) NULL
);
GO
CREATE TABLE dbo.OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES dbo.Orders(OrderID) ON DELETE CASCADE,
    ProductID INT NOT NULL REFERENCES dbo.Products(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,0) NOT NULL,
    LineTotal AS (Quantity * UnitPrice)
);
GO
CREATE TABLE dbo.OrderStatusHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES dbo.Orders(OrderID) ON DELETE CASCADE,
    Status NVARCHAR(20) NOT NULL,
    ChangedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ChangedBy INT NULL REFERENCES dbo.Employees(EmployeeID),
    Note NVARCHAR(255) NULL
);
GO
CREATE TABLE dbo.Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL REFERENCES dbo.Products(ProductID) ON DELETE CASCADE,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(1000) NULL,
    IsApproved BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TABLE dbo.Banners (
    BannerID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ImageUrl VARCHAR(255) NOT NULL,
    LinkUrl VARCHAR(255) NULL,
    Position NVARCHAR(30) NOT NULL DEFAULT N'HomeSlider',
    DisplayOrder INT NOT NULL DEFAULT 0,
    StartDate DATETIME NULL,
    EndDate DATETIME NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
CREATE TABLE dbo.TradeIns (
    TradeInID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    DeviceName NVARCHAR(150) NOT NULL,
    ConditionDescription NVARCHAR(500) NULL,
    ExpectedPrice DECIMAL(12,0) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'Pending',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 3. VIEWS
IF OBJECT_ID('dbo.vw_ProductCatalog', 'V') IS NOT NULL DROP VIEW dbo.vw_ProductCatalog;
GO

-- 5. VIEW --------------------------------------------------------------

-- Danh mục sản phẩm cho trang web (có giá, giảm giá, ảnh, tồn kho, đánh giá)
CREATE VIEW dbo.vw_ProductCatalog AS
SELECT p.ProductID, p.SKU, p.ProductName, p.Slug,
       p.CategoryID, c.CategoryName, pc.CategoryName AS ParentCategoryName,
       p.PlatformID, pl.PlatformName,
       p.BrandID, b.BrandName,
       p.GenreID, g.GenreName,
       p.ListPrice, p.SalePrice, p.CurrentPrice, p.DiscountPercent,
       img.ImageUrl AS PrimaryImage,
       ISNULL(st.OnlineStock, 0) AS OnlineStock,
       ISNULL(st.TotalStock, 0)  AS TotalStock,
       CASE WHEN ISNULL(st.OnlineStock, 0) > 0 THEN N'Còn hàng' ELSE N'Hết hàng' END AS StockStatus,
       rv.AvgRating, ISNULL(rv.ReviewCount, 0) AS ReviewCount,
       p.ShortDescription, p.ReleaseDate, p.AgeRating, p.WarrantyMonths,
       p.IsFeatured, p.IsActive, p.CreatedAt
FROM Products p
JOIN Categories c        ON c.CategoryID = p.CategoryID
LEFT JOIN Categories pc  ON pc.CategoryID = c.ParentCategoryID
JOIN Platforms pl        ON pl.PlatformID = p.PlatformID
JOIN Brands b            ON b.BrandID = p.BrandID
LEFT JOIN Genres g       ON g.GenreID = p.GenreID
OUTER APPLY (SELECT TOP 1 ImageUrl FROM ProductImages
             WHERE ProductID = p.ProductID ORDER BY IsPrimary DESC, DisplayOrder) img
OUTER APPLY (SELECT SUM(CASE WHEN s.IsWarehouse = 1 THEN i.Quantity ELSE 0 END) AS OnlineStock,
                    SUM(i.Quantity) AS TotalStock
             FROM Inventory i JOIN Stores s ON s.StoreID = i.StoreID
             WHERE i.ProductID = p.ProductID) st
OUTER APPLY (SELECT CAST(AVG(CAST(Rating AS DECIMAL(3,2))) AS DECIMAL(3,2)) AS AvgRating, COUNT(*) AS ReviewCount
             FROM Reviews WHERE ProductID = p.ProductID AND IsApproved = 1) rv;

GO
IF OBJECT_ID('dbo.vw_OrderSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_OrderSummary;
GO

-- Tóm tắt đơn hàng cho trang quản trị
CREATE VIEW dbo.vw_OrderSummary AS
SELECT o.OrderID, o.OrderCode, o.OrderDate, c.FullName AS Customer, e.FullName AS Employee,
       o.Status, o.PaymentMethod, o.PaymentStatus,
       o.SubTotal, o.DiscountAmount, o.ShippingFee, o.TotalAmount,
       (SELECT SUM(Quantity) FROM OrderDetails WHERE OrderID = o.OrderID) AS TotalItems
FROM Orders o
JOIN Customers c      ON c.CustomerID = o.CustomerID
LEFT JOIN Employees e ON e.EmployeeID = o.EmployeeID;

GO

-- 4. STORED PROCEDURES
IF OBJECT_ID('dbo.sp_GetProducts', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetProducts;
GO

-- 6.1 Lọc / tìm kiếm / sắp xếp / phân trang sản phẩm (trang danh mục)
--     @SortBy: name_asc | name_desc | price_asc | price_desc | newest
CREATE PROCEDURE dbo.sp_GetProducts
    @CategoryID INT = NULL,
    @BrandID    INT = NULL,
    @PlatformID INT = NULL,
    @MinPrice   DECIMAL(12,0) = NULL,
    @MaxPrice   DECIMAL(12,0) = NULL,
    @Keyword    NVARCHAR(100) = NULL,
    @SortBy     NVARCHAR(20)  = N'newest',
    @PageNumber INT = 1,
    @PageSize   INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize   < 1 SET @PageSize = 12;

    ;WITH cat AS (   -- danh mục được chọn + toàn bộ danh mục con
        SELECT CategoryID FROM Categories WHERE CategoryID = @CategoryID
        UNION ALL
        SELECT c.CategoryID FROM Categories c JOIN cat ON c.ParentCategoryID = cat.CategoryID
    )
    SELECT v.ProductID, v.SKU, v.ProductName, v.Slug, v.CategoryName, v.PlatformName, v.BrandName,
           v.ListPrice, v.SalePrice, v.CurrentPrice, v.DiscountPercent, v.PrimaryImage,
           v.StockStatus, v.OnlineStock, v.AvgRating, v.ReviewCount,
           COUNT(*) OVER () AS TotalRows
    FROM dbo.vw_ProductCatalog v
    WHERE v.IsActive = 1
      AND (@CategoryID IS NULL OR v.CategoryID IN (SELECT CategoryID FROM cat))
      AND (@BrandID    IS NULL OR v.BrandID    = @BrandID)
      AND (@PlatformID IS NULL OR v.PlatformID = @PlatformID)
      AND (@MinPrice   IS NULL OR v.CurrentPrice >= @MinPrice)
      AND (@MaxPrice   IS NULL OR v.CurrentPrice <= @MaxPrice)
      AND (@Keyword    IS NULL OR v.ProductName LIKE N'%' + @Keyword + N'%')
    ORDER BY
        CASE WHEN @SortBy = N'name_asc'   THEN v.ProductName  END ASC,
        CASE WHEN @SortBy = N'name_desc'  THEN v.ProductName  END DESC,
        CASE WHEN @SortBy = N'price_asc'  THEN v.CurrentPrice END ASC,
        CASE WHEN @SortBy = N'price_desc' THEN v.CurrentPrice END DESC,
        v.CreatedAt DESC, v.ProductID DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;
END

GO
IF OBJECT_ID('dbo.sp_PlaceOrder', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PlaceOrder;
GO

-- 6.2 Đặt hàng (có transaction: kiểm tra tồn kho, áp mã giảm giá, trừ kho, xóa giỏ)
CREATE PROCEDURE dbo.sp_PlaceOrder
    @CustomerID      INT,
    @PaymentMethod   NVARCHAR(30),
    @RecipientName   NVARCHAR(100),
    @Phone           VARCHAR(20),
    @ShippingAddress NVARCHAR(255),
    @Items           dbo.OrderItemType READONLY,
    @CouponCode      VARCHAR(30)   = NULL,
    @ShippingFee     DECIMAL(12,0) = 30000,
    @Note            NVARCHAR(500) = NULL,
    @NewOrderID      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @WarehouseID INT = (SELECT TOP 1 StoreID FROM Stores WHERE IsWarehouse = 1 ORDER BY StoreID);
    DECLARE @SubTotal DECIMAL(14,0), @Discount DECIMAL(14,0) = 0;
    DECLARE @CouponID INT = NULL, @CType NVARCHAR(10), @CValue DECIMAL(12,2), @CMax DECIMAL(12,0);

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM @Items)
            THROW 50001, N'Giỏ hàng trống.', 1;

        IF EXISTS (SELECT 1 FROM @Items i
                   LEFT JOIN Products p ON p.ProductID = i.ProductID AND p.IsActive = 1
                   WHERE p.ProductID IS NULL)
            THROW 50002, N'Có sản phẩm không tồn tại hoặc đã ngừng bán.', 1;

        -- Khóa dòng tồn kho và kiểm tra đủ hàng
        IF EXISTS (SELECT 1 FROM @Items i
                   LEFT JOIN Inventory inv WITH (UPDLOCK, HOLDLOCK)
                        ON inv.ProductID = i.ProductID AND inv.StoreID = @WarehouseID
                   WHERE ISNULL(inv.Quantity, 0) < i.Quantity)
            THROW 50003, N'Có sản phẩm không đủ hàng trong kho.', 1;

        SELECT @SubTotal = SUM(i.Quantity * p.CurrentPrice)
        FROM @Items i JOIN Products p ON p.ProductID = i.ProductID;

        -- Mã giảm giá
        IF @CouponCode IS NOT NULL
        BEGIN
            SELECT @CouponID = CouponID, @CType = DiscountType, @CValue = DiscountValue, @CMax = MaxDiscountAmount
            FROM Coupons
            WHERE Code = @CouponCode AND IsActive = 1
              AND GETDATE() BETWEEN StartDate AND EndDate
              AND @SubTotal >= MinOrderAmount
              AND (UsageLimit IS NULL OR UsedCount < UsageLimit);

            IF @CouponID IS NULL
                THROW 50004, N'Mã giảm giá không hợp lệ, đã hết hạn hoặc chưa đủ điều kiện.', 1;

            SET @Discount = CASE WHEN @CType = N'Percent' THEN ROUND(@SubTotal * @CValue / 100, 0) ELSE @CValue END;
            IF @CMax IS NOT NULL AND @Discount > @CMax SET @Discount = @CMax;
            IF @Discount > @SubTotal SET @Discount = @SubTotal;
        END

        INSERT INTO Orders (CustomerID, CouponID, OrderDate, Status, PaymentMethod, PaymentStatus,
                            RecipientName, Phone, ShippingAddress, ShippingFee, DiscountAmount,
                            SubTotal, TotalAmount, Note)
        VALUES (@CustomerID, @CouponID, GETDATE(), N'Pending', @PaymentMethod, N'Unpaid',
                @RecipientName, @Phone, @ShippingAddress, @ShippingFee, @Discount,
                @SubTotal, @SubTotal - @Discount + @ShippingFee, @Note);

        SET @NewOrderID = SCOPE_IDENTITY();

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @NewOrderID, i.ProductID, i.Quantity, p.CurrentPrice
        FROM @Items i JOIN Products p ON p.ProductID = i.ProductID;

        UPDATE inv SET inv.Quantity = inv.Quantity - i.Quantity
        FROM Inventory inv JOIN @Items i ON i.ProductID = inv.ProductID
        WHERE inv.StoreID = @WarehouseID;

        IF @CouponID IS NOT NULL
            UPDATE Coupons SET UsedCount = UsedCount + 1 WHERE CouponID = @CouponID;

        INSERT INTO OrderStatusHistory (OrderID, Status, Note)
        VALUES (@NewOrderID, N'Pending', N'Khách hàng đặt hàng');

        -- Xóa giỏ hàng của khách
        DELETE ci FROM CartItems ci JOIN Carts c ON c.CartID = ci.CartID WHERE c.CustomerID = @CustomerID;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END

GO
IF OBJECT_ID('dbo.sp_UpdateOrderStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateOrderStatus;
GO

-- 6.3 Cập nhật trạng thái đơn hàng (tự hoàn kho khi hủy / trả hàng)
CREATE PROCEDURE dbo.sp_UpdateOrderStatus
    @OrderID    INT,
    @NewStatus  NVARCHAR(20),
    @EmployeeID INT = NULL,
    @Note       NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Old NVARCHAR(20);
    DECLARE @WarehouseID INT = (SELECT TOP 1 StoreID FROM Stores WHERE IsWarehouse = 1 ORDER BY StoreID);

    BEGIN TRY
        BEGIN TRAN;

        SELECT @Old = Status FROM Orders WITH (UPDLOCK) WHERE OrderID = @OrderID;

        IF @Old IS NULL
            THROW 50010, N'Không tìm thấy đơn hàng.', 1;
        IF @Old IN (N'Cancelled', N'Returned')
            THROW 50011, N'Đơn hàng đã kết thúc, không thể đổi trạng thái.', 1;
        IF @NewStatus = N'Cancelled' AND @Old NOT IN (N'Pending', N'Confirmed')
            THROW 50012, N'Chỉ hủy được đơn chưa giao hàng.', 1;
        IF @Old = N'Completed' AND @NewStatus <> N'Returned'
            THROW 50013, N'Đơn đã hoàn thành chỉ có thể chuyển sang Returned.', 1;

        UPDATE Orders
        SET Status = @NewStatus,
            EmployeeID = ISNULL(@EmployeeID, EmployeeID),
            PaymentStatus = CASE
                WHEN @NewStatus = N'Completed' THEN N'Paid'
                WHEN @NewStatus IN (N'Cancelled', N'Returned') AND PaymentStatus = N'Paid' THEN N'Refunded'
                ELSE PaymentStatus END
        WHERE OrderID = @OrderID;

        IF @NewStatus IN (N'Cancelled', N'Returned')
            UPDATE inv SET inv.Quantity = inv.Quantity + od.Quantity
            FROM Inventory inv JOIN OrderDetails od ON od.ProductID = inv.ProductID
            WHERE od.OrderID = @OrderID AND inv.StoreID = @WarehouseID;

        INSERT INTO OrderStatusHistory (OrderID, Status, ChangedBy, Note)
        VALUES (@OrderID, @NewStatus, @EmployeeID, @Note);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END

GO

-- 5. TRIGGERS

-- 7. TRIGGER -----------------------------------------------------------
-- Tự cập nhật UpdatedAt mỗi khi sửa sản phẩm
CREATE TRIGGER trg_Products_UpdatedAt
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p SET p.UpdatedAt = GETDATE()
    FROM Products p JOIN inserted i ON i.ProductID = p.ProductID;
END

GO

-- 6. SAMPLE DATA
-- Data for Platforms
SET IDENTITY_INSERT dbo.Platforms ON;
INSERT INTO dbo.Platforms ([PlatformID], [PlatformName], [Slug]) VALUES (1, N'PS4', N'ps4');
INSERT INTO dbo.Platforms ([PlatformID], [PlatformName], [Slug]) VALUES (2, N'PS5', N'ps5');
INSERT INTO dbo.Platforms ([PlatformID], [PlatformName], [Slug]) VALUES (3, N'Nintendo Switch', N'nintendo-switch');
INSERT INTO dbo.Platforms ([PlatformID], [PlatformName], [Slug]) VALUES (4, N'PlayStation Network', N'psn');
SET IDENTITY_INSERT dbo.Platforms OFF;
GO
-- Data for Brands
SET IDENTITY_INSERT dbo.Brands ON;
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (1, N'Sony', N'sony', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (2, N'Nintendo', N'nintendo', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (3, N'Electronic Arts', N'electronic-arts', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (4, N'Bandai Namco', N'bandai-namco', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (5, N'Capcom', N'capcom', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (6, N'Rockstar Games', N'rockstar-games', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (7, N'Square Enix', N'square-enix', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (8, N'CD Projekt Red', N'cd-projekt-red', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (9, N'Mojang', N'mojang', NULL);
INSERT INTO dbo.Brands ([BrandID], [BrandName], [Slug], [LogoUrl]) VALUES (10, N'Outright Games', N'outright-games', NULL);
SET IDENTITY_INSERT dbo.Brands OFF;
GO
-- Data for Genres
SET IDENTITY_INSERT dbo.Genres ON;
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (6, N'Bắn súng');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (9, N'Chiến thuật');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (4, N'Đối kháng');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (5, N'Đua xe');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (1, N'Hành động - Phiêu lưu');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (7, N'Kinh dị');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (2, N'Nhập vai (RPG)');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (8, N'Platform - Giải đố');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (10, N'Sandbox - Sinh tồn');
INSERT INTO dbo.Genres ([GenreID], [GenreName]) VALUES (3, N'Thể thao');
SET IDENTITY_INSERT dbo.Genres OFF;
GO
-- Data for Suppliers
SET IDENTITY_INSERT dbo.Suppliers ON;
INSERT INTO dbo.Suppliers ([SupplierID], [SupplierName], [Phone], [Email], [Address]) VALUES (1, N'Sony Việt Nam', N'02838220000', N'sales@sony.vn', N'TP. Hồ Chí Minh');
INSERT INTO dbo.Suppliers ([SupplierID], [SupplierName], [Phone], [Email], [Address]) VALUES (2, N'Công ty GameHub Distribution', N'02838123456', N'contact@gamehub.vn', N'Quận 3, TP. Hồ Chí Minh');
INSERT INTO dbo.Suppliers ([SupplierID], [SupplierName], [Phone], [Email], [Address]) VALUES (3, N'Công ty DigiWorld', N'02438654321', N'info@digiworld.vn', N'Cầu Giấy, Hà Nội');
INSERT INTO dbo.Suppliers ([SupplierID], [SupplierName], [Phone], [Email], [Address]) VALUES (4, N'Nhà phân phối Nintendo Việt Nam', N'02839998888', N'order@nintendo-vn.com', N'Quận 7, TP. Hồ Chí Minh');
SET IDENTITY_INSERT dbo.Suppliers OFF;
GO
-- Data for Categories
SET IDENTITY_INSERT dbo.Categories ON;
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (1, NULL, N'Máy chơi game', N'may-choi-game', 1, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (2, 1, N'Máy PS5', N'may-ps5', 1, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (3, 1, N'Máy PS4', N'may-ps4', 2, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (4, 1, N'Máy Nintendo Switch', N'may-nintendo-switch', 3, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (5, NULL, N'Đĩa game', N'dia-game', 2, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (6, 5, N'Đĩa game PS5', N'dia-game-ps5', 1, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (7, 5, N'Đĩa game PS4', N'dia-game-ps4', 2, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (8, 5, N'Game Nintendo Switch', N'game-nintendo-switch', 3, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (9, NULL, N'Phụ kiện', N'phu-kien', 3, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (10, 9, N'Tay cầm', N'tay-cam', 1, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (11, 9, N'Tai nghe & VR', N'tai-nghe-vr', 2, 1);
INSERT INTO dbo.Categories ([CategoryID], [ParentCategoryID], [CategoryName], [Slug], [DisplayOrder], [IsActive]) VALUES (12, NULL, N'Thẻ PSN', N'the-psn', 4, 1);
SET IDENTITY_INSERT dbo.Categories OFF;
GO
-- Data for Stores
SET IDENTITY_INSERT dbo.Stores ON;
INSERT INTO dbo.Stores ([StoreID], [StoreName], [Address], [City], [Phone], [OpenHours], [IsWarehouse]) VALUES (1, N'Kho Online', N'45 Nguyễn Văn Linh, Quận 7', N'TP. Hồ Chí Minh', N'0900000001', N'08:00 - 20:00', 1);
INSERT INTO dbo.Stores ([StoreID], [StoreName], [Address], [City], [Phone], [OpenHours], [IsWarehouse]) VALUES (2, N'Cửa hàng Quận 1', N'123 Lê Lợi, Quận 1', N'TP. Hồ Chí Minh', N'0900000002', N'09:00 - 21:30', 0);
INSERT INTO dbo.Stores ([StoreID], [StoreName], [Address], [City], [Phone], [OpenHours], [IsWarehouse]) VALUES (3, N'Cửa hàng Cầu Giấy', N'88 Trần Thái Tông, Cầu Giấy', N'Hà Nội', N'0900000003', N'09:00 - 21:00', 0);
SET IDENTITY_INSERT dbo.Stores OFF;
GO
-- Data for Products
SET IDENTITY_INSERT dbo.Products ON;
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'PS5-CON-STD', N'Máy PS5 Standard Edition (có ổ đĩa)', N'may-ps5-standard-edition', 2, 2, 1, NULL, 1, 14500000, 13990000, 12500000, N'PS5 bản có ổ đĩa, SSD 825GB, hỗ trợ 4K 120Hz.', NULL, '2020-11-12 00:00:00', NULL, 12, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'PS5-CON-DIG', N'Máy PS5 Digital Edition (không ổ đĩa)', N'may-ps5-digital-edition', 2, 2, 1, NULL, 1, 12500000, NULL, 10800000, N'PS5 bản không ổ đĩa, chỉ chơi game tải về.', NULL, '2020-11-12 00:00:00', NULL, 12, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'PS5-CON-SLIM', N'Máy PS5 Slim 1TB (có ổ đĩa)', N'may-ps5-slim-1tb', 2, 2, 1, NULL, 1, 13500000, 12990000, 11500000, N'PS5 Slim thiết kế gọn nhẹ, SSD 1TB.', NULL, '2023-11-10 00:00:00', NULL, 12, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'PS4-CON-SLIM', N'Máy PS4 Slim 1TB', N'may-ps4-slim-1tb', 3, 1, 1, NULL, 1, 7990000, 7490000, 6500000, N'PS4 Slim ổ cứng 1TB, thư viện game phong phú.', NULL, '2016-09-15 00:00:00', NULL, 12, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5, N'NSW-CON-OLED', N'Máy Nintendo Switch OLED', N'may-nintendo-switch-oled', 4, 3, 2, NULL, 4, 8490000, 7990000, 7000000, N'Màn hình OLED 7 inch, chân đế điều chỉnh, 64GB.', NULL, '2021-10-08 00:00:00', NULL, 12, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (6, N'NSW-CON-LITE', N'Máy Nintendo Switch Lite', N'may-nintendo-switch-lite', 4, 3, 2, NULL, 4, 5490000, NULL, 4600000, N'Phiên bản cầm tay nhỏ gọn của Nintendo Switch.', NULL, '2019-09-20 00:00:00', NULL, 12, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (7, N'PS5-ACC-DS', N'Tay cầm DualSense PS5', N'tay-cam-dualsense-ps5', 10, 2, 1, NULL, 1, 1890000, 1790000, 1450000, N'Phản hồi xúc giác và trigger thích ứng.', NULL, '2020-11-12 00:00:00', NULL, 6, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (8, N'PS4-ACC-DS4', N'Tay cầm DualShock 4 PS4', N'tay-cam-dualshock-4-ps4', 10, 1, 1, NULL, 1, 1450000, 1390000, 1100000, N'Tay cầm không dây chính hãng cho PS4.', NULL, '2013-11-15 00:00:00', NULL, 6, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (9, N'PS5-ACC-PULSE', N'Tai nghe Pulse 3D Wireless', N'tai-nghe-pulse-3d-wireless', 11, 2, 1, NULL, 1, 2490000, 2290000, 1850000, N'Tai nghe không dây âm thanh 3D cho PS5.', NULL, '2020-11-12 00:00:00', NULL, 6, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (10, N'PS5-ACC-VR2', N'Kính thực tế ảo PlayStation VR2', N'kinh-playstation-vr2', 11, 2, 1, NULL, 1, 13500000, 12490000, 11000000, N'Kính VR cho PS5, màn hình OLED 4K HDR.', NULL, '2023-02-22 00:00:00', NULL, 6, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (11, N'NSW-ACC-PRO', N'Tay cầm Nintendo Switch Pro Controller', N'tay-cam-switch-pro-controller', 10, 3, 2, NULL, 4, 1750000, NULL, 1350000, N'Tay cầm Pro chính hãng cho Nintendo Switch.', NULL, '2017-03-03 00:00:00', NULL, 6, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (12, N'PSN-PLUS-12M', N'Thẻ PlayStation Plus Essential 12 tháng', N'the-playstation-plus-essential-12-thang', 12, 4, 1, NULL, 1, 850000, 750000, 680000, N'Chơi online, nhận game hàng tháng, lưu game trên đám mây.', NULL, NULL, NULL, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (13, N'PSN-CARD-500K', N'Thẻ nạp PSN 500.000đ', N'the-nap-psn-500k', 12, 4, 1, NULL, 1, 500000, NULL, 470000, N'Mã nạp tiền tài khoản PlayStation Store.', NULL, NULL, NULL, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (14, N'PS4-FC26', N'EA Sports FC 26 cho PS4', N'ea-sports-fc-26-cho-ps4', 7, 1, 3, 3, 2, 1600000, NULL, 1400000, N'Game bóng đá với dữ liệu cầu thủ và giải đấu mới nhất.', NULL, '2025-09-26 00:00:00', 3, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (15, N'PS5-FC26', N'EA Sports FC 26 cho PS5', N'ea-sports-fc-26-cho-ps5', 6, 2, 3, 3, 2, 1650000, NULL, 1450000, N'Game bóng đá thế hệ mới trên PS5.', NULL, '2025-09-26 00:00:00', 3, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (16, N'NSW-METROID', N'Metroid Prime Remastered - Nintendo Switch', N'metroid-prime-remastered-nintendo-switch', 8, 3, 2, 1, 4, 850000, NULL, 720000, N'Bản làm lại đồ họa của huyền thoại Metroid Prime.', NULL, '2023-02-08 00:00:00', 12, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (17, N'PS5-OCTO2', N'Octopath Traveler II cho PS5', N'octopath-traveler-ii-cho-ps5', 6, 2, 7, 2, 2, 1150000, NULL, 980000, N'JRPG phong cách HD-2D với 8 nhân vật chính.', NULL, '2023-02-24 00:00:00', 12, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (18, N'NSW-KIRBY', N'Kirby''s Return to Dreamland Deluxe - Nintendo Switch', N'kirbys-return-to-dreamland-deluxe-nintendo-switch', 8, 3, 2, 8, 4, 1150000, NULL, 980000, N'Cuộc phiêu lưu vui nhộn của Kirby, hỗ trợ chơi 4 người.', NULL, '2023-02-24 00:00:00', 7, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (19, N'PS5-WITCHER3', N'The Witcher 3: Wild Hunt Complete Edition cho PS5', N'the-witcher-3-wild-hunt-complete-edition-cho-ps5', 6, 2, 8, 2, 2, 1050000, NULL, 880000, N'Game nhập vai thế giới mở đạt hơn 800 giải thưởng.', NULL, '2022-12-14 00:00:00', 18, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (20, N'NSW-FEENGAGE', N'Nintendo Fire Emblem Engage - Nintendo Switch', N'nintendo-fire-emblem-engage-nintendo-switch', 8, 3, 2, 9, 4, 1150000, NULL, 980000, N'Game chiến thuật theo lượt với các Emblem huyền thoại.', NULL, '2023-01-20 00:00:00', 12, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (21, N'NSW-ITTAKESTWO', N'It Takes Two - Nintendo Switch', N'it-takes-two-nintendo-switch', 8, 3, 3, 8, 3, 1050000, NULL, 880000, N'Game co-op dành cho 2 người, đạt giải Game of the Year 2021.', NULL, '2022-11-04 00:00:00', 12, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (22, N'PS5-GOWR', N'God of War Ragnarök cho PS5', N'god-of-war-ragnarok-cho-ps5', 6, 2, 1, 1, 1, 1250000, 1190000, 1000000, N'Kratos và Atreus bước vào hành trình thần thoại Bắc Âu.', NULL, '2022-11-09 00:00:00', 18, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (23, N'PS5-SPIDER2', N'Marvel''s Spider-Man 2 cho PS5', N'marvels-spider-man-2-cho-ps5', 6, 2, 1, 1, 1, 1450000, 1390000, 1150000, N'Peter Parker và Miles Morales cùng bảo vệ New York.', NULL, '2023-10-20 00:00:00', 16, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (24, N'PS5-RE4', N'Resident Evil 4 Remake cho PS5', N'resident-evil-4-remake-cho-ps5', 6, 2, 5, 7, 2, 1150000, 1090000, 920000, N'Bản làm lại kinh điển của dòng game kinh dị sinh tồn.', NULL, '2023-03-24 00:00:00', 18, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (25, N'PS5-SF6', N'Street Fighter 6 cho PS5', N'street-fighter-6-cho-ps5', 6, 2, 5, 4, 2, 1100000, 1050000, 880000, N'Game đối kháng với chế độ World Tour hoàn toàn mới.', NULL, '2023-06-02 00:00:00', 12, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (26, N'PS5-TEKKEN8', N'Tekken 8 cho PS5', N'tekken-8-cho-ps5', 6, 2, 4, 4, 3, 1350000, 1290000, 1100000, N'Phần mới nhất của huyền thoại game đối kháng 3D.', NULL, '2024-01-26 00:00:00', 16, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (27, N'PS5-ELDEN', N'Elden Ring cho PS5', N'elden-ring-cho-ps5', 6, 2, 4, 2, 3, 1250000, 1190000, 1000000, N'Game nhập vai thế giới mở của FromSoftware.', NULL, '2022-02-25 00:00:00', 16, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (28, N'PS4-GTA5', N'Grand Theft Auto V cho PS4', N'grand-theft-auto-v-cho-ps4', 7, 1, 6, 1, 2, 590000, 490000, 400000, N'Game thế giới mở tội phạm nổi tiếng nhất thập kỷ.', NULL, '2014-11-18 00:00:00', 18, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (29, N'PS4-RDR2', N'Red Dead Redemption 2 cho PS4', N'red-dead-redemption-2-cho-ps4', 7, 1, 6, 1, 2, 790000, 690000, 560000, N'Câu chuyện miền Tây hoang dã của Arthur Morgan.', NULL, '2018-10-26 00:00:00', 18, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (30, N'PS4-TLOU2', N'The Last of Us Part II cho PS4', N'the-last-of-us-part-ii-cho-ps4', 7, 1, 1, 1, 1, 690000, 590000, 470000, N'Hành trình sinh tồn và trả thù đầy cảm xúc của Ellie.', NULL, '2020-06-19 00:00:00', 18, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (31, N'NSW-MARIOKART8', N'Mario Kart 8 Deluxe - Nintendo Switch', N'mario-kart-8-deluxe-nintendo-switch', 8, 3, 2, 5, 4, 1450000, 1350000, 1150000, N'Game đua xe vui nhộn bán chạy nhất trên Switch.', NULL, '2017-04-28 00:00:00', 3, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (32, N'NSW-ZELDATOTK', N'The Legend of Zelda: Tears of the Kingdom - Nintendo Switch', N'zelda-tears-of-the-kingdom-nintendo-switch', 8, 3, 2, 1, 4, 1550000, 1450000, 1250000, N'Phần tiếp theo của Breath of the Wild, khám phá cả bầu trời.', NULL, '2023-05-12 00:00:00', 12, 0, 1, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (33, N'NSW-MINECRAFT', N'Minecraft - Nintendo Switch', N'minecraft-nintendo-switch', 8, 3, 9, 10, 3, 750000, NULL, 620000, N'Xây dựng và sinh tồn trong thế giới khối vuông vô tận.', NULL, '2018-06-21 00:00:00', 7, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
INSERT INTO dbo.Products ([ProductID], [SKU], [ProductName], [Slug], [CategoryID], [PlatformID], [BrandID], [GenreID], [SupplierID], [ListPrice], [SalePrice], [CostPrice], [ShortDescription], [Description], [ReleaseDate], [AgeRating], [WarrantyMonths], [IsFeatured], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (34, N'PS5-PAWGP', N'PAW Patrol: Grand Prix cho PS5', N'paw-patrol-grand-prix-cho-ps5', 6, 2, 10, 5, 3, 850000, NULL, 700000, N'Game đua xe vui nhộn dành cho trẻ em.', NULL, NULL, 3, 0, 0, 1, '2026-11-16 13:49:04', '2026-11-16 13:49:04');
SET IDENTITY_INSERT dbo.Products OFF;
GO
-- Data for ProductImages
SET IDENTITY_INSERT dbo.ProductImages ON;
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (1, 11, N'/images/products/nsw-acc-pro.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (2, 6, N'/images/products/nsw-con-lite.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (3, 5, N'/images/products/nsw-con-oled.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (4, 20, N'/images/products/nsw-feengage.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (5, 21, N'/images/products/nsw-ittakestwo.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (6, 18, N'/images/products/nsw-kirby.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (7, 31, N'/images/products/nsw-mariokart8.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (8, 16, N'/images/products/nsw-metroid.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (9, 33, N'/images/products/nsw-minecraft.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (10, 32, N'/images/products/nsw-zeldatotk.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (11, 8, N'/images/products/ps4-acc-ds4.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (12, 4, N'/images/products/ps4-con-slim.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (13, 14, N'/images/products/ps4-fc26.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (14, 28, N'/images/products/ps4-gta5.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (15, 29, N'/images/products/ps4-rdr2.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (16, 30, N'/images/products/ps4-tlou2.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (17, 7, N'/images/products/ps5-acc-ds.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (18, 9, N'/images/products/ps5-acc-pulse.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (19, 10, N'/images/products/ps5-acc-vr2.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (20, 2, N'/images/products/ps5-con-dig.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (21, 3, N'/images/products/ps5-con-slim.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (22, 1, N'/images/products/ps5-con-std.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (23, 27, N'/images/products/ps5-elden.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (24, 15, N'/images/products/ps5-fc26.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (25, 22, N'/images/products/ps5-gowr.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (26, 17, N'/images/products/ps5-octo2.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (27, 34, N'/images/products/ps5-pawgp.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (28, 24, N'/images/products/ps5-re4.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (29, 25, N'/images/products/ps5-sf6.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (30, 23, N'/images/products/ps5-spider2.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (31, 26, N'/images/products/ps5-tekken8.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (32, 19, N'/images/products/ps5-witcher3.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (33, 13, N'/images/products/psn-card-500k.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (34, 12, N'/images/products/psn-plus-12m.jpg', 1, 0);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (35, 1, N'/images/products/ps5-con-std-2.jpg', 0, 1);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (36, 3, N'/images/products/ps5-con-slim-2.jpg', 0, 1);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (37, 5, N'/images/products/nsw-con-oled-2.jpg', 0, 1);
INSERT INTO dbo.ProductImages ([ImageID], [ProductID], [ImageUrl], [IsPrimary], [DisplayOrder]) VALUES (38, 22, N'/images/products/ps5-gowr-2.jpg', 0, 1);
SET IDENTITY_INSERT dbo.ProductImages OFF;
GO
-- Data for Inventory
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (1, 1, 15);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (1, 2, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (1, 3, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (2, 1, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (2, 2, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (2, 3, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (3, 1, 12);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (3, 2, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (3, 3, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (4, 1, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (4, 2, 2);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (4, 3, 2);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (5, 1, 9);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (5, 2, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (5, 3, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (6, 1, 7);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (6, 2, 2);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (6, 3, 2);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (7, 1, 40);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (7, 2, 13);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (7, 3, 13);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (8, 1, 30);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (8, 2, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (8, 3, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (9, 1, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (9, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (9, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (10, 1, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (10, 2, 1);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (10, 3, 1);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (11, 1, 14);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (11, 2, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (11, 3, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (12, 1, 100);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (12, 2, 33);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (12, 3, 33);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (13, 1, 60);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (13, 2, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (13, 3, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (14, 1, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (14, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (14, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (15, 1, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (15, 2, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (15, 3, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (16, 1, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (16, 2, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (16, 3, 0);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (17, 1, 12);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (17, 2, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (17, 3, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (18, 1, 15);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (18, 2, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (18, 3, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (19, 1, 18);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (19, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (19, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (20, 1, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (20, 2, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (20, 3, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (21, 1, 11);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (21, 2, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (21, 3, 3);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (22, 1, 25);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (22, 2, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (22, 3, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (23, 1, 22);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (23, 2, 7);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (23, 3, 7);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (24, 1, 18);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (24, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (24, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (25, 1, 14);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (25, 2, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (25, 3, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (26, 1, 16);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (26, 2, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (26, 3, 5);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (27, 1, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (27, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (27, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (28, 1, 40);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (28, 2, 13);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (28, 3, 13);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (29, 1, 28);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (29, 2, 9);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (29, 3, 9);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (30, 1, 24);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (30, 2, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (30, 3, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (31, 1, 30);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (31, 2, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (31, 3, 10);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (32, 1, 20);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (32, 2, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (32, 3, 6);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (33, 1, 25);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (33, 2, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (33, 3, 8);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (34, 1, 12);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (34, 2, 4);
INSERT INTO dbo.Inventory ([ProductID], [StoreID], [Quantity]) VALUES (34, 3, 4);
GO
-- Data for InstallmentPlans
SET IDENTITY_INSERT dbo.InstallmentPlans ON;
INSERT INTO dbo.InstallmentPlans ([PlanID], [PlanName], [Months], [InterestRatePercent], [MinOrderAmount], [IsActive]) VALUES (1, N'Trả góp 0% - 3 tháng', 3, 0.00, 3000000, 1);
INSERT INTO dbo.InstallmentPlans ([PlanID], [PlanName], [Months], [InterestRatePercent], [MinOrderAmount], [IsActive]) VALUES (2, N'Trả góp 0% - 6 tháng', 6, 0.00, 5000000, 1);
INSERT INTO dbo.InstallmentPlans ([PlanID], [PlanName], [Months], [InterestRatePercent], [MinOrderAmount], [IsActive]) VALUES (3, N'Trả góp 12 tháng', 12, 1.50, 5000000, 1);
SET IDENTITY_INSERT dbo.InstallmentPlans OFF;
GO
-- Data for Coupons
SET IDENTITY_INSERT dbo.Coupons ON;
INSERT INTO dbo.Coupons ([CouponID], [Code], [Description], [DiscountType], [DiscountValue], [MinOrderAmount], [MaxDiscountAmount], [StartDate], [EndDate], [UsageLimit], [UsedCount], [IsActive]) VALUES (1, N'WELCOME50K', N'Giảm 50.000đ cho đơn từ 500.000đ', N'Amount', 50000.00, 500000, NULL, '2026-01-01 00:00:00', '2026-12-31 00:00:00', 1000, 1, 1);
INSERT INTO dbo.Coupons ([CouponID], [Code], [Description], [DiscountType], [DiscountValue], [MinOrderAmount], [MaxDiscountAmount], [StartDate], [EndDate], [UsageLimit], [UsedCount], [IsActive]) VALUES (2, N'SALE5', N'Giảm 5% tối đa 300.000đ cho đơn từ 1.000.000đ', N'Percent', 5.00, 1000000, 300000, '2026-01-01 00:00:00', '2026-12-31 00:00:00', NULL, 1, 1);
INSERT INTO dbo.Coupons ([CouponID], [Code], [Description], [DiscountType], [DiscountValue], [MinOrderAmount], [MaxDiscountAmount], [StartDate], [EndDate], [UsageLimit], [UsedCount], [IsActive]) VALUES (3, N'BLACKFRIDAY10', N'Giảm 10% tối đa 500.000đ cho đơn từ 2.000.000đ', N'Percent', 10.00, 2000000, 500000, '2026-11-20 00:00:00', '2026-11-30 00:00:00', 200, 0, 1);
SET IDENTITY_INSERT dbo.Coupons OFF;
GO
-- Data for Customers
SET IDENTITY_INSERT dbo.Customers ON;
INSERT INTO dbo.Customers ([CustomerID], [FullName], [Email], [PasswordHash], [Phone], [DateOfBirth], [IsActive], [CreatedAt], [LastLoginAt]) VALUES (1, N'Nguyễn Văn An', N'an.nguyen@gmail.com', , N'0901234567', '2001-03-15 00:00:00', 1, '2026-11-16 13:49:05', NULL);
INSERT INTO dbo.Customers ([CustomerID], [FullName], [Email], [PasswordHash], [Phone], [DateOfBirth], [IsActive], [CreatedAt], [LastLoginAt]) VALUES (2, N'Trần Thị Bình', N'binh.tran@gmail.com', , N'0912345678', '1999-07-22 00:00:00', 1, '2026-11-16 13:49:05', NULL);
INSERT INTO dbo.Customers ([CustomerID], [FullName], [Email], [PasswordHash], [Phone], [DateOfBirth], [IsActive], [CreatedAt], [LastLoginAt]) VALUES (3, N'Lê Minh Cường', N'cuong.le@gmail.com', , N'0923456789', '2002-11-05 00:00:00', 1, '2026-11-16 13:49:05', NULL);
INSERT INTO dbo.Customers ([CustomerID], [FullName], [Email], [PasswordHash], [Phone], [DateOfBirth], [IsActive], [CreatedAt], [LastLoginAt]) VALUES (4, N'Phạm Thu Dung', N'dung.pham@gmail.com', , N'0934567890', '1998-01-30 00:00:00', 1, '2026-11-16 13:49:05', NULL);
INSERT INTO dbo.Customers ([CustomerID], [FullName], [Email], [PasswordHash], [Phone], [DateOfBirth], [IsActive], [CreatedAt], [LastLoginAt]) VALUES (5, N'Hoàng Đức Em', N'em.hoang@gmail.com', , N'0945678901', '2003-09-12 00:00:00', 1, '2026-11-16 13:49:05', NULL);
SET IDENTITY_INSERT dbo.Customers OFF;
GO
-- Data for CustomerAddresses
SET IDENTITY_INSERT dbo.CustomerAddresses ON;
INSERT INTO dbo.CustomerAddresses ([AddressID], [CustomerID], [RecipientName], [Phone], [Province], [District], [Ward], [StreetAddress], [IsDefault]) VALUES (1, 1, N'Nguyễn Văn An', N'0901234567', N'Đồng Nai', N'TP. Biên Hòa', N'P. Quang Vinh', N'12 Nguyễn Ái Quốc', 1);
INSERT INTO dbo.CustomerAddresses ([AddressID], [CustomerID], [RecipientName], [Phone], [Province], [District], [Ward], [StreetAddress], [IsDefault]) VALUES (2, 2, N'Trần Thị Bình', N'0912345678', N'TP. Hồ Chí Minh', N'Quận 1', N'P. Bến Nghé', N'45 Lê Lợi', 1);
INSERT INTO dbo.CustomerAddresses ([AddressID], [CustomerID], [RecipientName], [Phone], [Province], [District], [Ward], [StreetAddress], [IsDefault]) VALUES (3, 3, N'Lê Minh Cường', N'0923456789', N'Đà Nẵng', N'Hải Châu', N'P. Thạch Thang', N'78 Trần Phú', 1);
INSERT INTO dbo.CustomerAddresses ([AddressID], [CustomerID], [RecipientName], [Phone], [Province], [District], [Ward], [StreetAddress], [IsDefault]) VALUES (4, 4, N'Phạm Thu Dung', N'0934567890', N'Hà Nội', N'Hoàn Kiếm', N'P. Hàng Bài', N'90 Hai Bà Trưng', 1);
INSERT INTO dbo.CustomerAddresses ([AddressID], [CustomerID], [RecipientName], [Phone], [Province], [District], [Ward], [StreetAddress], [IsDefault]) VALUES (5, 5, N'Hoàng Đức Em', N'0945678901', N'Đồng Nai', N'TP. Biên Hòa', N'P. Hòa Bình', N'23 Võ Thị Sáu', 1);
SET IDENTITY_INSERT dbo.CustomerAddresses OFF;
GO
-- Data for Employees
SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees ([EmployeeID], [FullName], [Email], [PasswordHash], [Role], [Phone], [StoreID], [HireDate], [IsActive]) VALUES (1, N'Võ Quốc Huy', N'admin@gamestore.vn', , N'Admin', N'0971111111', 1, '2023-01-10 00:00:00', 1);
INSERT INTO dbo.Employees ([EmployeeID], [FullName], [Email], [PasswordHash], [Role], [Phone], [StoreID], [HireDate], [IsActive]) VALUES (2, N'Đặng Ngọc Lan', N'lan.dang@gamestore.vn', , N'Manager', N'0972222222', 2, '2023-03-01 00:00:00', 1);
INSERT INTO dbo.Employees ([EmployeeID], [FullName], [Email], [PasswordHash], [Role], [Phone], [StoreID], [HireDate], [IsActive]) VALUES (3, N'Bùi Anh Tuấn', N'tuan.bui@gamestore.vn', , N'Sales', N'0973333333', 2, '2023-06-15 00:00:00', 1);
INSERT INTO dbo.Employees ([EmployeeID], [FullName], [Email], [PasswordHash], [Role], [Phone], [StoreID], [HireDate], [IsActive]) VALUES (4, N'Ngô Thanh Sơn', N'son.ngo@gamestore.vn', , N'Warehouse', N'0974444444', 1, '2024-02-01 00:00:00', 1);
SET IDENTITY_INSERT dbo.Employees OFF;
GO
-- Data for Carts
SET IDENTITY_INSERT dbo.Carts ON;
INSERT INTO dbo.Carts ([CartID], [CustomerID], [UpdatedAt]) VALUES (1, 3, '2026-11-16 13:49:05');
INSERT INTO dbo.Carts ([CartID], [CustomerID], [UpdatedAt]) VALUES (2, 5, '2026-11-16 13:49:05');
SET IDENTITY_INSERT dbo.Carts OFF;
GO
-- Data for CartItems
SET IDENTITY_INSERT dbo.CartItems ON;
INSERT INTO dbo.CartItems ([CartItemID], [CartID], [ProductID], [Quantity], [AddedAt]) VALUES (1, 1, 26, 1, '2026-11-16 13:49:05');
INSERT INTO dbo.CartItems ([CartItemID], [CartID], [ProductID], [Quantity], [AddedAt]) VALUES (2, 1, 7, 1, '2026-11-16 13:49:05');
INSERT INTO dbo.CartItems ([CartItemID], [CartID], [ProductID], [Quantity], [AddedAt]) VALUES (3, 2, 5, 1, '2026-11-16 13:49:05');
SET IDENTITY_INSERT dbo.CartItems OFF;
GO
-- Data for Orders
SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (1, 1, 3, NULL, NULL, '2026-09-05 10:30:00', N'Completed', N'COD', N'Paid', N'Nguyễn Văn An', N'0901234567', N'12 Nguyễn Ái Quốc, P. Quang Vinh, TP. Biên Hòa, Đồng Nai', 0, 0, 16970000, 16970000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (2, 2, 3, 1, NULL, '2026-09-18 14:15:00', N'Completed', N'Momo', N'Paid', N'Trần Thị Bình', N'0912345678', N'45 Lê Lợi, P. Bến Nghé, Quận 1, TP. Hồ Chí Minh', 30000, 50000, 2140000, 2120000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (3, 3, 2, NULL, NULL, '2026-10-02 09:00:00', N'Completed', N'Bank Transfer', N'Paid', N'Lê Minh Cường', N'0923456789', N'78 Trần Phú, P. Thạch Thang, Hải Châu, Đà Nẵng', 0, 0, 8670000, 8670000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (4, 4, 3, 2, NULL, '2026-10-20 16:45:00', N'Completed', N'VNPay', N'Paid', N'Phạm Thu Dung', N'0934567890', N'90 Hai Bà Trưng, P. Hàng Bài, Hoàn Kiếm, Hà Nội', 0, 300000, 15490000, 15190000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (5, 5, 3, NULL, NULL, '2026-11-03 11:20:00', N'Shipping', N'COD', N'Unpaid', N'Hoàng Đức Em', N'0945678901', N'23 Võ Thị Sáu, P. Hòa Bình, TP. Biên Hòa, Đồng Nai', 30000, 0, 2200000, 2230000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (6, 2, NULL, NULL, NULL, '2026-11-08 19:10:00', N'Cancelled', N'Momo', N'Refunded', N'Trần Thị Bình', N'0912345678', N'45 Lê Lợi, P. Bến Nghé, Quận 1, TP. Hồ Chí Minh', 0, 0, 12490000, 12490000, NULL);
INSERT INTO dbo.Orders ([OrderID], [CustomerID], [EmployeeID], [CouponID], [InstallmentPlanID], [OrderDate], [Status], [PaymentMethod], [PaymentStatus], [RecipientName], [Phone], [ShippingAddress], [ShippingFee], [DiscountAmount], [SubTotal], [TotalAmount], [Note]) VALUES (7, 1, NULL, NULL, NULL, '2026-11-14 20:30:00', N'Pending', N'Bank Transfer', N'Unpaid', N'Nguyễn Văn An', N'0901234567', N'12 Nguyễn Ái Quốc, P. Quang Vinh, TP. Biên Hòa, Đồng Nai', 0, 0, 10790000, 10790000, NULL);
SET IDENTITY_INSERT dbo.Orders OFF;
GO
-- Data for OrderDetails
SET IDENTITY_INSERT dbo.OrderDetails ON;
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (1, 1, 1, 1, 13990000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (2, 1, 7, 1, 1790000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (3, 1, 22, 1, 1190000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (4, 2, 24, 1, 1090000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (5, 2, 25, 1, 1050000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (6, 3, 4, 1, 7490000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (7, 3, 28, 1, 490000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (8, 3, 29, 1, 690000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (9, 4, 2, 1, 12500000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (10, 4, 23, 1, 1390000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (11, 4, 14, 1, 1600000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (12, 5, 19, 1, 1050000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (13, 5, 17, 1, 1150000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (14, 6, 10, 1, 12490000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (15, 7, 31, 1, 1350000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (16, 7, 32, 1, 1450000);
INSERT INTO dbo.OrderDetails ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES (17, 7, 5, 1, 7990000);
SET IDENTITY_INSERT dbo.OrderDetails OFF;
GO
-- Data for OrderStatusHistory
SET IDENTITY_INSERT dbo.OrderStatusHistory ON;
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (1, 6, N'Pending', '2026-11-08 19:10:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (2, 1, N'Pending', '2026-09-05 10:30:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (3, 2, N'Pending', '2026-09-18 14:15:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (4, 3, N'Pending', '2026-10-02 09:00:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (5, 4, N'Pending', '2026-10-20 16:45:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (6, 7, N'Pending', '2026-11-14 20:30:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (7, 5, N'Pending', '2026-11-03 11:20:00', NULL, N'Khách hàng đặt hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (8, 6, N'Cancelled', '2026-11-09 19:10:00', NULL, N'Cập nhật trạng thái đơn hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (9, 1, N'Completed', '2026-09-06 10:30:00', NULL, N'Cập nhật trạng thái đơn hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (10, 2, N'Completed', '2026-09-19 14:15:00', NULL, N'Cập nhật trạng thái đơn hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (11, 3, N'Completed', '2026-10-03 09:00:00', NULL, N'Cập nhật trạng thái đơn hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (12, 4, N'Completed', '2026-10-21 16:45:00', NULL, N'Cập nhật trạng thái đơn hàng');
INSERT INTO dbo.OrderStatusHistory ([HistoryID], [OrderID], [Status], [ChangedAt], [ChangedBy], [Note]) VALUES (13, 5, N'Shipping', '2026-11-04 11:20:00', NULL, N'Cập nhật trạng thái đơn hàng');
SET IDENTITY_INSERT dbo.OrderStatusHistory OFF;
GO
-- Data for Reviews
SET IDENTITY_INSERT dbo.Reviews ON;
INSERT INTO dbo.Reviews ([ReviewID], [ProductID], [CustomerID], [Rating], [Comment], [IsApproved], [CreatedAt]) VALUES (1, 22, 1, 5, N'Game cực hay, cốt truyện và đồ họa đỉnh cao.', 1, '2026-11-16 13:49:05');
INSERT INTO dbo.Reviews ([ReviewID], [ProductID], [CustomerID], [Rating], [Comment], [IsApproved], [CreatedAt]) VALUES (2, 7, 1, 5, N'Tay cầm rung rất đã, cầm chắc tay.', 1, '2026-11-16 13:49:05');
INSERT INTO dbo.Reviews ([ReviewID], [ProductID], [CustomerID], [Rating], [Comment], [IsApproved], [CreatedAt]) VALUES (3, 24, 2, 4, N'Remake rất đáng chơi, hơi kinh dị với người mới.', 1, '2026-11-16 13:49:05');
INSERT INTO dbo.Reviews ([ReviewID], [ProductID], [CustomerID], [Rating], [Comment], [IsApproved], [CreatedAt]) VALUES (4, 28, 3, 5, N'Giá rẻ mà chơi mãi không chán.', 1, '2026-11-16 13:49:05');
INSERT INTO dbo.Reviews ([ReviewID], [ProductID], [CustomerID], [Rating], [Comment], [IsApproved], [CreatedAt]) VALUES (5, 23, 4, 5, N'Đánh nhau mượt, thành phố đẹp.', 1, '2026-11-16 13:49:05');
SET IDENTITY_INSERT dbo.Reviews OFF;
GO
-- Data for Banners
SET IDENTITY_INSERT dbo.Banners ON;
INSERT INTO dbo.Banners ([BannerID], [Title], [ImageUrl], [LinkUrl], [Position], [DisplayOrder], [StartDate], [EndDate], [IsActive]) VALUES (1, N'Deal hời giá sốc - PlayStation Plus Essential 750.000đ', N'/images/banners/psplus-750k.jpg', N'/danh-muc/the-psn', N'TopBar', 1, '2026-11-01 00:00:00', '2026-12-31 00:00:00', 1);
INSERT INTO dbo.Banners ([BannerID], [Title], [ImageUrl], [LinkUrl], [Position], [DisplayOrder], [StartDate], [EndDate], [IsActive]) VALUES (2, N'Ưu đãi máy PS5', N'/images/banners/ps5-sale.jpg', N'/danh-muc/may-ps5', N'HomeSlider', 1, NULL, NULL, 1);
INSERT INTO dbo.Banners ([BannerID], [Title], [ImageUrl], [LinkUrl], [Position], [DisplayOrder], [StartDate], [EndDate], [IsActive]) VALUES (3, N'Game Nintendo Switch mới về', N'/images/banners/switch-new.jpg', N'/danh-muc/game-nintendo-switch', N'HomeSlider', 2, NULL, NULL, 1);
SET IDENTITY_INSERT dbo.Banners OFF;
GO
-- Data for TradeIns
SET IDENTITY_INSERT dbo.TradeIns ON;
INSERT INTO dbo.TradeIns ([TradeInID], [CustomerID], [DeviceName], [ConditionDescription], [ExpectedPrice], [Status], [CreatedAt]) VALUES (1, 1, N'PS4 Pro 1TB', N'Máy hoạt động tốt, trầy xước nhẹ, kèm 1 tay cầm.', 4500000, N'Approved', '2026-11-16 13:49:05');
INSERT INTO dbo.TradeIns ([TradeInID], [CustomerID], [DeviceName], [ConditionDescription], [ExpectedPrice], [Status], [CreatedAt]) VALUES (2, 3, N'Nintendo Switch V1', N'Pin còn tốt, màn hình không xước.', 3200000, N'Pending', '2026-11-16 13:49:05');
SET IDENTITY_INSERT dbo.TradeIns OFF;
GO


-- =====================================================
-- MIGRATION 001: AuditLogs
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE AuditLogs (
        LogID       INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID  INT NOT NULL,
        Action      NVARCHAR(50) NOT NULL,
        EntityType  NVARCHAR(50) NOT NULL,
        EntityID    INT NULL,
        Detail      NVARCHAR(MAX) NULL,
        IpAddress   VARCHAR(45) NULL,
        CreatedAt   DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_AuditLogs_Employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
    );
    CREATE INDEX IX_AuditLogs_Employee ON AuditLogs(EmployeeID);
    CREATE INDEX IX_AuditLogs_EntityType ON AuditLogs(EntityType, EntityID);
    CREATE INDEX IX_AuditLogs_CreatedAt ON AuditLogs(CreatedAt DESC);
END
GO

-- =====================================================
-- MIGRATION 002: InventoryLogs
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InventoryLogs')
BEGIN
    CREATE TABLE InventoryLogs (
        LogID          INT IDENTITY(1,1) PRIMARY KEY,
        ProductID      INT NOT NULL,
        StoreID        INT NOT NULL,
        ChangeQty      INT NOT NULL,
        QtyAfter       INT NOT NULL,
        Reason         NVARCHAR(200) NOT NULL,
        ReferenceType  VARCHAR(30) NULL,
        ReferenceID    INT NULL,
        EmployeeID     INT NOT NULL,
        CreatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_InvLogs_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
        CONSTRAINT FK_InvLogs_Store FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
        CONSTRAINT FK_InvLogs_Employee FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
    );
    CREATE INDEX IX_InvLogs_Product ON InventoryLogs(ProductID);
    CREATE INDEX IX_InvLogs_Store ON InventoryLogs(StoreID);
    CREATE INDEX IX_InvLogs_Employee ON InventoryLogs(EmployeeID);
    CREATE INDEX IX_InvLogs_CreatedAt ON InventoryLogs(CreatedAt DESC);
END
GO
