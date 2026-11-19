package com.javaplay;

import com.javaplay.entity.NguoiDung;
import com.javaplay.service.TaiKhoanService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@Transactional
class NovaPlayApplicationTests {

        @Autowired
        private WebApplicationContext context;

        @Autowired
        private TaiKhoanService taiKhoanService;

        private MockMvc mockMvc;

        @BeforeEach
        void setup() {
                mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
        }

        @Test
        void kiemTraChucNangThanhVien2() throws Exception {
                mockMvc.perform(get("/")).andExpect(status().isOk());
                mockMvc.perform(get("/trang-chu")).andExpect(status().isOk());
                mockMvc.perform(get("/cua-hang")).andExpect(status().isOk());
                mockMvc.perform(get("/cua-hang?q=Shadow&maTheLoai=1&sort=danhGia&page=0")).andExpect(status().isOk());
                mockMvc.perform(get("/cua-hang/1")).andExpect(status().isOk());
                mockMvc.perform(get("/dang-nhap")).andExpect(status().isOk());
                mockMvc.perform(get("/dang-ky")).andExpect(status().isOk());

                mockMvc.perform(get("/admin/tai-khoan"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/dang-nhap?required=true"));
                mockMvc.perform(get("/gio-hang"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/dang-nhap?required=true"));

                mockMvc.perform(post("/dang-nhap")
                                .param("tenDangNhap", "hoaian")
                                .param("matKhau", "123456"))
                                .andExpect(status().isOk())
                                .andExpect(model().attributeExists("loiChung"));

                mockMvc.perform(post("/dang-nhap")
                                .param("tenDangNhap", "admin")
                                .param("matKhau", "123456"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/admin/tai-khoan"));

                mockMvc.perform(post("/dang-nhap")
                                .param("tenDangNhap", "khach")
                                .param("matKhau", "123456"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/trang-chu"));

                MockHttpSession userSession = new MockHttpSession();
                NguoiDung khach = taiKhoanService.dangNhap("khach", "123456");
                userSession.setAttribute("currentUser", khach);

                mockMvc.perform(get("/admin/tai-khoan").session(userSession))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/trang-chu?accessDenied=true"));

                MockHttpSession adminSession = new MockHttpSession();
                NguoiDung admin = taiKhoanService.dangNhap("admin", "123456");
                adminSession.setAttribute("currentUser", admin);

                mockMvc.perform(get("/gio-hang").session(adminSession))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/admin/tai-khoan?adminNoBuy=true"));

                mockMvc.perform(get("/admin/tai-khoan").session(adminSession))
                                .andExpect(status().isOk());

                String newUsername = "tv2_test_" + System.currentTimeMillis();
                mockMvc.perform(post("/dang-ky")
                                .param("tenHienThi", "Thành Viên Test")
                                .param("email", newUsername + "@example.test")
                                .param("tenDangNhap", newUsername)
                                .param("matKhau", "abcdef")
                                .param("xacNhanMatKhau", "abcdef"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/dang-nhap"));

                NguoiDung registered = taiKhoanService.dangNhap(newUsername, "abcdef");
                assertEquals("ROLE_USER", registered.getVaiTro());
                assertEquals("HOAT_DONG", registered.getTrangThai());

                mockMvc.perform(post("/dang-ky")
                                .param("tenHienThi", "Trùng Lặp")
                                .param("email", newUsername + "@example.test")
                                .param("tenDangNhap", newUsername)
                                .param("matKhau", "abcdef")
                                .param("xacNhanMatKhau", "abcdef"))
                                .andExpect(status().isOk())
                                .andExpect(view().name("tai-khoan/dang-ky"))
                                .andExpect(model().attributeExists("loiEmail", "loiTenDangNhap"))
                                .andExpect(model().attributeDoesNotExist("loiChung"));

                mockMvc.perform(post("/dang-ky")
                                .param("tenHienThi", "User Space")
                                .param("email", "khonghop")
                                .param("tenDangNhap", "ab cde")
                                .param("matKhau", "123")
                                .param("xacNhanMatKhau", "456"))
                                .andExpect(status().isOk())
                                .andExpect(view().name("tai-khoan/dang-ky"))
                                .andExpect(model().attributeExists("loiEmail", "loiTenDangNhap", "loiMatKhau"))
                                .andExpect(model().attributeDoesNotExist("loiChung"));

                mockMvc.perform(post("/dang-ky").session(userSession)
                                .param("tenHienThi", "Đã Login")
                                .param("email", "dalogin@example.test")
                                .param("tenDangNhap", "dalogin_" + System.currentTimeMillis())
                                .param("matKhau", "abcdef")
                                .param("xacNhanMatKhau", "abcdef"))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/trang-chu"));

                mockMvc.perform(post("/admin/tai-khoan/" + registered.getMaNguoiDung() + "/doi-trang-thai")
                                .session(adminSession))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/admin/tai-khoan"));

                NguoiDung locked = taiKhoanService.timTheoId(registered.getMaNguoiDung()).orElseThrow();
                assertEquals("BI_KHOA", locked.getTrangThai());

                mockMvc.perform(post("/admin/tai-khoan/" + registered.getMaNguoiDung() + "/doi-trang-thai")
                                .session(adminSession))
                                .andExpect(status().is3xxRedirection())
                                .andExpect(redirectedUrl("/admin/tai-khoan"));

                NguoiDung unlocked = taiKhoanService.timTheoId(registered.getMaNguoiDung()).orElseThrow();
                assertEquals("HOAT_DONG", unlocked.getTrangThai());
        }
}
