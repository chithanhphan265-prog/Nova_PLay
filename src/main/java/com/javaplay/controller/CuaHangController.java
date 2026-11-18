package com.javaplay.controller;

import com.javaplay.entity.DanhGia;
import com.javaplay.entity.NguoiDung;
import com.javaplay.entity.TroChoi;
import com.javaplay.service.CuaHangService;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/cua-hang")
public class CuaHangController {

    private final CuaHangService cuaHangService;

    public CuaHangController(CuaHangService cuaHangService) {
        this.cuaHangService = cuaHangService;
    }

    @GetMapping
    public String danhSachGame(
            @RequestParam(value = "q", defaultValue = "") String q,
            @RequestParam(value = "maTheLoai", required = false) Integer maTheLoai,
            @RequestParam(value = "sort", defaultValue = "moi") String sort,
            @RequestParam(value = "page", defaultValue = "0") int page,
            HttpSession session,
            Model model
    ) {
        Page<TroChoi> gamePage = cuaHangService.timKiemVaLocGame(q, maTheLoai, sort, page, 8);
        NguoiDung user = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;

        model.addAttribute("gamePage", gamePage);
        model.addAttribute("theLoais", cuaHangService.layTatCaTheLoai());
        model.addAttribute("q", q);
        model.addAttribute("maTheLoai", maTheLoai);
        model.addAttribute("sort", sort);
        model.addAttribute("currentPage", gamePage.getNumber());
        model.addAttribute("totalPages", gamePage.getTotalPages());
        model.addAttribute("diemTrungBinhMap", cuaHangService.layBangDiemTrungBinh());
        model.addAttribute("soDanhGiaMap", cuaHangService.layBangSoDanhGia());
        model.addAttribute("ownedIds", cuaHangService.layIdGameDaSoHuu(user));
        model.addAttribute("cartIds", cuaHangService.layIdGameTrongGio(user));
        return "cua-hang/danh-sach";
    }

    @GetMapping("/{id}")
    public String chiTietGame(@PathVariable("id") Integer id, HttpSession session, Model model) {
        TroChoi game = cuaHangService.layChiTietGame(id);
        List<DanhGia> danhGias = cuaHangService.layDanhGiaTheoGame(id);

        Map<Integer, Double> avgMap = cuaHangService.layBangDiemTrungBinh();
        Map<Integer, Long> countMap = cuaHangService.layBangSoDanhGia();
        double diemTrungBinh = avgMap.getOrDefault(id, 0.0);
        long soDanhGia = countMap.getOrDefault(id, 0L);

        NguoiDung user = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;
        boolean daSoHuu = cuaHangService.layIdGameDaSoHuu(user).contains(id);
        boolean trongGio = cuaHangService.layIdGameTrongGio(user).contains(id);

        model.addAttribute("game", game);
        model.addAttribute("danhGias", danhGias);
        model.addAttribute("diemTrungBinh", diemTrungBinh);
        model.addAttribute("soDanhGia", soDanhGia);
        model.addAttribute("daSoHuu", daSoHuu);
        model.addAttribute("trongGio", trongGio);
        return "cua-hang/chi-tiet";
    }
}
