## 1. Konsep Bisnis: "PRINTFLOW Hybrid Logistik"

Platform cetak online yang fokus pada **Hyper-Local Delivery**. Kita tidak hanya mengandalkan ekspedisi reguler, tapi memberdayakan driver internal, mitra perorangan (freelance ojol), dan kurir sekolah untuk menjangkau semua kalangan dengan sistem pembayaran COD/NON COD yang aman.

* **Kurir/Driver (Android):** Pengguna yang bertugas menjemput file (jika butuh scan) atau mengantar hasil cetak dan menerima uang tunai (COD/NON COD).
* **Partner Sekolah/Koperasi/Office/Public (Web/Android):** Admin sekolah yang mengelola pesanan kolektif siswa.
* **Agen/Partner (Android):** Pengguna khusus yang benyediakan daftar file customer mereka dan menentukan titik antat/jemput file (jika butuh scan) untuk driver atau mengantar hasil cetak dan menerima uang tunai (COD/NON COD).

### B. Fitur MVP Tambahan (Logistik & COD/NON COD)

| Fitur | Deskripsi | Platform |
| --- | --- | --- |
| **COD/NON COD Verification** | Sistem penguncian pesanan COD/NON COD. Kurir harus input jumlah uang yang diterima di aplikasi untuk menyelesaikan pesanan. | Android (Driver) |
| **Antar Jemput** | Sistem antar jemput pesanan | Android (Driver) - Web (Admin) Monitoring |
| **Driver Management** | Fitur untuk mendaftarkan driver internal atau mitra perorangan (Freelance). | Web (Admin) |
| **Partner Management** | Fitur untuk mendaftarkan driver internal atau mitra perorangan (Freelance). | Web (Admin) |
| **School/University Hub Point** | Pilihan pengiriman ke "Titik Jemput" di sekolah mitra dengan tarif flat/murah. | Web & Android |
| **Office Hub Point** | Pilihan pengiriman ke "Titik Jemput" di lingkungan peekantoran mitra dengan tarif flat/murah. | Web & Android |
| **Public Hub Point** | Pilihan pengiriman ke "Titik Jemput" di area publik/masyarakat umum mitra dengan tarif flat/murah. | Web & Android |
| **E-Receipt Print** | Driver bisa mencetak/membagikan tanda terima digital via WA setelah bayar COD/NON COD. | Android (Driver) |
| **Document Security Bag** | Fitur tracking khusus: "Dokumen dalam amplop tersegel" dengan foto bukti segel saat berangkat. | Android (Driver) |

---

### C. Alur Aplikasi (Flow Logistik & COD/NON COD)

1. **Checkout (User):**
* User memilih produk (Cetak Tugas/Dokumen).
* Memilih metode pengiriman: **"Kurir Lokal (COD/NON COD)"** atau **"Ambil di Sekolah"**.
* Sistem menghitung total (Biaya Cetak + Ongkir).

2. **Order Processing (Internal):**
* Admin cetak menyelesaikan dokumen.
* Admin menekan tombol "Request Pickup".

3. **Delivery (Driver/Mitra):**
* Driver (Internal/Mitra Perorangan) menerima notifikasi di aplikasi Android mereka.
* Driver mengambil barang di workshop/door to door.
* **Saat tiba di lokasi:** Driver menyerahkan dokumen -> Menerima uang tunai -> Input jumlah uang di aplikasi -> Pesanan "Closed".

4. **Settlement (Finance):**
* Sistem mencatat saldo yang dibawa driver. Di akhir hari, driver menyetor uang tunai ke Admin (atau via transfer) untuk mengosongkan limit saldo mereka.

---

## I. INTEGRASI AI PADA SOFTWARE MOBILE (USER & PARTNER)

### A. AI Verification (Sisi User & Admin)

Fitur ini berfungsi sebagai "Quality Control Otomatis" sebelum file masuk ke mesin cetak.

