-- TRUY VẤN
--1. DANH SÁCH CÁC SINH VIÊN KHOA "CÔNG NGHỆ THÔNG TIN" KHÓA 2002 - 2006.
SELECT * FROM SinhVien WHERE maLop IN 
(SELECT L.Ma FROM KhoaHoc KH LEFT JOIN Lop L
ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau = 2002 AND KH.namKetThuc = 2006 AND L.maKhoa = 'CNTT')

--2. CHO BIẾT CÁC SINH VIÊN (MSSV, HỌ TÊN, NĂM SINH) CỦA CÁC SINH VIÊN HỌC SỚM HƠN TUỔI QUI ĐỊNH
--THEO TUỔI QUI ĐỊNH THÌ SINH VIÊN ĐỦ 18 TUỔI KHI BẮT ĐẦU KHÓA HỌC
SELECT S.Ma, S.hoTen, S.namSinh FROM SinhVien S
LEFT JOIN LOP L ON s.maLop = L.Ma
LEFT JOIN KhoaHoc KH ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau - S.namSinh < 18

--3. CHO BIẾT SINH VIÊN KHOA CNTT, KHÓA 2002 - 2006 CHƯA HỌC MÔN CẤU TRÚC DỮ LIỆU 1
SELECT S.* FROM SinhVien S
LEFT JOIN LOP L ON S.maLop = L.Ma
LEFT JOIN KhoaHoc KH ON KH.Ma = L.maKhoaHoc
LEFT JOIN Khoa K ON K.ma = L.maKhoa
WHERE KH.namBatDau = 2002 AND KH.namKetThuc = 2006 AND L.maKhoa = 'CNTT'
AND S.Ma NOT IN
(SELECT KQ.maSinhVien FROM KetQua KQ
LEFT JOIN MonHoc MH ON KQ.maMonHoc = MH.Ma
WHERE MH.tenMonHoc = N'Cấu trúc dữ liệu 1')

--4. CHO BIẾT SINH VIÊN THI KHÔNG ĐẬU (ĐIỂM < 5) MÔN CẤU TRÚC DỮ LIỆU 1 NHƯNG CHƯA THI LẠI
SELECT SV.* FROM SinhVien SV
LEFT JOIN KetQua KQ
ON SV.Ma = KQ.maSinhVien
LEFT JOIN MonHoc MH
ON KQ.maMonHoc = MH.Ma
WHERE MH.tenMonHoc = N'Cấu trúc dữ liệu 1' AND KQ.diem < 5 AND KQ.lanThi = 1 AND NOT EXISTS
(SELECT * FROM KetQua KQ2
WHERE KQ2.maSinhVien = KQ.maSinhVien
AND	KQ2.maMonHoc = KQ.maMonHoc
AND KQ2.lanThi = 2)

--5. VỚI MỖI LỚP THUỘC KHOA CNTT, CHO BIẾT MÃ LỚP, MÃ KHÓA HỌC, TÊN CHƯƠNG TRÌNH VÀ SỐ SINH VIÊN THUỘC LỚP ĐÓ

--6. CHO BIẾT ĐIỂM TRUNG BÌNH CỦA SINH VIÊN CÓ MÃ SỐ 0212003 (ĐIỂM TRUNG BÌNH CHỈ TÍNH TRÊN LẦN THI SAU CÙNG CỦA SINH VIÊN)

-- FUNCTION
--1. VỚI 1 MÃ SINH VIÊN VÀ 1 MÃ KHOA, KIỂM TRA XEM SINH VIÊN CÓ THUỘC KHOA NÀY KHÔNG (TRẢ VỀ ĐÚNG HAY SAI)

--2.  TÍNH ĐIỂM THI SAU CÙNG CỦA MỘT SINH VIÊN TRONG MỘT MÔN HỌC CỤ THỂ

--3. TÍNH ĐIỂM TRUNG BÌNH CỦA MỘT SINH VIÊN (CHÚ Ý: ĐIỂM TRUNG BÌNH ĐƯỢC TÍNH DỰA TRÊN LẦN THI SAU CÙNG)
-- SỬA DỤNG FUNCTION CÂU 2 ĐÃ VIẾT

