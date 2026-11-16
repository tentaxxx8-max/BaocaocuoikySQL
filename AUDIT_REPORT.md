# BÁO CÁO TOÀN DIỆN VỀ CHẤT LƯỢNG, BẢO MẬT & HIỆU NĂNG HỆ THỐNG
**Dự án:** FARM OF PHAM (Tactical Game Vault & Next-Gen Armory)  
**Công nghệ:** Node.js, Express 5, SQL Server Express (`GameStoreDB`), Vanilla JS/CSS  
**Thời gian bắt đầu audit:** 2026-11-16  
**Chuyên gia thực hiện:** Lead QA & Senior Security Fullstack Engineer  

---

## GIAI ĐOẠN 0: NẮM TOÀN CẢNH HỆ THỐNG

### 1. Danh sách các trang người dùng và quản trị
| STT | Tên file / URL | Loại trang | Chức năng chính | Trạng thái hiện tại |
|---|---|---|---|---|
| 1 | `public/index.html` | Client | Trang chủ, banner chính, danh mục hot, sản phẩm bán chạy, sản phẩm mới, khuyến mãi, cam kết | Đã có, hoạt động |
| 2 | `public/products.html` | Client | Danh mục kho vũ khí, lọc (hệ máy, danh mục, khoảng giá), sắp xếp, tìm kiếm, phân trang | Đã có, hoạt động |
| 3 | `public/product-detail.html` | Client | Chi tiết sản phẩm, gallery ảnh, thông số, tồn kho theo chi nhánh, gửi và xem đánh giá | Đã có, hoạt động |
| 4 | `public/login.html` | Client | Đăng nhập tài khoản khách hàng, gợi ý tài khoản mẫu | Đã có, hoạt động |
| 5 | `public/register.html` | Client | Đăng ký tài khoản khách hàng mới, tích hợp gộp giỏ hàng khách vãng lai | Đã có, hoạt động |
| 6 | `public/cart.html` | Client | Giỏ hàng tác chiến, tăng/giảm số lượng, xóa món, tính ship, chuyển sang checkout | Đã có, hoạt động |
| 7 | `public/checkout.html` | Client | Đặt hàng & thanh toán (COD, VietQR, MoMo, VNPay), áp coupon, tính tiền ship | Đã có, hoạt động |
| 8 | `public/order-success.html` | Client | Thông báo đặt hàng thành công, hiển thị mã đơn, QR VietQR cho thanh toán ngân hàng | Đã có, hoạt động |
| 9 | `public/account.html` | Client | Trung tâm chỉ huy cá nhân: hồ sơ, sổ địa chỉ, lịch sử đơn hàng + timeline, hủy đơn, yêu cầu thu cũ | Đã có, hoạt động |
| 10 | `public/stores.html` | Client | Mạng lưới căn cứ showroom & tổng kho tiếp vận, chỉ đường Google Maps | Đã có, hoạt động |
| 11 | `public/trade-in.html` | Client | Giới thiệu chương trình và form định giá thu cũ đổi mới vũ khí game | Đã có, hoạt động |
| 12 | `public/installment.html` | Client | Giới thiệu chính sách và bảng tính dự toán trả góp lãi suất 0% | Đã có, hoạt động |
| 13 | `public/admin/login.html` | Admin | Cổng xác thực nhân sự quản trị (RBAC: Admin, Manager, Sales, Warehouse) | Đã có, hoạt động |
| 14 | `public/admin/index.html` | Admin | Bảng điều khiển tác chiến: Dashboard doanh thu, Quản lý sản phẩm, Đơn hàng, Tồn kho, Coupon, Thu cũ | Đã có, hoạt động |

---

