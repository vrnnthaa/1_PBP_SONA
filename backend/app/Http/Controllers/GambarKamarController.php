<?php

namespace App\Http\Controllers;

use App\Models\GambarKamar;
use App\Models\Kamar;
use Illuminate\Http\Request;

class GambarKamarController
{
    public function index()
    {
        $gambar = GambarKamar::with('kamar')->get();

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil diambil',
            'data' => $gambar,
        ], 200);
    }

    public function show($id_gambarkamar)
    {
        $gambar = GambarKamar::with('kamar')
            ->where('id_gambarkamar', $id_gambarkamar)
            ->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar Kamar tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil diambil',
            'data' => $gambar,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_kamar' => 'required|exists:kamar,id_kamar',
            'nama_gambarkamar' => 'nullable|string',
            'keterangan_gambarkamar' => 'nullable|string',
            'url_gambarkamar' => 'required|string',
        ]);

        $kamar = Kamar::where('id_kamar', $validated['id_kamar'])->first();

        if (!$kamar) {
            return response()->json([
                'message' => 'Kamar tidak ditemukan.',
            ], 404);
        }

        $gambar = GambarKamar::create([
            'id_kamar' => $validated['id_kamar'],
            'nama_gambarkamar' => $validated['nama_gambarkamar'] ?? null,
            'keterangan_gambarkamar' => $validated['keterangan_gambarkamar'] ?? null,
            'url_gambarkamar' => $validated['url_gambarkamar'],
        ]);

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil ditambahkan',
            'data' => $gambar,
        ], 201);
    }

    public function update(Request $request, $id_gambarkamar)
    {
        $gambar = GambarKamar::where('id_gambarkamar', $id_gambarkamar)->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar Kamar tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'nama_gambarkamar' => 'nullable|string',
            'keterangan_gambarkamar' => 'nullable|string',
            'url_gambarkamar' => 'nullable|string',
        ]);

        $gambar->update($validated);

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil diupdate',
            'data' => $gambar,
        ], 200);
    }

    public function destroy($id_gambarkamar)
    {
        $gambar = GambarKamar::where('id_gambarkamar', $id_gambarkamar)->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar Kamar tidak ditemukan.',
            ], 404);
        }

        $gambar->delete();

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil dihapus',
        ], 200);
    }

    public function byKamar($id_kamar)
    {
        $gambar = GambarKamar::with('kamar')
            ->where('id_kamar', $id_kamar)
            ->get();

        return response()->json([
            'message' => 'Data Gambar Kamar berhasil diambil',
            'data' => $gambar,
        ], 200);
    }
}