--4. NHẬP VÀO 1 SINH VIÊN VÀ 1 MÔN HỌC, TRẢ VỀ CÁC ĐIỂM THI CỦA SINH VIÊN NÀY TRONG CÁC LẦN THI CỦA MÔN HỌC ĐÓ.

--5. NHẬP VÀO 1 SINH VIÊN, TRẢ VỀ DANH SÁCH CÁC MÔN HỌC MÀ SINH VIÊN NÀY PHẢI HỌC.

-- STORE PROCEDURE
--1. IN DANH SÁCH CÁC SINH VIÊN CỦA 1 LỚP HỌC

--2. NHẬP VÀO 2 SINH VIÊN, 1 MÔN HỌC, 
-- TÌM XEM SINH VIÊN NÀO CÓ ĐIỂM THI MÔN HỌC ĐÓ LẦN ĐẦU TIÊN CAO HƠN

--3. NHẬP VÀO 1 MÔN HỌC VÀ 1 MÃ SINH VIÊN,
-- KIỂM TRA XEM SINH VIÊN CÓ ĐẬU MÔN NÀY TRONG LẦN THI ĐẦU TIÊN KHÔNG 
-- NẾU ĐẬU THÌ XUẤT RA LÀ "ĐẬU", KHÔNG THÌ XUẤT RA "KHÔNG ĐẬU"

--4. NHẬP VÀO 1 KHOA
-- IN DANH SÁCH CÁC SINH VIÊN (MÃ SINH VIÊN, HỌ TÊN, NGÀY SINH) THUỘC KHOA NÀY

--5. NHẬP VÀO 1 SINH VIÊN VÀ 1 MÔN HỌC, IN ĐIỂM THI CỦA SINH VIÊN NÀY CỦA CÁC LẦN THI MÔN HỌC ĐÓ
-- VÍ DỤ: LẦN 1: 10; LẦN 2: 9

--6. NHẬP VÀO 1 SINH VIÊN, IN RA CÁC MÔN HỌC MÀ SINH VIÊN NÀY PHẢI HỌC

--7. NHẬP VÀO 1 MÔN HỌC
-- IN DANH SÁCH CÁC SINH VIÊN ĐẬU MÔN HỌC NÀY TRONG LẦN THI ĐẦU TIÊN

--8. IN ĐIỂM CÁC MÔN HỌC CỦA SINH VIÊN CÓ MÃ SỐ SINH VIÊN MASINHVIEN ĐƯỢC NHẬP VÀO
-- CHÚ Ý: ĐIỂM CỦA MÔN HỌC LÀ ĐIỂM THI CỦA LẦN SAU CÙNG
--	8.1 CHỈ IN CÁC MÔN ĐÃ CÓ ĐIỂM
--	8.2 CÁC MÔN CHƯA CÓ ĐIỂM THÌ GHI ĐIỂM LÀ NULL
--	8.3 CÁC MÔN CHƯA CÓ ĐIỂM THÌ GHI ĐIỂM LÀ <CHƯA CÓ ĐIỂM>

--THÊM MỘT QUAN HỆ
--XepLoai(maSinhVien, diemTrungBinh, ketQua, hocLuc)

--9. ĐƯA DỮ LIỆU VÀO BẢNG XEPLOAI. SỬ DỤNG FUNCTION CÂU 3 ĐÃ VIẾT Ở TRÊN
-- QUI ĐỊNH: KETQUA CỦA SINH VIÊN LÀ "ĐẠT" NẾU DIEMTRUNGBINH (CHỈ TÍNH CÁC MÔN ĐÃ CÓ ĐIỂM)
-- CỦA SINH VIÊN ĐÓ LỚN HƠN HOẶC BẰNG 5 VÀ KHÔNG QUÁ 2 MÔN DƯỚI 4 ĐIỂM, NGƯỢC LẠI THÌ KẾT QUẢ LÀ "KHÔNG ĐẠT"
-- ĐỐI VỚI NHỮNG SINH VIÊN CÓ KETQUA LÀ "ĐẠT" THÌ HOCLUC ĐƯỢC XẾP LOẠI NHƯ SAU:
-- DIEMTRUNGBINH >= 8 LÀ HOCLUC "GIỎI"
-- 7 <= DIEMTRUNGBINH < 8 LÀ HOCLUC "KHÁ"
-- CÒN LẠI LÀ HOCLUC "TRUNG BÌNH"

