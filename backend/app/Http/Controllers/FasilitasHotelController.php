<?php

namespace App\Http\Controllers;

use App\Models\Fasilitas;
use Illuminate\Http\Request;

class FasilitasHotelController
{
    public function index()
    {
        $fasilitas = Fasilitas::with('hotels')->get();

        return response()->json([
            'message' => 'Data Fasilitas Hotel berhasil diambil',
            'data' => $fasilitas,
        ], 200);
    }

    public function show($id_fasilitas)
    {
        $fasilitas = Fasilitas::with('hotels')
            ->where('id_fasilitas', $id_fasilitas)
            ->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Data Fasilitas berhasil diambil',
            'data' => $fasilitas,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_fasilitasKamar' => 'required|string|unique:kamar_fasilitas',
            'keterangan_fasilitasKamar' => 'nullable|string',
        ]);

        $fasilitas = Fasilitas::create([
            'nama_fasilitas' => $validated['nama_fasilitas'],
            'icon_fasilitas' => $validated['icon_fasilitas'] ?? null,
        ]);

        return response()->json([
            'message' => 'Data Fasilitas berhasil ditambahkan',
            'data' => $fasilitas,
        ], 201);
    }

    public function update(Request $request, $id_fasilitas)
    {
        $fasilitas = Fasilitas::where('id_fasilitas', $id_fasilitas)->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'nama_fasilitas' => 'nullable|string|unique:fasilitas,nama_fasilitas,' . $id_fasilitas . ',id_fasilitas',
            'icon_fasilitas' => 'nullable|string',
        ]);

        $fasilitas->update($validated);

        return response()->json([
            'message' => 'Data Fasilitas berhasil diupdate',
            'data' => $fasilitas,
        ], 200);
    }

    public function destroy($id_fasilitas)
    {
        $fasilitas = Fasilitas::where('id_fasilitas', $id_fasilitas)->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas tidak ditemukan.',
            ], 404);
        }

        $fasilitas->delete();

        return response()->json([
            'message' => 'Data Fasilitas berhasil dihapus',
        ], 200);
    }
}