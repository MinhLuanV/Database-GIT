/* 1. Danh sách các sinh viên khoa "Công nghệ Thông tin" khóa 2002 - 2006 */
SELECT * FROM SinhVien WHERE maLop IN 
(SELECT L.Ma FROM KhoaHoc KH LEFT JOIN Lop L
ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau = 2002 AND KH.namKetThuc = 2006 AND L.maKhoa = 'CNTT')

/* 2. Cho biết các sinh viên (MSSV, họ tên, năm sinh) của các sinh viên học sớm hơn tuổi qui định  (theo tuổi qui định thì sinh viên đủ 18 tuổi khi bắt đầu khóa học)*/
SELECT S.Ma, S.hoTen, S.namSinh FROM SinhVien S
LEFT JOIN LOP L ON s.maLop = L.Ma
LEFT JOIN KhoaHoc KH ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau - S.namSinh < 18

/* 3. Cho iết sinh viên khoa CNTT, khóa 2002 - 2006 chưa học môn cấu trúc dữ liệu 1*/
SELECT S.* FROM SinhVien S
WHERE S.Ma NOT IN
(SELECT S.Ma FROM SinhVien S
LEFT JOIN LOP L ON S.maLop = L.Ma
LEFT JOIN KhoaHoc KH ON KH.Ma = L.maKhoaHoc
LEFT JOIN Khoa K ON K.ma = L.maKhoa
LEFT JOIN MonHoc MH ON MH.maKhoa = K.ma
WHERE KH.namBatDau = 2002 AND KH.namKetThuc = 2006 AND L.maKhoa = 'CNTT' AND MH.tenMonHoc = N'Cấu trúc dữ liệu 1')