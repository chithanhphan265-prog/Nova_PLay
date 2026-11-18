package com.javaplay.repository;

import com.javaplay.entity.TheLoai;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TheLoaiRepository extends JpaRepository<TheLoai, Integer> {
    List<TheLoai> findAllByOrderByTenTheLoaiAsc();
}
