# JejakGS

JejakGS adalah aplikasi mobile Flutter untuk layanan alumni STIKES Gunung Sari. Aplikasi ini menjadi mobile client untuk alumni agar dapat melakukan aktivasi akun, melengkapi profil, mengikuti tracer study, mengakses layanan IKA, melihat informasi karier/event, kartu digital, notifikasi, dan Jejak Angkatan.

Semua data utama berasal dari API SIMAWA-GS. Aplikasi tidak menggunakan data dummy untuk fitur alumni, tracer, IKA, loker, event, notifikasi, atau Jejak Angkatan. Jika data API belum tersedia, layar harus menampilkan `LoadingState`, `EmptyState`, atau `ErrorState`.

## Arsitektur Sistem

JejakGS menggunakan arsitektur modular berbasis Flutter:

- UI berada di `screens/` dan `widgets/`.
- State aplikasi berada di `providers/state/AppState`.
- Model domain berada di `models/`.
- Integrasi SIMAWA-GS berada di `services/`.
- Konfigurasi environment berada di `config/`.
- Design system berada di `widgets/design_system/`.

Alur utama:

1. User login/aktivasi melalui `AuthService`.
2. Token disimpan aman dengan `flutter_secure_storage`.
3. `AuthorizationInterceptor` menambahkan `Authorization: Bearer <token>` untuk request authenticated.
4. `AppState` mengambil profil alumni dari SIMAWA-GS.
5. UI menampilkan fitur berdasarkan `verification_status` dan `role`.
6. Setiap fitur mengambil data melalui service API terkait.

## Hubungan JejakGS, SIMAWA-GS, dan SIAKAD-GS

- **JejakGS**: aplikasi mobile alumni untuk pengguna akhir.
- **SIMAWA-GS**: backend utama layanan alumni. Semua data profil alumni, tracer, IKA, loker, event, notifikasi, kartu digital, privacy setting, dan Jejak Angkatan berasal dari SIMAWA-GS.
- **SIAKAD-GS**: sumber data akademik alumni baru/terhubung SSO. Data akademik dari SIAKAD-GS bersifat read-only di aplikasi dan disinkronkan melalui SIMAWA-GS.

JejakGS tidak langsung menjadi sumber kebenaran data akademik. Source of truth tetap berada pada SIMAWA-GS/SIAKAD-GS.

## Flow Alumni Lama

Flow alumni lama digunakan untuk alumni yang belum memiliki akun aktif atau belum tersinkron penuh melalui SIAKAD-GS.

1. Alumni melakukan register mandiri.
2. Alumni mengisi NIM, program studi, tahun angkatan, dan tahun lulus.
3. Alumni mengunggah foto ijazah sebagai dokumen pendukung verifikasi.
4. Alumni membuat kredensial email/password.
5. Alumni login menggunakan email/password.
6. Akun masuk status `pending` dan menunggu verifikasi admin SIMAWA-GS.
7. Admin SIMAWA-GS melakukan `approve`, `decline`, atau meminta `revision_required`.
8. Alumni hanya dapat mengakses fitur utama setelah status menjadi `verified`.

Foto ijazah pada flow alumni lama hanya digunakan untuk proses verifikasi admin SIMAWA-GS dan tidak boleh tampil di profil publik, Jejak Angkatan, kartu alumni, kartu IKA, forum, event peserta, atau direktori alumni.

## Flow Alumni Baru

Flow alumni baru digunakan untuk alumni yang data akademiknya sudah tersedia di SIAKAD-GS.

1. Data akademik alumni tersedia di SIAKAD-GS.
2. Email alumni diperbarui oleh bagian akademik di SIAKAD-GS jika diperlukan.
3. Alumni login melalui SSO/SIAKAD.
4. Data akademik seperti NIM, nama, program studi, tahun angkatan, dan tahun lulus bersifat read-only di JejakGS.
5. Alumni melengkapi data non-akademik seperti email, nomor HP, domisili, pekerjaan, instansi, dan sosial media.
6. Akses fitur mengikuti `verification_status` dari SIMAWA-GS.

Data akademik alumni baru tidak diedit langsung dari JejakGS. Perbaikan data akademik dilakukan melalui SIAKAD-GS/SIMAWA-GS sesuai kewenangan institusi.

## Struktur Folder

