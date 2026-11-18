package com.javaplay.repository;

import com.javaplay.entity.GioHang;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GioHangRepository extends JpaRepository<GioHang, Integer> {

    List<GioHang> findByNguoiDung_MaNguoiDung(Integer maNguoiDung);

    long countByNguoiDung_MaNguoiDung(Integer maNguoiDung);
}
