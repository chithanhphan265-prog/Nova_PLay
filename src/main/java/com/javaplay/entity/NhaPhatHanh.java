package com.javaplay.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "NHAPHATHANH")
public class NhaPhatHanh {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_nha_phat_hanh")
    private Integer maNhaPhatHanh;

    @Column(name = "ten_nha_phat_hanh", nullable = false, unique = true, length = 150)
    private String tenNhaPhatHanh;

    @Column(name = "quoc_gia", length = 100)
    private String quocGia;

    @Column(name = "nam_thanh_lap")
    private Short namThanhLap;

    public Integer getMaNhaPhatHanh() {
        return maNhaPhatHanh;
    }

    public void setMaNhaPhatHanh(Integer maNhaPhatHanh) {
        this.maNhaPhatHanh = maNhaPhatHanh;
    }

    public String getTenNhaPhatHanh() {
        return tenNhaPhatHanh;
    }

    public void setTenNhaPhatHanh(String tenNhaPhatHanh) {
        this.tenNhaPhatHanh = tenNhaPhatHanh;
    }

    public String getQuocGia() {
        return quocGia;
    }

    public void setQuocGia(String quocGia) {
        this.quocGia = quocGia;
    }

    public Short getNamThanhLap() {
        return namThanhLap;
    }

    public void setNamThanhLap(Short namThanhLap) {
        this.namThanhLap = namThanhLap;
    }
}
