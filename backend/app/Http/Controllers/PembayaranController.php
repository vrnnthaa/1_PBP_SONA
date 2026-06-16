<?php

namespace App\Http\Controllers;

use App\Models\Pembayaran;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PembayaranController
{
    // GET /pembayaran
    public function index()
    {
        $pembayaran = Pembayaran::with('pemesanan')
            ->latest('id_pembayaran')
            ->get();

        return response()->json($pembayaran, 200);
    }

    // GET /pembayaran/{id}
    public function show($id)
    {
        $pembayaran = Pembayaran::with('pemesanan')->find($id);

        if (!$pembayaran) {
            return response()->json(['message' => 'Pembayaran tidak ditemukan'], 404);
        }

        return response()->json($pembayaran, 200);
    }

    // POST /pembayaran
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_pemesanan'       => 'required|integer|exists:pemesanan,id_pemesanan',
            'tanggal_pembayaran' => 'required|date',
            'jumlah_bayar'       => 'required|numeric|min:0',
            'metode_pembayaran'  => 'required|string|max:100',
        ]);

        // Cek apakah pemesanan sudah memiliki pembayaran
        $exists = Pembayaran::where('id_pemesanan', $validated['id_pemesanan'])->exists();
        if ($exists) {
            return response()->json(['message' => 'Pemesanan ini sudah memiliki data pembayaran'], 422);
        }

        $validated['status_pembayaran'] = Pembayaran::STATUS_PENDING;

        $pembayaran = Pembayaran::create($validated);

        return response()->json($pembayaran, 201);
    }

    // PUT /pembayaran/{id}
    public function update(Request $request, $id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json(['message' => 'Pembayaran tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'tanggal_pembayaran' => 'sometimes|date',
            'jumlah_bayar'       => 'sometimes|numeric|min:0',
            'metode_pembayaran'  => 'sometimes|string|max:100',
            'status_pembayaran'  => ['sometimes', Rule::in([
                Pembayaran::STATUS_PENDING,
                Pembayaran::STATUS_PAID,
                Pembayaran::STATUS_EXPIRED,
                Pembayaran::STATUS_FAILED,
            ])],
        ]);

        $pembayaran->update($validated);

        // Sinkronisasi status pemesanan berdasarkan status pembayaran
        if (isset($validated['status_pembayaran'])) {
            $pemesanan = Pemesanan::find($pembayaran->id_pemesanan);

            if ($pemesanan) {
                if ($validated['status_pembayaran'] === Pembayaran::STATUS_PAID) {
                    $pemesanan->update(['status_pemesanan' => Pemesanan::STATUS_AKTIF]);
                } elseif (in_array($validated['status_pembayaran'], [
                    Pembayaran::STATUS_FAILED,
                    Pembayaran::STATUS_EXPIRED,
                ])) {
                    $pemesanan->update(['status_pemesanan' => Pemesanan::STATUS_CANCELLED]);
                } 
            }
        }

        return response()->json($pembayaran, 200);
    }

    // DELETE /pembayaran/{id}
    public function destroy($id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json(['message' => 'Pembayaran tidak ditemukan'], 404);
        }

        $pembayaran->delete();

        return response()->json(['message' => 'Pembayaran berhasil dihapus'], 200);
    }

    // GET /pembayaran/pemesanan/{id_pemesanan}
    public function getByPemesanan($id_pemesanan)
    {
        $pembayaran = Pembayaran::with('pemesanan')
            ->where('id_pemesanan', $id_pemesanan)
            ->first();

        if (!$pembayaran) {
            return response()->json(['message' => 'Pembayaran tidak ditemukan untuk pemesanan ini'], 404);
        }

        return response()->json($pembayaran, 200);
    }
}