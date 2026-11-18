package com.javaplay.controller;

import com.javaplay.entity.NguoiDung;
import com.javaplay.service.TaiKhoanService;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class TaiKhoanController {

    private final TaiKhoanService taiKhoanService;

    public TaiKhoanController(TaiKhoanService taiKhoanService) {
        this.taiKhoanService = taiKhoanService;
    }

    @GetMapping("/dang-nhap")
    public String trangDangNhap(HttpSession session) {
        NguoiDung user = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;
        if (user != null) {
            return user.laAdmin() ? "redirect:/admin/tai-khoan" : "redirect:/trang-chu";
        }
        return "tai-khoan/dang-nhap";
    }

    @PostMapping("/dang-nhap")
    public String xuLyDangNhap(
            @RequestParam(value = "tenDangNhap", defaultValue = "") String tenDangNhap,
            @RequestParam(value = "matKhau", defaultValue = "") String matKhau,
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes
    ) {
        boolean coLoi = false;
        if (tenDangNhap.trim().isEmpty()) {
            model.addAttribute("loiTenDangNhap", "Vui lòng nhập tên đăng nhập.");
            coLoi = true;
        }
        if (matKhau.isEmpty()) {
            model.addAttribute("loiMatKhau", "Vui lòng nhập mật khẩu.");
            coLoi = true;
        }
        if (coLoi) {
            model.addAttribute("tenDangNhap", tenDangNhap);
            return "tai-khoan/dang-nhap";
        }

        try {
            NguoiDung user = taiKhoanService.dangNhap(tenDangNhap, matKhau);
            session.setAttribute("currentUser", user);
            redirectAttributes.addFlashAttribute("toastMessage", "Đăng nhập thành công. Xin chào " + user.getTenHienThi() + "!");
            return user.laAdmin() ? "redirect:/admin/tai-khoan" : "redirect:/trang-chu";
        } catch (IllegalArgumentException | IllegalStateException ex) {
            model.addAttribute("tenDangNhap", tenDangNhap);
            model.addAttribute("loiChung", ex.getMessage());
            return "tai-khoan/dang-nhap";
        }
    }

    @GetMapping("/dang-ky")
    public String trangDangKy(HttpSession session) {
        NguoiDung user = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;
        if (user != null) {
            return user.laAdmin() ? "redirect:/admin/tai-khoan" : "redirect:/trang-chu";
        }
        return "tai-khoan/dang-ky";
    }

    @PostMapping("/dang-ky")
    public String xuLyDangKy(
            @RequestParam(value = "tenHienThi", defaultValue = "") String tenHienThi,
            @RequestParam(value = "email", defaultValue = "") String email,
            @RequestParam(value = "tenDangNhap", defaultValue = "") String tenDangNhap,
            @RequestParam(value = "matKhau", defaultValue = "") String matKhau,
            @RequestParam(value = "xacNhanMatKhau", defaultValue = "") String xacNhanMatKhau,
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes
    ) {
        NguoiDung currentUser = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;
        if (currentUser != null) {
            return currentUser.laAdmin() ? "redirect:/admin/tai-khoan" : "redirect:/trang-chu";
        }

        Map<String, String> loi = taiKhoanService.dangKy(tenHienThi, email, tenDangNhap, matKhau, xacNhanMatKhau);
        if (!loi.isEmpty()) {
            model.addAllAttributes(loi);
            model.addAttribute("tenHienThi", tenHienThi.trim());
            model.addAttribute("email", email.trim());
            model.addAttribute("tenDangNhap", tenDangNhap.trim());
            return "tai-khoan/dang-ky";
        }

        redirectAttributes.addFlashAttribute("toastMessage", "Đăng ký tài khoản thành công! Hãy đăng nhập ngay.");
        return "redirect:/dang-nhap";
    }

    @GetMapping("/dang-xuat")
    public String dangXuat(HttpSession session, RedirectAttributes redirectAttributes) {
        if (session != null) {
            session.invalidate();
        }
        redirectAttributes.addFlashAttribute("toastMessage", "Đã đăng xuất khỏi hệ thống.");
        return "redirect:/trang-chu";
    }

    @GetMapping("/admin")
    public String adminMacDinh() {
        return "redirect:/admin/tai-khoan";
    }

    @GetMapping("/admin/tai-khoan")
    public String danhSachTaiKhoanAdmin(
            @RequestParam(value = "q", defaultValue = "") String q,
            @RequestParam(value = "vaiTro", defaultValue = "") String vaiTro,
            @RequestParam(value = "trangThai", defaultValue = "") String trangThai,
            @RequestParam(value = "page", defaultValue = "0") int page,
            Model model
    ) {
        Page<NguoiDung> userPage = taiKhoanService.timKiemTaiKhoan(q, vaiTro, trangThai, page, 8);
        model.addAttribute("userPage", userPage);
        model.addAttribute("q", q);
        model.addAttribute("vaiTro", vaiTro);
        model.addAttribute("trangThai", trangThai);
        model.addAttribute("currentPage", userPage.getNumber());
        model.addAttribute("totalPages", userPage.getTotalPages());
        return "admin/tai-khoan/danh-sach";
    }

    @PostMapping("/admin/tai-khoan/{id}/doi-trang-thai")
    public String doiTrangThaiTaiKhoan(
            @PathVariable("id") Integer id,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        NguoiDung adminDangNhap = (NguoiDung) session.getAttribute("currentUser");
        try {
            NguoiDung updated = taiKhoanService.doiTrangThai(id, adminDangNhap);
            String msg = "HOAT_DONG".equals(updated.getTrangThai())
                    ? "Đã mở khóa tài khoản '" + updated.getTenDangNhap() + "'."
                    : "Đã khóa tài khoản '" + updated.getTenDangNhap() + "'.";
            redirectAttributes.addFlashAttribute("toastMessage", msg);
        } catch (IllegalArgumentException | IllegalStateException ex) {
            redirectAttributes.addFlashAttribute("toastError", ex.getMessage());
        }
        return "redirect:/admin/tai-khoan";
    }
}