1. **AI Image Upscaler & Fixer:** Jika user mengunggah foto dengan resolusi rendah (pecah), AI akan secara otomatis meningkatkan ketajaman (*denoising* dan *super-resolution*) agar layak cetak.
2. **Auto-Layout & Pre-flight AI:** AI mendeteksi elemen penting (seperti teks atau logo) yang terlalu dekat dengan garis potong (*bleed*) dan memberikan saran koreksi otomatis.
3. **OCR (Optical Character Recognition):** Untuk cetak dokumen seperti KTP atau dokumen resmi sekolah, AI akan mengekstraksi data teks secara otomatis untuk mempermudah pengisian formulir/arsip digital.

### 1. Blue Print Fitur & Software (Mobile User & Partner)

| Komponen | Fitur AI | Fungsi Utama |
| --- | --- | --- |
| **User App** | **AI Print-Validator** | Verifikasi otomatis kelayakan file (resolusi, warna CMYK, dan margin). |
| **User App** | **AI Background Remover** | Memungkinkan user menghapus background foto secara instan sebelum dicetak. |
| **Partner App** | **AI Bio-Verification** | Verifikasi wajah pemilik agen/jasa (*Face Recognition*) /ID/Rek.Bank/Bio Perusahaan/ComPro dll. saat akan memulai *shift* untuk keamanan akun. |
| **Partner App** | **AI Smart-Nav** | Navigasi khusus yang menghindari jalur macet ekstrem dan mengelompokkan titik antar/jemput yang searah. |
| **Partner App** | **AI Photo QC** | Saat driver memotret bukti serah terima, AI mengecek apakah foto tersebut jelas/tidak blur sebagai syarat sah COD/NON COD. |
| **Driver App** | **AI Bio-Verification** | Verifikasi wajah driver (*Face Recognition*) saat akan memulai *shift* untuk keamanan akun. |
| **Driver App** | **AI Smart-Nav** | Navigasi khusus yang menghindari jalur macet ekstrem dan mengelompokkan titik antar yang searah. |
| **Driver App** | **AI Photo QC** | Saat driver memotret bukti serah terima, AI mengecek apakah foto tersebut jelas/tidak blur sebagai syarat sah COD/NON COD. |

### 2. Blue Print Web (Dashboard Monitoring Web-Based)

Dashboard admin **AI-Assisted Oversight**:

1. **AI Demand Forecasting:** Menganalisis data historis untuk memprediksi kapan permintaan cetak akan melonjak (misal: Musim ujian sekolah atau pendaftaran sekolah baru) sehingga admin bisa menyetok kertas lebih awal.
2. **AI Fraud Detection (COD/NON COD):** Mendeteksi pola mencurigakan pada transaksi COD/NON COD (misal: Driver yang sering menunda setoran tunai atau rute yang tidak sesuai dengan navigasi).
3. **Automated Billing AI:** Memisahkan secara otomatis komisi untuk mitra ojol perorangan dan potongan untuk koperasi sekolah mitra.
Bukan sekadar Google Maps biasa, tapi sistem navigasi yang cerdas.
4. **Dynamic Route Optimization (AI-Route):** Jika driver membawa 10 paket sekaligus ke beberapa sekolah dan alamat COD/NON COD, AI akan menghitung urutan pengantaran paling efisien berdasarkan kemacetan *real-time* dan waktu tutup sekolah untuk menghemat BBM.
5. **Predictive Delivery Time:** AI memberikan estimasi waktu tiba (ETA) yang lebih akurat ke pelanggan dengan mempelajari pola kecepatan driver di area tersebut pada jam-jam tertentu.
---

## III. BLUE PRINT TEKNOLOGI (STACK DETAIL)

