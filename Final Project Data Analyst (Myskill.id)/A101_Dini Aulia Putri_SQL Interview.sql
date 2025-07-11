-- Nama: Dini Aulia Putri
-- Asal: Pariaman
-- Tugas 11

-- =============================================
--Jawaban Nomor 1
-- Jumlah perusahaan dengan postingan pekerjaan duplikat
-- Definisi duplikat: Dua atau lebih postingan pekerjaan dari perusahaan yang sama dengan judul (title) dan deskripsi (description) yang identik.
-- Langkah-langkah:
-- 1. Mengelompokkan data berdasarkan company_id, title, dan description.
-- 2. Mengidentifikasi kombinasi yang memiliki lebih dari satu entri (duplikat) menggunakan HAVING COUNT(*) > 1.
-- 3. Menghitung jumlah perusahaan unik (DISTINCT company_id) dari hasil identifikasi tersebut.

SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM job_listings
WHERE (company_id, title, description) IN (
    SELECT company_id, title, description
    FROM job_listings
    GROUP BY company_id, title, description
    HAVING COUNT(*) > 1
);

-- =============================================
--Jawaban Nomor 2
-- Perbedaan jumlah kartu kredit yang diterbitkan antara bulan dengan jumlah penerbitan tertinggi dan terendah
-- Langkah-langkah:
-- 1. Mengelompokkan data berdasarkan nama kartu (card_name).
-- 2. Menghitung jumlah maksimum (MAX) dan minimum (MIN) kartu yang diterbitkan untuk setiap kartu.
-- 3. Menghitung selisih antara jumlah maksimum dan minimum.
-- 4. Mengurutkan hasil berdasarkan selisih terbesar.

SELECT 
    card_name,
    MAX(issued_amount) - MIN(issued_amount) AS difference
FROM 
    monthly_cards_issued
GROUP BY 
    card_name
ORDER BY 
    difference DESC;
    
-- =============================================
--Jawaban Nomor 3
-- Persentase waktu yang dihabiskan untuk mengirim vs membuka snap berdasarkan kelompok usia
-- Langkah-langkah:
-- 1. Gabungkan tabel activities dengan tabel age_breakdown berdasarkan user_id.
-- 2. Kelompokkan data berdasarkan age_bucket dan activity_type ('send' dan 'open').
-- 3. Hitung total waktu untuk aktivitas 'send' dan 'open' untuk setiap kelompok usia.
-- 4. Hitung persentase waktu 'send' dan 'open' dari total waktu yang dihabiskan.
-- 5. Bulatkan hasil persentase hingga dua desimal.

SELECT 
    ab.age_bucket,
    ROUND(SUM(CASE WHEN a.activity_type = 'send' THEN a.time_spent ELSE 0 END) / SUM(a.time_spent) * 100.0, 2) AS send_perc,
    ROUND(SUM(CASE WHEN a.activity_type = 'open' THEN a.time_spent ELSE 0 END) / SUM(a.time_spent) * 100.0, 2) AS open_perc
FROM 
    activities a
JOIN 
    age_breakdown ab
ON 
    a.user_id = ab.user_id
WHERE 
    a.activity_type IN ('send', 'open')
GROUP BY 
    ab.age_bucket
ORDER BY 
    ab.age_bucket;

