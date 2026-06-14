<?php

namespace App\Http\Controllers;

use App\Models\AddOn;
use Illuminate\Http\Request;

class AddOnController{
    public function index() {
        $addOn = AddOn::with('pemesanan')->latest('id_addon')->get();

        return response()->json($addOn, 200);
    }

    public function show($id) {
        
        $addOn = AddOn::with('pemesanan')->find($id);

        if(!$addOn) {
            return response()->json(['message' => 'Add On tidak ditemukan'], 400);
        }

        return response()->json($addOn, 200);
    }

    public function store(Request $request){
        
        $validated = $request->validate([
            'id_pemesanan'              => 'required|integer|exists:pemesanan, id_pemesanan',
            'nama_addon'            => 'required|string|max:100',
            'harga_addon'           => 'required|float|min:100',
            'keterangan_addon'      => 'required|string|max:500',
        ]);

        $addOn = AddOn::create($validated);

        return response()->json($addOn, 201);
    }

    public function update(Request $request, $id) {
        $addOn = AddOn::with('pemesanan')->find($id);

        if(!$addOn) {
            return response()->json(['message' => 'Add On tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'id_pemesanan'              => 'sometimes|integer|exists:pemesanan, id_pemesanan',
            'nama_addon'            => 'sometimes|string|max:100',
            'harga_addon'           => 'sometimes|float|min:100',
            'keterangan_addon'      => 'sometimes|string|max:500',

        ]);

        $addOn->update($validated);

        return response()->json($addOn, 200);
    }

    public function destroy($id){
        $addOn = AddOn::find($id);

        if (!$addOn) {
            return response()->json(['message' => 'Add On tidak ditemukan'], 404);
        }

        $addOn->delete();

        return response()->json(['message' => 'Add On berhasil dihapus'], 200);
    }

    public function getByPemesanan($id_pemesanan) {

        $addOn = AddOn::where('id_pemesanan', $id_pemesanan)->get();

        if($addOn->isEmpty()) {
            return response()->json(['message' => 'Tidak ada Add On untuk pemesanan ini'], 404);
        }

        return response()->json($addOn, 200);
    }

}
