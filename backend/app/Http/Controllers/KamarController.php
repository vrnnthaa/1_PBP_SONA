<?php

namespace App\Http\Controllers;

use App\Models\Kamar;
use App\Models\Pemesanan;
use Illuminate\Http\Request;

class KamarController
{
    public function index()
    {
        $kamars = Kamar::with(['fasilitasKamar', 'gambarKamar', 'hotel'])
            ->where('is_delete', false)
            ->get();

        return response()->json([
            'message' => 'Data Kamar berhasil diambil',
            'data' => $kamars,
        ], 200);
    }

    public function update(Request $request, $id_kamar)
    {
        $validated = $request->validate([
            'nama_kamar' => 'sometimes|string',
            'tipe_kamar' => 'sometimes|string',
            'harga' => 'sometimes|numeric|min:0',
            'kapasitas' => 'sometimes|integer|min:1',
            'status_kamar' => 'sometimes|boolean',
            'deskripsi' => 'sometimes|nullable|string',
            'rating_kamar' => 'sometimes|numeric|min:0|max:5',
            'ukuran_kamar' => 'sometimes|integer|min:1',
            'offer' => 'sometimes|array',
            'offer.*.title' => 'required_with:offer|string',
            'offer.*.description' => 'nullable|string',
            'occupancy' => 'sometimes|array',
            'occupancy.*.title' => 'required_with:occupancy|string',
            'occupancy.*.description' => 'nullable|string',
        ]);

        $kamar = Kamar::where('id_kamar', $id_kamar)
            ->where('is_delete', false)
            ->first();

        if (!$kamar) {
            return response()->json([
                'message' => 'Data Kamar tidak ditemukan.',
            ], 404);
        }

        $kamar->update($validated);
        $kamar->load(['fasilitasKamar', 'gambarKamar', 'hotel']);

        return response()->json([
            'message' => 'Data kamar berhasil diupdate',
            'data' => $kamar,
        ], 200);
    }

    public function getAvailableRooms(Request $request, $id_hotel)
    {
        $validated = $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'guest' => 'required|integer|min:1',
        ]);

        $rooms = Kamar::with(['fasilitasKamar', 'gambarKamar'])
            ->where('id_hotel', $id_hotel)
            ->where('is_delete', false)
            ->orderBy('harga', 'asc')
            ->get();

        $data = $rooms->map(function ($room) use ($validated) {
            $isBooked = Pemesanan::where('id_kamar', $room->id_kamar)
                ->where('is_delete', false)
                ->whereIn('status_pemesanan', ['aktif'])
                ->where('check_in', '<', $validated['check_out'])
                ->where('check_out', '>', $validated['check_in'])
                ->exists();

            $guestAllowed = (int) $room->kapasitas >= (int) $validated['guest'];
            $roomEnabled = (bool) $room->status_kamar;
            $isAvailable = !$isBooked && $guestAllowed && $roomEnabled;

            return [
                'id_kamar' => $room->id_kamar,
                'id_hotel' => $room->id_hotel,
                'nama_kamar' => $room->nama_kamar,
                'tipe_kamar' => $room->tipe_kamar,
                'kapasitas' => (int) $room->kapasitas,
                'harga' => (int) $room->harga,
                'rating_kamar' => (float) ($room->rating_kamar ?? 0),
                'ukuran_kamar' => (int) ($room->ukuran_kamar ?? 0),
                'deskripsi' => $room->deskripsi,
                'status_kamar' => $roomEnabled,
                'status_available' => $isAvailable,
                'availability_label' => !$roomEnabled
                    ? 'Room inactive'
                    : (!$guestAllowed
                        ? 'Guest limit exceeded'
                        : ($isBooked ? 'Already booked' : 'Available')),
                'offer' => $room->offer ?? [],
                'occupancy' => $room->occupancy ?? [],
                'fasilitas' => $room->fasilitasKamar,
                'gambar_kamar' => $room->gambarKamar,
                'detail_kamar' => [
                    'id_kamar' => $room->id_kamar,
                    'id_hotel' => $room->id_hotel,
                    'nama_kamar' => $room->nama_kamar,
                    'tipe_kamar' => $room->tipe_kamar,
                    'harga' => (int) $room->harga,
                    'kapasitas' => (int) $room->kapasitas,
                    'deskripsi' => $room->deskripsi,
                    'rating_kamar' => (float) ($room->rating_kamar ?? 0),
                    'ukuran_kamar' => (int) ($room->ukuran_kamar ?? 0),
                    'status_kamar' => $roomEnabled,
                    'offer' => $room->offer ?? [],
                    'occupancy' => $room->occupancy ?? [],
                    'fasilitas' => $room->fasilitasKamar,
                    'gambar_kamar' => $room->gambarKamar,
                ],
            ];
        })->values();

        return response()->json([
            'message' => 'Availability kamar berhasil diambil',
            'data' => $data,
        ], 200);
    }
}