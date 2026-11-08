# Cài bản Android staging (sideload)

Đây là APK debug-signed của kênh thử nghiệm `android-staging`; không phải bản Google Play.

1. Vào [trang itch.io](https://hieuphung1qaz.itch.io/25d-game), tải file Android ở kênh `android-staging`. Hoặc, khi đã cài `gh` và `adb`, nối điện thoại bật USB debugging rồi chạy `tools/run-staging.sh apk` tại root repo.
2. Mở file APK trên điện thoại. Android sẽ yêu cầu cho phép ứng dụng đang mở file (trình duyệt/trình quản lý tệp) **cài ứng dụng không rõ nguồn**; bật quyền này và xác nhận cài đặt.
3. Nếu Android báo chữ ký khác, gỡ bản Khế Ước staging cũ rồi cài lại. APK debug có thể đổi chữ ký khi môi trường build đổi.
4. Mở game và đọc badge môi trường trên màn hình: badge phải là `staging` và có version dạng `0.1.0-staging+<sha>`. Gửi lại version đó khi báo lỗi.

Không dùng APK này cho phát hành hay dữ liệu quan trọng; nó dùng namespace lưu riêng của staging.
