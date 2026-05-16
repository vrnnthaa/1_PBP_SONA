<?php

namespace App\Http\Controllers;

use App\Models\Hotel;
use App\Models\Review;
use Illuminate\Http\Request;

class HotelController extends Controller
{
    public function index()
    {
        $hotels = Hotel::with(['kamar', 'gambarHotel', 'fasilitasHotel'])
            ->where('is_delete', false)
            ->get();

        foreach ($hotels as $hotel) {
            $averageRating = Review::where('id_hotel', $hotel->id_hotel)
                ->where('is_delete', false)
                ->avg('rating');

            $hotel->rating_hotel = $averageRating ? round($averageRating, 1) : 0;
            $hotel->save();
        }

        return response()->json([
            'message' => 'Data Hotel berhasil diambil',
            'data' => $hotels,
        ], 200);
    }

    public function show($id_hotel)
    {
        $hotel = Hotel::with(['kamar', 'gambarHotel', 'fasilitasHotel'])
            ->where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Data Hotel tidak ditemukan.',
            ], 404);
        }

        $averageRating = Review::where('id_hotel', $hotel->id_hotel)
            ->where('is_delete', false)
            ->avg('rating');

        $hotel->rating_hotel = $averageRating ? round($averageRating, 1) : 0;
        $hotel->save();

        return response()->json([
            'message' => 'Data Hotel berhasil diambil',
            'data' => $hotel,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_hotel' => 'required|string',
            'kota' => 'required|string',
            'alamat' => 'required|string',
            'deskripsi' => 'nullable|string',
        ]);

        $hotel = Hotel::create([
            'nama_hotel' => $validated['nama_hotel'],
            'kota' => $validated['kota'],
            'alamat' => $validated['alamat'],
            'deskripsi' => $validated['deskripsi'] ?? null,
            'is_delete' => false,
        ]);

        return response()->json([
            'message' => 'Data Hotel berhasil ditambahkan',
            'data' => $hotel,
        ], 201);
    }

    public function update(Request $request, $id_hotel)
    {
        $hotel = Hotel::where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Data Hotel tidak ditemukan.',
            ], 404);
        }

        $validated = $request->validate([
            'nama_hotel' => 'nullable|string',
            'kota' => 'nullable|string',
            'alamat' => 'nullable|string',
            'deskripsi' => 'nullable|string',
        ]);

        $hotel->update($validated);

        return response()->json([
            'message' => 'Data Hotel berhasil diupdate',
            'data' => $hotel,
        ], 200);
    }

    public function destroy($id_hotel)
    {
        $hotel = Hotel::where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Data Hotel tidak ditemukan.',
            ], 404);
        }

        $hotel->update(['is_delete' => true]);

        return response()->json([
            'message' => 'Data Hotel berhasil dihapus',
        ], 200);
    }
}