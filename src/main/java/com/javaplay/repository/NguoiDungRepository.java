package com.javaplay.repository;

import com.javaplay.entity.NguoiDung;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface NguoiDungRepository extends JpaRepository<NguoiDung, Integer> {

    Optional<NguoiDung> findByTenDangNhap(String tenDangNhap);

    Optional<NguoiDung> findByEmail(String email);

    boolean existsByTenDangNhap(String tenDangNhap);

    boolean existsByEmail(String email);

    @Query("""
            SELECT u FROM NguoiDung u
            WHERE (:tuKhoa = ''
                   OR LOWER(u.tenDangNhap) LIKE LOWER(CONCAT('%', :tuKhoa, '%'))
                   OR LOWER(u.email) LIKE LOWER(CONCAT('%', :tuKhoa, '%'))
                   OR LOWER(u.tenHienThi) LIKE LOWER(CONCAT('%', :tuKhoa, '%')))
              AND (:vaiTro = '' OR u.vaiTro = :vaiTro)
              AND (:trangThai = '' OR u.trangThai = :trangThai)
            """)
    Page<NguoiDung> timKiemTaiKhoan(
            @Param("tuKhoa") String tuKhoa,
            @Param("vaiTro") String vaiTro,
            @Param("trangThai") String trangThai,
            Pageable pageable
    );
}
