package com.javaplay.service;

import com.javaplay.entity.TheLoai;
import com.javaplay.entity.TroChoi;
import com.javaplay.repository.TheLoaiRepository;
import com.javaplay.repository.TroChoiRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
public class CuaHangService {

    private final TroChoiRepository troChoiRepository;
    private final TheLoaiRepository theLoaiRepository;

    public CuaHangService(
            TroChoiRepository troChoiRepository,
            TheLoaiRepository theLoaiRepository
    ) {
        this.troChoiRepository = troChoiRepository;
        this.theLoaiRepository = theLoaiRepository;
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

        if ("giaTang".equals(sort)) {
            danhSach.sort(Comparator.comparing(TroChoi::getGiaBan));
        } else if ("giaGiam".equals(sort)) {
            danhSach.sort(Comparator.comparing(TroChoi::getGiaBan).reversed());
        } else if ("tenAZ".equals(sort)) {
            danhSach.sort(Comparator.comparing(TroChoi::getTieuDe, String.CASE_INSENSITIVE_ORDER));
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
}
