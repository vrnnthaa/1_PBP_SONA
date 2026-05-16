<?php

namespace App\Http\Controllers;

use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PemesananController extends Controller {
    public function index(){
        $pemesanan = Pemesanan::with(['user', 'pembayaran', 'review'])->latest()->get();

        return response()->json($pemesanan, 200);
    }

    public function show($id){
        $pemesanan = Pemesanan::with(['user', 'pembayaran', 'review'])->find($id);

        if(!$pemesanan) {
            return response()->json(['message' => 'Pemesanan tidak ditemukan'], 404);
        }

        return response()->json($pemesanan, 200);
    }

    public function store(Request $request) {
        $validated = $request->validate([
            'id_user'               => 'required|integer|exists:users, id_user',
            'check_in'              => 'required|date|after_or_equal:today',
            'check_out'             => 'required|date|after:check_in',
            'jumlah_pengunjung'     => 'required|integer|min:1',
            'total_biaya'           => 'required|numeric|min:0',
        ]);

        $validated['status_pembayaran'] = Pemesanan::STATUS_PENDING;

        $pemesanan = Pemesanan::create($validated);

        return response()->json($pemesanan, 201);
    }

    public function update(Request $request, $id){
        $pemesanan = Pemesanan::find($id);
 
        if (!$pemesanan) {
            return response()->json(['message' => 'Pemesanan tidak ditemukan'], 404);
        }
 
        $validated = $request->validate([
            'check_in'          => 'sometimes|date|after_or_equal:today',
            'check_out'         => 'sometimes|date|after:check_in',
            'jumlah_pengunjung' => 'sometimes|integer|min:1',
            'total_biaya'       => 'sometimes|numeric|min:0',
            'status_pemesanan'  => ['sometimes', Rule::in([
                Pemesanan::STATUS_PENDING,
                Pemesanan::STATUS_CONFIRMED,
                Pemesanan::STATUS_CANCELLED,
            ])],
        ]);

        $pemesanan->update($validated);

        return response()->json($pemesanan, 200);
    }

    public function destroy($id){
        $pemesanan = Pemesanan::find($id);

        if (!$pemesanan) {
            return response()->json(['message' => 'Pemesanan tidak ditemukan'], 404);
        }

        $pemesanan->delete();

        return response()->json(['message' => 'Pemesanan berhasil dihapus'], 200);
    }

    public function getByStatus($status){
        $allowedStatus = [
            Pemesanan::STATUS_PENDING,
            Pemesanan::STATUS_CONFIRMED,
            Pemesanan::STATUS_CANCELLED,
        ];

        if (!in_array($status, $allowedStatus)) {
            return response()->json(['message' => 'Status tidak valid'], 422);
        }

        $pemesanan = Pemesanan::with(['user', 'pembayaran'])
            ->where('status_pemesanan', $status)
            ->latest()
            ->get();

        return response()->json($pemesanan, 200);
    }

    public function getByUser($id_user){
        $pemesanan = Pemesanan::with(['pembayaran', 'review'])
            ->where('id_user', $id_user)
            ->latest()
            ->get();

        return response()->json($pemesanan, 200);
    }


}