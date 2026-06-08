<?php

namespace App\Http\Controllers;

use App\Models\Kamar;
use App\Models\Pemesanan;
use App\Models\Review;
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
            'harga' => 'sometimes|numeric|min:0',
            'kapasitas' => 'sometimes|integer|min:1',
            'status_kamar' => 'sometimes|boolean',
            'deskripsi' => 'sometimes|nullable|string',
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
            ->get();

        $data = $rooms->map(function ($room) use ($validated) {
            $isBooked = Pemesanan::where('id_kamar', $room->id_kamar)
                ->where('is_delete', false)
                ->whereIn('status_pemesanan', ['aktif'])
                ->where('check_in', '<', $validated['check_out'])
                ->where('check_out', '>', $validated['check_in'])
                ->exists();

            $guestAllowed = $room->kapasitas >= $validated['guest'];
            $roomEnabled = (bool) $room->status_kamar;
            $isAvailable = !$isBooked && $guestAllowed && $roomEnabled;

            return [
                'id_kamar' => $room->id_kamar,
                'nama_kamar' => $room->nama_kamar,
                'tipe_kamar' => $room->tipe_kamar,
                'kapasitas' => $room->kapasitas,
                'harga' => $room->harga,
                'status_kamar' => $room->status_kamar,
                'status_available' => $isAvailable,
                'availability_label' => !$roomEnabled
                    ? 'Room inactive'
                    : (!$guestAllowed
                        ? 'Guest limit exceeded'
                        : ($isAvailable ? 'Available' : 'Unavailable')),
                'fasilitas' => $room->fasilitasKamar,
                'gambar_kamar' => $room->gambarKamar,
                'data' => $room,
            ];
        });

        return response()->json([
            'message' => 'Availability kamar berhasil diambil',
            'data' => $data,
        ], 200);
    }
}