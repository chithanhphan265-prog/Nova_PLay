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
}
