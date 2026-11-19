CREATE DATABASE IF NOT EXISTS java_play
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE java_play;
SET NAMES utf8mb4;

-- Chạy lại sẽ xóa dữ liệu trong 11 bảng của đồ án. Sao lưu trước nếu cần.
DROP TABLE IF EXISTS GIOHANG;
DROP TABLE IF EXISTS DANHGIA;
DROP TABLE IF EXISTS THUVIEN;
DROP TABLE IF EXISTS LICHSUTHANHTOAN;
DROP TABLE IF EXISTS CHITIETDONHANG;
DROP TABLE IF EXISTS DONHANG;
DROP TABLE IF EXISTS TROCHOI_THELOAI;
DROP TABLE IF EXISTS TROCHOI;
DROP TABLE IF EXISTS THELOAI;
DROP TABLE IF EXISTS NHAPHATHANH;
DROP TABLE IF EXISTS NGUOIDUNG;

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
    quoc_gia VARCHAR(100) NULL,
    nam_thanh_lap SMALLINT NULL,
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

-- Dữ liệu khởi tạo. Tài khoản kiểm thử: admin và khach, mật khẩu 123456.
START TRANSACTION;

INSERT INTO NGUOIDUNG (ma_nguoi_dung, ten_dang_nhap, email, mat_khau_hash, ten_hien_thi, vai_tro, trang_thai)
VALUES
    (1, 'admin', 'admin@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Quản trị viên', 'ROLE_ADMIN', 'HOAT_DONG'),
    (2, 'khach', 'khach@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Nguyễn Khánh Linh', 'ROLE_USER', 'HOAT_DONG'),
    (3, 'minhkhang', 'minhkhang@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Trần Minh Khang', 'ROLE_USER', 'HOAT_DONG'),
    (4, 'thaovy', 'thaovy@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Lê Thảo Vy', 'ROLE_USER', 'HOAT_DONG'),
    (5, 'giahuy', 'giahuy@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Vũ Gia Huy', 'ROLE_USER', 'HOAT_DONG'),
    (6, 'thuha', 'thuha@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Phạm Thu Hà', 'ROLE_USER', 'HOAT_DONG'),
    (7, 'hainam', 'hainam@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Đỗ Hải Nam', 'ROLE_USER', 'HOAT_DONG'),
    (8, 'ngocanh', 'ngocanh@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Lâm Ngọc Anh', 'ROLE_USER', 'HOAT_DONG'),
    (9, 'baotran', 'baotran@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Lý Bảo Trân', 'ROLE_USER', 'HOAT_DONG'),
    (10, 'tuankiet', 'tuankiet@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Hồ Tuấn Kiệt', 'ROLE_USER', 'HOAT_DONG'),
    (11, 'yennhi', 'yennhi@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Đinh Yến Nhi', 'ROLE_USER', 'HOAT_DONG'),
    (12, 'nhatminh', 'nhatminh@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Ngô Nhật Minh', 'ROLE_USER', 'HOAT_DONG'),
    (13, 'hongphuc', 'hongphuc@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Mai Hồng Phúc', 'ROLE_USER', 'HOAT_DONG'),
    (14, 'thanhlam', 'thanhlam@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Trần Thanh Lam', 'ROLE_USER', 'HOAT_DONG'),
    (15, 'quocbao', 'quocbao@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Phan Quốc Bảo', 'ROLE_USER', 'HOAT_DONG'),
    (16, 'anhduong', 'anhduong@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Lê Ánh Dương', 'ROLE_USER', 'HOAT_DONG'),
    (17, 'haidang', 'haidang@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Trương Hải Đăng', 'ROLE_USER', 'HOAT_DONG'),
    (18, 'kimngan', 'kimngan@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Đào Kim Ngân', 'ROLE_USER', 'HOAT_DONG'),
    (19, 'ducanh', 'ducanh@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Võ Đức Anh', 'ROLE_USER', 'HOAT_DONG'),
    (20, 'annhien', 'annhien@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Bùi An Nhiên', 'ROLE_USER', 'HOAT_DONG'),
    (21, 'hoaian', 'hoaian@example.test', '$2b$12$OntmH821ElI.6q10cG4.TeyBVHg7fxkX7CGMo9r53saSTW/pKj5w2', 'Cao Hoài An', 'ROLE_USER', 'BI_KHOA');

