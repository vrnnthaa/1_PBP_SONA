<?php

namespace App\Http\Controllers;

use App\Models\Pemesanan;
use App\Models\AddOn;
use App\Models\Pembayaran;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\DB;

class PemesananController extends Controller
{
    public function index()
    {
        $pemesanan = Pemesanan::with(['user', 'kamar', 'pembayaran', 'review'])
            ->latest('id_pemesanan')
            ->get();

        return response()->json([
            'message' => 'Data pemesanan berhasil diambil',
            'data' => $pemesanan,
        ], 200);
    }

    public function show($id)
    {
        $pemesanan = Pemesanan::with(['user', 'kamar', 'pembayaran', 'review'])
            ->where('id_pemesanan', $id)
            ->first();

        if (!$pemesanan) {
            return response()->json([
                'message' => 'Pemesanan tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'message' => 'Detail pemesanan berhasil diambil',
            'data' => $pemesanan,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id_user',
            'id_kamar' => 'required|integer|exists:kamar,id_kamar',
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'jumlah_pengunjung' => 'required|integer|min:1',
            'total_biaya' => 'required|numeric|min:0',
            
            //Validasi untuk addons
            'addons' => 'array|nullable',
            'addons.*.nama' => 'required_with:addons|string',
            'addons.*.harga' => 'required_with:addons|numeric',
            'addons.*.keterangan' => 'required_with:addons|string',
        ]);

        $isOverlapping = Pemesanan::where('id_kamar', $validated['id_kamar'])
            ->whereIn('status_pemesanan', [
                Pemesanan::STATUS_AKTIF,
                Pemesanan::STATUS_MENUNGGU_REVIEW,
            ])
            ->where('check_in', '<', $validated['check_out'])
            ->where('check_out', '>', $validated['check_in'])
            ->exists();

        if ($isOverlapping) {
            return response()->json([
                'message' => 'Kamar tidak tersedia pada tanggal yang dipilih',
            ], 422);
        }

        DB::beginTransaction();

        try {
            $pemesananData = [
                'id_user' => $validated['id_user'],
                'id_kamar' => $validated['id_kamar'],
                'check_in' => $validated['check_in'],
                'check_out' => $validated['check_out'],
                'jumlah_pengunjung' => $validated['jumlah_pengunjung'],
                'total_biaya' => $validated['total_biaya'],
                'status_pemesanan' => Pemesanan::STATUS_AKTIF,
            ];
    
            $pemesanan = Pemesanan::create($pemesananData);

            if (!empty($validated['addons'])) {
                foreach ($validated['addons'] as $addon) {
                    $addonData = [
                        'id_pemesanan' => $pemesanan->id_pemesanan,
                        'nama_addon' => $addon['nama'],
                        'harga_addon' => $addon['harga'],
                        'keterangan_addon' => $addon['keterangan'],
                    ];
                    AddOn::create($addonData);
                }
            }

            DB::commit();

            return response()->json([
                'message' => 'Pemesanan berhasil dibuat',
                'data' => $pemesanan->load(['user', 'kamar', 'pembayaran', 'review']),
            ], 201);
            
        }catch (\Exception $e) {
            
            DB::rollBack();

            \Illuminate\Support\Facades\Log::error('Pemesanan Error Asli: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Terjadi kesalahan saat membuat pemesanan',
                'error' => $e->getMessage(),
            ], 500);
        }

    }

