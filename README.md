# SONA (Smooth Online Night Accommodation) 
> **Tugas Besar Pemrograman Berbasis Platform - Kelompok 1**

# **1. Penjelasan Aplikasi**
SONA adalah aplikasi pemesanan hotel berbasis mobile yang yang dilengkapi dengan fitur pencarian hotel dengan lokasi, pemesanan, cetak bukti pembayaran, dan sistem review pesanan. 
Aplikasi ini dikembangkan dengan framework Flutter sebagai frontend dan didukung oleh Laravel dan Firebase sebagai sistem backend.

# **2. Fitur Besar Aplikasi**
Fitur besar aplikasi ini meliputi:
  - Pencarian hotel berbasis lokasi.
  - Pemesanan hotel dengan opsi addon.
  - Pembayaran dengan konfirmasi menggunakan sidik jari.
  - Pencetakan hasil bukti pembayaran dengan format PDF.
  - Sistem review dengan opsi menggunakan kamera.
  - Sistem profile yang dapat dimodifikasi.
  
# **3. Link ERD dan Figma**
Berikut adalah ERD dan Figma SONA:
  - https://lucid.app/lucidchart/8e3686a4-28d0-4312-97d5-ca1601662616/edit?viewport_loc=-9786%2C-885%2C7794%2C4038%2C0_0&invitationId=inv_be325e76-7641-4c0c-b836-4db530d896c5
  - https://www.figma.com/design/wCBb9kgA2DOEtQFFFdbrlG/Mock-Up-Desain?node-id=4-12&p=f&t=nQ7vU2UcDGexqiGV-0

# **4. Pembagian Tugas**
  - Chaterina Olivia Putri Sugiarto
      - Mendesain halaman homepage, profile, dan review.
      - Mendesain ERD.
      - Membuat database menggunakan Supabase.
      - Membuat backend dan frontend serta mengintegrasikan halaman homepage, profile, dan review.
      - Membuat fitur map dan penggunaan hardware sidik jari dan kamera.
      - Mendeploy aplikasi menggunakan Railway untuk backend.

  - Deven Christian Aditya
      - Mendesain logo dan tema SONA.
      - Membuat animasi splash screen, halaman konfirmasi, dan animasi loading.
      - Mendesain halaman onboarding page, login, register, dan set-pin.
      - Membuat backend dan frontend serta mengintegrasikan halaman onboarding, login, register, dan set-pin.
      - Membuat fitur sign-in-with-Google dan notifikasi berbasis Firebase.
        
  - Dionisius Christinus Jan Alvin
      - Mendesain halaman history, pesanan, pembayaran.
      - Membantu dalam membuat database menggunakan Supabase.
      - Membuat backend dan frontend serta mengintegrasikan halaman history, pesanan, pembayaran.
      - Membuat fitur pembayaran dengan penggunaan hardware sidik jari.
        
  - Verrent Natha Aurelia
      - Mendesain fitur searching, halaman informasi hotel, kamar, dan detail kamar.
      - Membantu dalam mendesain ERD
      - Membuat backend dan frontend serta mengintegrasikan fitur searching, halaman informasi hotel, kamar, dan detail kamar.
      - Membuat fitur map pada halaman informasi hotel.

# **5. Kendala dan Solusi**
Berikut adalah beberapa kendala yang kami hadapi selama proses development dan bagaimana cara kami mengatasinya:
  - Device berbeda dalam melakukan run project: menggunakan ngrok untuk mempermudah run project sehingga tidak perlu mengganti konfigurasi setiap kali run.
  - Data yang bentrok di database: memastikan menambahkan data dengan menyesuaikan ID terlebih dahulu untuk tabel yang menggunakan 'auto-increment'.
  - Notifikasi tidak terkirim: memastikan bahwa status 'Menunggu Review' sudah tersedia.

# **DISCLAIMER**
Project berikut dibuat untuk memenuhi tugas mata kuliah Pemrograman Berbasis Platform di Program Studi Informatika, Fakultas Teknologi Industri, Universitas Atma Jaya Yogyakarta.
