package com.javaplay.config;

import com.javaplay.entity.NguoiDung;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@ControllerAdvice
public class GlobalModelAdvice {

    @ModelAttribute("currentUser")
    public NguoiDung layNguoiDungHienTai(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (NguoiDung) session.getAttribute("currentUser");
    }

    @ModelAttribute("cartCount")
    public long laySoLuongGioHang() {
        return 0L;
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public String xuLyKhongTimThay(NoResourceFoundException ex, HttpServletRequest request, Model model) {
        model.addAttribute("errorCode", "404");
        model.addAttribute("errorTitle", "Không tìm thấy trang");
        model.addAttribute("errorDetail", "Đường dẫn '" + request.getRequestURI() + "' chưa tồn tại hoặc đang được thành viên khác phát triển.");
        return "error";
    }

    @ExceptionHandler({IllegalArgumentException.class, IllegalStateException.class})
    public String xuLyLoiNghiepVu(RuntimeException ex, Model model) {
        model.addAttribute("errorCode", "400");
        model.addAttribute("errorTitle", "Thao tác không hợp lệ");
        model.addAttribute("errorDetail", ex.getMessage());
        return "error";
    }

    @ExceptionHandler(Exception.class)
    public String xuLyLoiChung(Exception ex, Model model) {
        model.addAttribute("errorCode", "500");
        model.addAttribute("errorTitle", "Sự cố hệ thống");
        model.addAttribute("errorDetail", ex.getMessage() != null ? ex.getMessage() : "Đã xảy ra lỗi ngoài ý muốn.");
        return "error";
    }
}
