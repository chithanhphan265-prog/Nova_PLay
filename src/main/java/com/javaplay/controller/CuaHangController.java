package com.javaplay.controller;

import com.javaplay.entity.TroChoi;
import com.javaplay.service.CuaHangService;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
            Model model
    ) {
        Page<TroChoi> gamePage = cuaHangService.timKiemVaLocGame(q, maTheLoai, sort, page, 8);

        model.addAttribute("gamePage", gamePage);
        model.addAttribute("theLoais", cuaHangService.layTatCaTheLoai());
        model.addAttribute("q", q);
        model.addAttribute("maTheLoai", maTheLoai);
        model.addAttribute("sort", sort);
        model.addAttribute("currentPage", gamePage.getNumber());
        model.addAttribute("totalPages", gamePage.getTotalPages());
        return "cua-hang/danh-sach";
    }

    @GetMapping("/{id}")
    public String chiTietGame(@PathVariable("id") Integer id, Model model) {
        TroChoi game = cuaHangService.layChiTietGame(id);
        model.addAttribute("game", game);
        return "cua-hang/chi-tiet";
    }
}
