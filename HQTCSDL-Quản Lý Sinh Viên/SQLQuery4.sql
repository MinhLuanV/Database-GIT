-- TRUY VẤN
--1. DANH SÁCH CÁC SINH VIÊN KHOA "CÔNG NGHỆ THÔNG TIN" KHÓA 2002 - 2006.
SELECT * FROM SinhVien WHERE maLop IN 
(SELECT L.Ma FROM KhoaHoc KH LEFT JOIN Lop L
ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau = 2002 AND KH.namKetThuc = 2006 AND L.maKhoa = 'CNTT')
--------------------------------------------------------------------------------------------------------------

--2. CHO BIẾT CÁC SINH VIÊN (MSSV, HỌ TÊN, NĂM SINH) CỦA CÁC SINH VIÊN HỌC SỚM HƠN TUỔI QUI ĐỊNH
--THEO TUỔI QUI ĐỊNH THÌ SINH VIÊN ĐỦ 18 TUỔI KHI BẮT ĐẦU KHÓA HỌC
SELECT S.Ma, S.hoTen, S.namSinh FROM SinhVien S
LEFT JOIN LOP L ON s.maLop = L.Ma
LEFT JOIN KhoaHoc KH ON KH.Ma = L.maKhoaHoc
WHERE KH.namBatDau - S.namSinh < 18
--------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------

--5. VỚI MỖI LỚP THUỘC KHOA CNTT, CHO BIẾT MÃ LỚP, MÃ KHÓA HỌC, TÊN CHƯƠNG TRÌNH VÀ SỐ SINH VIÊN THUỘC LỚP ĐÓ
SELECT L.Ma, L.maKhoaHoc, CT.tenChuongTrinh, COUNT(SV.Ma) AS SoSinhVien FROM Lop L
LEFT JOIN ChuongTrinh CT
ON L.maChuongTrinh = CT.Ma
LEFT JOIN SinhVien SV
ON SV.maLop = L.Ma
WHERE L.maKhoa = N'CNTT'
GROUP BY L.Ma, L.maKhoaHoc, CT.tenChuongTrinh
--------------------------------------------------------------------------------------------------------------

--6. CHO BIẾT ĐIỂM TRUNG BÌNH CỦA SINH VIÊN CÓ MÃ SỐ 0212003 (ĐIỂM TRUNG BÌNH CHỈ TÍNH TRÊN LẦN THI SAU CÙNG CỦA SINH VIÊN)
SELECT AVG(KQ.diem) AS DiemTrungBinh FROM KetQua KQ
WHERE KQ.maSinhVien = 0212003 AND KQ.lanThi =
(SELECT MAX(KQ1.lanThi) FROM KetQua KQ1
WHERE KQ1.maMonHoc = KQ.maMonHoc AND
KQ1.maSinhVien = KQ.maSinhVien)
--------------------------------------------------------------------------------------------------------------

-- FUNCTION
--1. VỚI 1 MÃ SINH VIÊN VÀ 1 MÃ KHOA, KIỂM TRA XEM SINH VIÊN CÓ THUỘC KHOA NÀY KHÔNG (TRẢ VỀ ĐÚNG HAY SAI)
GO
CREATE OR ALTER FUNCTION FN_KiemTraKhoa
(
@MaSinhVien varchar(10),
@MaKhoa varchar (10)
)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @KETQUA NVARCHAR(10)
	IF EXISTS (
		SELECT * FROM SinhVien SV
		LEFT JOIN Lop L
		ON SV.maLop = L.Ma
		WHERE SV.Ma = @MaSinhVien
		AND L.maKhoa = @MaKhoa)
		SET @KETQUA = N'Đúng'
	ELSE
		SET @KETQUA = N'Sai'
	RETURN @KETQUA
END
GO

SELECT dbo.FN_KiemTraKhoa('0212001', 'CNTT')

