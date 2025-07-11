-- Nama: Dini Aulia Putri
-- Asal: Pariaman
--Tugas: Intro to Statistics

-- =============================================
-- TUGAS STANDARD DEV
-- Menghitung Rata-Rata, Varians, 
-- Standar Deviasi, dan Kursi Dibutuhkan

-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS PengunjungLayananPublik;

-- Buat tabel untuk menyimpan data pengunjung layanan publik
CREATE TABLE PengunjungLayananPublik (
    Tanggal DATE,
    JumlahPengunjung INTEGER
);

-- Masukkan data ke dalam tabel
INSERT INTO PengunjungLayananPublik (Tanggal, JumlahPengunjung) VALUES
('2022-12-01', 4), ('2022-12-02', 2), ('2022-12-03', 5), ('2022-12-04', 10),
('2022-12-05', 7), ('2022-12-06', 8), ('2022-12-07', 10), ('2022-12-08', 5),
('2022-12-09', 8), ('2022-12-10', 4), ('2022-12-11', 9), ('2022-12-12', 6),
('2022-12-13', 10), ('2022-12-14', 8), ('2022-12-15', 4), ('2022-12-16', 6),
('2022-12-17', 8), ('2022-12-18', 5), ('2022-12-19', 7), ('2022-12-20', 3),
('2022-12-21', 9), ('2022-12-22', 7), ('2022-12-23', 5), ('2022-12-24', 4),
('2022-12-25', 7), ('2022-12-26', 7), ('2022-12-27', 7), ('2022-12-28', 5),
('2022-12-29', 8), ('2022-12-30', 5);

-- Hitung rata-rata, varians, standar deviasi, dan kursi yang dibutuhkan
WITH MeanCalc AS (
    SELECT AVG(JumlahPengunjung) AS Mean
    FROM PengunjungLayananPublik
),
VarianceCalc AS (
    SELECT 
        AVG((JumlahPengunjung - (SELECT Mean FROM MeanCalc)) * 
        (JumlahPengunjung - (SELECT Mean FROM MeanCalc))) AS Variance
    FROM PengunjungLayananPublik
)
-- Hitung Mean, Stdev, dan kursi yang diperlukan
SELECT 
    ROUND((SELECT Mean FROM MeanCalc), 1) AS Mean,
    ROUND(SQRT((SELECT Variance FROM VarianceCalc)), 1) AS Stdev,
    CAST(CEIL((SELECT Mean FROM MeanCalc) + SQRT((SELECT Variance FROM VarianceCalc))) AS INT) AS KursiDibutuhkan
FROM PengunjungLayananPublik
LIMIT 1;

-- =============================================
-- TUGAS Z Score
-- Menghitung Mean, Std Dev, dan Z-Score
-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS BiayaHidup;

-- Buat tabel untuk data biaya hidup teman Udin
CREATE TABLE BiayaHidup (
    Lokasi TEXT,
    BiayaHidup INT
);

-- Masukkan data biaya hidup ke dalam tabel
INSERT INTO BiayaHidup (Lokasi, BiayaHidup) VALUES
('Bekasi', 4800000), ('Bekasi', 5000000), ('Bekasi', 4200000),
('Bekasi', 4600000), ('Bekasi', 4500000), ('Bekasi', 5200000),
('Tuban', 2500000), ('Tuban', 2100000), ('Tuban', 3000000),
('Tuban', 3000000), ('Tuban', 2500000), ('Tuban', 2400000);

-- Hitung rata-rata, varians, dan standar deviasi secara manual
WITH MeanCalc AS (
    SELECT 
        Lokasi,
        AVG(BiayaHidup) AS Mean
    FROM BiayaHidup
    GROUP BY Lokasi
),
VarianceCalc AS (
    SELECT 
        b.Lokasi,
        AVG((b.BiayaHidup - m.Mean) * (b.BiayaHidup - m.Mean)) AS Variance
    FROM BiayaHidup b
    JOIN MeanCalc m ON b.Lokasi = m.Lokasi
    GROUP BY b.Lokasi
),
StdDevCalc AS (
    SELECT 
        v.Lokasi,
        v.Variance,
        m.Mean,
        sqrt(v.Variance) AS StdDev
    FROM VarianceCalc v
    JOIN MeanCalc m ON v.Lokasi = m.Lokasi
),
TawaranKerja AS (
    SELECT 'Bekasi' AS Lokasi, 5000000 AS Gaji
    UNION ALL
    SELECT 'Tuban', 3500000
),
ZScoreCalc AS (
    SELECT 
        t.Lokasi,
        t.Gaji,
        s.Mean,
        s.StdDev,
        ROUND((t.Gaji - s.Mean) / s.StdDev, 2) AS ZScore
    FROM TawaranKerja t
    JOIN StdDevCalc s ON t.Lokasi = s.Lokasi
)
-- Tampilkan hasil akhir
SELECT 
    Lokasi,
    Gaji,
    ROUND(Mean, 2) AS Mean_BiayaHidup,
    ROUND(StdDev, 2) AS StdDev_BiayaHidup,
    ZScore
FROM ZScoreCalc
ORDER BY ZScore DESC;

-- =============================================
-- TUGAS Percentile
-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS Transactions;

-- Buat tabel untuk data transaksi
CREATE TABLE Transactions (
    TransactionID INT,
    ServiceDuration INT
);

