package com.javaplay.repository;

import com.javaplay.entity.DanhGia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface DanhGiaRepository extends JpaRepository<DanhGia, Integer> {

    List<DanhGia> findByTroChoi_MaTroChoiOrderByNgayDanhGiaDesc(Integer maTroChoi);

    @Query("SELECT d.troChoi.maTroChoi, AVG(d.soSao), COUNT(d) FROM DanhGia d GROUP BY d.troChoi.maTroChoi")
    List<Object[]> thongKeSaoTheoGame();
}
