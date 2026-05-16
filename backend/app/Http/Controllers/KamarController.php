<?php

namespace App\Http\Controllers;

use App\Models\Kamar;
use App\Models\Review;
use Illuminate\Http\Request;

class KamarController
{
    public function index()
    {
        $kamars = Kamar::with(['fasilitasKamar', 'gambarKamar', 'hotel'])
            ->where('is_delete', false)
            ->get();

        foreach ($kamars as $kamar) {
            $averageRating = Review::where('id_hotel', $kamar->id_hotel)
                ->where('is_delete', false)
                ->avg('rating');

            $kamar->rating_kamar = $averageRating ? round($averageRating, 1) : 0;
            
            $kamar->save(); 
        }

        return response()->json([
            'message' => 'Data Kamar berhasil diambil',
            'data' => $kamars,
        ], 200);
    }

    public function update(Request $request, $id_kamar)
    {
        $validated = $request->validate([
            'jumlah_kamar_dipesan' => 'required|integer',
        ]);

        $kamar = Kamar::where('id_kamar', $id_kamar)
            ->where('is_delete', false)
            ->first();

        if (!$kamar) {
            return response()->json([
                'message' => 'Data Kamar tidak ditemukan.',
            ], 404);
        }

        $kapasitasBaru = $kamar->kapasitas - $validated['jumlah_kamar_dipesan'];

        if ($kapasitasBaru < 0) {
            return response()->json([
                'message' => 'Kapasitas kamar tidak mencukupi untuk pemesanan ini.',
                'sisa_kapasitas' => $kamar->kapasitas
            ], 400);
        }

        $kamar->update([
            'kapasitas' => $kapasitasBaru,
            'status_kamar' => $kapasitasBaru >= 1 
        ]);

        return response()->json([
            'message' => 'Kapasitas dan Status Kamar berhasil diupdate',
            'data' => $kamar,
        ], 200);
    }
}