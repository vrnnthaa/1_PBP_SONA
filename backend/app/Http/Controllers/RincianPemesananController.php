<?php

namespace App\Http\Controllers;

use App\Models\RincianPemesanan;
use Illuminate\Http\Request;

class RincianPemesananController
{
    public function index()
    {
        $rincian = RincianPemesanan::with(['pemesanan', 'kamar'])
            ->where('is_delete', false)
            ->latest('id_rincianpemesanan')
            ->get();

        return response()->json($rincian, 200);
    }

    public function show($id)
    {
        $rincian = RincianPemesanan::with(['pemesanan', 'kamar'])
            ->where('id_rincianpemesanan', $id)
            ->where('is_delete', false)
            ->first();

        if (!$rincian) {
            return response()->json([
                'message' => 'Rincian pemesanan tidak ditemukan'
            ], 404);
        }

        return response()->json($rincian, 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_pemesanan' => 'required|integer|exists:pemesanan,id_pemesanan',
            'id_kamar' => 'required|integer|exists:kamar,id_kamar',
            'jumlah_kamar' => 'required|integer|min:1',
            'sub_total' => 'required|numeric|min:0',
        ]);

        $rincian = RincianPemesanan::create([
            'id_pemesanan' => $validated['id_pemesanan'],
            'id_kamar' => $validated['id_kamar'],
            'jumlah_kamar' => $validated['jumlah_kamar'],
            'sub_total' => $validated['sub_total'],
            'is_delete' => false,
        ]);

        return response()->json($rincian, 201);
    }

    public function update(Request $request, $id)
    {
        $rincian = RincianPemesanan::where('id_rincianpemesanan', $id)
            ->where('is_delete', false)
            ->first();

        if (!$rincian) {
            return response()->json([
                'message' => 'Rincian pemesanan tidak ditemukan'
            ], 404);
        }

        $validated = $request->validate([
            'id_pemesanan' => 'sometimes|integer|exists:pemesanan,id_pemesanan',
            'id_kamar' => 'sometimes|integer|exists:kamar,id_kamar',
            'jumlah_kamar' => 'sometimes|integer|min:1',
            'sub_total' => 'sometimes|numeric|min:0',
        ]);

        $rincian->update($validated);

        return response()->json($rincian, 200);
    }

    public function destroy($id)
    {
        $rincian = RincianPemesanan::where('id_rincianpemesanan', $id)
            ->where('is_delete', false)
            ->first();

        if (!$rincian) {
            return response()->json([
                'message' => 'Rincian pemesanan tidak ditemukan'
            ], 404);
        }

        $rincian->update([
            'is_delete' => true
        ]);

        return response()->json([
            'message' => 'Rincian pemesanan berhasil dihapus'
        ], 200);
    }

    public function getByPemesanan($id_pemesanan)
    {
        $rincian = RincianPemesanan::with(['kamar'])
            ->where('id_pemesanan', $id_pemesanan)
            ->where('is_delete', false)
            ->get();

        return response()->json($rincian, 200);
    }
}