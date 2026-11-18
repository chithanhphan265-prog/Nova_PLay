package com.javaplay.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "THELOAI")
public class TheLoai {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ma_the_loai")
    private Integer maTheLoai;

    @Column(name = "ten_the_loai", nullable = false, unique = true, length = 80)
    private String tenTheLoai;

    @Column(name = "mo_ta", length = 255)
    private String moTa;

    public Integer getMaTheLoai() {
        return maTheLoai;
    }

    public void setMaTheLoai(Integer maTheLoai) {
        this.maTheLoai = maTheLoai;
    }

    public String getTenTheLoai() {
        return tenTheLoai;
    }

    public void setTenTheLoai(String tenTheLoai) {
        this.tenTheLoai = tenTheLoai;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }
}
