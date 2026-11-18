package com.javaplay.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "THUVIEN")
public class ThuVien {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_thu_vien")
    private Integer maThuVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_nguoi_dung", nullable = false)
    private NguoiDung nguoiDung;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "ma_tro_choi", nullable = false)
    private TroChoi troChoi;

    @Column(name = "ma_chi_tiet", nullable = false)
    private Integer maChiTiet;

    @Column(name = "ngay_so_huu", nullable = false)
    private LocalDateTime ngaySoHuu;

    public Integer getMaThuVien() {
        return maThuVien;
    }

    public void setMaThuVien(Integer maThuVien) {
        this.maThuVien = maThuVien;
    }

    public NguoiDung getNguoiDung() {
        return nguoiDung;
    }

    public void setNguoiDung(NguoiDung nguoiDung) {
        this.nguoiDung = nguoiDung;
    }

    public TroChoi getTroChoi() {
        return troChoi;
    }

    public void setTroChoi(TroChoi troChoi) {
        this.troChoi = troChoi;
    }

    public Integer getMaChiTiet() {
        return maChiTiet;
    }

    public void setMaChiTiet(Integer maChiTiet) {
        this.maChiTiet = maChiTiet;
    }

    public LocalDateTime getNgaySoHuu() {
        return ngaySoHuu;
    }

    public void setNgaySoHuu(LocalDateTime ngaySoHuu) {
        this.ngaySoHuu = ngaySoHuu;
    }
}
