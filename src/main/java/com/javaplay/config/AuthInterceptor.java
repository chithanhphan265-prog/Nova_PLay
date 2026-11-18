package com.javaplay.config;

import com.javaplay.entity.NguoiDung;
import com.javaplay.repository.NguoiDungRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Optional;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final NguoiDungRepository nguoiDungRepository;

    public AuthInterceptor(NguoiDungRepository nguoiDungRepository) {
        this.nguoiDungRepository = nguoiDungRepository;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        NguoiDung currentUser = null;
        if (session != null) {
            NguoiDung sessionUser = (NguoiDung) session.getAttribute("currentUser");
            if (sessionUser != null && sessionUser.getMaNguoiDung() != null) {
                Optional<NguoiDung> dbUser = nguoiDungRepository.findById(sessionUser.getMaNguoiDung());
                if (dbUser.isPresent() && dbUser.get().dangHoatDong()) {
                    currentUser = dbUser.get();
                    session.setAttribute("currentUser", currentUser);
                } else {
                    session.invalidate();
                }
            }
        }

        if ("/".equals(uri)
                || "/trang-chu".equals(uri)
                || uri.startsWith("/cua-hang")
                || "/dang-nhap".equals(uri)
                || "/dang-ky".equals(uri)
                || "/dang-xuat".equals(uri)) {
            return true;
        }

        if (uri.startsWith("/admin")) {
            if (currentUser == null) {
                response.sendRedirect("/dang-nhap?required=true");
                return false;
            }
            if (!currentUser.laAdmin()) {
                response.sendRedirect("/trang-chu?accessDenied=true");
                return false;
            }
            return true;
        }

        if (uri.startsWith("/gio-hang")
                || uri.startsWith("/don-hang")
                || uri.startsWith("/thanh-toan")
                || uri.startsWith("/thu-vien")
                || uri.startsWith("/danh-gia")) {
            if (currentUser == null) {
                response.sendRedirect("/dang-nhap?required=true");
                return false;
            }
            if (currentUser.laAdmin()) {
                response.sendRedirect("/admin/tai-khoan?adminNoBuy=true");
                return false;
            }
            return true;
        }

        return true;
    }
}
