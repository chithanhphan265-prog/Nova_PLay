CREATE DATABASE IF NOT EXISTS java_play
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE java_play;
SET NAMES utf8mb4;

-- 1. NGƯỜI DÙNG: mã tự tăng; tài khoản khách và admin dùng chung bảng.
CREATE TABLE IF NOT EXISTS NGUOIDUNG (
    ma_nguoi_dung INT AUTO_INCREMENT PRIMARY KEY,
    ten_dang_nhap VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    mat_khau_hash VARCHAR(255) NOT NULL,
    ten_hien_thi VARCHAR(100) NOT NULL,
    vai_tro VARCHAR(20) NOT NULL DEFAULT 'ROLE_USER',
    trang_thai VARCHAR(20) NOT NULL DEFAULT 'HOAT_DONG',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT ck_nd_ten CHECK (CHAR_LENGTH(TRIM(ten_dang_nhap)) >= 3),
    CONSTRAINT ck_nd_email CHECK (CHAR_LENGTH(TRIM(email)) > 0),
    CONSTRAINT ck_nd_matkhau CHECK (CHAR_LENGTH(TRIM(mat_khau_hash)) > 0),
    CONSTRAINT ck_nd_hienthi CHECK (CHAR_LENGTH(TRIM(ten_hien_thi)) > 0),
    CONSTRAINT ck_nd_vaitro CHECK (vai_tro IN ('ROLE_USER', 'ROLE_ADMIN')),
    CONSTRAINT ck_nd_trangthai CHECK (trang_thai IN ('HOAT_DONG', 'BI_KHOA'))
) ENGINE=InnoDB;

-- 2. NHÀ PHÁT HÀNH: không xóa nếu còn game sử dụng.
CREATE TABLE IF NOT EXISTS NHAPHATHANH (
    ma_nha_phat_hanh INT AUTO_INCREMENT PRIMARY KEY,
    ten_nha_phat_hanh VARCHAR(150) NOT NULL UNIQUE,
    CONSTRAINT ck_nph_ten CHECK (CHAR_LENGTH(TRIM(ten_nha_phat_hanh)) > 0)
) ENGINE=InnoDB;

-- 3. THỂ LOẠI: không xóa nếu còn liên kết với game.
CREATE TABLE IF NOT EXISTS THELOAI (
    ma_the_loai INT AUTO_INCREMENT PRIMARY KEY,
    ten_the_loai VARCHAR(80) NOT NULL UNIQUE,
    mo_ta VARCHAR(255) NULL,
    CONSTRAINT ck_tl_ten CHECK (CHAR_LENGTH(TRIM(ten_the_loai)) > 0)
) ENGINE=InnoDB;

-- 4. TRÒ CHƠI: nhà phát triển lưu tên, không tạo thêm bảng.
CREATE TABLE IF NOT EXISTS TROCHOI (
    ma_tro_choi INT AUTO_INCREMENT PRIMARY KEY,
    tieu_de VARCHAR(200) NOT NULL UNIQUE,
    ma_nha_phat_hanh INT NOT NULL,
    ten_nha_phat_trien VARCHAR(150) NOT NULL,
    mo_ta TEXT NOT NULL,
    hinh_anh VARCHAR(255) NULL,
    ngay_phat_hanh DATE NOT NULL,
    gia_ban DECIMAL(12,0) NOT NULL,
    do_tuoi_khuyen_nghi INT NOT NULL DEFAULT 0,
    dung_luong_gb DECIMAL(8,2) NOT NULL,
    cau_hinh_yeu_cau TEXT NOT NULL,
    trang_thai VARCHAR(20) NOT NULL DEFAULT 'DANG_BAN',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tc_nph FOREIGN KEY (ma_nha_phat_hanh)
        REFERENCES NHAPHATHANH(ma_nha_phat_hanh) ON DELETE RESTRICT,
    CONSTRAINT ck_tc_ten CHECK (CHAR_LENGTH(TRIM(tieu_de)) > 0),
    CONSTRAINT ck_tc_npt CHECK (CHAR_LENGTH(TRIM(ten_nha_phat_trien)) > 0),
    CONSTRAINT ck_tc_mota CHECK (CHAR_LENGTH(TRIM(mo_ta)) > 0),
    CONSTRAINT ck_tc_cauhinh CHECK (CHAR_LENGTH(TRIM(cau_hinh_yeu_cau)) > 0),
    CONSTRAINT ck_tc_gia CHECK (gia_ban >= 0),
    CONSTRAINT ck_tc_tuoi CHECK (do_tuoi_khuyen_nghi BETWEEN 0 AND 18),
    CONSTRAINT ck_tc_dungluong CHECK (dung_luong_gb > 0),
    CONSTRAINT ck_tc_trangthai CHECK (trang_thai IN ('DANG_BAN', 'NGUNG_BAN'))
) ENGINE=InnoDB;

