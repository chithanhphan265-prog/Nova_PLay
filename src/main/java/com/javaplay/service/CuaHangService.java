package com.javaplay.service;

import com.javaplay.entity.*;
import com.javaplay.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CuaHangService {

    private final TroChoiRepository troChoiRepository;
    private final TheLoaiRepository theLoaiRepository;
    private final DanhGiaRepository danhGiaRepository;
    private final ThuVienRepository thuVienRepository;
    private final GioHangRepository gioHangRepository;

    public CuaHangService(
            TroChoiRepository troChoiRepository,
            TheLoaiRepository theLoaiRepository,
            DanhGiaRepository danhGiaRepository,
            ThuVienRepository thuVienRepository,
            GioHangRepository gioHangRepository
    ) {
        this.troChoiRepository = troChoiRepository;
        this.theLoaiRepository = theLoaiRepository;
        this.danhGiaRepository = danhGiaRepository;
        this.thuVienRepository = thuVienRepository;
        this.gioHangRepository = gioHangRepository;
    }

    public List<TheLoai> layTatCaTheLoai() {
        return theLoaiRepository.findAllByOrderByTenTheLoaiAsc();
    }

    public List<TroChoi> layGameDangBanMoiNhat() {
        return troChoiRepository.findByTrangThaiOrderByMaTroChoiDesc("DANG_BAN");
    }

    public Page<TroChoi> timKiemVaLocGame(String tuKhoa, Integer maTheLoai, String sort, int page, int size) {
        String key = tuKhoa != null ? tuKhoa.trim() : "";
        List<TroChoi> danhSach = troChoiRepository.timGameDangBan(key, maTheLoai);

        Map<Integer, Double> diemTrungBinhMap = layBangDiemTrungBinh();
        Map<Integer, Long> soDanhGiaMap = layBangSoDanhGia();

        if ("giaTang".equals(sort)) {
            danhSach.sort(Comparator.comparing(TroChoi::getGiaBan));
        } else if ("giaGiam".equals(sort)) {
            danhSach.sort(Comparator.comparing(TroChoi::getGiaBan).reversed());
        } else if ("danhGia".equals(sort)) {
            danhSach.sort((a, b) -> {
                double avgA = diemTrungBinhMap.getOrDefault(a.getMaTroChoi(), 0.0);
                double avgB = diemTrungBinhMap.getOrDefault(b.getMaTroChoi(), 0.0);
                int cmp = Double.compare(avgB, avgA);
                if (cmp != 0) return cmp;
                long countA = soDanhGiaMap.getOrDefault(a.getMaTroChoi(), 0L);
                long countB = soDanhGiaMap.getOrDefault(b.getMaTroChoi(), 0L);
                return Long.compare(countB, countA);
            });
        } else {
            danhSach.sort(Comparator.comparing(TroChoi::getMaTroChoi).reversed());
        }

        int pageIndex = Math.max(page, 0);
        int start = pageIndex * size;
        if (start >= danhSach.size()) {
            start = 0;
            pageIndex = 0;
        }
        int end = Math.min(start + size, danhSach.size());
        List<TroChoi> subList = danhSach.subList(start, end);

        return new PageImpl<>(subList, PageRequest.of(pageIndex, size), danhSach.size());
    }

    public TroChoi layChiTietGame(Integer maTroChoi) {
        return troChoiRepository.findById(maTroChoi)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy trò chơi #" + maTroChoi));
    }

    public List<DanhGia> layDanhGiaTheoGame(Integer maTroChoi) {
        return danhGiaRepository.findByTroChoi_MaTroChoiOrderByNgayDanhGiaDesc(maTroChoi);
    }

    public Map<Integer, Double> layBangDiemTrungBinh() {
        Map<Integer, Double> map = new HashMap<>();
        List<Object[]> rows = danhGiaRepository.thongKeSaoTheoGame();
        for (Object[] row : rows) {
            Integer gameId = ((Number) row[0]).intValue();
            Double avg = row[1] != null ? ((Number) row[1]).doubleValue() : 0.0;
            map.put(gameId, avg);
        }
        return map;
    }

    public Map<Integer, Long> layBangSoDanhGia() {
        Map<Integer, Long> map = new HashMap<>();
        List<Object[]> rows = danhGiaRepository.thongKeSaoTheoGame();
        for (Object[] row : rows) {
            Integer gameId = ((Number) row[0]).intValue();
            Long count = row[2] != null ? ((Number) row[2]).longValue() : 0L;
            map.put(gameId, count);
        }
        return map;
    }

    public Set<Integer> layIdGameDaSoHuu(NguoiDung user) {
        Set<Integer> ids = new HashSet<>();
        if (user == null || user.laAdmin()) {
            return ids;
        }
        List<ThuVien> list = thuVienRepository.findByNguoiDung_MaNguoiDung(user.getMaNguoiDung());
        for (ThuVien tv : list) {
            ids.add(tv.getTroChoi().getMaTroChoi());
        }
        return ids;
    }

    public Set<Integer> layIdGameTrongGio(NguoiDung user) {
        Set<Integer> ids = new HashSet<>();
        if (user == null || user.laAdmin()) {
            return ids;
        }
        List<GioHang> list = gioHangRepository.findByNguoiDung_MaNguoiDung(user.getMaNguoiDung());
        for (GioHang gh : list) {
            ids.add(gh.getTroChoi().getMaTroChoi());
        }
        return ids;
    }
}
