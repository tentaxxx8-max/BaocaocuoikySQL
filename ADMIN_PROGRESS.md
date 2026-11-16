# ADMIN UPGRADE PROGRESS - FARM OF PHAM

> Tài liệu theo dõi tiến độ nâng cấp hệ thống admin.  
> Cập nhật lần cuối: 2026-11-16 16:30 (UTC+7)

---

## BƯỚC 0: KIỂM KÊ HIỆN TRẠNG

### A. ADMIN HIỆN CÓ

#### Files:
- `public/admin/login.html` - Trang đăng nhập admin ✅ hoạt động
- `public/admin/index.html` - Trang admin chính (6 tab)
- `public/admin/admin.js` - JS controller (532 dòng)
- `public/admin/admin.css` - CSS riêng admin (278 dòng)
- `routes/admin.routes.js` - Backend routes (786 dòng)
- `middleware/auth.js` - JWT + RBAC + rate limit

#### 6 Tab hiện có:
| Tab | Tên | API Backend | Tính năng hiện tại | Trạng thái |
|-----|-----|------------|-------------------|-----------|
| Dashboard | Bảng điều khiển | `GET /dashboard` | 4 KPI (doanh thu, tổng đơn, đơn chờ, khách hoạt động), Top 5 bán chạy, cảnh báo tồn kho thấp | ⚠️ Cơ bản - thiếu biểu đồ, thiếu KPI chi tiết |
| Products | Kho sản phẩm | `GET/POST/PUT /products`, `PATCH toggle` | Danh sách (ID, ảnh, tên, SKU, hệ máy, giá, tồn kho, trạng thái), bật/tắt, nút thêm SP (chưa hoạt động - chỉ hiện toast) | ⚠️ Thiếu form thêm/sửa thực, lọc, phân trang, nhân bản, ảnh, CSV |
| Orders | Đơn hàng | `GET /orders`, `GET /orders/:id`, `PATCH status` | Danh sách, modal chi tiết, cập nhật trạng thái qua SP | ⚠️ Thiếu lọc nâng cao, xuất CSV, in hóa đơn |
| Inventory | Tồn kho | `GET/PUT /inventory` | Ma trận SP×cửa hàng, điều chỉnh số lượng trực tiếp | ⚠️ Thiếu nhập kho, chuyển kho, lý do, log, phân trang |
| Coupons | Mã giảm giá | `GET/POST/PUT/DELETE /coupons` | Danh sách, CRUD API có sẵn nhưng UI chỉ hiện danh sách, nút thêm chưa hoạt động | ⚠️ Thiếu form thêm/sửa UI, validate |
| Trade-ins | Thu cũ đổi mới | `GET /trade-ins`, `PATCH status` | Danh sách, nút duyệt/từ chối | ⚠️ Thiếu chi tiết, giá thẩm định, ghi chú, lọc |

### B. BẢNG ĐỐI CHIẾU: YÊU CẦU vs HIỆN TRẠNG

