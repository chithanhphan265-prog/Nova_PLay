package com.javaplay.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "TROCHOI")
public class TroChoi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_tro_choi")
    private Integer maTroChoi;

    @Column(name = "tieu_de", nullable = false, unique = true, length = 200)
    private String tieuDe;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "ma_nha_phat_hanh", nullable = false)
    private NhaPhatHanh nhaPhatHanh;

    @Column(name = "ten_nha_phat_trien", nullable = false, length = 150)
    private String tenNhaPhatTrien;

    @Column(name = "mo_ta", nullable = false, columnDefinition = "TEXT")
    private String moTa;

    @Column(name = "hinh_anh", length = 255)
    private String hinhAnh;

    @Column(name = "ngay_phat_hanh", nullable = false)
    private LocalDate ngayPhatHanh;

    @Column(name = "gia_ban", nullable = false, precision = 12, scale = 0)
    private BigDecimal giaBan;

    @Column(name = "do_tuoi_khuyen_nghi", nullable = false)
    private Integer doTuoiKhuyenNghi = 0;

    @Column(name = "dung_luong_gb", nullable = false, precision = 8, scale = 2)
    private BigDecimal dungLuongGb;

    @Column(name = "cau_hinh_yeu_cau", nullable = false, columnDefinition = "TEXT")
    private String cauHinhYeuCau;

    @Column(name = "trang_thai", nullable = false, length = 20)
    private String trangThai = "DANG_BAN";

    @Column(name = "ngay_tao", updatable = false)
    private LocalDateTime ngayTao;

    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "TROCHOI_THELOAI",
            joinColumns = @JoinColumn(name = "ma_tro_choi"),
            inverseJoinColumns = @JoinColumn(name = "ma_the_loai")
    )
    private List<TheLoai> danhSachTheLoai = new ArrayList<>();

    @Transient
    public String getMauBia() {
        String[] colors = {
            "#5659db", "#ad3a93", "#bb8740", "#268cb1",
            "#9b4054", "#279daa", "#8474ba", "#7b7542",
            "#c06c3c", "#7454b8", "#318579", "#4365d4"
        };
        int idx = (maTroChoi != null ? Math.abs(maTroChoi - 1) : 0) % colors.length;
        return colors[idx];
    }

    public boolean dangBan() {
        return "DANG_BAN".equals(trangThai);
    }

    public Integer getMaTroChoi() {
        return maTroChoi;
    }

    public void setMaTroChoi(Integer maTroChoi) {
        this.maTroChoi = maTroChoi;
    }

    public String getTieuDe() {
        return tieuDe;
    }

    public void setTieuDe(String tieuDe) {
        this.tieuDe = tieuDe;
    }

    public NhaPhatHanh getNhaPhatHanh() {
        return nhaPhatHanh;
    }

    public void setNhaPhatHanh(NhaPhatHanh nhaPhatHanh) {
        this.nhaPhatHanh = nhaPhatHanh;
    }

    public String getTenNhaPhatTrien() {
        return tenNhaPhatTrien;
    }

    public void setTenNhaPhatTrien(String tenNhaPhatTrien) {
        this.tenNhaPhatTrien = tenNhaPhatTrien;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public LocalDate getNgayPhatHanh() {
        return ngayPhatHanh;
    }

    public void setNgayPhatHanh(LocalDate ngayPhatHanh) {
        this.ngayPhatHanh = ngayPhatHanh;
    }

    public BigDecimal getGiaBan() {
        return giaBan;
    }

    public void setGiaBan(BigDecimal giaBan) {
        this.giaBan = giaBan;
    }

    public Integer getDoTuoiKhuyenNghi() {
        return doTuoiKhuyenNghi;
    }

    public void setDoTuoiKhuyenNghi(Integer doTuoiKhuyenNghi) {
        this.doTuoiKhuyenNghi = doTuoiKhuyenNghi;
    }

    public BigDecimal getDungLuongGb() {
        return dungLuongGb;
    }

    public void setDungLuongGb(BigDecimal dungLuongGb) {
        this.dungLuongGb = dungLuongGb;
    }

    public String getCauHinhYeuCau() {
        return cauHinhYeuCau;
    }

    public void setCauHinhYeuCau(String cauHinhYeuCau) {
        this.cauHinhYeuCau = cauHinhYeuCau;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public LocalDateTime getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(LocalDateTime ngayTao) {
        this.ngayTao = ngayTao;
    }

    public LocalDateTime getNgayCapNhat() {
        return ngayCapNhat;
    }

    public void setNgayCapNhat(LocalDateTime ngayCapNhat) {
        this.ngayCapNhat = ngayCapNhat;
    }

    public List<TheLoai> getDanhSachTheLoai() {
        return danhSachTheLoai;
    }

    public void setDanhSachTheLoai(List<TheLoai> danhSachTheLoai) {
        this.danhSachTheLoai = danhSachTheLoai;
    }
}
