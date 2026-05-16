<?php

namespace App\Http\Controllers;

use App\Models\GambarHotel;
use App\Models\Hotel;
use Illuminate\Http\Request;

class GambarHotelController extends Controller
{
    public function index()
    {
        $gambar = GambarHotel::with('hotel')->get();

        return response()->json([
            'message' => 'Data Gambar Hotel berhasil diambil',
            'data' => $gambar,
        ], 200);
    }

    public function show($id_gambarhotel)
    {
        $gambar = GambarHotel::with('hotel')
            ->where('id_gambarhotel', $id_gambarhotel)
            ->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'message' => 'Data Gambar berhasil diambil',
            'data' => $gambar,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_hotel' => 'required|exists:hotel,id_hotel',
            'nama_gambarhotel' => 'nullable|string',
            'keterangan_gambarhotel' => 'nullable|string',
            'url_gambarhotel' => 'required|string',
        ]);

        $hotel = Hotel::where('id_hotel', $validated['id_hotel'])
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Hotel tidak ditemukan.',
            ], 404);
        }

        $gambar = GambarHotel::create([
            'id_hotel' => $validated['id_hotel'],
            'nama_gambarhotel' => $validated['nama_gambarhotel'] ?? null,
            'keterangan_gambarhotel' => $validated['keterangan_gambarhotel'] ?? null,
            'url_gambarhotel' => $validated['url_gambarhotel'],
        ]);

        return response()->json([
            'message' => 'Data Gambar berhasil ditambahkan',
            'data' => $gambar,
        ], 201);
    }

    public function update(Request $request, $id_gambarhotel)
    {
        $gambar = GambarHotel::where('id_gambarhotel', $id_gambarhotel)->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'nama_gambarhotel' => 'nullable|string',
            'keterangan_gambarhotel' => 'nullable|string',
            'url_gambarhotel' => 'nullable|string',
        ]);

        $gambar->update($validated);

        return response()->json([
            'message' => 'Data Gambar berhasil diupdate',
            'data' => $gambar,
        ], 200);
    }

    public function destroy($id_gambarhotel)
    {
        $gambar = GambarHotel::where('id_gambarhotel', $id_gambarhotel)->first();

        if (!$gambar) {
            return response()->json([
                'message' => 'Data Gambar tidak ditemukan.',
            ], 404);
        }

        $gambar->delete();

        return response()->json([
            'message' => 'Data Gambar berhasil dihapus',
        ], 200);
    }

    public function byHotel($id_hotel)
    {
        $gambar = GambarHotel::with('hotel')
            ->where('id_hotel', $id_hotel)
            ->get();

        return response()->json([
            'message' => 'Data Gambar Hotel berhasil diambil',
            'data' => $gambar,
        ], 200);
    }
}