```text
lib/
  app.dart
  main.dart
  config/              Konfigurasi aplikasi, route, environment API.
  core/                Konstanta, error type, fondasi lintas fitur.
  models/              Model domain dan parser JSON.
  providers/state/     Global app state dan aturan akses.
  repositories/        Abstraksi akses data umum.
  screens/             Halaman aplikasi per modul.
  services/            API client, interceptor, token storage, feature services.
  themes/              Theme aplikasi JejakGS.
  utils/               Helper umum.
  widgets/             Komponen UI reusable.
```

## Konfigurasi Base URL API

Base URL SIMAWA-GS dikonfigurasi melalui compile-time environment:

```bash
flutter run --dart-define=SIMAWA_GS_BASE_URL=https://domain-simawa-gs.ac.id/api
```

Environment dan timeout opsional:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=SIMAWA_GS_BASE_URL=https://domain-simawa-gs.ac.id/api \
  --dart-define=SIMAWA_GS_TIMEOUT_SECONDS=30
```

Variabel yang didukung:

- `APP_ENV`: `development`, `staging`, atau `production`.
- `SIMAWA_GS_BASE_URL`: base URL API SIMAWA-GS.
- `SIMAWA_GS_TIMEOUT_SECONDS`: timeout request API, default `30`.

Jika `SIMAWA_GS_BASE_URL` belum dikonfigurasi, aplikasi tetap dapat dibuka, tetapi request API akan gagal dan UI harus menampilkan state yang sesuai.

## Cara Menjalankan Aplikasi

Install dependency:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run --dart-define=SIMAWA_GS_BASE_URL=https://domain-simawa-gs.ac.id/api
```

Pemeriksaan kualitas:

```bash
dart format lib test
flutter analyze
flutter test
```

## Daftar Fitur

- Login dan aktivasi akun alumni.
- Lengkapi profil alumni.
- Status verifikasi alumni: `pending`, `revision_required`, `declined`, `verified`, `inactive`.
- Beranda alumni berbasis dashboard SIMAWA-GS.
- Tracer Study: status, form dinamis, draft, submit final, history, review.
- IKA: status keanggotaan, pendaftaran, kartu anggota, event anggota, iuran/donasi, voting, forum.
- Kartu Alumni digital.
- Kartu IKA digital.
- Loker/Karier: list, search, filter, detail, simpan, riwayat lamaran.
- Event Alumni: list, detail, registrasi, tiket/QR, sertifikat, galeri.
- Jejak Angkatan: daftar teman seangkatan dengan aturan privacy ketat.
- Informasi Umum: pengumuman, kategori, banner, search, bookmark.
- Notifikasi: list, detail, mark as read, unread badge, register push token placeholder.
- Pengaturan privasi profil publik.
- Logout dan token expiry handling.

## Endpoint API Yang Dibutuhkan

Auth:

- `POST /auth/login`
- `GET /auth/me`
- `POST /auth/activate`
- `POST /auth/logout`

Alumni:

- `GET /alumni/profile`
- `PATCH /alumni/profile`
- `GET /alumni/card`
- `GET /alumni`
- `GET /alumni/batchmates`
- `GET /alumni/batchmates/{id}`

Dashboard:

- `GET /dashboard`

Tracer:

- `GET /tracer/progress`
- `GET /tracer/form`
- `POST /tracer/draft`
- `POST /tracer/submit`
- `GET /tracer/history`
- `GET /tracer/submissions/{submissionId}`

IKA:

- `GET /ika/status`
- `GET /ika/information`
- `POST /ika/membership`
- `GET /ika/member-card`
- `GET /ika/events`
- `GET /ika/payments`
- `GET /ika/voting`
- `GET /ika/forum`
- `GET /ika/board/forum`
- `GET /ika/board/dashboard`
- `GET /ika/board/registrations`
- `POST /ika/board/broadcasts`
- `GET /ika/board/member-recap`
- `GET /ika/board/payment-recap`

Loker:

- `GET /jobs`
- `GET /jobs/{id}`
- `POST /jobs/{id}/save`
- `DELETE /jobs/{id}/save`
- `GET /jobs/saved`
- `GET /jobs/applications`

Event:

- `GET /events`
- `GET /events/{id}`
- `POST /events/{id}/register`
- `GET /events/{id}/ticket`
- `GET /events/{id}/certificate`
- `GET /events/{id}/gallery`
- `POST /events/{id}/evaluation`

Informasi Umum:

