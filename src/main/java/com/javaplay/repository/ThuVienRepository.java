package com.javaplay.repository;

import com.javaplay.entity.ThuVien;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ThuVienRepository extends JpaRepository<ThuVien, Integer> {

    List<ThuVien> findByNguoiDung_MaNguoiDung(Integer maNguoiDung);

    boolean existsByNguoiDung_MaNguoiDungAndTroChoi_MaTroChoi(Integer maNguoiDung, Integer maTroChoi);
}