| # | Bảng DB | Màn hình yêu cầu | Đã có | Còn thiếu | Đang lỗi |
|---|---------|-------------------|-------|-----------|----------|
| 1 | Products, ProductImages | Sản phẩm CRUD + ảnh + nhân bản + CSV | Danh sách + toggle | Form thêm/sửa đầy đủ, upload ảnh, nhân bản, CSV import/export, lọc nâng cao, phân trang, xóa an toàn | Cột giá hiện `DiscountPrice`/`Price` (không khớp DB `ListPrice`/`SalePrice`) |
| 2 | Inventory + InventoryLogs (mới) | Tồn kho: ma trận, nhập kho, điều chỉnh, chuyển kho, lịch sử | Ma trận + điều chỉnh cơ bản | Bảng InventoryLogs (migration), nhập kho form, chuyển kho (transaction), lý do bắt buộc, lịch sử, phân trang | PUT inventory không ghi log, không yêu cầu lý do |
| 3 | Orders, OrderDetails, OrderStatusHistory | Đơn hàng + Bán tại quầy | Danh sách + chi tiết modal + cập nhật status | Lọc nâng cao (ngày, tiền, phương thức), xuất CSV, in hóa đơn A4/A5, timeline đầy đủ, POS (bán tại quầy) | Select status có 'Processing' nhưng SP không hỗ trợ (chỉ: Pending→Confirmed→Shipping→Completed) |
| 4 | Customers, CustomerAddresses | Khách hàng: danh sách, chi tiết, khóa/mở, reset mật khẩu | ❌ Chưa có | Toàn bộ | - |
| 5 | Carts, CartItems | Giỏ hàng khách (chỉ xem) | ❌ Chưa có | Toàn bộ | - |
| 6 | Coupons | Mã giảm giá CRUD + validate | API CRUD có, UI chỉ đọc | Form thêm/sửa UI, validate, thống kê lượt dùng, vô hiệu hóa thay vì xóa cứng | Cột CouponCode không tồn tại (DB dùng `Code`) |
| 7 | InstallmentPlans | Gói trả góp | ❌ Chưa có | Toàn bộ | - |
| 8 | Banners | Banner CRUD + upload + xem trước | API CRUD có | UI form thêm/sửa, upload ảnh, xem trước, lịch hiển thị | - |
| 9 | Reviews | Đánh giá: duyệt, ẩn, xóa, lọc | ❌ Chưa có trong sidebar (API có nhưng không có tab UI) | Tab UI, lọc theo SP/sao/trạng thái | - |
| 10 | TradeIns | Thu cũ đổi mới | Danh sách + duyệt/từ chối | Chi tiết, giá thẩm định, ghi chú, lọc theo trạng thái | Thiếu cột giá thẩm định trong DB |
| 11 | Categories | Danh mục dạng cây | ❌ Chưa có | Toàn bộ CRUD cây | - |
| 12 | Brands | Hãng | ❌ Chưa có | Toàn bộ CRUD | - |
| 13 | Platforms | Nền tảng | ❌ Chưa có | Toàn bộ CRUD | - |
| 14 | Genres | Thể loại | ❌ Chưa có | Toàn bộ CRUD | - |
| 15 | Suppliers | Nhà cung cấp | ❌ Chưa có | Toàn bộ CRUD | - |
| 16 | Stores | Cửa hàng | ❌ Chưa có | Toàn bộ CRUD + bảo vệ kho online | - |
| 17 | Employees | Nhân viên (chỉ Admin) | ❌ Chưa có | Toàn bộ CRUD + đổi Role + reset mật khẩu | - |
| 18 | AuditLogs (mới) | Nhật ký thao tác (chỉ Admin) | ❌ Bảng chưa tồn tại | Migration + API + UI | - |
| 19 | InventoryLogs (mới) | Lịch sử tồn kho | ❌ Bảng chưa tồn tại | Migration + API + UI | - |

### C. TÍNH NĂNG CHUNG CÒN THIẾU

| Tính năng | Trạng thái |
|-----------|-----------|
| Bảng dữ liệu dùng chung (phân trang server, sort, search debounce, lọc, chọn hàng loạt, CSV export) | ❌ Chưa có |
| Modal thêm/sửa dùng chung (validate client+server, chống bấm đúp, cảnh báo rời form) | ❌ Chưa có |
| Modal xác nhận xóa | ❌ Chưa có |
| Chống ghi đè đồng thời (UpdatedAt comparison) | ❌ Chưa có |
| Middleware ghi AuditLogs | ❌ Chưa có |
| Ô tìm nhanh toàn hệ thống (mã đơn, SĐT, email, SKU) | ❌ Chưa có |
| Upload ảnh (multer + kiểm tra nội dung file) | ❌ Chưa có |
| Dashboard biểu đồ (chart library cục bộ) | ❌ Chưa có |
| Báo cáo (doanh thu theo thời gian/SP/danh mục/khách/NV) | ❌ Chưa có |
| Kiểm tra dữ liệu (SP không ảnh, giá lỗi, đơn bất thường...) | ❌ Chưa có |
| POS - Bán tại quầy | ❌ Chưa có |
| In hóa đơn CSS (A4/A5) | ❌ Chưa có |
| Hồ sơ nhân viên (tự đổi mật khẩu) | ❌ Chưa có |
| Trung tâm dữ liệu (xem tất cả bảng, xuất ZIP) | ❌ Chưa có |
| Phân quyền server đầy đủ theo yêu cầu | ⚠️ Có cơ bản nhưng thiếu chi tiết |
| Validate server (express-validator/zod) | ❌ Chưa có |
| CSRF protection (Origin check / token) | ❌ Chưa có |
| Escape dữ liệu hiển thị (XSS) | ⚠️ Dùng `escapeHTML()` ở một số chỗ, nhưng vẫn dùng `innerHTML` chèn dữ liệu DB |

