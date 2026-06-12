<?php

namespace App\Http\Controllers;

use App\Models\Hotel;
use Illuminate\Http\Request;

class HotelController extends Controller
{
    public function index()
    {
        $hotels = Hotel::with([
                'kamar',
                'gambarHotel',
                'fasilitas',
            ])
            ->where('is_delete', false)
            ->orderBy('id_hotel')
            ->get();

        return response()->json([
            'message' => 'Data Hotel berhasil diambil',
            'data' => $hotels,
        ], 200);
    }

    public function show($id_hotel)
    {
        $hotel = Hotel::with([
                'kamar',
                'gambarHotel',
                'fasilitas',
            ])
            ->where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Data Hotel tidak ditemukan.',
            ], 404);
        }

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
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'policies' => 'nullable|array',
            'policies.*.kategori' => 'required|string',
            'policies.*.items' => 'required|array',
            'policies.*.items.*' => 'required|string',
        ]);

        $hotel = Hotel::create([
            'nama_hotel' => $validated['nama_hotel'],
            'kota' => $validated['kota'],
            'alamat' => $validated['alamat'],
            'deskripsi' => $validated['deskripsi'] ?? null,
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'policies' => $validated['policies'] ?? [],
            'rating_hotel' => 0.0,
            'harga_terendah' => null,
            'is_delete' => false,
        ]);

        $hotel->load(['kamar', 'gambarHotel', 'fasilitas']);

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
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'policies' => 'nullable|array',
            'policies.*.kategori' => 'required_with:policies|string',
            'policies.*.items' => 'required_with:policies|array',
            'policies.*.items.*' => 'required_with:policies|string',
        ]);

        $hotel->update($validated);
        $hotel->load(['kamar', 'gambarHotel', 'fasilitas']);

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

    public function search(Request $request)
    {
        $query = trim($request->query('q', ''));

        $hotels = Hotel::with([
                'kamar',
                'gambarHotel',
                'fasilitas',
            ])
            ->where('is_delete', false)
            ->when($query !== '', function ($builder) use ($query) {
                $builder->where(function ($q) use ($query) {
                    $q->where('nama_hotel', 'like', "%{$query}%")
                      ->orWhere('kota', 'like', "%{$query}%")
                      ->orWhere('alamat', 'like', "%{$query}%");
                });
            })
            ->orderBy('id_hotel')
            ->get();

        return response()->json([
            'message' => 'Hasil pencarian hotel berhasil diambil',
            'data' => $hotels,
        ], 200);
    }

    public function refreshAggregate($id_hotel)
    {
        $hotel = Hotel::where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->first();

        if (!$hotel) {
            return response()->json([
                'message' => 'Data Hotel tidak ditemukan.',
            ], 404);
        }

        $hotel->refreshAggregates();
        $hotel->load(['kamar', 'gambarHotel', 'fasilitas']);

        return response()->json([
            'message' => 'Harga terendah dan rating hotel berhasil diperbarui',
            'data' => $hotel,
        ], 200);
    }
}