<?php

namespace App\Http\Controllers;

use App\Models\AddOn;
use Illuminate\Http\Request;

class AddOnController{
    public function index() {
        $addOn = AddOn::with('kamar')->latest('id_addon')->get();

        return response()->json($addOn, 200);
    }

    public function show($id) {
        
        $addOn = AddOn::with('kamar')->find($id);

        if(!$addOn) {
            return response()->json(['message' => 'Add On tidak ditemukan'], 400);
        }

        return response()->json($addOn, 200);
    }

    public function store(Request $request){
        $validated = $request->validate([
            'id_kamar'              => 'required|integer|exists:kamar, id_kamar',
            'nama_addOn'            => 'required|string|max:100',
            'keterangan_addOn'      => 'required|string|max:500',
        ]);

        $addOn = AddOn::create($validated);

        return response()->json($addOn, 201);
    }

    public function update(Request $request, $id) {
        $addOn = AddOn::with('kamar')->find($id);

        if(!$addOn) {
            return response()->json(['message' => 'Add On tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'id_kamar'              => 'sometimes|integer|exists:kamar, id_kamar',
            'nama_addOn'            => 'sometimes|string|max:100',
            'keterangan_addOn'      => 'required|string|max:500',

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

    public function getByKamar($id_kamar) {

        $addOn = AddOn::where('id_kamar', $id_kamar)->get();

        if($addOn->isEmpty()) {
            return response()->json(['message' => 'Tidak ada Add On untuk kamar ini'], 404);
        }

        return response()->json($addOn, 200);
    }

}