### 2. Danh sách các bảng, view, Stored Procedure và Type trong GameStoreDB
| Tên đối tượng | Loại | Mục đích sử dụng | Khớp trong Code? |
|---|---|---|---|
| `Categories` | Table | Lưu phân loại sản phẩm (Đĩa game, Máy chơi game, Phụ kiện, Thẻ quà tặng) | Có |
| `Platforms` | Table | Lưu hệ máy (PS5, PS4, Nintendo Switch, Phụ kiện chung) | Có |
| `Brands` | Table | Lưu nhà sản xuất/hãng phát hành (Sony, Nintendo, Bandai, EA...) | Có |
| `Products` | Table | Lưu thông tin sản phẩm, SKU, giá niêm yết, giá giảm, mô tả, IsActive | Có |
| `ProductImages` | Table | Lưu danh sách ảnh sản phẩm (IsPrimary) | Có |
| `Stores` | Table | Lưu showroom và kho tổng | Có |
| `Inventory` | Table | Lưu số lượng tồn kho theo cặp (ProductID, StoreID) | Có |
| `Customers` | Table | Lưu khách hàng, Email, PasswordHash, LoyaltyPoints, IsActive | Có |
| `CustomerAddresses`| Table | Sổ địa chỉ giao hàng của khách (IsDefault) | Có |
| `Employees` | Table | Lưu nhân viên, Role (Admin, Manager, Sales, Warehouse), PasswordHash | Có |
| `Orders` | Table | Lưu đơn hàng, OrderCode, CustomerID, TotalAmount, Status, PaymentMethod | Có |
| `OrderDetails` | Table | Chi tiết từng món trong đơn (ProductID, Quantity, UnitPrice, LineTotal) | Có |
| `OrderStatusHistory`| Table | Lịch sử thay đổi trạng thái đơn hàng (Timeline) | Có |
| `Reviews` | Table | Đánh giá & bình luận sản phẩm của khách đã mua (Rating 1-5, IsApproved) | Có |
| `Coupons` | Table | Mã giảm giá (Percentage / FixedAmount, MaxDiscountAmount, MinOrderAmount) | Có |
| `Banners` | Table | Banner quảng cáo trang chủ | Có |
| `TradeIns` | Table | Yêu cầu thu cũ đổi mới của khách | Có |
| `InstallmentPlans`| Table | Gói trả góp lãi suất 0% và có lãi | Có |
| `Carts`, `CartItems`| Table | Giỏ hàng lưu database cho khách đã đăng nhập | Có |
| `vw_ProductCatalog`| View | View tổng hợp sản phẩm, hệ máy, danh mục, tồn kho online | Có |
| `vw_OrderSummary` | View | View tổng hợp danh sách đơn hàng cho admin và khách | Có |
| `dbo.OrderItemType`| Type | User-Defined Table Type truyền danh sách món vào `sp_PlaceOrder` | Có |
| `sp_GetProducts` | Procedure| Tìm kiếm, lọc đa tiêu chí, sắp xếp, phân trang sản phẩm | Có |
| `sp_PlaceOrder` | Procedure| Đặt hàng an toàn bằng TVP, kiểm tra tồn kho, trừ kho, tạo đơn | Có |
| `sp_UpdateOrderStatus` | Procedure| Cập nhật trạng thái đơn hàng, hoàn trả tồn kho nếu hủy đơn | Có |

---

### 3. Bảng đối chiếu Yêu Cầu Ban Đầu và Hiện Trạng
| Yêu cầu ban đầu | Trạng thái | Đánh giá sơ bộ & Ghi chú |
|---|---|---|
| Trang chủ | Đầy đủ | Lấy dữ liệu từ API banners, featured, new, on-sale |
| Danh mục, lọc, sắp xếp, phân trang | Đầy đủ | Gọi `sp_GetProducts` qua `/api/products` |
| Tìm kiếm + gợi ý trực tiếp | Đầy đủ | Gợi ý 5-8 kết quả qua `/api/products/search-suggestions` |
| Chi tiết sản phẩm (gallery, tồn kho, review) | Đầy đủ | Xem kho theo chi nhánh, xem đánh giá duyệt |
| Đăng ký / Đăng nhập | Đầy đủ | Hashing bcrypt, JWT cookie, rate limiter chống dò pass |
| Giỏ hàng (DB + localStorage gộp) | Đầy đủ | Xử lý cả khách vãng lai và gộp khi đăng nhập |
| Thanh toán 5 phương thức, coupon, ship | Đầy đủ | COD, VietQR, MoMo, VNPay, Credit Card |
| Trang cảm ơn / Xác nhận đơn | Đầy đủ | Mã đơn hàng `DHxxxxxxx`, hướng dẫn chuyển khoản |
| Tài khoản cá nhân | Đầy đủ | Hồ sơ, sổ địa chỉ, lịch sử đơn, timeline, hủy đơn |
| Cửa hàng & Showroom | Đầy đủ | Tải danh sách cửa hàng từ DB |
| Thu cũ đổi mới | Đầy đủ | Form gửi định giá thu cũ, lưu vào `TradeIns` |
| Trả góp | Đầy đủ | Bảng tính góp và gói từ `InstallmentPlans` |
| Trang Admin đầy đủ + RBAC theo Role | Đầy đủ | Dashboard, Sản phẩm, Đơn hàng, Tồn kho, Coupon, Thu cũ |

