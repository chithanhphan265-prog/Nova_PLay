package com.javaplay.controller;

import com.javaplay.entity.TroChoi;
import com.javaplay.service.CuaHangService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class TrangChuController {

    private final CuaHangService cuaHangService;

    public TrangChuController(CuaHangService cuaHangService) {
        this.cuaHangService = cuaHangService;
    }

    @GetMapping({"/", "/trang-chu"})
    public String trangChu(Model model) {
        List<TroChoi> tatCaGame = cuaHangService.layGameDangBanMoiNhat();
        TroChoi heroGame = tatCaGame.isEmpty() ? null : tatCaGame.get(0);
        List<TroChoi> gameNoiBat = tatCaGame.subList(0, Math.min(4, tatCaGame.size()));
        List<TroChoi> gameKhamPha = tatCaGame.size() > 4
                ? tatCaGame.subList(4, tatCaGame.size())
                : List.of();

        model.addAttribute("heroGame", heroGame);
        model.addAttribute("gameNoiBat", gameNoiBat);
        model.addAttribute("gameKhamPha", gameKhamPha);
        model.addAttribute("theLoais", cuaHangService.layTatCaTheLoai());
        return "trang-chu";
    }
}