    public function update(Request $request, $id)
    {
        $pemesanan = Pemesanan::where('id_pemesanan', $id)->first();

        if (!$pemesanan) {
            return response()->json([
                'message' => 'Pemesanan tidak ditemukan',
            ], 404);
        }

        $validated = $request->validate([
            'id_user' => 'sometimes|integer|exists:users,id_user',
            'id_kamar' => 'sometimes|integer|exists:kamar,id_kamar',
            'check_in' => 'sometimes|date|after_or_equal:today',
            'check_out' => 'sometimes|date',
            'jumlah_pengunjung' => 'sometimes|integer|min:1',
            'total_biaya' => 'sometimes|numeric|min:0',
            'status_pemesanan' => [
                'sometimes',
                Rule::in([
                    Pemesanan::STATUS_TIDAK_AKTIF,
                    Pemesanan::STATUS_AKTIF,
                    Pemesanan::STATUS_CANCELLED,
                    Pemesanan::STATUS_MENUNGGU_REVIEW,
                    Pemesanan::STATUS_SUDAH_REVIEW,
                ]),
            ],
        ]);

        $idKamar = $validated['id_kamar'] ?? $pemesanan->id_kamar;
        $checkIn = $validated['check_in'] ?? $pemesanan->check_in;
        $checkOut = $validated['check_out'] ?? $pemesanan->check_out;

        $checkInDate = is_string($checkIn) ? $checkIn : $checkIn->format('Y-m-d');
        $checkOutDate = is_string($checkOut) ? $checkOut : $checkOut->format('Y-m-d');

        if ($checkOutDate <= $checkInDate) {
            return response()->json([
                'message' => 'Tanggal check_out harus setelah check_in',
            ], 422);
        }

        $isOverlapping = Pemesanan::where('id_kamar', $idKamar)
            ->where('id_pemesanan', '!=', $pemesanan->id_pemesanan)
            ->whereIn('status_pemesanan', [
                Pemesanan::STATUS_AKTIF,
                Pemesanan::STATUS_MENUNGGU_REVIEW,
            ])
            ->where('check_in', '<', $checkOutDate)
            ->where('check_out', '>', $checkInDate)
            ->exists();

        if ($isOverlapping) {
            return response()->json([
                'message' => 'Kamar tidak tersedia pada tanggal yang dipilih',
            ], 422);
        }

        $pemesanan->update($validated);

        return response()->json([
            'message' => 'Pemesanan berhasil diperbarui',
            'data' => $pemesanan->load(['user', 'kamar', 'pembayaran', 'review']),
        ], 200);
    }

    public function destroy($id)
    {
        $pemesanan = Pemesanan::where('id_pemesanan', $id)->first();

        if (!$pemesanan) {
            return response()->json([
                'message' => 'Pemesanan tidak ditemukan',
            ], 404);
        }

        $pemesanan->delete();

        return response()->json([
            'message' => 'Pemesanan berhasil dihapus',
        ], 200);
    }

    public function getByStatus($status)
    {
        $allowedStatus = [
            Pemesanan::STATUS_TIDAK_AKTIF,
            Pemesanan::STATUS_AKTIF,
            Pemesanan::STATUS_CANCELLED,
            Pemesanan::STATUS_MENUNGGU_REVIEW,
            Pemesanan::STATUS_SUDAH_REVIEW,
        ];

        if (!in_array($status, $allowedStatus)) {
            return response()->json([
                'message' => 'Status tidak valid',
            ], 422);
        }

        $pemesanan = Pemesanan::with(['user', 'kamar', 'pembayaran', 'review'])
            ->where('status_pemesanan', $status)
            ->latest('id_pemesanan')
            ->get();

        return response()->json([
            'message' => 'Data pemesanan berdasarkan status berhasil diambil',
            'data' => $pemesanan,
        ], 200);
    }

    // public function getByUser($id_user)
    // {
    //     $pemesanan = Pemesanan::with(['kamar', 'pembayaran', 'review'])
    //         ->where('id_user', $id_user)
    //         ->latest('id_pemesanan')
    //         ->get();

    //     return response()->json([
    //         'message' => 'Data pemesanan user berhasil diambil',
    //         'data' => $pemesanan,
    //     ], 200);
    // }

    public function updateStatusReview($id_user)
    {
        $today = date('Y-m-d');

        Pemesanan::where('id_user', $id_user)
            ->where('status_pemesanan', Pemesanan::STATUS_AKTIF)
            ->where('check_out', '<=', $today)
            ->whereHas('pembayaran', function ($query) {
                $query->where('status_pembayaran', Pembayaran::STATUS_PAID);
            })
            ->update(['status_pemesanan' => Pemesanan::STATUS_MENUNGGU_REVIEW]);
    }

    public function getByUser($id_user)
    {
        // Jalankan update status review otomatis
        $this->updateStatusReview($id_user);

        // Kita gunakan model Pemesanan, pastikan relasi di Model sudah didefinisikan dengan benar
        $pemesanan = Pemesanan::with(['kamar.hotel', 'pembayaran', 'review']) // Tambahkan kamar.hotel agar bisa menampilkan nama hotel
            ->where('id_user', $id_user)
            ->latest('id_pemesanan')
            ->get()
            ->filter(function ($item) {
                // Filter manual jika ada relasi yang null untuk mencegah error aplikasi
                return $item->kamar !== null; 
            })
            ->values(); // Reset index array

        return response()->json([
            'message' => 'Data pemesanan user berhasil diambil',
            'data' => $pemesanan,
        ], 200);
    }

    

    // public function getByUser($id_user)
    // {
    //     $pemesanan = Pemesanan::where('id_user', $id_user)
    //         ->latest('id_pemesanan')
    //         ->get();

    //     return response()->json([
    //         'message' => 'Data pemesanan user berhasil diambil',
    //         'data' => $pemesanan,
    //     ], 200);
    // }
}