* **AI Engine:**
* *Computer Vision:* Menggunakan **TensorFlow Lite** (untuk dipasang di perangkat mobile agar cepat).
* *Mapping & Route:* **Google OR-Tools** atau **GraphHopper** untuk optimasi rute.
* **Verification API:** Menggunakan **OpenCV** untuk pemrosesan gambar dan **Tesseract** untuk OCR dokumen.
* **Cloud Computing:** Pemrosesan AI berat dilakukan di sisi server menggunakan **Python (FastAPI)** untuk memastikan aplikasi mobile tetap ringan.
Frontend: Flutter (untuk mobilitas Android/iOS) dan React.js untuk dashboard web.  
Backend: Node.js untuk menangani unggahan file besar dengan performa tinggi.  
AI Engine: TensorFlow Lite untuk pemeriksaan kualitas gambar dan Google OR-Tools untuk optimasi rute navigasi. 
AWS cloudstorage Api dan jwt, github ci
---

## IV. VISUALISASI BLUEPRINT SISTEM (LOGIKA KERJA)

1. **INPUT (User):** User upload file + Pilih Alamat.
2. **VERIFIKASI (AI):** Sistem AI mengecek: "File Pecah?" -> Jika ya, tawarkan *Upscale*. "Alamat Valid?" -> Jika ya, lanjut ke pembayaran.
3. **PROSES (Admin):** Admin monitoring antrean di Web Dashboard. AI menyarankan mesin mana yang paling kosong untuk digunakan.
4. **NAVIGASI (Driver):** Driver klik "Mulai Antar". **AI-Nav** menyusun rute: *Sekolah A -> Sekolah B -> Rumah User C (COD/NON COD)*.
5. **CLOSING (AI-Check):** Driver foto barang + terima uang. **AI Photo QC** mengonfirmasi foto bukti layak. Data keuangan langsung ter-update di Web Admin.
6. **UI/UX** fast reliable untuk srmua device dan bisa di akses di tv android
---
# 🔧 PRINTFLOW - Required Tool Versions & Dependencies

## 📋 Complete Version Requirements Matrix

### A. Core Development Tools

| Tool | Minimum Version | Recommended Version | Command to Check | Notes |
|------|----------------|---------------------|------------------|-------|
| **Node.js** | v18.0.0 | v20.11.0 LTS | `node --version` | Required for backend |
| **npm** | v9.0.0 | v10.2.4 | `npm --version` | Node package manager |
| **PostgreSQL** | v14.0 | v15.5 | `psql --version` | Primary database |
| **Redis** | v6.2 | v7.2.4 | `redis-server --version` | Cache & session store |
| **Flutter** | v3.13.0 | v3.16.9 | `flutter --version` | Mobile apps |
| **Dart** | v3.1.0 | v3.2.3 | `dart --version` | Flutter language |
| **Go** | v1.20 | v1.21.5 | `go version` | For OR-Tools (optional) |
| **Python** | v3.10 | v3.11.7 | `python --version` | For AI services |

### B. Backend Dependencies

| Package | Minimum Version | Recommended | Purpose |
|---------|----------------|-------------|---------|
| **express** | ^4.18.0 | 4.18.2 | Web framework |
| **@prisma/client** | ^5.0.0 | 5.7.1 | Database ORM |
| **prisma** | ^5.0.0 | 5.7.1 | Prisma CLI |
| **jsonwebtoken** | ^9.0.0 | 9.0.2 | JWT handling |
| **bcryptjs** | ^2.4.0 | 2.4.3 | Password hashing |
| **socket.io** | ^4.5.0 | 4.5.4 | WebSocket |
| **multer** | ^1.4.5 | 1.4.5-lts.1 | File upload |
| **sharp** | ^0.32.0 | 0.33.1 | Image processing |
| **tesseract.js** | ^5.0.0 | 5.0.5 | OCR engine |
| **aws-sdk** | ^2.1400.0 | 2.1500.0 | AWS services |
| **redis** | ^4.6.0 | 4.6.10 | Redis client |
| **axios** | ^1.4.0 | 1.6.2 | HTTP client |
| **dotenv** | ^16.0.0 | 16.3.1 | Environment variables |
| **cors** | ^2.8.5 | 2.8.5 | CORS middleware |
| **helmet** | ^7.0.0 | 7.1.0 | Security headers |
| **express-rate-limit** | ^6.10.0 | 7.1.5 | Rate limiting |
| **winston** | ^3.10.0 | 3.11.0 | Logging |
| **joi** | ^17.9.0 | 17.11.0 | Validation |
| **nodemailer** | ^6.9.0 | 6.9.7 | Email (fallback) |
| **bull** | ^4.11.0 | 4.11.5 | Queue system |

