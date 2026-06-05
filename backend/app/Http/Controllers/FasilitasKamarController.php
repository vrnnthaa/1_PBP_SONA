<?php

namespace App\Http\Controllers;

use App\Models\FasilitasKamar;
use Illuminate\Http\Request;

class FasilitasKamarController
{
    public function index()
    {
        $fasilitas = FasilitasKamar::with('kamars')->get();

        return response()->json([
            'message' => 'Data Fasilitas Kamar berhasil diambil',
            'data' => $fasilitas,
        ], 200);
    }

    public function show($id_fasilitaskamar)
    {
        $fasilitas = FasilitasKamar::with('kamars')
            ->where('id_fasilitaskamar', $id_fasilitaskamar)
            ->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas Kamar tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Data Fasilitas Kamar berhasil diambil',
            'data' => $fasilitas,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_fasilitaskamar' => 'required|string|unique:fasilitas_kamar,nama_fasilitaskamar',
            'icon_fasilitaskamar' => 'nullable|string',
            'keterangan_fasilitaskamar' => 'nullable|string',
        ]);

        $fasilitas = FasilitasKamar::create([
            'nama_fasilitaskamar' => $validated['nama_fasilitaskamar'],
            'icon_fasilitaskamar' => $validated['icon_fasilitaskamar'] ?? null,
            'keterangan_fasilitaskamar' => $validated['keterangan_fasilitaskamar'] ?? null,
        ]);

        return response()->json([
            'message' => 'Data Fasilitas Kamar berhasil ditambahkan',
            'data' => $fasilitas,
        ], 201);
    }

    public function update(Request $request, $id_fasilitaskamar)
    {
        $fasilitas = FasilitasKamar::where('id_fasilitaskamar', $id_fasilitaskamar)->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas Kamar tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'nama_fasilitaskamar' => 'nullable|string|unique:fasilitas_kamar,nama_fasilitaskamar,' . $id_fasilitaskamar . ',id_fasilitaskamar',
            'icon_fasilitaskamar' => 'nullable|string',
            'keterangan_fasilitaskamar' => 'nullable|string',
        ]);

        $fasilitas->update($validated);

        return response()->json([
            'message' => 'Data Fasilitas Kamar berhasil diupdate',
            'data' => $fasilitas,
        ], 200);
    }

    public function destroy($id_fasilitaskamar)
    {
        $fasilitas = FasilitasKamar::where('id_fasilitaskamar', $id_fasilitaskamar)->first();

        if (!$fasilitas) {
            return response()->json([
                'message' => 'Data Fasilitas Kamar tidak ditemukan.',
            ], 404);
        }

        $fasilitas->delete();

        return response()->json([
            'message' => 'Data Fasilitas Kamar berhasil dihapus',
        ], 200);
    }
}