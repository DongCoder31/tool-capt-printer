# Hướng dẫn dùng máy in Canon LBP2900

Máy in laser trắng đen, A4, kết nối **USB**. Mã trên tem đáy máy (`L11121E`) là mã quy chuẩn, tên máy thật là **Canon LBP2900**.
Laptop: Dell Vostro 3458 (i3-4005U, 8GB RAM, Windows 64-bit).

## 1. Cài đặt (làm 1 lần)

1. Copy cả thư mục này sang laptop.
2. Cắm dây nguồn và dây USB máy in, bật máy in.
3. **Double-click `Cai-May-In.bat`** → bấm **Yes** khi Windows hỏi quyền Administrator.
4. Đợi script chạy xong (cần mạng nếu chưa có file trong thư mục `driver\`, khoảng 11 MB).
5. Khi hỏi *In trang thu*, bấm Enter → máy in ra 1 trang thử là xong.

Script tự làm: tải driver Canon CAPT v3.30 → cài → dò máy in USB → đặt làm máy in mặc định, giấy A4 → thêm menu chuột phải **Print** cho file `.md`.

## 2. In tài liệu hằng ngày

| Loại file | Cách in |
|---|---|
| PDF | Mở bằng Edge/Chrome → `Ctrl+P` → **Print** |
| Word / Excel | Mở file → `Ctrl+P` → chọn *Canon LBP2900* → **Print** |
| Ảnh | Chuột phải → **Print** |
| Văn bản `.txt`, `.md` | Chuột phải → **Print** (in nguyên văn bản Markdown, chưa dựng định dạng) |
| Nhiều file một lúc | Chọn tất cả → chuột phải → **Print** |

### In Markdown đẹp (có định dạng)
Notepad chỉ in chữ thô (`# tiêu đề`, `**đậm**` hiện nguyên ký hiệu). Muốn in đẹp:

1. Mở file `.md` trong VS Code → `Ctrl+Shift+V` (xem trước) → chuột phải → mở bằng trình duyệt, hoặc dùng extension *Markdown PDF* để xuất PDF.
2. Mở PDF → `Ctrl+P` → in.

### Thiết lập khi in (hộp thoại Print)
- **Copies**: số bản.
- **Pages**: ví dụ `1-3` hoặc `2,5`.
- **Paper size**: A4. **Orientation**: dọc/ngang.
- In 2 mặt: máy không có duplex tự động → in trang lẻ, lật giấy bỏ lại khay, in trang chẵn (hoặc chọn *Print on both sides - manual* nếu có).
- Tiết kiệm mực: *Printer Properties → Finishing Details → Toner Saver*.

## 3. Sử dụng máy in

- Nạp giấy A4 vào khay phía trước (tối đa khoảng 150 tờ), chỉnh thanh dẫn sát mép giấy.
- Đèn trên máy: xanh ổn định = sẵn sàng; chớp = đang nhận/in; cam = lỗi (kẹt giấy, hết giấy, nắp mở).
- Máy nóng lên vài giây trước khi in trang đầu, bình thường.
- Mực dùng hộp **Canon 303 (CRG-303)**. Khi chữ mờ, lấy hộp mực ra lắc nhẹ ngang vài lần để dùng thêm.
- Kẹt giấy: tắt máy → mở nắp → kéo giấy theo chiều ra phía trước, kéo nhẹ không giật.

## 4. Xử lý sự cố

| Triệu chứng | Cách xử lý |
|---|---|
| Script báo "Chưa thấy máy in" | Kiểm tra USB, bật nguồn, thử cổng USB khác (cắm trực tiếp vào laptop, không qua hub) rồi chạy lại `Cai-May-In.bat`. |
| Lệnh in treo ở trạng thái *Printing* / *Error* | Mở *Settings → Printers & scanners → Canon LBP2900 → Open queue* → Printer → *Cancel All Documents*; tắt/bật máy in. |
| Không tải được driver | Tải tay từ [Canon Asia - LBP2900 CAPT Driver 64-bit](https://asia.canon/en/support/0100278201) và để file `.exe` vào thư mục `driver\` rồi chạy lại. |
| Script không tự giải nén được | Trình cài chính thức của Canon sẽ hiện ra: bấm Next/Yes, cắm USB khi được hỏi, rồi Enter ở cửa sổ script. |
| In ra trang trắng / chữ nhạt | Lắc hộp mực, hoặc thay hộp 303. |
| Máy in mặc định bị đổi | Script đã tắt chế độ Windows tự đổi máy in mặc định; cài lại nếu vẫn bị. |

## 5. Ghi chú kỹ thuật

- Driver: **LBP2900/2900B CAPT Printer Driver R1.50 Ver.3.30** (bản chính thức của Canon, hỗ trợ Windows 7/8/10 64-bit và 32-bit; script tự nhận hệ điều hành).
- Máy dùng giao thức CAPT: **chỉ in qua USB**, không in qua mạng/Wi-Fi nếu không chia sẻ từ một máy tính khác.
- Để chia sẻ cho máy khác trong mạng LAN: *Printer properties → Sharing → Share this printer*.