INSERT INTO NHAPHATHANH (ma_nha_phat_hanh, ten_nha_phat_hanh, quoc_gia, nam_thanh_lap)
VALUES
    (1, 'Nova Publishing', 'Canada', 2008),
    (2, 'Blue Horizon', 'Úc', 2011),
    (3, 'Orbit Interactive', 'Anh', 2004),
    (4, 'Lantern Bay Games', 'Nhật Bản', 2015),
    (5, 'Mây Tre Studio', 'Việt Nam', 2017),
    (6, 'Copper Finch Publishing', 'Phần Lan', 2012),
    (7, 'Ember Coast Games', 'Hoa Kỳ', 2009),
    (8, 'Trăng Non Interactive', 'Việt Nam', 2019),
    (9, 'Paper Kite Publishing', 'Đài Loan', 2010),
    (10, 'Cinder Valley Games', 'Đức', 2007),
    (11, 'Pine Harbor Interactive', 'Canada', 2016),
    (12, 'Moss Lantern Games', 'Thụy Điển', 2013),
    (13, 'Sao Khuê Games', 'Việt Nam', 2014),
    (14, 'Red Otter Publishing', 'Hà Lan', 2005),
    (15, 'Moonbridge Interactive', 'Hàn Quốc', 2006),
    (16, 'Đom Đóm Studio', 'Việt Nam', 2018),
    (17, 'Glass Harbor Games', 'Pháp', 2002),
    (18, 'Silver Reed Publishing', 'Anh', 1999),
    (19, 'Dawn Orchard Games', 'New Zealand', 2011),
    (20, 'Gió Nồm Studio', 'Việt Nam', 2017);

INSERT INTO THELOAI (ma_the_loai, ten_the_loai, mo_ta)
VALUES
    (1, 'Hành động', 'Né đòn và phản công trong những trận đánh nhịp nhanh.'),
    (2, 'Phiêu lưu', 'Lần theo dấu vết qua các vùng đất xa lạ.'),
    (3, 'Nhập vai', 'Xây dựng nhân vật và chọn cách giải quyết nhiệm vụ.'),
    (4, 'Đua xe', 'Canh điểm phanh và vượt đối thủ trên đường đua.'),
    (5, 'Chiến thuật', 'Bố trí lực lượng và phân bổ nguồn lực.'),
    (6, 'Giải đố', 'Tìm quy luật từ manh mối để mở lối đi.'),
    (7, 'Mô phỏng', 'Điều khiển máy móc hoặc thử sức với một nghề.'),
    (8, 'Sinh tồn', 'Tìm thức ăn, giữ ấm và dựng nơi trú ẩn.'),
    (9, 'Thể thao', 'Thi đấu theo luật của từng môn thể thao.'),
    (10, 'Đối kháng', 'Đấu tay đôi, đỡ đòn và nối chuỗi chiêu thức.'),
    (11, 'Kinh dị', 'Đối mặt với những mối đe dọa trong bóng tối.'),
    (12, 'Thế giới mở', 'Tự chọn đường đi và thứ tự thực hiện nhiệm vụ.'),
    (13, 'Đi cảnh', 'Canh nhịp nhảy qua chướng ngại vật.'),
    (14, 'Âm nhạc', 'Thao tác theo nhịp trống và giai điệu.'),
    (15, 'Thẻ bài', 'Xây bộ bài và phối hợp hiệu ứng giữa các lá.'),
    (16, 'Chiến thuật theo lượt', 'Luân phiên di chuyển và ra lệnh trên bàn đấu.'),
    (17, 'Khám phá', 'Quan sát môi trường để ghi lại những phát hiện mới.'),
    (18, 'Quản lý', 'Cân đối chi phí, nhân lực và lịch vận hành.'),
    (19, 'Bắn súng', 'Ngắm bắn và tìm vị trí che chắn.'),
    (20, 'Tiểu thuyết tương tác', 'Quyết định diễn biến câu chuyện qua các lựa chọn đối thoại.');

