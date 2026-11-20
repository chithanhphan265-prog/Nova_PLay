package com.javaplay.service;

import com.javaplay.entity.NguoiDung;
import com.javaplay.repository.NguoiDungRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class TaiKhoanService {

    private final NguoiDungRepository nguoiDungRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final Object registerLock = new Object();

    public TaiKhoanService(NguoiDungRepository nguoiDungRepository) {
        this.nguoiDungRepository = nguoiDungRepository;
    }

    public NguoiDung dangNhap(String tenDangNhap, String matKhau) {
        String username = tenDangNhap != null ? tenDangNhap.trim() : "";
        Optional<NguoiDung> opt = nguoiDungRepository.findByTenDangNhap(username);
        if (opt.isEmpty()) {
            opt = nguoiDungRepository.findByEmail(username);
        }
        if (opt.isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập hoặc mật khẩu không đúng.");
        }

        NguoiDung user = opt.get();
        if (!passwordEncoder.matches(matKhau, user.getMatKhauHash())) {
            throw new IllegalArgumentException("Tên đăng nhập hoặc mật khẩu không đúng.");
        }
        if (!user.dangHoatDong()) {
            throw new IllegalStateException("Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.");
        }
        return user;
    }

    public Map<String, String> dangKy(
            String tenHienThi,
            String email,
            String tenDangNhap,
            String matKhau,
            String xacNhanMatKhau
    ) {
        Map<String, String> loi = new LinkedHashMap<>();

        String cleanName = tenHienThi != null ? tenHienThi.trim() : "";
        String cleanEmail = email != null ? email.trim().toLowerCase() : "";
        String cleanUsername = tenDangNhap != null ? tenDangNhap.trim() : "";
        String rawPassword = matKhau != null ? matKhau : "";
        String rawConfirm = xacNhanMatKhau != null ? xacNhanMatKhau : "";

        if (cleanName.isEmpty()) {
            loi.put("loiTenHienThi", "Vui lòng nhập tên hiển thị.");
        } else if (cleanName.length() > 100) {
            loi.put("loiTenHienThi", "Tên hiển thị tối đa 100 ký tự.");
        }

        if (!cleanEmail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            loi.put("loiEmail", "Email chưa đúng định dạng.");
        } else if (cleanEmail.length() > 100) {
            loi.put("loiEmail", "Email tối đa 100 ký tự.");
        }

        if (cleanUsername.length() < 3 || cleanUsername.length() > 50) {
            loi.put("loiTenDangNhap", "Tên đăng nhập phải từ 3 đến 50 ký tự.");
        } else if (cleanUsername.matches(".*\\s.*")) {
            loi.put("loiTenDangNhap", "Tên đăng nhập không được chứa khoảng trắng.");
        }

        if (rawPassword.length() < 6) {
            loi.put("loiMatKhau", "Mật khẩu phải có ít nhất 6 ký tự.");
        } else if (!rawPassword.equals(rawConfirm)) {
            loi.put("loiXacNhanMatKhau", "Mật khẩu xác nhận không khớp.");
        }

        synchronized (registerLock) {
            if (!loi.containsKey("loiEmail") && nguoiDungRepository.existsByEmail(cleanEmail)) {
                loi.put("loiEmail", "Email đã được sử dụng.");
            }
            if (!loi.containsKey("loiTenDangNhap") && nguoiDungRepository.existsByTenDangNhap(cleanUsername)) {
                loi.put("loiTenDangNhap", "Tên đăng nhập đã tồn tại.");
            }
            if (!loi.isEmpty()) {
                return loi;
            }

            try {
                NguoiDung user = new NguoiDung();
                user.setTenHienThi(cleanName);
                user.setEmail(cleanEmail);
                user.setTenDangNhap(cleanUsername);
                user.setMatKhauHash(passwordEncoder.encode(rawPassword));
                user.setVaiTro("ROLE_USER");
                user.setTrangThai("HOAT_DONG");
                nguoiDungRepository.saveAndFlush(user);
            } catch (DataIntegrityViolationException ex) {
                if (nguoiDungRepository.existsByEmail(cleanEmail)) {
                    loi.put("loiEmail", "Email đã được sử dụng.");
                }
                if (nguoiDungRepository.existsByTenDangNhap(cleanUsername)) {
                    loi.put("loiTenDangNhap", "Tên đăng nhập đã tồn tại.");
                }
                if (loi.isEmpty()) {
                    loi.put("loiChung", "Không thể tạo tài khoản lúc này. Vui lòng thử lại.");
                }
            }
        }

        return loi;
    }

    public Optional<NguoiDung> timTheoId(Integer id) {
        return nguoiDungRepository.findById(id);
    }

    public Page<NguoiDung> timKiemTaiKhoan(String tuKhoa, String vaiTro, String trangThai, int page, int size) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), size, Sort.by("maNguoiDung").ascending());
        String key = tuKhoa != null ? tuKhoa.trim() : "";
        String role = vaiTro != null ? vaiTro.trim() : "";
        String status = trangThai != null ? trangThai.trim() : "";
        return nguoiDungRepository.timKiemTaiKhoan(key, role, status, pageable);
    }

    @Transactional
    public NguoiDung doiTrangThai(Integer maNguoiDung, NguoiDung adminDangNhap) {
        NguoiDung user = nguoiDungRepository.findById(maNguoiDung)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản #" + maNguoiDung));

        if (user.laAdmin()) {
            throw new IllegalStateException("Không thể khóa tài khoản quản trị viên.");
        }
        if (adminDangNhap != null && adminDangNhap.getMaNguoiDung().equals(maNguoiDung)) {
            throw new IllegalStateException("Không thể tự khóa tài khoản đang đăng nhập.");
        }

        if ("HOAT_DONG".equals(user.getTrangThai())) {
            user.setTrangThai("BI_KHOA");
        } else {
            user.setTrangThai("HOAT_DONG");
        }
        return nguoiDungRepository.saveAndFlush(user);
    }
}
