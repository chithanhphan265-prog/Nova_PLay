package com.javaplay.controller;

import com.javaplay.entity.NguoiDung;
import com.javaplay.entity.TroChoi;
import com.javaplay.service.CuaHangService;
import jakarta.servlet.http.HttpSession;
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
    public String trangChu(HttpSession session, Model model) {
        List<TroChoi> tatCaGame = cuaHangService.layGameDangBanMoiNhat();
        TroChoi heroGame = tatCaGame.isEmpty() ? null : tatCaGame.get(0);
        List<TroChoi> gameNoiBat = tatCaGame.subList(0, Math.min(4, tatCaGame.size()));
        List<TroChoi> gameKhamPha = tatCaGame.size() > 4
                ? tatCaGame.subList(4, Math.min(8, tatCaGame.size()))
                : List.of();

        NguoiDung user = (session != null) ? (NguoiDung) session.getAttribute("currentUser") : null;

        model.addAttribute("heroGame", heroGame);
        model.addAttribute("gameNoiBat", gameNoiBat);
        model.addAttribute("gameKhamPha", gameKhamPha);
        model.addAttribute("theLoais", cuaHangService.layTatCaTheLoai());
        model.addAttribute("diemTrungBinhMap", cuaHangService.layBangDiemTrungBinh());
        model.addAttribute("soDanhGiaMap", cuaHangService.layBangSoDanhGia());
        model.addAttribute("ownedIds", cuaHangService.layIdGameDaSoHuu(user));
        model.addAttribute("cartIds", cuaHangService.layIdGameTrongGio(user));
        return "trang-chu";
    }
}