-- Masukkan data ke dalam tabel
INSERT INTO Transactions (TransactionID, ServiceDuration) VALUES
(1, 1), (2, 4), (3, 8), (4, 5), (5, 5), (6, 1), (7, 10), (8, 5),
(9, 6), (10, 1), (11, 1), (12, 10), (13, 2), (14, 1), (15, 4),
(16, 6), (17, 8), (18, 4), (19, 9), (20, 5), (21, 10), (22, 7),
(23, 10), (24, 2), (25, 10), (26, 2), (27, 7), (28, 10), (29, 7),
(30, 4), (31, 3), (32, 10), (33, 8), (34, 10), (35, 4), (36, 10),
(37, 10), (38, 5), (39, 10), (40, 9), (41, 3), (42, 7), (43, 9),
(44, 9), (45, 6), (46, 3), (47, 5), (48, 7), (49, 6), (50, 8);

-- Hitung P90
WITH SortedData AS (
    SELECT 
        ServiceDuration,
        ROW_NUMBER() OVER (ORDER BY ServiceDuration ASC) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM Transactions
),
P90Calc AS (
    SELECT 
        ServiceDuration AS P90,
        TotalRows,
        RowNum
    FROM SortedData
    WHERE RowNum = CAST(CEIL(0.9 * TotalRows) AS INT)
)
-- Tampilkan hasil
SELECT 
    P90Calc.P90,
    CASE 
        WHEN P90Calc.P90 <= 5 THEN 'SLA Achieved'
        ELSE 'SLA Not Achieved'
    END AS SLA_Status
FROM P90Calc;

-- =============================================
-- TUGAS STATS
-- ANALISIS DATA PENGUNJUNG PASAR
-- Hapus tabel jika sudah ada
DROP TABLE IF EXISTS VisitorData;

-- Buat tabel untuk data pengunjung
CREATE TABLE VisitorData (
    VisitDate DATE,
    Visitors INT
);

-- Masukkan data pengunjung ke dalam tabel
INSERT INTO VisitorData (VisitDate, Visitors) VALUES
('2022-12-01', 8), ('2022-12-02', 1), ('2022-12-03', 2),
('2022-12-04', 3), ('2022-12-05', 3), ('2022-12-06', 8),
('2022-12-07', 1), ('2022-12-08', 8), ('2022-12-09', 10),
('2022-12-10', 5), ('2022-12-11', 9), ('2022-12-12', 6),
('2022-12-13', 8), ('2022-12-14', 2), ('2022-12-15', 9),
('2022-12-16', 4), ('2022-12-17', 25), ('2022-12-18', 10),
('2022-12-19', 6), ('2022-12-20', 1), ('2022-12-21', 6),
('2022-12-22', 10), ('2022-12-23', 7), ('2022-12-24', 3),
('2022-12-25', 5), ('2022-12-26', 9), ('2022-12-27', 6),
('2022-12-28', 2), ('2022-12-29', 10), ('2022-12-30', 1);

-- 1. Hitung Mean dan Total Count
WITH Stats AS (
    SELECT 
        AVG(Visitors) AS Mean,
        COUNT(*) AS TotalCount,
        SUM((Visitors - (SELECT AVG(Visitors) FROM VisitorData)) * 
            (Visitors - (SELECT AVG(Visitors) FROM VisitorData))) / (COUNT(*) - 1) AS Variance,
        SQRT(SUM((Visitors - (SELECT AVG(Visitors) FROM VisitorData)) * 
                 (Visitors - (SELECT AVG(Visitors) FROM VisitorData))) / (COUNT(*) - 1)) AS StdDev
    FROM VisitorData
),
-- 2. Hitung Data Terurut
SortedData AS (
    SELECT 
        Visitors,
        ROW_NUMBER() OVER (ORDER BY Visitors ASC) AS RowNum,
        (SELECT TotalCount FROM Stats) AS TotalRows
    FROM VisitorData
),
-- 3. Hitung Percentiles Secara Terpisah
Q1Calc AS (
    SELECT Visitors AS Q1
    FROM SortedData
    WHERE RowNum = CAST(0.25 * TotalRows AS INT)
),
MedianCalc AS (
    SELECT Visitors AS Median
    FROM SortedData
    WHERE RowNum = CAST(0.5 * TotalRows AS INT)
),
Q3Calc AS (
    SELECT Visitors AS Q3
    FROM SortedData
    WHERE RowNum = CAST(0.75 * TotalRows AS INT)
),
-- 4. Hitung IQR dan Thresholds
IQRCalc AS (
    SELECT 
        (SELECT Q3 FROM Q3Calc) - (SELECT Q1 FROM Q1Calc) AS IQR
),
Thresholds AS (
    SELECT 
        (SELECT Q1 FROM Q1Calc) - 1.5 * (SELECT IQR FROM IQRCalc) AS LowerThreshold,
        (SELECT Q3 FROM Q3Calc) + 1.5 * (SELECT IQR FROM IQRCalc) AS UpperThreshold
)
-- 5. Tampilkan hasil analisis
SELECT 
    (SELECT Mean FROM Stats) AS Mean,
    (SELECT Median FROM MedianCalc) AS Median,
    (SELECT COUNT(Visitors) AS Frequency 
        FROM VisitorData 
        GROUP BY Visitors 
        ORDER BY Frequency DESC LIMIT 1) AS Mode,
    (SELECT Variance FROM Stats) AS Variance,
    (SELECT StdDev FROM Stats) AS StdDev,
    (SELECT Q1 FROM Q1Calc) AS Percentile_25,
    (SELECT Q3 FROM Q3Calc) AS Percentile_75,
    (SELECT IQR FROM IQRCalc) AS IQR,
    (SELECT LowerThreshold FROM Thresholds) AS LowerThreshold,
    (SELECT UpperThreshold FROM Thresholds) AS UpperThreshold,
    SUM(CASE 
        WHEN Visitors < (SELECT LowerThreshold FROM Thresholds) OR 
             Visitors > (SELECT UpperThreshold FROM Thresholds)
        THEN 1 ELSE 0 END) AS OutlierCount
FROM VisitorData;