### D. LỖI PHÁT HIỆN TRONG CODE HIỆN TẠI

1. **admin.js dòng 197**: `p.DiscountPrice || p.Price` - DB không có cột này, phải là `p.SalePrice || p.ListPrice`
2. **admin.js dòng 440**: `c.DiscountType === 'Percentage'` - DB dùng `'Percent'`, không phải `'Percentage'`
3. **admin.js dòng 445**: `c.CouponCode` - DB cột tên là `Code`, không phải `CouponCode`
4. **admin.js dòng 249-268**: `o.OrderCode` sử dụng view `vw_OrderSummary` nhưng xây chuỗi `'DH' + padStart` fallback - cần kiểm tra view có cột OrderCode không
5. **admin.js dòng 253**: `o.RecipientName` - view có thể không có cột này, cần kiểm tra
6. **index.html dòng 291-296**: Select status có `Processing` nhưng SP sp_UpdateOrderStatus chỉ hỗ trợ: Pending→Confirmed, Confirmed→Shipping, Shipping→Completed
7. **admin.routes.js dòng 93**: LIKE search `%${keyword}%` - không escape `%`, `_`, `[` wildcard
8. **admin.routes.js**: Products POST/PUT dùng trùng tên input 'sku' (dòng 162 vs 172) → potential SQL param conflict
9. **admin.js**: Dùng innerHTML nhiều chỗ với dữ liệu từ DB (XSS risk), dù có escapeHTML ở một số nơi
10. **admin.routes.js dòng 695**: Banner DELETE xóa cứng không kiểm tra liên kết

### E. BẢNG MỚI CẦN TẠO (MIGRATION)

1. **AuditLogs**: LogID (IDENTITY), EmployeeID (FK), Action NVARCHAR(50), EntityType NVARCHAR(50), EntityID INT, Detail NVARCHAR(MAX), IpAddress VARCHAR(45), CreatedAt DATETIME DEFAULT GETDATE()
2. **InventoryLogs**: LogID (IDENTITY), ProductID (FK), StoreID (FK), ChangeQty INT, QtyAfter INT, Reason NVARCHAR(200), ReferenceType VARCHAR(30), ReferenceID INT, EmployeeID (FK), CreatedAt DATETIME DEFAULT GETDATE()

### F. PACKAGES CẦN CÀI THÊM

- `multer` - Upload file
- `express-validator` hoặc `zod` - Validate đầu vào
- `file-type` - Kiểm tra nội dung file thật (magic bytes)
- `archiver` - Tạo file ZIP (xuất dữ liệu)
- `chart.js` (hoặc vẽ SVG thuần) - Biểu đồ dashboard (cục bộ, không CDN)

---

## GIAI ĐOẠN 1: NỀN TẢNG DÙNG CHUNG

**Trạng thái:** ✅ ĐÃ HOÀN THÀNH (12/12 Test Đạt)