--------------------------------------------------------------------------------------------------------------
--2.  TÍNH ĐIỂM THI SAU CÙNG CỦA MỘT SINH VIÊN TRONG MỘT MÔN HỌC CỤ THỂ
GO
CREATE OR ALTER FUNCTION FN_TinhDiemThiSauCung
(
	@MaSinhVien VARCHAR(10),
	@MaMonHoc VARCHAR(10)
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @KETQUA FLOAT
	SElECT @KETQUA = diem FROM KetQua KQ
	WHERE KQ.maSinhVien = @MaSinhVien AND KQ.maMonHoc = @MaMonHoc
	AND KQ.lanThi = (SELECT MAX(KQ1.lanThi) FROM KetQua KQ1
					WHERE KQ.maMonHoc = KQ1.maMonHoc AND KQ.maSinhVien = KQ1.maSinhVien)
	RETURN @KETQUA
END
GO

SELECT dbo.FN_TinhDiemThiSauCung('0212003', 'THT02')
--------------------------------------------------------------------------------------------------------------

--3. TÍNH ĐIỂM TRUNG BÌNH CỦA MỘT SINH VIÊN (CHÚ Ý: ĐIỂM TRUNG BÌNH ĐƯỢC TÍNH DỰA TRÊN LẦN THI SAU CÙNG)
-- SỬ DỤNG FUNCTION CÂU 2 ĐÃ VIẾT
GO
CREATE OR ALTER FUNCTION FN_TinhDiemTrungBinh
(
	@MaSinhVien VARCHAR(10)
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @KETQUA FLOAT
	SElECT @KETQUA = AVG(dbo.TinhDiemThiSauCung(@MaSinhVien, KQ.maMonHoc)) 
	FROM 
	(SELECT DISTINCT maMonHoc FROM KetQua
	WHERE maSinhVien = @MaSinhVien) KQ
	RETURN @KETQUA
END
GO

SELECT dbo.FN_TinhDiemTrungBinh('0212003')
--------------------------------------------------------------------------------------------------------------

--4. NHẬP VÀO 1 SINH VIÊN VÀ 1 MÔN HỌC, TRẢ VỀ CÁC ĐIỂM THI CỦA SINH VIÊN NÀY TRONG CÁC LẦN THI CỦA MÔN HỌC ĐÓ.
GO
CREATE OR ALTER FUNCTION FN_TraVeDiemThi
(
	@MaSinhVien VARCHAR(10),
	@MaMonHoc VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
	SELECT SV.Ma, SV.hoTen, KQ.maMonHoc, KQ.lanThi, KQ.diem FROM SinhVien SV
	LEFT JOIN KetQua KQ ON SV.Ma = KQ.maSinhVien
	WHERE SV.Ma = @MaSinhVien AND KQ.maMonHoc = @MaMonHoc
GO

SELECT * FROM dbo.FN_TraVeDiemThi('0212003', 'THT02')
--------------------------------------------------------------------------------------------------------------

--5. NHẬP VÀO 1 SINH VIÊN, TRẢ VỀ DANH SÁCH CÁC MÔN HỌC MÀ SINH VIÊN NÀY PHẢI HỌC.
GO
CREATE OR ALTER FUNCTION FN_DanhSachCacMonHoc
(
	@MaSinhVien VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
	SELECT MH.tenMonHoc FROM SinhVien SV
	LEFT JOIN Lop L
	ON SV.maLop = L.Ma
	LEFT JOIN KHOA K
	ON L.maKhoa = K.ma
	LEFT JOIN MonHoc MH
	ON MH.maKhoa = K.ma
	WHERE SV.Ma = @MaSinhVien
GO

SELECT * FROM dbo.FN_DanhSachCacMonHoc('0212001')
--------------------------------------------------------------------------------------------------------------

-- STORE PROCEDURE
--1. IN DANH SÁCH CÁC SINH VIÊN CỦA 1 LỚP HỌC
GO
CREATE OR ALTER PROCEDURE SP_InDanhSach
(
	@MaLopHoc VARCHAR(10)
)
AS
	SELECT * FROM SinhVien SV
	WHERE SV.maLop = @MaLopHoc
GO

EXEC SP_InDanhSach 'TH2002/01'
--------------------------------------------------------------------------------------------------------------

--2. NHẬP VÀO 2 SINH VIÊN, 1 MÔN HỌC, 
-- TÌM XEM SINH VIÊN NÀO CÓ ĐIỂM THI MÔN HỌC ĐÓ LẦN ĐẦU TIÊN CAO HƠN
GO
CREATE OR ALTER PROCEDURE SP_SinhVienDiemCaoHon
(
	@MaSinhVien1 VARCHAR(10),
	@MaSinhVien2 VARCHAR(10),
	@MaMonHoc VARCHAR(10)
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @KQ1 FLOAT
		DECLARE @KQ2 FLOAT
	
	SELECT @KQ1 = diem FROM KetQua KQ
	WHERE KQ.maSinhVien = @MaSinhVien1 AND KQ.maMonHoc = @MaMonHoc AND KQ.lanThi = 1
	
	SELECT @KQ2 = diem FROM KetQua KQ
	WHERE KQ.maSinhVien = @MaSinhVien2 AND KQ.maMonHoc = @MaMonHoc AND KQ.lanThi = 1

	IF @KQ1 IS NULL OR @KQ2 IS NULL
	BEGIN
		PRINT N'Một Trong Hai Sinh Viên Chưa Có Điểm Lần 1 Môn Học Này'
		ROLLBACK TRANSACTION
		RETURN
	END

	IF @KQ1 > @KQ2
	BEGIN
		PRINT N'Sinh Viên ' + @MaSinhVien1 + N' Có Điểm Cao Hơn'
	END

	IF @KQ1 < @KQ2
	BEGIN
		PRINT N'Sinh Viên ' + @MaSinhVien2 + N' Có Điểm Cao Hơn'
	END
	ELSE
	BEGIN
		PRINT N'Hai Sinh Viên Điểm Bằng Nhau'
	END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION
		PRINT N'Lỗi Xảy Ra: ' + ERROR_MESSAGE()
	END CATCH
END
GO

EXEC SP_SinhVienDiemCaoHon '0212001','0212002','THT01'
--------------------------------------------------------------------------------------------------------------

--3. NHẬP VÀO 1 MÔN HỌC VÀ 1 MÃ SINH VIÊN,
-- KIỂM TRA XEM SINH VIÊN CÓ ĐẬU MÔN NÀY TRONG LẦN THI ĐẦU TIÊN KHÔNG 
-- NẾU ĐẬU THÌ XUẤT RA LÀ "ĐẬU", KHÔNG THÌ XUẤT RA "KHÔNG ĐẬU"
GO
CREATE OR ALTER PROCEDURE SP_KiemTraCoDauKhong
(
	@MaSinhVien VARCHAR(10),
	@MaMonHoc VARCHAR(10)
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @KQ FLOAT
		SELECT @KQ = diem FROM KetQua
		WHERE maSinhVien = @MaSinhVien AND maMonHoc = @MaMonHoc AND lanThi = 1

		IF @KQ IS NULL
		BEGIN
		PRINT N'Sinh Viên Chưa Có Kết Quả Thi Môn Này Lần Đầu'
		ROLLBACK TRANSACTION
		RETURN
		END

		IF @KQ >= 5
		BEGIN
			PRINT N'ĐẬU'
		END
		ELSE
		BEGIN
			PRINT N'KHÔNG ĐẬU'
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION
		PRINT N'Lỗi Xảy Ra: '+ ERROR_MESSAGE()
	END CATCH
END
GO

EXEC SP_KiemTraCoDauKhong '0212003', 'THCS01'
--------------------------------------------------------------------------------------------------------------

--4. NHẬP VÀO 1 KHOA
-- IN DANH SÁCH CÁC SINH VIÊN (MÃ SINH VIÊN, HỌ TÊN, NGÀY SINH) THUỘC KHOA NÀY
GO
CREATE OR ALTER PROCEDURE SP_InDanhSachSinhVien
	@MaKhoa VARCHAR(10)

AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			SELECT SV.Ma, SV.hoTen, SV.namSinh FROM SinhVien SV
			LEFT JOIN Lop L ON SV.maLop = L.Ma
			LEFT JOIN Khoa K ON L.maKhoa = K.ma
			WHERE K.ma = @MaKhoa
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
		ROLLBACK TRANSACTION
		PRINT N'Lỗi: '+ ERROR_MESSAGE()	
	END CATCH
END
GO

EXEC SP_InDanhSachSinhVien 'CNTT'
--------------------------------------------------------------------------------------------------------------

--5. NHẬP VÀO 1 SINH VIÊN VÀ 1 MÔN HỌC, IN ĐIỂM THI CỦA SINH VIÊN NÀY CỦA CÁC LẦN THI MÔN HỌC ĐÓ
-- VÍ DỤ: LẦN 1: 10; LẦN 2: 9
GO
CREATE OR ALTER PROCEDURE SP_InDiemThiCuaSinhVien
	@MaSinhVien VARCHAR(10),
	@MaMonHoc VARCHAR(10)
AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @LanThi INT
				DECLARE @Diem FLOAT
				DECLARE cur_DiemThi CURSOR FOR
				SELECT lanThi, diem FROM KetQua
				WHERE maSinhVien = @MaSinhVien AND maMonHoc = @MaMonHoc
				ORDER BY lanThi ASC

				OPEN cur_DiemThi 

				FETCH NEXT FROM cur_DiemThi INTO @LanThi, @Diem

				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT N'Lần ' + CAST(@LanThi AS NVARCHAR(10)) + N': ' + CAST(@Diem AS NVARCHAR(10))
					FETCH NEXT FROM cur_DiemThi INTO @LanThi, @Diem
				END

				CLOSE cur_DiemThi
				DEALLOCATE cur_DiemThi
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION

			IF CURSOR_STATUS('GLOBAL', 'cur_DiemThi') >= 0
			BEGIN
				CLOSE cur_DiemThi
				DEALLOCATE cur_DiemThi
			END
			PRINT N'Lỗi: ' + ERROR_MESSAGE()
		END CATCH
	END
GO

EXEC SP_InDiemThiCuaSinhVien '0212001', 'THT01'
--------------------------------------------------------------------------------------------------------------

--6. NHẬP VÀO 1 SINH VIÊN, IN RA CÁC MÔN HỌC MÀ SINH VIÊN NÀY PHẢI HỌC
GO
CREATE OR ALTER PROCEDURE SP_InCacMonHoc
	@MaSinhVien VARCHAR(10)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRY
		BEGIN TRANSACTION
			PRINT N'Danh Sách Các Môn Học Sinh Viên Phải Học'
			SELECT MH.Ma, MH.tenMonHoc  FROM SinhVien SV
			LEFT JOIN Lop L ON L.Ma = SV.maLop
			LEFT JOIN GiangKhoa GK ON L.maChuongTrinh = GK.maChuongTrinh AND L.maKhoa = gk.maKhoa
			LEFT JOIN MonHoc MH ON MH.Ma = GK.maMonHoc
			WHERE SV.Ma = @MaSinhVien
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK TRANSACTION
				PRINT N'Lỗi ' + ERROR_MESSAGE() 
			END
	END CATCH
END
GO

EXEC SP_InCacMonHoc '0212001'
--------------------------------------------------------------------------------------------------------------

--7. NHẬP VÀO 1 MÔN HỌC
-- IN DANH SÁCH CÁC SINH VIÊN ĐẬU MÔN HỌC NÀY TRONG LẦN THI ĐẦU TIÊN
GO
CREATE OR ALTER PROCEDURE SP_InDanhSachCacSinhVienDau
	@MaMonHoc VARCHAR(10)
AS
	BEGIN
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		BEGIN TRY
			BEGIN TRANSACTION
				IF NOT EXISTS (
				SELECT * FROM KetQua KQ
				LEFT JOIN SinhVien SV ON KQ.maSinhVien = SV.Ma
				WHERE KQ.lanThi = 1 AND KQ.diem >= 5 AND KQ.maMonHoc = @MaMonHoc)
				
				BEGIN
					PRINT N'Không Có Sinh Viên Đậu Môn Học Này'
					ROLLBACK TRANSACTION
					RETURN
				END

				ELSE
				BEGIN
					SELECT SV.Ma, SV.hoTen FROM KetQua KQ
				LEFT JOIN SinhVien SV ON KQ.maSinhVien = SV.Ma
				WHERE KQ.lanThi = 1 AND KQ.diem >= 5 AND KQ.maMonHoc = @MaMonHoc
				END

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION
			PRINT 'Lỗi: ' + ERROR_MESSAGE()
		END CATCH
	END
GO

EXEC SP_InDanhSachCacSinhVienDau 'THCS01'
--------------------------------------------------------------------------------------------------------------

--8. IN ĐIỂM CÁC MÔN HỌC CỦA SINH VIÊN CÓ MÃ SỐ SINH VIÊN MASINHVIEN ĐƯỢC NHẬP VÀO
-- CHÚ Ý: ĐIỂM CỦA MÔN HỌC LÀ ĐIỂM THI CỦA LẦN SAU CÙNG
--	8.1 CHỈ IN CÁC MÔN ĐÃ CÓ ĐIỂM
--	8.2 CÁC MÔN CHƯA CÓ ĐIỂM THÌ GHI ĐIỂM LÀ NULL
--	8.3 CÁC MÔN CHƯA CÓ ĐIỂM THÌ GHI ĐIỂM LÀ <CHƯA CÓ ĐIỂM>

--8.1
GO
CREATE OR ALTER PROCEDURE SP_InDiemCuaSinhVien
	@MaSinhVien VARCHAR(10)
AS
	BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
		BEGIN TRY
			BEGIN TRANSACTION
				SELECT KQ.maMonHoc, MH.tenMonHoc, KQ.diem FROM KetQua KQ
				LEFT JOIN MonHoc MH ON MH.Ma = KQ.maMonHoc
				WHERE KQ.maSinhVien = @MaSinhVien AND KQ.diem IS NOT NULL
				AND lanThi = (SELECT MAX(KQ1.lanThi) FROM KetQua KQ1
								WHERE KQ1.maMonHoc = KQ.maMonHoc
								AND KQ1.maSinhVien = KQ.maSinhVien)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION
			PRINT N'Lỗi: ' + ERROR_MESSAGE()
		END CATCH
	END
GO

EXEC SP_InDiemCuaSinhVien '0212003'
--------------------------------------------------------------------------------------------------------------
--8.2
GO
CREATE OR ALTER PROCEDURE SP_InDiemSinhVienCoNull
	@MaSinhVien VARCHAR(10)
AS
	BEGIN
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRY
			BEGIN TRANSACTION
				SELECT KQ.maMonHoc, MH.tenMonHoc, KQ.diem FROM SinhVien SV
				LEFT JOIN Lop L ON SV.maLop = L.Ma
				LEFT JOIN GiangKhoa GK ON GK.maKhoa = L.maKhoa AND GK.maChuongTrinh = L.maChuongTrinh
				LEFT JOIN MonHoc MH ON MH.Ma = GK.maMonHoc
				LEFT JOIN KetQua KQ ON KQ.maSinhVien = SV.Ma AND KQ.maMonHoc = MH.Ma
				AND KQ.lanThi = (SELECT MAX(KQ1.lanThi) FROM KetQua KQ1
								WHERE KQ1.maMonHoc = KQ.maMonHoc
								AND KQ1.maSinhVien = KQ.maSinhVien)
				WHERE SV.Ma = @MaSinhVien
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION
			PRINT N'Lỗi: ' + ERROR_MESSAGE()
		END CATCH
	END
GO

EXEC SP_InDiemSinhVienCoNull '0311002' 
--------------------------------------------------------------------------------------------------------------
--8.3
GO
CREATE OR ALTER PROCEDURE SP_InDiemSinhVienKhongNull
	@MaSinhVien VARCHAR(10)
AS
	BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRY
			BEGIN TRANSACTION
			SELECT SV.Ma, MH.Ma, ISNULL(CAST(KQ.diem AS NVARCHAR(20)), N'Chưa Có Điểm') FROM SinhVien SV
			LEFT JOIN Lop L ON L.Ma = SV.maLop
			LEFT JOIN GiangKhoa GK ON L.maKhoa = GK.maKhoa AND L.maChuongTrinh = GK.maChuongTrinh
			LEFT JOIN MonHoc MH ON MH.Ma = GK.maMonHoc
			LEFT JOIN KetQua KQ ON KQ.maSinhVien = SV.Ma AND KQ.maMonHoc = MH.Ma
								AND KQ.lanThi = (SELECT MAX(KQ1.lanThi) FROM KetQua KQ1
												WHERE KQ1.maMonHoc = KQ.maMonHoc
												AND KQ1.maSinhVien = KQ.maSinhVien)
			WHERE SV.Ma = @MaSinhVien
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION
			PRINT N'Lỗi: ' + ERROR_MESSAGE()
		END CATCH
	END
GO

EXEC SP_InDiemSinhVienKhongNull '0212004' 
--------------------------------------------------------------------------------------------------------------
--THÊM MỘT QUAN HỆ
--XepLoai(maSinhVien, diemTrungBinh, ketQua, hocLuc)

--------------------------------------------------------------------------------------------------------------

--9. ĐƯA DỮ LIỆU VÀO BẢNG XEPLOAI. SỬ DỤNG FUNCTION CÂU 3 ĐÃ VIẾT Ở TRÊN
-- QUI ĐỊNH: KETQUA CỦA SINH VIÊN LÀ "ĐẠT" NẾU DIEMTRUNGBINH (CHỈ TÍNH CÁC MÔN ĐÃ CÓ ĐIỂM)
-- CỦA SINH VIÊN ĐÓ LỚN HƠN HOẶC BẰNG 5 VÀ KHÔNG QUÁ 2 MÔN DƯỚI 4 ĐIỂM, NGƯỢC LẠI THÌ KẾT QUẢ LÀ "KHÔNG ĐẠT"
-- ĐỐI VỚI NHỮNG SINH VIÊN CÓ KETQUA LÀ "ĐẠT" THÌ HOCLUC ĐƯỢC XẾP LOẠI NHƯ SAU:
-- DIEMTRUNGBINH >= 8 LÀ HOCLUC "GIỎI"
-- 7 <= DIEMTRUNGBINH < 8 LÀ HOCLUC "KHÁ"
-- CÒN LẠI LÀ HOCLUC "TRUNG BÌNH"
--------------------------------------------------------------------------------------------------------------

--10. VỚI CÁC SINH VIÊN THAM GIA ĐẦY ĐỦ CÁC MÔN HỌC CỦA KHOA, CHƯƠNG TRÌNH MÀ SINH VIÊN ĐANG THEO HỌC, HÃY IN RA
-- ĐIỂM TRUNG BÌNH CỦA CÁC SINH VIÊN NÀY
-- CHÚ Ý: ĐIỂM TRUNG BÌNH ĐƯỢC TÍNH DỰA VÀO LẦN THI SAU CÙNG
-- SỬ DỤNG FUNCTION CÂU 3 ĐÃ VIẾT Ở TRÊN
--------------------------------------------------------------------------------------------------------------

-- CÀI ĐẶT CÁC RÀNG BUỘC TOÀN VẸN (CHECK CONSTRAIN, UNIQUE, CONSTRAIN, RULE HOẶC TRIGGER)
-- MIỀN GIÁ TRỊ
--1. ChuongTrinh.ma CHỈ CÓ THỂ LÀ "CQ" HOẶC "CD" HOẶC "TC"
--------------------------------------------------------------------------------------------------------------

--2. CHỈ CÓ 2 HỌC KỲ LÀ "HK1" VÀ "HK2"
--------------------------------------------------------------------------------------------------------------

--3. SỐ TIẾT LÝ THUYẾT (GiangKhoa.soTietLyThuyet) TỐI ĐA LÀ 120
--------------------------------------------------------------------------------------------------------------

--4. SỐ TIẾT THỰC HÀNH (GiangKhoa.soTietThucHanh) TỐI ĐA LÀ 120
--------------------------------------------------------------------------------------------------------------

--5. SỐ TÍN CHỈ (GiangKhoa.soTinChi) CỦA MỘT MÔN HỌC TỐI ĐA LÀ 6
--------------------------------------------------------------------------------------------------------------

--6. ĐIỂM THI (KetQua.diem) ĐƯỢC CHẤM THEO THANG ĐIỂM 10 VÀ CHÍNH XÁC ĐẾN 0.5
--	LÀM BẰNG 2 CÁCH: KIỂM TRA VÀ BÁO LỖI NẾU KHÔNG ĐÚNG QUI ĐỊNH
--	 TỰ ĐỘNG LÀM TRÒN NẾU KHÔNG ĐÚNG QUI ĐỊNH VỀ ĐỘ CHÍNH XÁC
--------------------------------------------------------------------------------------------------------------

-- LIÊN THUỘC TÍNH TRÊN MỘT QUAN HỆ
--1. NĂM KẾT THÚC KHÓA HỌC PHẢI LỚN HƠN HOẶC BẰNG NĂM BẮT ĐẦU
--------------------------------------------------------------------------------------------------------------

--2. SỐ TIẾT LÝ THUYẾT CỦA MỖI GIẢNG KHOA KHÓA KHÔNG NHỎ HƠN SỐ TIẾT THỰC HÀNH
--------------------------------------------------------------------------------------------------------------

-- LIÊN BỘ TRÊN MỘT QUAN HỆ
--1. TÊN CHƯƠNG TRÌNH PHẢI PHÂN BIỆT
--------------------------------------------------------------------------------------------------------------

--2. TÊN KHOA PHẢI PHÂN BIỆT
--------------------------------------------------------------------------------------------------------------

--3. TÊN MÔN HỌC PHẢI DUY NHẤT
--------------------------------------------------------------------------------------------------------------

--4. SINH VIÊN CHỈ ĐƯỢC THI TỐI ĐA 2 LẦN CHO MỘT MÔN HỌC
--------------------------------------------------------------------------------------------------------------

-- LIÊN THUỘC TÍNH TRÊN NHIỀU QUAN HỆ
--1. NĂM BẮT ĐẦU KHÓA HỌC CỦA MỘT LỚP KHÔNG THỂ NHỎ HƠN NĂM THÀNH LẬP CỦA KHOA QUẢN LÝ LỚP ĐÓ
--------------------------------------------------------------------------------------------------------------

--2. SINH VIÊN CHỈ CÓ THỂ DỰ THI CÁC MÔN HỌC CÓ TRONG CHƯƠNG TRÌNH VÀ THUỘC VỀ KHOA MÀ SINH VIÊN ĐÓ ĐANG THEO HỌC
--------------------------------------------------------------------------------------------------------------

-- TỔNG HỢP
--1. HÃY BỔ SUNG VÀO QUAN HỆ LOP THUỘC TÍNH SISO VÀ KIỂM TRA SĨ SỐ CỦA MỘT LỚP PHẢI BẰNG SỐ LƯỢNG SINH VIÊN ĐANG THEO HỌC LỚP ĐÓ