-- Liệt kê tất cả các sản phẩm (masp, tensp) có số lượng bán ra lớn hơn 30.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP In (
    SELECT MASP
    FROM CTHD
    GROUP BY MASP
    HAVING SUM(SL) > 30);

-- In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP LIKE 'B%01';

-- In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 20.000 đến 30.000.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = N'Trung Quốc' AND GIABAN BETWEEN 10000 and 30000;

-- In ra danh sách các sản phẩm (MASP,TENSP) do “Việt Nam” hoặc “Thái Lan” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP, TENSP, NUOCSX
FROM SANPHAM
WHERE NUOCSX In(N'Việt Nam', N'Thái Lan') and GIABAN BETWEEN 30000 and 40000;

-- In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 01/12/2022 đến ngày 31/12/2022.
SELECT SOHD, TRIGIA, NGHD
FROM HOADON
WHERE NGHD BETWEEN '2022-01-01' AND'2022-12-31';

-- Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua (MAKH null)?
SELECT COUNT(*) AS SOHOADON
FROM HOADON
WHERE MAKH IS NULL;

-- Tính tổng giá trị đơn hàng (số tiền) cho mỗi khách hàng (MAKH).
SELECT MAKH, SUM(TRIGIA) AS TONGTIEN
FROM HOADON
WHERE MAKH IS NOT NULL
GROUP BY MAKH;

-- In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 01/01/2023.
SELECT KH.MAKH, HOTEN
FROM KHACHHANG KH JOIN HOADON HD ON KH.MAKH=HD.MAKH
WHERE NGHD= '01/01/2023';

-- In ra danh sách các sản phẩm (MASP,TENSP) và số lượng được khách hàng có tên “Nguyễn Văn A” mua trong tháng 11/2022.
SELECT SP.MASP, TENSP, SL
FROM KHACHHANG KH
JOIN HOADON HD  ON KH.MAKH = HD.MAKH
JOIN CTHD       ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE HOTEN= N'Nguyễn Văn A' AND YEAR(NGHD)='2022' AND MONTH(NGHD)='11';

-- Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 20 trở lên.
SELECT DISTINCT SOHD
FROM CTHD
WHERE MASP In('BB01', 'BB02') AND SL > 20;

-- Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT SOHD
FROM CTHD A
WHERE MASP = 'BB02' AND A.SL BETWEEN 10 AND 20 AND EXISTS 
	(
	SELECT SOHD 
	FROM CTHD B
	WHERE MASP = 'BB01' AND A.SOHD = B.SOHD AND B.SL BETWEEN 10 AND 20
	);

-- In ra danh sách các sản phẩm (MASP,TENSP) chưa bán được lần nào trong giai đoạn vừa qua.
SELECT A.MASP , TENSP
FROM SANPHAM A
WHERE NOT EXISTS (
	SELECT MASP
	FROM CTHD B
	WHERE A.MASP = B.MASP
	);

-- Tìm số hóa đơn đã mua tất cả các sản phẩm do nước Singapore sản xuất.
SELECT SOHD
FROM CTHD 
JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
WHERE NUOCSX ='Singapore'
GROUP BY SOHD
HAVING COUNT(CTHD.MASP) =
	(
	SELECT COUNT(MASP)
	FROM SANPHAM
	WHERE NUOCSX='Singapore'
	);

-- Số sản phẩm khác nhau được bán ra trong năm 2022.
SELECT COUNT(DISTINCT MASP)	SOSP
FROM CTHD JOIN HOADON ON CTHD.SOHD=HOADON.SOHD
WHERE YEAR(NGHD)='2022';


-- Tính tổng doanh thu bán hàng và doanh thu trung bình mỗi tháng trong năm 2022.
SELECT  convert(nvarchar(20), SUM(TRIGIA) ,1)  DOANHTHU, 
		convert(nvarchar(20), SUM(TRIGIA)/COUNT(DISTINCT(MONTH(NGHD))) ,1) DOANHTHUTB
FROM HOADON
WHERE YEAR(NGHD)='2022';

-- Tìm những tháng trong năm 2022 có doanh thu lớn hơn hoặc bằng 20% giá trị trung bình mỗi tháng của năm đó.
SELECT MONTH(NGHD) AS THANG
FROM HOADON 
GROUP BY MONTH(NGHD)
HAVING SUM(TRIGIA) >= 1.2 * 
	(
	SELECT SUM(TRIGIA)/COUNT(DISTINCT(MONTH(NGHD)))	
	FROM HOADON 
	);

-- In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT top 3  KH.MAKH, HOTEN, TRIGIA,  RANK() OVER(ORDER BY TRIGIA DESC) RANK
FROM KHACHHANG	KH
JOIN HOADON HD ON KH.MAKH = HD.MAKH
ORDER BY TRIGIA DESC;

-- In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP ,TENSP
FROM SANPHAM
WHERE GIABAN IN (
	SELECT TOP 3 GIABAN
	FROM SANPHAM
	ORDER BY GIABAN DESC);

-- Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm
select NUOCSX, MAX(GIABAN) AS max_price, MIN(GIABAN) as min_price, AVG(GIABAN) AS avg_price 
FROM SANPHAM
GROUP BY NUOCSX;

-- Tính doanh thu bán hàng mỗi ngày.
SELECT CAST(NGHD AS DATE) AS NGAY, SUM(TRIGIA) AS DOANHTHU 
FROM HOADON
GROUP BY CAST(NGHD AS DATE);

-- Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau
SELECT SOHD 
FROM CTHD
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) > 4;

-- Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất
SELECT  KH.MAKH, COUNT(*) AS SOLANMUAHANG
FROM HOADON HD
JOIN KHACHHANG KH ON HD.MAKH = KH.MAKH
GROUP BY KH.MAKH , HOTEN
ORDER BY COUNT(*) DESC;


-- Sắp xếp các sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2022
SELECT SP.MASP, TENSP, SUM(SL) AS SOLUONGSP
FROM HOADON HD
JOIN CTHD ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE YEAR (NGHD) = 2022
GROUP BY SP.MASP, TENSP
ORDER BY SUM(SL);

-- Với mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
WITH RANK_ AS (
	SELECT NUOCSX, MASP, TENSP, GIABAN, RANK() OVER(PARTITION BY NUOCSX ORDER BY GIABAN DESC) RANK
	FROM SANPHAM)

SELECT MASP, TENSP, NUOCSX
FROM RANK_ R
WHERE RANK = 1; 

-- Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT TOP 1 MAKH ,HOTEN 
FROM (
		SELECT TOP 10 KH.MAKH , HOTEN , SUM(TRIGIA)	AS DOANHSO, COUNT(*) AS SOLAN
		FROM  KHACHHANG KH JOIN HOADON HD ON KH.MAKH = HD.MAKH
		GROUP BY KH.MAKH , HOTEN
		ORDER BY DOANHSO DESC
		) KH
ORDER BY SOLAN DESC; 