---

---

## GIAI ĐOẠN 1: KIỂM TRA LIÊN KẾT VỚI SQL SERVER

### 1. Kết quả kiểm tra đối chiếu Schema & Kết nối
* **Tài khoản kết nối**: Xác thực SQL Server Authentication với tài khoản `gamestore_app` (Database User: `gamestore_app`, Role: `db_owner` trong `GameStoreDB`, không dùng tài khoản hệ thống `sa`).
* **Đối chiếu Schema**:
  * Đầy đủ 17 bảng cơ sở theo đúng `GameStoreDB.sql`.
  * Đầy đủ 2 Views: `vw_ProductCatalog`, `vw_OrderSummary`.
  * Đầy đủ 3 Stored Procedures: `sp_GetProducts`, `sp_PlaceOrder`, `sp_UpdateOrderStatus`.
  * Đầy đủ User-Defined Table Type: `dbo.OrderItemType`.
* **An toàn Parameterized Queries**:
  * Kiểm tra 100% các câu truy vấn qua scanner tự động: Không có bất kỳ câu lệnh nào nối chuỗi trực tiếp (`+`) hay chèn template string. 100% sử dụng `.input()`.
* **Tiếng Việt & Unicode (NVarChar)**:
  * Tất cả các trường văn bản người dùng (Họ tên, Địa chỉ, Ghi chú đơn, Đánh giá, Mô tả) đều dùng `sql.NVarChar`.
  * Đã test chuỗi tiếng Việt phức tạp có dấu: `'Đặc nhiệm Chiến trường: Căn cứ Hỏa lực & Đột kích Tối thượng - 100% Tiếng Việt'` lưu trữ và đọc ra chính xác 100%.
* **Độ chính xác số thập phân (DECIMAL)**:
  * Các trường giá tiền như `13.990.000đ` được tính toán chuẩn xác, không bị lệch làm tròn.
* **Xử lý mã lỗi Stored Procedure & Transaction Rollback**:
  * `50001` (Giỏ hàng trống) -> Bắt lỗi và thông báo tiếng Việt thân thiện.
  * `50002` (Sản phẩm không tồn tại / ngừng bán) -> Bắt lỗi và từ chối tạo đơn.
  * `50003` (Vượt quá tồn kho khả dụng) -> Bắt lỗi và từ chối tạo đơn.
  * `50004` (Mã giảm giá không hợp lệ/hết hạn) -> Bắt lỗi và từ chối tạo đơn.
  * `50010` (Không tìm thấy đơn hàng) -> Bắt lỗi chính xác.
  * `50012` (Chỉ hủy được đơn chưa giao hàng) -> Bắt lỗi chính xác khi cố hủy đơn đã hoàn tất.
  * **Đảm bảo Rollback giao dịch**: Khi đơn hàng bị lỗi (ví dụ mã giảm giá sai), giao dịch tự động `ROLLBACK TRANSACTION`, số lượng tồn kho được giữ nguyên tuyệt đối (`Stock before: 15, Stock after: 15`).

### 2. Sự cố phát hiện và đã khắc phục trong Giai đoạn 1:
| Sự cố | Mức độ | Nguyên nhân | Biện pháp khắc phục | Bằng chứng |
|---|---|---|---|---|
| Lệch tên biến `deliveryAddress` vs `shippingAddress` tại `POST /api/orders` | **HIGH** | Frontend `checkout.js` gửi `deliveryAddress` còn backend chỉ đọc `shippingAddress` | Sửa backend `const shippingAddress = req.body.shippingAddress \|\| req.body.deliveryAddress` | Checkout API tiếp nhận mượt mà |
| Lệch tên biến `newStatus` vs `status` tại `PATCH /api/admin/orders/:id/status` | **HIGH** | Frontend `admin.js` gửi `newStatus` còn backend chỉ đọc `status` | Sửa backend `const status = req.body.status \|\| req.body.newStatus` | Admin đổi trạng thái đơn hàng thành công |
| Database bị kẹt `SINGLE_USER` do SSMS | **CRITICAL** | Tiến trình SSMS đặt DB ở chế độ Single User | Chạy lệnh ngắt session treo và chuyển về `MULTI_USER` | `GameStoreDB` ONLINE & MULTI_USER, test 14/14 PASS |

```
=============================================================
   PHASE 1 SUMMARY: 14 PASSED | 0 FAILED
=============================================================
```

