package com.javaplay.repository;

import com.javaplay.entity.TroChoi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TroChoiRepository extends JpaRepository<TroChoi, Integer> {

    List<TroChoi> findByTrangThaiOrderByMaTroChoiDesc(String trangThai);

    @Query("""
            SELECT DISTINCT t FROM TroChoi t
            LEFT JOIN t.danhSachTheLoai tl
            WHERE t.trangThai = 'DANG_BAN'
              AND (:tuKhoa = '' OR LOWER(t.tieuDe) LIKE LOWER(CONCAT('%', :tuKhoa, '%')))
              AND (:maTheLoai IS NULL OR tl.maTheLoai = :maTheLoai)
            """)
    List<TroChoi> timGameDangBan(
            @Param("tuKhoa") String tuKhoa,
            @Param("maTheLoai") Integer maTheLoai
    );
}