### C. Frontend Web Dependencies

| Package | Minimum Version | Recommended | Purpose |
|---------|----------------|-------------|---------|
| **react** | ^18.2.0 | 18.2.0 | UI framework |
| **react-dom** | ^18.2.0 | 18.2.0 | DOM rendering |
| **vite** | ^4.4.0 | 5.0.10 | Build tool |
| **tailwindcss** | ^3.3.0 | 3.4.0 | CSS framework |
| **axios** | ^1.4.0 | 1.6.2 | HTTP client |
| **socket.io-client** | ^4.5.0 | 4.5.4 | WebSocket client |
| **react-router-dom** | ^6.14.0 | 6.20.1 | Routing |
| **recharts** | ^2.7.0 | 2.10.3 | Charts |
| **@react-google-maps/api** | ^2.19.0 | 2.19.2 | Google Maps |
| **react-query** | ^3.39.0 | 3.39.3 | Data fetching |
| **zustand** | ^4.3.0 | 4.4.7 | State management |
| **react-hook-form** | ^7.45.0 | 7.48.2 | Form handling |
| **framer-motion** | ^10.12.0 | 10.16.16 | Animations |
| **date-fns** | ^2.30.0 | 2.30.0 | Date formatting |

### D. Flutter/Dart Dependencies (pubspec.yaml)

### E. Infrastructure & DevOps Tools

| Tool | Minimum Version | Recommended | Purpose |
|------|----------------|-------------|---------|
| **Docker** | v20.10.0 | v24.0.7 | Containerization |
| **Docker Compose** | v2.20.0 | v2.23.0 | Multi-container |
| **Terraform** | v1.5.0 | v1.6.6 | Infrastructure as Code |
| **AWS CLI** | v2.13.0 | v2.13.35 | AWS management |
| **kubectl** | v1.27.0 | v1.29.0 | Kubernetes |
| **Helm** | v3.12.0 | v3.13.2 | K8s package manager |
| **PM2** | v5.3.0 | v5.3.0 | Process manager |
| **nginx** | v1.22.0 | v1.24.0 | Web server |
| **certbot** | v2.0.0 | v2.8.0 | SSL certificates |
| **Git** | v2.30.0 | v2.43.0 | Version control |
| **GitHub CLI** | v2.30.0 | v2.42.0 | GitHub operations |

### E. AWS Service Versions Required

| AWS Service | Configuration | Notes |
|-------------|--------------|-------|
| **Cognito** | User Pool with WebAuthn support | Requires Essentials tier |
| **RDS PostgreSQL** | Version 15.5+ | Supports pgcrypto, postgis |
| **ElastiCache Redis** | Version 7.1+ | Supports RedisJSON |
| **SES** | Production access | For bulk email |
| **SQS** | Standard or FIFO | For email queue |
| **SNS** | Standard | For email events |
| **ECS** | Fargate launch type | For containers |
| **S3** | Latest | For file storage |
| **CloudFront** | Latest | CDN for static assets |
| **Lambda** | Node.js 18.x | For triggers |
| **API Gateway** | HTTP API or REST | For endpoints |

---

**Ringkasan Penting:**
- Gunakan **Node.js 20 LTS** (bukan 18 atau 21)
- **PostgreSQL 15** (bukan 16 untuk kompatibilitas Prisma)
- **Flutter 3.16 stable** channel
- **Docker 24+** untuk production