### Checklist:
- [x] Viết migration `001_audit_logs.sql` + `002_inventory_logs.sql`
- [x] Nối vào cuối `GameStoreDB.sql`
- [x] Tạo bảng `AuditLogs` và `InventoryLogs` trên SQL Server
- [x] Cài đặt `multer` và `express-validator`
- [x] Component JS dùng chung: `public/admin/components.js` (TacticalDataTable, ConfirmModal, AdminToast, CSVExporter với UTF-8 BOM tiếng Việt, FormGuard)
- [x] Middleware AuditLogs: `utils/audit.js` (ghi nhận thay đổi dữ liệu của nhân viên)
- [x] Middleware InventoryLogs: ghi nhận biến động tồn kho kèm lý do
- [x] API tìm nhanh toàn hệ thống: `GET /api/admin/quick-search` (tìm mã đơn, SĐT, email, SKU, tên SP)
- [x] Upload ảnh (multer): `POST /api/admin/upload` (kiểm tra magic bytes thật JPG/PNG/WEBP, giới hạn 3MB, lưu tên ngẫu nhiên)
- [x] Chống ghi đè đồng thời (Concurrency / Anti-overwrite): so sánh `UpdatedAt` và trả về HTTP 409 Conflict
- [x] Chống CSRF: middleware `middleware/csrf.js` kiểm tra Origin / Referer trên các phương thức POST, PUT, PATCH, DELETE
- [x] Sửa các lỗi phát hiện ở Bước 0 (sai tên trường giá, sai mã DiscountType, sai cột CouponCode)
- [x] Thanh tìm kiếm nhanh tích hợp trên thanh trên cùng của `public/admin/index.html`

### Bằng chứng Kiểm thử (Test Suite: `tests/test-phase1-admin.js`):
```text
====================================================
  KIỂM THỬ GIAI ĐOẠN 1: NỀN TẢNG DÙNG CHUNG ADMIN   
====================================================

[1/7] Xác thực tài khoản Quản trị viên (Admin)
  ✓ PASS: Admin Login (Đăng nhập thành công với vai trò: Admin)

[2/7] Kiểm tra các file tĩnh Admin & Components
  ✓ PASS: Component Library (components.js) (Tải thành công DataTable, Modal, Toast, CSVExporter)
  ✓ PASS: Admin Index HTML (Có thanh tìm kiếm nhanh toàn hệ thống và load components.js)

[3/7] Kiểm tra API Tìm kiếm nhanh toàn hệ thống
  ✓ PASS: Quick Search (Zelda) (Tìm thấy 1 sản phẩm)
  ✓ PASS: Quick Search (Số điện thoại) (Tìm thấy 4 đơn, 1 khách)

[4/7] Kiểm tra Cơ chế Chống CSRF
  ✓ PASS: CSRF Block Forged Origin (Từ chối request từ domain giả mạo (HTTP 403))

[5/7] Kiểm tra Chống Ghi Đè Đồng Thời (Concurrency)
  ✓ PASS: Concurrency Conflict (HTTP 409) (Bắt đúng xung đột khi dữ liệu bị sửa đồng thời bởi người khác)

[6/7] Kiểm tra Ghi và Truy Vấn AuditLogs & InventoryLogs
  ✓ PASS: Inventory Adjust with Reason (Điều chỉnh tồn kho có kèm lý do thành công)
  ✓ PASS: AuditLogs Query (Ghi nhận thành công log: [ADJUST_INVENTORY] bởi Võ Quốc Huy)
  ✓ PASS: InventoryLogs Query (Ghi nhận thành công: SP #34, Thay đổi: 13, Lý do: "TEST_PHASE1: Kiểm tra ghi nhật ký tồn kho")

[7/7] Kiểm tra Tải file ảnh & Xác thực Magic Bytes
  ✓ PASS: Upload Valid JPEG (Magic Bytes OK) (Đã lưu file an toàn)
  ✓ PASS: Reject Fake Image (Magic Bytes Block) (Phát hiện và chặn thành công file giả mạo đuôi .jpg)

====================================================
TỔNG KẾT: 12/12 TEST ĐẠT (100% PASS)
====================================================
```

---

## GIAI ĐOẠN 2: SẢN PHẨM + TỒN KHO
**Trạng thái:** ⏳ Đang chờ người dùng bấm "tiếp"

---

## GIAI ĐOẠN 3-6: Chưa bắt đầu