- `GET /information/announcements`
- `GET /information/announcements/{id}`
- `POST /information/announcements/{id}/bookmark`
- `DELETE /information/announcements/{id}/bookmark`

Notifikasi:

- `GET /notifications`
- `GET /notifications/{id}`
- `PATCH /notifications/{id}/read`
- `PATCH /notifications/read-all`
- `POST /notifications/push-token`

Privacy:

- `GET /privacy`
- `PATCH /privacy`

## Role dan Hak Akses

JejakGS menerapkan dua lapisan akses:

1. `verification_status`
2. `role`

Status verifikasi harus dicek lebih dulu. Role hanya berlaku jika akun alumni sudah `verified`. Status `verified` adalah syarat utama untuk mengakses fitur JejakGS.

Status:

- `pending`: akun sedang menunggu verifikasi admin SIMAWA-GS dan tidak dapat mengakses fitur utama.
- `revision_required`: alumni dapat melihat catatan admin dan memperbaiki data yang diminta.
- `declined`: alumni dapat melihat alasan penolakan dan tidak dapat mengakses fitur utama.
- `verified`: alumni dapat mengakses fitur sesuai role.
- `inactive`: akun tidak aktif dan tidak dapat mengakses fitur utama.

Role:

- `alumni`: akses fitur dasar alumni, seperti Beranda, Tracer, Loker, Event umum, Jejak Angkatan, dan Kartu Alumni.
- `ika_member`: akses fitur dasar dan fitur anggota IKA, termasuk Kartu IKA, event anggota, iuran/donasi, voting, dan forum anggota.
- `ika_officer`: akses fitur anggota IKA dan fitur pengurus IKA.
- `alumni_admin`: akses administratif alumni sesuai dukungan backend SIMAWA-GS.
- `super_admin`: akses tertinggi sesuai kebijakan backend SIMAWA-GS.

Fitur utama tidak boleh dibuka hanya berdasarkan role. `verification_status == verified` adalah syarat utama.

## Aturan Privasi Data Alumni

JejakGS menerapkan aturan privacy berikut:

- Nomor HP alumni tidak boleh ditampilkan kepada alumni lain.
- WhatsApp alumni tidak boleh ditampilkan kepada alumni lain.
- Email pribadi tidak tampil default pada profil publik/Jejak Angkatan.
- Alamat lengkap tidak boleh tampil.
- NIK tidak boleh tampil.
- Tanggal lahir tidak boleh tampil.
- Foto ijazah tidak boleh tampil di Jejak Angkatan, direktori alumni, profil publik, kartu alumni, kartu IKA, forum, atau event peserta.
- Foto ijazah hanya boleh digunakan untuk register alumni lama, perbaikan data jika diminta admin, dan verifikasi oleh admin backend SIMAWA-GS.
- Data alumni manual register yang belum `verified` tidak boleh tampil di Jejak Angkatan, direktori alumni, statistik publik, atau kartu alumni.
- Alumni `pending`, `revision_required`, `declined`, dan `inactive` tidak boleh muncul di Jejak Angkatan.
- Field sosial media hanya boleh tampil jika alumni mengizinkan melalui privacy setting.
- Alumni dapat menonaktifkan tampilan profil di Jejak Angkatan melalui `show_in_batchmates`.

Catatan penting: **nomor HP tidak boleh ditampilkan ke alumni lain dalam kondisi apa pun.**

## Data Tracer dan IKA

Data Tracer Study dan IKA berasal dari SIMAWA-GS:

- Pertanyaan tracer, progress, draft, submit final, history, dan review harus dimuat dari endpoint Tracer SIMAWA-GS.
- Status keanggotaan IKA, pendaftaran, kartu IKA, event anggota, pembayaran, voting, forum, dan fitur pengurus harus dimuat dari endpoint IKA SIMAWA-GS.
- Tidak boleh menggunakan data contoh/dummy pada production screen.

## Cara Build APK

Build APK debug:

```bash
flutter build apk --debug \
  --dart-define=SIMAWA_GS_BASE_URL=https://domain-simawa-gs.ac.id/api
```

Build APK release:

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=SIMAWA_GS_BASE_URL=https://domain-simawa-gs.ac.id/api \
  --dart-define=SIMAWA_GS_TIMEOUT_SECONDS=30
```

Output APK release biasanya berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Sebelum release, jalankan:

```bash
dart format lib test
flutter analyze
flutter test
```