INSERT INTO TROCHOI (ma_tro_choi, tieu_de, ma_nha_phat_hanh, ten_nha_phat_trien, mo_ta, hinh_anh, ngay_phat_hanh, gia_ban, do_tuoi_khuyen_nghi, dung_luong_gb, cau_hinh_yeu_cau, trang_thai)
VALUES
    (1, 'Astral Odyssey', 1, 'Vệt Sao', 'Vá cánh buồm năng lượng và lái tàu theo các chòm sao để đưa đoàn thám hiểm về trạm cuối.', NULL, '2021-03-12', 299000, 7, 8.4, 'Windows 10, RAM 8 GB, GTX 1050', 'NGUNG_BAN'),
    (2, 'Neon District', 2, 'Hẻm Đêm', 'Trong vai người giao thư đêm, bạn lần theo các biển hiệu mất điện để tìm chủ nhân một bưu kiện vô danh.', NULL, '2022-01-19', 349000, 12, 3.2, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (3, 'Lost Kingdom', 3, 'Ash Crown', 'Chiếc nhẫn của vị vua mất tích mở được ba hầm mộ. Bạn phải chọn người đồng hành trước khi xuống hầm đầu tiên.', NULL, '2022-11-28', 199000, 12, 21, 'Windows 10, RAM 16 GB, GTX 1660', 'DANG_BAN'),
    (4, 'Ocean Echoes', 4, 'Tidepool Lab', 'Lặn dọc xác tàu đắm, thu tiếng vọng rồi ghép chúng thành bản đồ của một cảng cổ.', NULL, '2023-10-07', 129000, 7, 5.6, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (5, 'Shadow Ronin', 5, 'Trúc Xanh', 'Một lãng khách giấu kiếm trong ống trúc, lần theo vết guốc để tìm người thầy thất lạc.', NULL, '2024-08-15', 459000, 16, 16.8, 'Windows 10, RAM 16 GB, GTX 1660', 'DANG_BAN'),
    (6, 'Velocity X', 6, 'Apex Works', 'Giữ tốc độ qua các khúc cua nghiêng trên đường thử bỏ hoang và tự chỉnh tỉ số truyền trước mỗi chặng.', NULL, '2025-06-24', 249000, 3, 24, 'Windows 10, RAM 16 GB, GTX 1660', 'DANG_BAN'),
    (7, 'Moonlight Valley', 7, 'Cỏ May', 'Trồng dược thảo theo lịch trăng rồi đạp xe giao thuốc cho những căn nhà bên kia thung lũng.', NULL, '2021-06-07', 159000, 3, 2.4, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (8, 'Iron Frontier', 8, 'Rivet House', 'Qua mùa đông ở tiền đồn đường sắt, bạn phải chia than giữa lò sưởi và đầu máy chở lương thực.', NULL, '2022-04-16', 399000, 12, 12, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (9, 'Ember Quest', 9, 'Hearthbird', 'Mang đốm lửa cuối cùng qua dãy núi, học phép mới từ những bếp lửa của các làng ven đường.', NULL, '2023-02-23', 179000, 7, 6.8, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (10, 'Celestial Drift', 10, 'Low Orbit', 'Đấu tay đôi trên sàn trôi ngoài quỹ đạo, lợi dụng những lần đổi trọng lực để ép đối thủ ra rìa.', NULL, '2024-01-02', 229000, 12, 7.5, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (11, 'Forest Spirits', 11, 'Fern Hollow', 'Mỗi đêm một lối mòn trong rừng biến mất. Theo tiếng gõ trên thân cây để tìm đường về trước bình minh.', NULL, '2024-11-10', 99000, 16, 4.6, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (12, 'Beyond the Rift', 12, 'Twin Shore', 'Băng qua các vết nứt nối hai phiên bản của cùng một hòn đảo để mở lại tuyến đường của dân làng.', NULL, '2025-09-19', 329000, 12, 32, 'Windows 10, RAM 16 GB, GTX 1660', 'DANG_BAN'),
    (13, 'Crystal Harbor', 13, 'Saltbox', 'Nhảy qua giàn cẩu và xoay các lăng kính để bật lại ngọn hải đăng trước giờ tàu cập bến.', NULL, '2021-09-02', 149000, 3, 1.8, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (14, 'Solar Rally', 14, 'Helio Garage', 'Lái xe năng lượng mặt trời qua đồng muối, chọn đường theo bóng mây để đủ điện về đích.', NULL, '2022-07-12', 159000, 3, 11.5, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (15, 'Winter Haven', 15, 'Snowcap Desk', 'Xếp các lá bài chỗ ở, củi và lương thực để đưa một đoàn người vượt đợt tuyết cuối mùa.', NULL, '2023-05-21', 169000, 7, 1.2, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (16, 'Pixel Voyage', 16, 'Little Compass', 'Dẫn đội thủy thủ tí hon qua quần đảo ô vuông và tính từng lượt chèo theo hướng gió.', NULL, '2024-03-29', 179000, 7, 0.85, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (17, 'Midnight Signal', 17, 'Đèn Khuya', 'Dò tần số lúc nửa đêm để nghe những mẩu tin phát ra từ một nhà ga đã đóng cửa.', NULL, '2025-02-05', 189000, 12, 2.2, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (18, 'Skybound Tales', 18, 'Cloud Berth', 'Điều hành bến khí cầu, xếp lịch hạ cánh và cân tải hành lý trước khi giông kéo tới.', NULL, '2025-12-15', 199000, 3, 5, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (19, 'Desert Legends', 19, 'Ochre Fox', 'Bảo vệ đoàn xe chở nước qua biển cát bằng súng móc và tận dụng các vách đá để tránh bão.', NULL, '2021-11-28', 209000, 16, 18, 'Windows 10, RAM 16 GB, GTX 1660', 'DANG_BAN'),
    (20, 'Echoes of Time', 20, 'Nếp Giấy', 'Đọc những lá thư gửi nhầm thời điểm và chọn câu trả lời để thay đổi cuộc gặp của hai chị em.', NULL, '2022-10-07', 219000, 7, 1.6, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (21, 'Coral Garden', 1, 'Reef Loom', 'Ươm từng nhánh san hô rồi điều chỉnh dòng chảy để đưa đàn cá hề trở lại rạn đá.', NULL, '2023-08-16', 229000, 3, 3, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (22, 'Starlight Arena', 2, 'Beat Bench', 'Canh theo tiếng trống để chuyền quả cầu sáng qua sân vận động giữa các vì sao.', NULL, '2024-06-24', 239000, 3, 4.2, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN'),
    (23, 'Silent Meadow', 3, 'Bờ Cỏ', 'Lần theo dấu chân sóc qua đồng cỏ sau mưa và vẽ lại các loài hoa vào sổ tay.', NULL, '2025-05-03', 249000, 3, 1.4, 'Windows 10, RAM 4 GB, Intel UHD 620', 'DANG_BAN'),
    (24, 'Lunar Express', 4, 'Switchyard', 'Chuyển đường ray trên mặt trăng và chia điện giữa các toa để chuyến tàu đêm kịp nối tuyến.', NULL, '2021-04-16', 259000, 7, 6, 'Windows 10, RAM 8 GB, GTX 1050', 'DANG_BAN');

INSERT INTO TROCHOI_THELOAI (ma_tro_choi, ma_the_loai)
VALUES
    (1, 17),
    (1, 2),
    (2, 2),
    (2, 6),
    (3, 3),
    (4, 17),
    (5, 1),
    (5, 2),
    (6, 4),
    (7, 7),
    (8, 8),
    (8, 5),
    (9, 3),
    (10, 10),
    (11, 11),
    (12, 12),
    (13, 13),
    (13, 6),
    (14, 4),
    (14, 9),
    (15, 15),
    (16, 16),
    (17, 6),
    (17, 11),
    (18, 18),
    (19, 19),
    (20, 20),
    (21, 7),
    (22, 14),
    (22, 9),
    (23, 17),
    (24, 18),
    (24, 6);

INSERT INTO DONHANG (ma_don_hang, ma_nguoi_dung, tong_tien, trang_thai, ngay_dat, ngay_thanh_toan)
VALUES
    (1, 2, 528000, 'DA_THANH_TOAN', '2026-11-01 10:00:00', '2026-11-01 10:02:00'),
    (2, 3, 349000, 'DA_THANH_TOAN', '2026-11-01 09:00:00', '2026-11-01 09:02:00'),
    (3, 4, 199000, 'DA_THANH_TOAN', '2026-11-02 10:00:00', '2026-11-02 10:02:00'),
    (4, 5, 129000, 'DA_THANH_TOAN', '2026-11-02 09:00:00', '2026-11-02 09:02:00'),
    (5, 6, 459000, 'DA_THANH_TOAN', '2026-11-03 10:00:00', '2026-11-03 10:02:00'),
    (6, 7, 249000, 'DA_THANH_TOAN', '2026-11-03 09:00:00', '2026-11-03 09:02:00'),
    (7, 8, 159000, 'DA_THANH_TOAN', '2026-11-04 10:00:00', '2026-11-04 10:02:00'),
    (8, 9, 399000, 'DA_THANH_TOAN', '2026-11-04 09:00:00', '2026-11-04 09:02:00'),
    (9, 10, 179000, 'DA_THANH_TOAN', '2026-11-05 10:00:00', '2026-11-05 10:02:00'),
    (10, 11, 229000, 'DA_THANH_TOAN', '2026-11-05 09:00:00', '2026-11-05 09:02:00'),
    (11, 12, 99000, 'DA_THANH_TOAN', '2026-11-06 10:00:00', '2026-11-06 10:02:00'),
    (12, 13, 329000, 'DA_THANH_TOAN', '2026-11-06 09:00:00', '2026-11-06 09:02:00'),
    (13, 14, 149000, 'DA_THANH_TOAN', '2026-11-07 10:00:00', '2026-11-07 10:02:00'),
    (14, 15, 159000, 'DA_THANH_TOAN', '2026-11-07 09:00:00', '2026-11-07 09:02:00'),
    (15, 16, 169000, 'DA_THANH_TOAN', '2026-11-08 10:00:00', '2026-11-08 10:02:00'),
    (16, 17, 179000, 'DA_THANH_TOAN', '2026-11-08 09:00:00', '2026-11-08 09:02:00'),
    (17, 18, 189000, 'DA_THANH_TOAN', '2026-11-09 10:00:00', '2026-11-09 10:02:00'),
    (18, 19, 199000, 'DA_THANH_TOAN', '2026-11-09 09:00:00', '2026-11-09 09:02:00'),
    (19, 20, 209000, 'DA_THANH_TOAN', '2026-11-10 10:00:00', '2026-11-10 10:02:00'),
    (20, 21, 219000, 'DA_THANH_TOAN', '2026-11-10 09:00:00', '2026-11-10 09:02:00'),
    (21, 2, 239000, 'CHO_THANH_TOAN', '2026-11-12 10:00:00', NULL),
    (22, 3, 249000, 'CHO_THANH_TOAN', '2026-11-12 11:00:00', NULL),
    (23, 4, 259000, 'CHO_THANH_TOAN', '2026-11-12 12:00:00', NULL),
    (24, 5, 239000, 'CHO_THANH_TOAN', '2026-11-12 13:00:00', NULL),
    (25, 6, 249000, 'DA_HUY', '2026-11-12 14:00:00', NULL);

INSERT INTO CHITIETDONHANG (ma_chi_tiet, ma_don_hang, ma_tro_choi, ten_game_luc_mua, don_gia, so_luong)
VALUES
    (1, 1, 1, 'Astral Odyssey', 299000, 1),
    (2, 1, 21, 'Coral Garden', 229000, 1),
    (3, 2, 2, 'Neon District', 349000, 1),
    (4, 3, 3, 'Lost Kingdom', 199000, 1),
    (5, 4, 4, 'Ocean Echoes', 129000, 1),
    (6, 5, 5, 'Shadow Ronin', 459000, 1),
    (7, 6, 6, 'Velocity X', 249000, 1),
    (8, 7, 7, 'Moonlight Valley', 159000, 1),
    (9, 8, 8, 'Iron Frontier', 399000, 1),
    (10, 9, 9, 'Ember Quest', 179000, 1),
    (11, 10, 10, 'Celestial Drift', 229000, 1),
    (12, 11, 11, 'Forest Spirits', 99000, 1),
    (13, 12, 12, 'Beyond the Rift', 329000, 1),
    (14, 13, 13, 'Crystal Harbor', 149000, 1),
    (15, 14, 14, 'Solar Rally', 159000, 1),
    (16, 15, 15, 'Winter Haven', 169000, 1),
    (17, 16, 16, 'Pixel Voyage', 179000, 1),
    (18, 17, 17, 'Midnight Signal', 189000, 1),
    (19, 18, 18, 'Skybound Tales', 199000, 1),
    (20, 19, 19, 'Desert Legends', 209000, 1),
    (21, 20, 20, 'Echoes of Time', 219000, 1),
    (22, 21, 22, 'Starlight Arena', 239000, 1),
    (23, 22, 23, 'Silent Meadow', 249000, 1),
    (24, 23, 24, 'Lunar Express', 259000, 1),
    (25, 24, 22, 'Starlight Arena', 239000, 1),
    (26, 25, 23, 'Silent Meadow', 249000, 1);

INSERT INTO LICHSUTHANHTOAN (ma_giao_dich, ma_don_hang, phuong_thuc, so_tien, trang_thai, thoi_gian_tao, thoi_gian_het_han, so_lan_nhap_sai, thoi_gian_ket_thuc, ghi_chu)
VALUES
    (1, 1, 'MOMO', 528000, 'THAT_BAI', '2026-11-01 10:00:05', '2026-11-01 10:01:35', 3, '2026-11-01 10:00:35', 'Sai OTP 3 lần'),
    (2, 1, 'MOMO', 528000, 'THANH_CONG', '2026-11-01 10:01:35', '2026-11-01 10:03:05', 0, '2026-11-01 10:02:00', NULL),
    (3, 2, 'MOMO', 349000, 'THAT_BAI', '2026-11-01 09:00:05', '2026-11-01 09:01:35', 3, '2026-11-01 09:00:35', 'Sai OTP 3 lần'),
    (4, 2, 'NGAN_HANG', 349000, 'THANH_CONG', '2026-11-01 09:01:35', '2026-11-01 09:03:05', 0, '2026-11-01 09:02:00', NULL),
    (5, 3, 'MOMO', 199000, 'THAT_BAI', '2026-11-02 10:00:05', '2026-11-02 10:01:35', 3, '2026-11-02 10:00:35', 'Sai OTP 3 lần'),
    (6, 3, 'MOMO', 199000, 'THANH_CONG', '2026-11-02 10:01:35', '2026-11-02 10:03:05', 0, '2026-11-02 10:02:00', NULL),
    (7, 4, 'MOMO', 129000, 'THAT_BAI', '2026-11-02 09:00:05', '2026-11-02 09:01:35', 3, '2026-11-02 09:00:35', 'Sai OTP 3 lần'),
    (8, 4, 'NGAN_HANG', 129000, 'THANH_CONG', '2026-11-02 09:01:35', '2026-11-02 09:03:05', 0, '2026-11-02 09:02:00', NULL),
    (9, 5, 'MOMO', 459000, 'THAT_BAI', '2026-11-03 10:00:05', '2026-11-03 10:01:35', 3, '2026-11-03 10:00:35', 'Sai OTP 3 lần'),
    (10, 5, 'MOMO', 459000, 'THANH_CONG', '2026-11-03 10:01:35', '2026-11-03 10:03:05', 0, '2026-11-03 10:02:00', NULL),
    (11, 6, 'NGAN_HANG', 249000, 'THANH_CONG', '2026-11-03 09:01:35', '2026-11-03 09:03:05', 0, '2026-11-03 09:02:00', NULL),
    (12, 7, 'MOMO', 159000, 'THANH_CONG', '2026-11-04 10:01:35', '2026-11-04 10:03:05', 0, '2026-11-04 10:02:00', NULL),
    (13, 8, 'NGAN_HANG', 399000, 'THANH_CONG', '2026-11-04 09:01:35', '2026-11-04 09:03:05', 0, '2026-11-04 09:02:00', NULL),
    (14, 9, 'MOMO', 179000, 'THANH_CONG', '2026-11-05 10:01:35', '2026-11-05 10:03:05', 0, '2026-11-05 10:02:00', NULL),
    (15, 10, 'NGAN_HANG', 229000, 'THANH_CONG', '2026-11-05 09:01:35', '2026-11-05 09:03:05', 0, '2026-11-05 09:02:00', NULL),
    (16, 11, 'MOMO', 99000, 'THANH_CONG', '2026-11-06 10:01:35', '2026-11-06 10:03:05', 0, '2026-11-06 10:02:00', NULL),
    (17, 12, 'NGAN_HANG', 329000, 'THANH_CONG', '2026-11-06 09:01:35', '2026-11-06 09:03:05', 0, '2026-11-06 09:02:00', NULL),
    (18, 13, 'MOMO', 149000, 'THANH_CONG', '2026-11-07 10:01:35', '2026-11-07 10:03:05', 0, '2026-11-07 10:02:00', NULL),
    (19, 14, 'NGAN_HANG', 159000, 'THANH_CONG', '2026-11-07 09:01:35', '2026-11-07 09:03:05', 0, '2026-11-07 09:02:00', NULL),
    (20, 15, 'MOMO', 169000, 'THANH_CONG', '2026-11-08 10:01:35', '2026-11-08 10:03:05', 0, '2026-11-08 10:02:00', NULL),
    (21, 16, 'NGAN_HANG', 179000, 'THANH_CONG', '2026-11-08 09:01:35', '2026-11-08 09:03:05', 0, '2026-11-08 09:02:00', NULL),
    (22, 17, 'MOMO', 189000, 'THANH_CONG', '2026-11-09 10:01:35', '2026-11-09 10:03:05', 0, '2026-11-09 10:02:00', NULL),
    (23, 18, 'NGAN_HANG', 199000, 'THANH_CONG', '2026-11-09 09:01:35', '2026-11-09 09:03:05', 0, '2026-11-09 09:02:00', NULL),
    (24, 19, 'MOMO', 209000, 'THANH_CONG', '2026-11-10 10:01:35', '2026-11-10 10:03:05', 0, '2026-11-10 10:02:00', NULL),
    (25, 20, 'NGAN_HANG', 219000, 'THANH_CONG', '2026-11-10 09:01:35', '2026-11-10 09:03:05', 0, '2026-11-10 09:02:00', NULL),
    (26, 21, 'MOMO', 239000, 'HET_HAN', '2026-11-12 10:00:05', '2026-11-12 10:01:35', 0, '2026-11-12 10:01:35', 'OTP hết hạn'),
    (27, 22, 'MOMO', 249000, 'DA_HUY', '2026-11-12 11:00:05', '2026-11-12 11:01:35', 0, '2026-11-12 11:00:35', 'Khách hủy lần thanh toán'),
    (28, 23, 'MOMO', 259000, 'THAT_BAI', '2026-11-12 12:00:05', '2026-11-12 12:01:35', 3, '2026-11-12 12:00:35', 'Sai OTP 3 lần'),
    (29, 24, 'MOMO', 239000, 'HET_HAN', '2026-11-12 13:00:05', '2026-11-12 13:01:35', 0, '2026-11-12 13:01:35', 'OTP hết hạn');

INSERT INTO THUVIEN (ma_thu_vien, ma_nguoi_dung, ma_tro_choi, ma_chi_tiet, ngay_so_huu)
VALUES
    (1, 2, 1, 1, '2026-11-01 10:02:00'),
    (2, 2, 21, 2, '2026-11-01 10:02:00'),
    (3, 3, 2, 3, '2026-11-01 09:02:00'),
    (4, 4, 3, 4, '2026-11-02 10:02:00'),
    (5, 5, 4, 5, '2026-11-02 09:02:00'),
    (6, 6, 5, 6, '2026-11-03 10:02:00'),
    (7, 7, 6, 7, '2026-11-03 09:02:00'),
    (8, 8, 7, 8, '2026-11-04 10:02:00'),
    (9, 9, 8, 9, '2026-11-04 09:02:00'),
    (10, 10, 9, 10, '2026-11-05 10:02:00'),
    (11, 11, 10, 11, '2026-11-05 09:02:00'),
    (12, 12, 11, 12, '2026-11-06 10:02:00'),
    (13, 13, 12, 13, '2026-11-06 09:02:00'),
    (14, 14, 13, 14, '2026-11-07 10:02:00'),
    (15, 15, 14, 15, '2026-11-07 09:02:00'),
    (16, 16, 15, 16, '2026-11-08 10:02:00'),
    (17, 17, 16, 17, '2026-11-08 09:02:00'),
    (18, 18, 17, 18, '2026-11-09 10:02:00'),
    (19, 19, 18, 19, '2026-11-09 09:02:00'),
    (20, 20, 19, 20, '2026-11-10 10:02:00'),
    (21, 21, 20, 21, '2026-11-10 09:02:00');

INSERT INTO DANHGIA (ma_danh_gia, ma_nguoi_dung, ma_tro_choi, so_sao, noi_dung, ngay_danh_gia, ngay_cap_nhat)
VALUES
    (1, 2, 1, 4, 'Bản đồ sao viết tay đẹp quá, mình chỉ ước có thể đánh dấu thêm vài bến đáp.', '2026-11-02 10:02:00', '2026-11-02 10:02:00'),
    (2, 3, 2, 5, 'Mất một lúc mới nhận ra địa chỉ nằm trong bóng phản chiếu của biển hiệu!', '2026-11-02 09:02:00', '2026-11-02 09:02:00'),
    (3, 4, 3, 3, 'Hầm thứ hai thú vị nhưng đoạn quay về thành hơi dài.', '2026-11-03 10:02:00', '2026-11-03 10:02:00'),
    (4, 5, 4, 4, 'Đeo tai nghe mới nghe rõ tiếng chuông chìm dưới khoang tàu.', '2026-11-03 09:02:00', '2026-11-03 09:02:00'),
    (5, 6, 5, 5, 'Màn đấu dưới mưa rất đã, nhất là lúc đỡ được ba nhát liên tiếp.', '2026-11-04 10:02:00', '2026-11-04 10:02:00'),
    (6, 7, 6, 3, 'Xe bám đường tốt nhưng mình muốn có thêm góc nhìn trong buồng lái.', '2026-11-04 09:02:00', '2026-11-04 09:02:00'),
    (7, 8, 7, 4, 'Mình thích tự chọn luống cây, chỉ tiếc đường giao thuốc hơi ngắn.', '2026-11-05 10:02:00', '2026-11-05 10:02:00'),
    (8, 9, 8, 5, 'Có hôm mình phải tháo cả đường ray phụ để giữ ấm cho trạm.', '2026-11-05 09:02:00', '2026-11-05 09:02:00'),
    (9, 10, 9, 3, 'Phép lửa khá vui nhưng chỉ dẫn ở đèo đầu tiên hơi mờ.', '2026-11-06 10:02:00', '2026-11-06 10:02:00'),
    (10, 11, 10, 4, 'Lật trọng lực giữa một pha phản đòn khá khó, tập được thì rất vui.', '2026-11-06 09:02:00', '2026-11-06 09:02:00'),
    (11, 12, 11, 5, 'Không cần quái vật xuất hiện liên tục mà tiếng gõ vẫn làm mình hồi hộp.', '2026-11-07 10:02:00', '2026-11-07 10:02:00'),
    (12, 13, 12, 3, 'Hai bờ đảo nhìn khác hẳn nhau, nhưng phải đi bộ khá nhiều.', '2026-11-07 09:02:00', '2026-11-07 09:02:00'),
    (13, 14, 13, 4, 'Cú nhảy từ cần cẩu cuối khá khó, bù lại có điểm lưu ngay trước đó.', '2026-11-08 10:02:00', '2026-11-08 10:02:00'),
    (14, 15, 14, 5, 'Có lần mình thắng nhờ giữ pin ở vòng đầu thay vì tăng tốc.', '2026-11-08 09:02:00', '2026-11-08 09:02:00'),
    (15, 16, 15, 3, 'Bộ bài nhỏ dễ học, mình mong có thêm sự kiện ở cuối mùa.', '2026-11-09 10:02:00', '2026-11-09 10:02:00'),
    (16, 17, 16, 4, 'Ván nào gió đổi hướng cũng phải tính lại đường chèo.', '2026-11-09 09:02:00', '2026-11-09 09:02:00'),
    (17, 18, 17, 5, 'Đoạn nhận ra hai giọng nói cách nhau nhiều năm làm mình bất ngờ.', '2026-11-10 10:02:00', '2026-11-10 10:02:00'),
    (18, 19, 18, 3, 'Bố trí thêm cầu neo giúp bến đỡ tắc hẳn vào giờ cao điểm.', '2026-11-10 09:02:00', '2026-11-10 09:02:00'),
    (19, 20, 19, 4, 'Súng móc kéo được thùng nước về xe, hay hơn mình tưởng.', '2026-11-11 10:02:00', '2026-11-11 10:02:00'),
    (20, 21, 20, 5, 'Chơi lại mới hiểu vì sao người chị giữ tấm vé tàu suốt mười năm.', '2026-11-11 09:02:00', '2026-11-11 09:02:00');

INSERT INTO GIOHANG (ma_gio_hang, ma_nguoi_dung, ma_tro_choi)
VALUES
    (1, 2, 7),
    (2, 3, 8),
    (3, 4, 9),
    (4, 5, 10),
    (5, 6, 11),
    (6, 7, 12),
    (7, 8, 13),
    (8, 9, 14),
    (9, 10, 15),
    (10, 11, 16),
    (11, 12, 17),
    (12, 13, 18),
    (13, 14, 19),
    (14, 15, 20),
    (15, 16, 21),
    (16, 17, 22),
    (17, 18, 23),
    (18, 19, 24),
    (19, 20, 2),
    (20, 21, 3);

COMMIT;
