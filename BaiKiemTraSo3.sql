CREATE DATABASE BaiKiemTraSo3
GO
USE BaiKiemTraSo3
GO

CREATE TABLE Kho
(
	MaKho INT PRIMARY KEY IDENTITY,
	TenKho NVARCHAR(30) UNIQUE NOT NULL
)
GO
CREATE TABLE DonViTinh
(
	MaDonViTinh INT PRIMARY KEY IDENTITY,
	TenDonViTinh NVARCHAR(30) UNIQUE NOT NULL
)
GO
CREATE TABLE HangHoa
(
	MaHangHoa INT NOT NULL PRIMARY KEY,
	TenHangHoa NVARCHAR(30) UNIQUE NOT NULL,
	GhiChu NVARCHAR(30) NOT NULL
)
GO
CREATE TABLE LuuKho
(
	MaHangHoa INT NOT NULL REFERENCES HangHoa(MaHangHoa),
	MaDonViTinh INT NOT NULL REFERENCES DonViTinh(MaDonViTinh),
	MaKho INT NOT NULL REFERENCES Kho(MaKho),
	SoLuong FLOAT NOT NULL,
	CONSTRAINT LuuKho_PK PRIMARY KEY (MaHangHoa, MaDonViTinh, MaKho),
	CONSTRAINT SoLuon_CK CHECK (SoLuong>0)
)
GO
--Câu 2:
CREATE VIEW vChiTietLuuKho AS
SELECT LuuKho.MaHangHoa, TenHangHoa, TenDonViTinh, TenKho, SoLuong FROM LuuKho
INNER JOIN HangHoa ON HangHoa.MaHangHoa = LuuKho.MaHangHoa
INNER JOIN DonViTinh ON DonViTinh.MaDonViTinh = LuuKho.MaDonViTinh
INNER JOIN Kho ON Kho.MaKho = LuuKho.MaKho
GO
--Câu 3:
CREATE PROCEDURE spThemLuuKho @Hang NVARCHAR(30), @DV NVARCHAR(30), @Kho NVARCHAR(30), @Soluong INT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM HangHoa WHERE TenHangHoa = @Hang) PRINT N'Hàng hóa không tồn tại'
	ELSE IF NOT EXISTS (SELECT * FROM DonViTinh WHERE TenDonViTinh = @DV) PRINT N'Đơn vị tính không tồn tại'
	ELSE IF NOT EXISTS (SELECT * FROM Kho WHERE TenKho = @Kho) PRINT N'Kho không tồn tại'
	ELSE IF @Soluong <= 0 PRINT N'Số lượng hàng hóa phải là số lớn hơn 0'
	ELSE IF EXISTS 
	(SELECT * FROM LuuKho 
	INNER JOIN Kho ON Kho.MaKho = LuuKho.MaKho
	INNER JOIN HangHoa ON HangHoa.MaHangHoa = LuuKho.MaHangHoa
	INNER JOIN DonViTinh ON DonViTinh.MaDonViTinh = LuuKho.MaDonViTinh
	WHERE TenHangHoa = @Hang AND TenKho = @Kho AND TenDonViTinh = @DV) PRINT N'Hàng hóa đã tồn tại'
	ELSE
	BEGIN
		DECLARE @MaHH INT, @MaDV INT, @MaKho INT
		SELECT @MaHH = MaHangHoa FROM HangHoa WHERE TenHangHoa = @Hang
		SELECT @MaDV = MaDonViTinh FROM DonViTinh WHERE TenDonViTinh = @DV
		SELECT @MaKho = MaKho FROM Kho WHERE TenKho = @Kho
		INSERT LuuKho VALUES(@MaHH, @MaDV, @MaKho, @Soluong)
	END
END
GO
--Câu 4:
CREATE FUNCTION TimKiemHangHoa(@MaHH INT, @TenHH NVARCHAR(100), @GhiChu NVARCHAR(100))
RETURNS TABLE
AS RETURN
SELECT * FROM HangHoa WHERE (MaHangHoa = NULL OR MaHangHoa = @MaHH) AND (TenHangHoa = NULL OR TenHangHoa = @TenHH) AND (GhiChu = NULL OR GhiChu = @GhiChu)