--10. VỚI CÁC SINH VIÊN THAM GIA ĐẦY ĐỦ CÁC MÔN HỌC CỦA KHOA, CHƯƠNG TRÌNH MÀ SINH VIÊN ĐANG THEO HỌC, HÃY IN RA
-- ĐIỂM TRUNG BÌNH CỦA CÁC SINH VIÊN NÀY
-- CHÚ Ý: ĐIỂM TRUNG BÌNH ĐƯỢC TÍNH DỰA VÀO LẦN THI SAU CÙNG
-- SỬ DỤNG FUNCTION CÂU 3 ĐÃ VIẾT Ở TRÊN

-- CÀI ĐẶT CÁC RÀNG BUỘC TOÀN VẸN (CHECK CONSTRAIN, UNIQUE, CONSTRAIN, RULE HOẶC TRIGGER)
-- MIỀN GIÁ TRỊ
--1. ChuongTrinh.ma CHỈ CÓ THỂ LÀ "CQ" HOẶC "CD" HOẶC "TC"

--2. CHỈ CÓ 2 HỌC KỲ LÀ "HK1" VÀ "HK2"

--3. SỐ TIẾT LÝ THUYẾT (GiangKhoa.soTietLyThuyet) TỐI ĐA LÀ 120

--4. SỐ TIẾT THỰC HÀNH (GiangKhoa.soTietThucHanh) TỐI ĐA LÀ 120

--5. SỐ TÍN CHỈ (GiangKhoa.soTinChi) CỦA MỘT MÔN HỌC TỐI ĐA LÀ 6

--6. ĐIỂM THI (KetQua.diem) ĐƯỢC CHẤM THEO THANG ĐIỂM 10 VÀ CHÍNH XÁC ĐẾN 0.5
--	LÀM BẰNG 2 CÁCH: KIỂM TRA VÀ BÁO LỖI NẾU KHÔNG ĐÚNG QUI ĐỊNH
--	 TỰ ĐỘNG LÀM TRÒN NẾU KHÔNG ĐÚNG QUI ĐỊNH VỀ ĐỘ CHÍNH XÁC

-- LIÊN THUỘC TÍNH TRÊN MỘT QUAN HỆ
--1. NĂM KẾT THÚC KHÓA HỌC PHẢI LỚN HƠN HOẶC BẰNG NĂM BẮT ĐẦU

--2. SỐ TIẾT LÝ THUYẾT CỦA MỖI GIẢNG KHOA KHÓA KHÔNG NHỎ HƠN SỐ TIẾT THỰC HÀNH

-- LIÊN BỘ TRÊN MỘT QUAN HỆ
--1. TÊN CHƯƠNG TRÌNH PHẢI PHÂN BIỆT

--2. TÊN KHOA PHẢI PHÂN BIỆT

--3. TÊN MÔN HỌC PHẢI DUY NHẤT

--4. SINH VIÊN CHỈ ĐƯỢC THI TỐI ĐA 2 LẦN CHO MỘT MÔN HỌC

-- LIÊN THUỘC TÍNH TRÊN NHIỀU QUAN HỆ
--1. NĂM BẮT ĐẦU KHÓA HỌC CỦA MỘT LỚP KHÔNG THỂ NHỎ HƠN NĂM THÀNH LẬP CỦA KHOA QUẢN LÝ LỚP ĐÓ

--2. SINH VIÊN CHỈ CÓ THỂ DỰ THI CÁC MÔN HỌC CÓ TRONG CHƯƠNG TRÌNH VÀ THUỘC VỀ KHOA MÀ SINH VIÊN ĐÓ ĐANG THEO HỌC

-- TỔNG HỢP
--1. HÃY BỔ SUNG VÀO QUAN HỆ LOP THUỘC TÍNH SISO VÀ KIỂM TRA SĨ SỐ CỦA MỘT LỚP PHẢI BẰNG SỐ LƯỢNG SINH VIÊN ĐANG THEO HỌC LỚP ĐÓ