-- 5. GAME - THỂ LOẠI: khóa chính ghép; hai mã đều KHÔNG tự tăng.
CREATE TABLE IF NOT EXISTS TROCHOI_THELOAI (
    ma_tro_choi INT NOT NULL,
    ma_the_loai INT NOT NULL,
    PRIMARY KEY (ma_tro_choi, ma_the_loai),
    CONSTRAINT fk_tctl_tc FOREIGN KEY (ma_tro_choi)
        REFERENCES TROCHOI(ma_tro_choi) ON DELETE CASCADE,
    CONSTRAINT fk_tctl_tl FOREIGN KEY (ma_the_loai)
        REFERENCES THELOAI(ma_the_loai) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. GIỎ HÀNG: một dòng = một game trong giỏ của một người.
-- Không lưu ô tích chọn; danh sách game được chọn gửi từ giao diện sang Java.
CREATE TABLE IF NOT EXISTS GIOHANG (
    ma_gio_hang INT AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung INT NOT NULL,
    ma_tro_choi INT NOT NULL,
    ngay_them DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_gh_nguoi_game UNIQUE (ma_nguoi_dung, ma_tro_choi),
    CONSTRAINT fk_gh_nd FOREIGN KEY (ma_nguoi_dung)
        REFERENCES NGUOIDUNG(ma_nguoi_dung) ON DELETE CASCADE,
    CONSTRAINT fk_gh_tc FOREIGN KEY (ma_tro_choi)
        REFERENCES TROCHOI(ma_tro_choi) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. ĐƠN HÀNG: phương thức nằm ở từng lần thanh toán, không nằm ở đây.
-- Tổng tiền do Java tính từ chi tiết đơn, không lấy trực tiếp từ trình duyệt.
CREATE TABLE IF NOT EXISTS DONHANG (
    ma_don_hang INT AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung INT NOT NULL,
    tong_tien DECIMAL(12,0) NOT NULL,
    trang_thai VARCHAR(20) NOT NULL DEFAULT 'CHO_THANH_TOAN',
    ngay_dat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_thanh_toan DATETIME NULL,
    CONSTRAINT fk_dh_nd FOREIGN KEY (ma_nguoi_dung)
        REFERENCES NGUOIDUNG(ma_nguoi_dung) ON DELETE RESTRICT,
    CONSTRAINT ck_dh_tien CHECK (tong_tien >= 0),
    CONSTRAINT ck_dh_trangthai CHECK (trang_thai IN ('CHO_THANH_TOAN', 'DA_THANH_TOAN', 'DA_HUY')),
    -- Đơn đã thanh toán phải có ngày thanh toán; đơn khác chưa có ngày này.
    CONSTRAINT ck_dh_ngay CHECK (
        (trang_thai = 'DA_THANH_TOAN' AND ngay_thanh_toan IS NOT NULL AND ngay_thanh_toan >= ngay_dat)
        OR (trang_thai <> 'DA_THANH_TOAN' AND ngay_thanh_toan IS NULL)
    )
) ENGINE=InnoDB;

-- 8. CHI TIẾT ĐƠN: giữ nguyên tên, giá tại lúc đặt; số lượng luôn là 1.
CREATE TABLE IF NOT EXISTS CHITIETDONHANG (
    ma_chi_tiet INT AUTO_INCREMENT PRIMARY KEY,
    ma_don_hang INT NOT NULL,
    ma_tro_choi INT NOT NULL,
    ten_game_luc_mua VARCHAR(200) NOT NULL,
    don_gia DECIMAL(12,0) NOT NULL,
    so_luong INT NOT NULL DEFAULT 1,
    CONSTRAINT uq_ctdh_don_game UNIQUE (ma_don_hang, ma_tro_choi),
    CONSTRAINT fk_ctdh_dh FOREIGN KEY (ma_don_hang)
        REFERENCES DONHANG(ma_don_hang) ON DELETE RESTRICT,
    CONSTRAINT fk_ctdh_tc FOREIGN KEY (ma_tro_choi)
        REFERENCES TROCHOI(ma_tro_choi) ON DELETE RESTRICT,
    CONSTRAINT ck_ctdh_ten CHECK (CHAR_LENGTH(TRIM(ten_game_luc_mua)) > 0),
    CONSTRAINT ck_ctdh_gia CHECK (don_gia >= 0),
    CONSTRAINT ck_ctdh_soluong CHECK (so_luong = 1)
) ENGINE=InnoDB;

-- 9. LỊCH SỬ THANH TOÁN: một dòng = một lần xác nhận bắt đầu thanh toán.
-- Chỉ tạo dòng sau bước khách kiểm tra đơn và bấm Xác nhận thanh toán.
-- OTP mô phỏng 123456 do Java kiểm tra, KHÔNG phải xác thực tiền thật.
CREATE TABLE IF NOT EXISTS LICHSUTHANHTOAN (
    ma_giao_dich INT AUTO_INCREMENT PRIMARY KEY,
    ma_don_hang INT NOT NULL,
    phuong_thuc VARCHAR(20) NOT NULL,
    so_tien DECIMAL(12,0) NOT NULL,
    trang_thai VARCHAR(20) NOT NULL DEFAULT 'CHO_XU_LY',
    thoi_gian_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    thoi_gian_het_han DATETIME NOT NULL,
    so_lan_nhap_sai INT NOT NULL DEFAULT 0,
    thoi_gian_ket_thuc DATETIME NULL,
    ghi_chu VARCHAR(255) NULL,
    CONSTRAINT fk_lstt_dh FOREIGN KEY (ma_don_hang)
        REFERENCES DONHANG(ma_don_hang) ON DELETE RESTRICT,
    CONSTRAINT ck_lstt_phuongthuc CHECK (phuong_thuc IN ('MOMO', 'NGAN_HANG')),
    CONSTRAINT ck_lstt_tien CHECK (so_tien >= 0),
    CONSTRAINT ck_lstt_trangthai CHECK (trang_thai IN ('CHO_XU_LY', 'THANH_CONG', 'THAT_BAI', 'HET_HAN', 'DA_HUY')),
    CONSTRAINT ck_lstt_hethan CHECK (thoi_gian_het_han > thoi_gian_tao),
    CONSTRAINT ck_lstt_solan CHECK (so_lan_nhap_sai BETWEEN 0 AND 3),
    CONSTRAINT ck_lstt_ketthuc CHECK (
        (trang_thai = 'CHO_XU_LY' AND thoi_gian_ket_thuc IS NULL)
        OR (trang_thai <> 'CHO_XU_LY' AND thoi_gian_ket_thuc IS NOT NULL AND thoi_gian_ket_thuc >= thoi_gian_tao)
    )
) ENGINE=InnoDB;

-- 10. THƯ VIỆN: mỗi người chỉ có một dòng cho mỗi game; không có hạn dùng.
CREATE TABLE IF NOT EXISTS THUVIEN (
    ma_thu_vien INT AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung INT NOT NULL,
    ma_tro_choi INT NOT NULL,
    ma_chi_tiet INT NOT NULL UNIQUE,
    ngay_so_huu DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tv_nguoi_game UNIQUE (ma_nguoi_dung, ma_tro_choi),
    CONSTRAINT fk_tv_nd FOREIGN KEY (ma_nguoi_dung)
        REFERENCES NGUOIDUNG(ma_nguoi_dung) ON DELETE RESTRICT,
    CONSTRAINT fk_tv_tc FOREIGN KEY (ma_tro_choi)
        REFERENCES TROCHOI(ma_tro_choi) ON DELETE RESTRICT,
    CONSTRAINT fk_tv_ctdh FOREIGN KEY (ma_chi_tiet)
        REFERENCES CHITIETDONHANG(ma_chi_tiet) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. ĐÁNH GIÁ: FK ghép yêu cầu người đó đã có game đó trong thư viện.
CREATE TABLE IF NOT EXISTS DANHGIA (
    ma_danh_gia INT AUTO_INCREMENT PRIMARY KEY,
    ma_nguoi_dung INT NOT NULL,
    ma_tro_choi INT NOT NULL,
    so_sao INT NOT NULL,
    noi_dung VARCHAR(1000) NOT NULL,
    ngay_danh_gia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_dg_nguoi_game UNIQUE (ma_nguoi_dung, ma_tro_choi),
    CONSTRAINT fk_dg_thuvien FOREIGN KEY (ma_nguoi_dung, ma_tro_choi)
        REFERENCES THUVIEN(ma_nguoi_dung, ma_tro_choi) ON DELETE RESTRICT,
    CONSTRAINT ck_dg_sao CHECK (so_sao BETWEEN 1 AND 5),
    CONSTRAINT ck_dg_noidung CHECK (CHAR_LENGTH(TRIM(noi_dung)) > 0)
) ENGINE=InnoDB;

-- PHẦN B. DỮ LIỆU MẪU
-- @nap_du_lieu_mau là biến dùng trong lần chạy file, không phải bảng/cột mới.
-- Chỉ nạp mẫu nếu CẢ 11 bảng đều trống. Nếu đã có dữ liệu thì bỏ qua toàn bộ.
-- Nhờ vậy chạy lại không làm game đã xóa xuất hiện lại hoặc giỏ đã mua đầy lại.
-- Mỗi lệnh INSERT ... SELECT ... WHERE @nap_du_lieu_mau = 1 có nghĩa:
-- "thêm dòng mẫu này CHỈ KHI được phép nạp mẫu".
-- Nạp mẫu trên một kết nối, không chạy đồng thời file này ở nhiều cửa sổ.
-- Nếu lần nạp mẫu báo lỗi: dừng và ROLLBACK; không tự bấm COMMIT sau lỗi.
START TRANSACTION;
SET @nap_du_lieu_mau = (
    (SELECT COUNT(*) FROM NGUOIDUNG) = 0
    AND (SELECT COUNT(*) FROM NHAPHATHANH) = 0
    AND (SELECT COUNT(*) FROM THELOAI) = 0
    AND (SELECT COUNT(*) FROM TROCHOI) = 0
    AND (SELECT COUNT(*) FROM TROCHOI_THELOAI) = 0
    AND (SELECT COUNT(*) FROM GIOHANG) = 0
    AND (SELECT COUNT(*) FROM DONHANG) = 0
    AND (SELECT COUNT(*) FROM CHITIETDONHANG) = 0
    AND (SELECT COUNT(*) FROM LICHSUTHANHTOAN) = 0
    AND (SELECT COUNT(*) FROM THUVIEN) = 0
    AND (SELECT COUNT(*) FROM DANHGIA) = 0
);

-- 21 tài khoản giả. Đăng nhập admin hoặc khach; mật khẩu 123456, lưu BCrypt. Java dùng BCryptPasswordEncoder.matches để kiểm tra, không so chuỗi trực tiếp.
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 1, 'admin', 'admin@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Quản trị viên', 'ROLE_ADMIN', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 2, 'khach', 'khach01@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách trải nghiệm', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 3, 'khach02', 'khach02@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 02', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 4, 'khach03', 'khach03@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 03', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 5, 'khach04', 'khach04@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 04', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 6, 'khach05', 'khach05@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 05', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 7, 'khach06', 'khach06@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 06', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 8, 'khach07', 'khach07@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 07', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 9, 'khach08', 'khach08@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 08', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 10, 'khach09', 'khach09@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 09', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 11, 'khach10', 'khach10@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 10', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 12, 'khach11', 'khach11@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 11', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 13, 'khach12', 'khach12@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 12', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 14, 'khach13', 'khach13@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 13', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 15, 'khach14', 'khach14@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 14', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 16, 'khach15', 'khach15@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 15', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 17, 'khach16', 'khach16@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 16', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 18, 'khach17', 'khach17@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 17', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 19, 'khach18', 'khach18@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 18', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 20, 'khach19', 'khach19@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 19', 'ROLE_USER', 'HOAT_DONG' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
SELECT 21, 'khach20', 'khach20@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Khách mẫu 20', 'ROLE_USER', 'BI_KHOA' WHERE @nap_du_lieu_mau = 1;

-- 20 nhà phát hành minh họa, không phải thông tin thương mại thật.
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 1, 'Nova Publishing' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 2, 'Blue Horizon' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 3, 'Orbit Interactive' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 4, 'Nhà phát hành mẫu 04' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 5, 'Nhà phát hành mẫu 05' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 6, 'Nhà phát hành mẫu 06' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 7, 'Nhà phát hành mẫu 07' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 8, 'Nhà phát hành mẫu 08' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 9, 'Nhà phát hành mẫu 09' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 10, 'Nhà phát hành mẫu 10' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 11, 'Nhà phát hành mẫu 11' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 12, 'Nhà phát hành mẫu 12' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 13, 'Nhà phát hành mẫu 13' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 14, 'Nhà phát hành mẫu 14' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 15, 'Nhà phát hành mẫu 15' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 16, 'Nhà phát hành mẫu 16' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 17, 'Nhà phát hành mẫu 17' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 18, 'Nhà phát hành mẫu 18' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 19, 'Nhà phát hành mẫu 19' WHERE @nap_du_lieu_mau = 1;
INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh)
SELECT 20, 'Nhà phát hành mẫu 20' WHERE @nap_du_lieu_mau = 1;

-- 20 thể loại để thử tìm kiếm và phân trang.
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 1, 'Hành động', 'Nhóm game hành động.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 2, 'Phiêu lưu', 'Nhóm game phiêu lưu.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 3, 'Nhập vai', 'Nhóm game nhập vai.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 4, 'Đua xe', 'Nhóm game đua xe.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 5, 'Chiến thuật', 'Nhóm game chiến thuật.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 6, 'Giải đố', 'Nhóm game giải đố.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 7, 'Mô phỏng', 'Nhóm game mô phỏng.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 8, 'Sinh tồn', 'Nhóm game sinh tồn.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 9, 'Thể thao', 'Nhóm game thể thao.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 10, 'Đối kháng', 'Nhóm game đối kháng.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 11, 'Kinh dị', 'Nhóm game kinh dị.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 12, 'Thế giới mở', 'Nhóm game thế giới mở.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 13, 'Đi cảnh', 'Nhóm game đi cảnh.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 14, 'Âm nhạc', 'Nhóm game âm nhạc.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 15, 'Thẻ bài', 'Nhóm game thẻ bài.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 16, 'Chiến thuật theo lượt', 'Nhóm game chiến thuật theo lượt.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 17, 'Khám phá', 'Nhóm game khám phá.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 18, 'Quản lý', 'Nhóm game quản lý.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 19, 'Bắn súng', 'Nhóm game bắn súng.' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
SELECT 20, 'Tiểu thuyết tương tác', 'Nhóm game tiểu thuyết tương tác.' WHERE @nap_du_lieu_mau = 1;

-- 24 game giả lập, giá/tuổi/cấu hình chỉ minh họa. Ảnh NULL: giao diện dùng ảnh mặc định. Game 1 ngừng bán nhưng khách đã mua vẫn sở hữu.
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 1, 'Astral Odyssey', 1, 'Nova Studio', 'Khám phá thế giới của Astral Odyssey. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 299000, 0, 12.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'NGUNG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 2, 'Neon District', 2, 'Nova Studio', 'Khám phá thế giới của Neon District. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 349000, 6, 14.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 3, 'Lost Kingdom', 3, 'Nova Studio', 'Khám phá thế giới của Lost Kingdom. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 199000, 12, 16.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 4, 'Ocean Echoes', 4, 'Nova Studio', 'Khám phá thế giới của Ocean Echoes. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 129000, 16, 18.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 5, 'Shadow Ronin', 5, 'Nova Studio', 'Khám phá thế giới của Shadow Ronin. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 459000, 18, 20.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 6, 'Velocity X', 6, 'Nova Studio', 'Khám phá thế giới của Velocity X. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 249000, 0, 22.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 7, 'Moonlight Valley', 7, 'Nova Studio', 'Khám phá thế giới của Moonlight Valley. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 159000, 6, 24.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 8, 'Iron Frontier', 8, 'Nova Studio', 'Khám phá thế giới của Iron Frontier. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 399000, 12, 26.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 9, 'Ember Quest', 9, 'Nova Studio', 'Khám phá thế giới của Ember Quest. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 179000, 16, 28.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 10, 'Celestial Drift', 10, 'Nova Studio', 'Khám phá thế giới của Celestial Drift. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 229000, 18, 30.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 11, 'Forest Spirits', 11, 'Nova Studio', 'Khám phá thế giới của Forest Spirits. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 99000, 0, 32.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 12, 'Beyond the Rift', 12, 'Nova Studio', 'Khám phá thế giới của Beyond the Rift. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 329000, 6, 34.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 13, 'Crystal Harbor', 13, 'Nova Studio', 'Khám phá thế giới của Crystal Harbor. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 149000, 12, 36.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 14, 'Solar Rally', 14, 'Nova Studio', 'Khám phá thế giới của Solar Rally. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 159000, 16, 38.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 15, 'Winter Haven', 15, 'Nova Studio', 'Khám phá thế giới của Winter Haven. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 169000, 18, 40.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 16, 'Pixel Voyage', 16, 'Nova Studio', 'Khám phá thế giới của Pixel Voyage. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 179000, 0, 42.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 17, 'Midnight Signal', 17, 'Nova Studio', 'Khám phá thế giới của Midnight Signal. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 189000, 6, 44.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 18, 'Skybound Tales', 18, 'Nova Studio', 'Khám phá thế giới của Skybound Tales. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 199000, 12, 46.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 19, 'Desert Legends', 19, 'Nova Studio', 'Khám phá thế giới của Desert Legends. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 209000, 16, 48.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 20, 'Echoes of Time', 20, 'Nova Studio', 'Khám phá thế giới của Echoes of Time. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 219000, 18, 50.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 21, 'Coral Garden', 1, 'Nova Studio', 'Khám phá thế giới của Coral Garden. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 229000, 0, 52.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 22, 'Starlight Arena', 2, 'Nova Studio', 'Khám phá thế giới của Starlight Arena. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 239000, 6, 54.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 23, 'Silent Meadow', 3, 'Nova Studio', 'Khám phá thế giới của Silent Meadow. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 249000, 12, 56.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
SELECT 24, 'Lunar Express', 4, 'Nova Studio', 'Khám phá thế giới của Lunar Express. Dữ liệu game giả lập phục vụ đồ án.', NULL, '2026-09-15', 259000, 16, 58.0, 'Windows 10/11; RAM 8 GB; CPU 4 nhân.', 'DANG_BAN' WHERE @nap_du_lieu_mau = 1;

-- 32 liên kết, mỗi game có ít nhất một thể loại.
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 1, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 2, 2 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 3, 3 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 4, 4 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 5, 5 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 6, 6 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 7, 7 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 8, 8 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 9, 9 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 10, 10 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 11, 11 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 12, 12 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 13, 13 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 14, 14 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 15, 15 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 16, 16 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 17, 17 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 18, 18 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 19, 19 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 20, 20 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 21, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 22, 2 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 23, 3 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 24, 4 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 1, 5 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 2, 6 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 3, 7 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 4, 8 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 5, 9 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 6, 10 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 7, 11 WHERE @nap_du_lieu_mau = 1;
INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
SELECT 8, 12 WHERE @nap_du_lieu_mau = 1;

-- 25 đơn: 20 đã thanh toán, 4 chờ thanh toán, 1 đã hủy.
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 1, 2, 528000, 'DA_THANH_TOAN', '2026-11-01 10:00:00', '2026-11-01 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 2, 3, 349000, 'DA_THANH_TOAN', '2026-11-01 09:00:00', '2026-11-01 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 3, 4, 199000, 'DA_THANH_TOAN', '2026-11-02 10:00:00', '2026-11-02 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 4, 5, 129000, 'DA_THANH_TOAN', '2026-11-02 09:00:00', '2026-11-02 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 5, 6, 459000, 'DA_THANH_TOAN', '2026-11-03 10:00:00', '2026-11-03 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 6, 7, 249000, 'DA_THANH_TOAN', '2026-11-03 09:00:00', '2026-11-03 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 7, 8, 159000, 'DA_THANH_TOAN', '2026-11-04 10:00:00', '2026-11-04 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 8, 9, 399000, 'DA_THANH_TOAN', '2026-11-04 09:00:00', '2026-11-04 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 9, 10, 179000, 'DA_THANH_TOAN', '2026-11-05 10:00:00', '2026-11-05 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 10, 11, 229000, 'DA_THANH_TOAN', '2026-11-05 09:00:00', '2026-11-05 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 11, 12, 99000, 'DA_THANH_TOAN', '2026-11-06 10:00:00', '2026-11-06 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 12, 13, 329000, 'DA_THANH_TOAN', '2026-11-06 09:00:00', '2026-11-06 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 13, 14, 149000, 'DA_THANH_TOAN', '2026-11-07 10:00:00', '2026-11-07 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 14, 15, 159000, 'DA_THANH_TOAN', '2026-11-07 09:00:00', '2026-11-07 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 15, 16, 169000, 'DA_THANH_TOAN', '2026-11-08 10:00:00', '2026-11-08 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 16, 17, 179000, 'DA_THANH_TOAN', '2026-11-08 09:00:00', '2026-11-08 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 17, 18, 189000, 'DA_THANH_TOAN', '2026-11-09 10:00:00', '2026-11-09 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 18, 19, 199000, 'DA_THANH_TOAN', '2026-11-09 09:00:00', '2026-11-09 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 19, 20, 209000, 'DA_THANH_TOAN', '2026-11-10 10:00:00', '2026-11-10 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 20, 21, 219000, 'DA_THANH_TOAN', '2026-11-10 09:00:00', '2026-11-10 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 21, 2, 239000, 'CHO_THANH_TOAN', '2026-11-12 10:00:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 22, 3, 249000, 'CHO_THANH_TOAN', '2026-11-12 11:00:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 23, 4, 259000, 'CHO_THANH_TOAN', '2026-11-12 12:00:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 24, 5, 239000, 'CHO_THANH_TOAN', '2026-11-12 13:00:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
SELECT 25, 6, 249000, 'DA_HUY', '2026-11-12 14:00:00', NULL WHERE @nap_du_lieu_mau = 1;

-- 26 chi tiết. Đơn 1 mua hai game; tên và giá tại lúc đặt được giữ nguyên.
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 1, 1, 1, 'Astral Odyssey', 299000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 2, 1, 21, 'Coral Garden', 229000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 3, 2, 2, 'Neon District', 349000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 4, 3, 3, 'Lost Kingdom', 199000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 5, 4, 4, 'Ocean Echoes', 129000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 6, 5, 5, 'Shadow Ronin', 459000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 7, 6, 6, 'Velocity X', 249000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 8, 7, 7, 'Moonlight Valley', 159000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 9, 8, 8, 'Iron Frontier', 399000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 10, 9, 9, 'Ember Quest', 179000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 11, 10, 10, 'Celestial Drift', 229000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 12, 11, 11, 'Forest Spirits', 99000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 13, 12, 12, 'Beyond the Rift', 329000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 14, 13, 13, 'Crystal Harbor', 149000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 15, 14, 14, 'Solar Rally', 159000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 16, 15, 15, 'Winter Haven', 169000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 17, 16, 16, 'Pixel Voyage', 179000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 18, 17, 17, 'Midnight Signal', 189000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 19, 18, 18, 'Skybound Tales', 199000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 20, 19, 19, 'Desert Legends', 209000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 21, 20, 20, 'Echoes of Time', 219000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 22, 21, 22, 'Starlight Arena', 239000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 23, 22, 23, 'Silent Meadow', 249000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 24, 23, 24, 'Lunar Express', 259000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 25, 24, 22, 'Starlight Arena', 239000, 1 WHERE @nap_du_lieu_mau = 1;
INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
SELECT 26, 25, 23, 'Silent Meadow', 249000, 1 WHERE @nap_du_lieu_mau = 1;

-- 29 lần thanh toán. Mỗi đơn đã trả tiền có đúng một lần thành công; có dữ liệu thử lại, hết hạn, hủy.
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 1, 1, 'MOMO', 528000, 'THAT_BAI', '2026-11-01 10:00:05', '2026-11-01 10:01:35', 3, '2026-11-01 10:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 2, 1, 'MOMO', 528000, 'THANH_CONG', '2026-11-01 10:01:35', '2026-11-01 10:03:05', 0, '2026-11-01 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 3, 2, 'MOMO', 349000, 'THAT_BAI', '2026-11-01 09:00:05', '2026-11-01 09:01:35', 3, '2026-11-01 09:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 4, 2, 'NGAN_HANG', 349000, 'THANH_CONG', '2026-11-01 09:01:35', '2026-11-01 09:03:05', 0, '2026-11-01 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 5, 3, 'MOMO', 199000, 'THAT_BAI', '2026-11-02 10:00:05', '2026-11-02 10:01:35', 3, '2026-11-02 10:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 6, 3, 'MOMO', 199000, 'THANH_CONG', '2026-11-02 10:01:35', '2026-11-02 10:03:05', 0, '2026-11-02 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 7, 4, 'MOMO', 129000, 'THAT_BAI', '2026-11-02 09:00:05', '2026-11-02 09:01:35', 3, '2026-11-02 09:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 8, 4, 'NGAN_HANG', 129000, 'THANH_CONG', '2026-11-02 09:01:35', '2026-11-02 09:03:05', 0, '2026-11-02 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 9, 5, 'MOMO', 459000, 'THAT_BAI', '2026-11-03 10:00:05', '2026-11-03 10:01:35', 3, '2026-11-03 10:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 10, 5, 'MOMO', 459000, 'THANH_CONG', '2026-11-03 10:01:35', '2026-11-03 10:03:05', 0, '2026-11-03 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 11, 6, 'NGAN_HANG', 249000, 'THANH_CONG', '2026-11-03 09:01:35', '2026-11-03 09:03:05', 0, '2026-11-03 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 12, 7, 'MOMO', 159000, 'THANH_CONG', '2026-11-04 10:01:35', '2026-11-04 10:03:05', 0, '2026-11-04 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 13, 8, 'NGAN_HANG', 399000, 'THANH_CONG', '2026-11-04 09:01:35', '2026-11-04 09:03:05', 0, '2026-11-04 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 14, 9, 'MOMO', 179000, 'THANH_CONG', '2026-11-05 10:01:35', '2026-11-05 10:03:05', 0, '2026-11-05 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 15, 10, 'NGAN_HANG', 229000, 'THANH_CONG', '2026-11-05 09:01:35', '2026-11-05 09:03:05', 0, '2026-11-05 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 16, 11, 'MOMO', 99000, 'THANH_CONG', '2026-11-06 10:01:35', '2026-11-06 10:03:05', 0, '2026-11-06 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 17, 12, 'NGAN_HANG', 329000, 'THANH_CONG', '2026-11-06 09:01:35', '2026-11-06 09:03:05', 0, '2026-11-06 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 18, 13, 'MOMO', 149000, 'THANH_CONG', '2026-11-07 10:01:35', '2026-11-07 10:03:05', 0, '2026-11-07 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 19, 14, 'NGAN_HANG', 159000, 'THANH_CONG', '2026-11-07 09:01:35', '2026-11-07 09:03:05', 0, '2026-11-07 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 20, 15, 'MOMO', 169000, 'THANH_CONG', '2026-11-08 10:01:35', '2026-11-08 10:03:05', 0, '2026-11-08 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 21, 16, 'NGAN_HANG', 179000, 'THANH_CONG', '2026-11-08 09:01:35', '2026-11-08 09:03:05', 0, '2026-11-08 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 22, 17, 'MOMO', 189000, 'THANH_CONG', '2026-11-09 10:01:35', '2026-11-09 10:03:05', 0, '2026-11-09 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 23, 18, 'NGAN_HANG', 199000, 'THANH_CONG', '2026-11-09 09:01:35', '2026-11-09 09:03:05', 0, '2026-11-09 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 24, 19, 'MOMO', 209000, 'THANH_CONG', '2026-11-10 10:01:35', '2026-11-10 10:03:05', 0, '2026-11-10 10:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 25, 20, 'NGAN_HANG', 219000, 'THANH_CONG', '2026-11-10 09:01:35', '2026-11-10 09:03:05', 0, '2026-11-10 09:02:00', NULL WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 26, 21, 'MOMO', 239000, 'HET_HAN', '2026-11-12 10:00:05', '2026-11-12 10:01:35', 0, '2026-11-12 10:01:35', 'OTP hết hạn' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 27, 22, 'MOMO', 249000, 'DA_HUY', '2026-11-12 11:00:05', '2026-11-12 11:01:35', 0, '2026-11-12 11:00:35', 'Khách hủy lần thanh toán' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 28, 23, 'MOMO', 259000, 'THAT_BAI', '2026-11-12 12:00:05', '2026-11-12 12:01:35', 3, '2026-11-12 12:00:35', 'Sai OTP 3 lần' WHERE @nap_du_lieu_mau = 1;
INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
SELECT 29, 24, 'MOMO', 239000, 'HET_HAN', '2026-11-12 13:00:05', '2026-11-12 13:01:35', 0, '2026-11-12 13:01:35', 'OTP hết hạn' WHERE @nap_du_lieu_mau = 1;

-- 21 quyền sở hữu, tất cả đều đến từ chi tiết đơn đã thanh toán.
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 1, 2, 1, 1, '2026-11-01 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 2, 2, 21, 2, '2026-11-01 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 3, 3, 2, 3, '2026-11-01 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 4, 4, 3, 4, '2026-11-02 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 5, 5, 4, 5, '2026-11-02 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 6, 6, 5, 6, '2026-11-03 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 7, 7, 6, 7, '2026-11-03 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 8, 8, 7, 8, '2026-11-04 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 9, 9, 8, 9, '2026-11-04 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 10, 10, 9, 10, '2026-11-05 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 11, 11, 10, 11, '2026-11-05 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 12, 12, 11, 12, '2026-11-06 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 13, 13, 12, 13, '2026-11-06 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 14, 14, 13, 14, '2026-11-07 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 15, 15, 14, 15, '2026-11-07 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 16, 16, 15, 16, '2026-11-08 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 17, 17, 16, 17, '2026-11-08 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 18, 18, 17, 18, '2026-11-09 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 19, 19, 18, 19, '2026-11-09 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 20, 20, 19, 20, '2026-11-10 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
SELECT 21, 21, 20, 21, '2026-11-10 09:02:00' WHERE @nap_du_lieu_mau = 1;

-- 20 đánh giá, người đánh giá đều đã sở hữu đúng game.
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 1, 2, 1, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-02 10:02:00', '2026-11-02 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 2, 3, 2, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-02 09:02:00', '2026-11-02 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 3, 4, 3, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-03 10:02:00', '2026-11-03 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 4, 5, 4, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-03 09:02:00', '2026-11-03 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 5, 6, 5, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-04 10:02:00', '2026-11-04 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 6, 7, 6, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-04 09:02:00', '2026-11-04 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 7, 8, 7, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-05 10:02:00', '2026-11-05 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 8, 9, 8, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-05 09:02:00', '2026-11-05 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 9, 10, 9, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-06 10:02:00', '2026-11-06 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 10, 11, 10, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-06 09:02:00', '2026-11-06 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 11, 12, 11, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-07 10:02:00', '2026-11-07 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 12, 13, 12, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-07 09:02:00', '2026-11-07 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 13, 14, 13, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-08 10:02:00', '2026-11-08 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 14, 15, 14, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-08 09:02:00', '2026-11-08 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 15, 16, 15, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-09 10:02:00', '2026-11-09 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 16, 17, 16, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-09 09:02:00', '2026-11-09 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 17, 18, 17, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-10 10:02:00', '2026-11-10 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 18, 19, 18, 3, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-10 09:02:00', '2026-11-10 09:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 19, 20, 19, 4, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-11 10:02:00', '2026-11-11 10:02:00' WHERE @nap_du_lieu_mau = 1;
INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
SELECT 20, 21, 20, 5, 'Game dễ làm quen, trải nghiệm phù hợp để giải trí.', '2026-11-11 09:02:00', '2026-11-11 09:02:00' WHERE @nap_du_lieu_mau = 1;

-- 20 dòng giỏ: game đang bán, chưa thuộc thư viện của khách. Có thể tồn tại trong đơn chưa thanh toán.
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 1, 2, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 2, 3, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 3, 4, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 4, 5, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 5, 6, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 6, 7, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 7, 8, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 8, 9, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 9, 10, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 10, 11, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 11, 12, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 12, 13, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 13, 14, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 14, 15, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 15, 16, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 16, 17, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 17, 18, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 18, 19, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 19, 20, 22 WHERE @nap_du_lieu_mau = 1;
INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
SELECT 20, 21, 22 WHERE @nap_du_lieu_mau = 1;

COMMIT;

-- PHẦN C. KIỂM TRA SAU KHI CHẠY 
SELECT IF(@nap_du_lieu_mau = 1,
    'Đã tạo cấu trúc và nạp dữ liệu mẫu.',
    'Đã có dữ liệu: giữ nguyên, không nạp thêm mẫu.') AS ket_qua;
SHOW TABLES;
SELECT 'NGUOIDUNG' AS ten_bang, COUNT(*) AS so_dong FROM NGUOIDUNG;
SELECT 'NHAPHATHANH' AS ten_bang, COUNT(*) AS so_dong FROM NHAPHATHANH;
SELECT 'THELOAI' AS ten_bang, COUNT(*) AS so_dong FROM THELOAI;
SELECT 'TROCHOI' AS ten_bang, COUNT(*) AS so_dong FROM TROCHOI;
SELECT 'TROCHOI_THELOAI' AS ten_bang, COUNT(*) AS so_dong FROM TROCHOI_THELOAI;
SELECT 'DONHANG' AS ten_bang, COUNT(*) AS so_dong FROM DONHANG;
SELECT 'CHITIETDONHANG' AS ten_bang, COUNT(*) AS so_dong FROM CHITIETDONHANG;
SELECT 'LICHSUTHANHTOAN' AS ten_bang, COUNT(*) AS so_dong FROM LICHSUTHANHTOAN;
SELECT 'THUVIEN' AS ten_bang, COUNT(*) AS so_dong FROM THUVIEN;
SELECT 'DANHGIA' AS ten_bang, COUNT(*) AS so_dong FROM DANHGIA;
SELECT 'GIOHANG' AS ten_bang, COUNT(*) AS so_dong FROM GIOHANG;

-- Tổng quan ban đầu: 20 đơn thành công, 23 game đang bán.
-- COALESCE(..., 0): nếu chưa có đơn thành công thì hiển thị 0 đồng.
SELECT COALESCE(SUM(tong_tien), 0) AS doanh_thu,
       COUNT(*) AS so_don_thanh_cong
FROM DONHANG WHERE trang_thai = 'DA_THANH_TOAN';
SELECT COUNT(*) AS game_dang_ban FROM TROCHOI WHERE trang_thai = 'DANG_BAN';


