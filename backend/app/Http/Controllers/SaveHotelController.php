<?php 

namespace App\Http\Controllers; 

use App\Models\SaveHotel; 
use Illuminate\Http\Request; 

class SaveHotelController
{
    public function index(Request $request){
        $savehotel = SaveHotel::with(
            'hotel'
        )->where('id_user', $request->id_user)
         ->where('is_saved', true)
         ->get(); 

        return response()->json([
            'message' => 'Data Save Hotel berhasil diambil', 
            'data' => $savehotel, 
        ], 200); 
    }

    public function store(Request $request){
        $validated = $request->validate([
            'id_user' => 'nullable|integer|exists:users,id_user', 
            'id_hotel' => 'nullable|integer|exists:hotel,id_hotel', 
        ]); 

        $save = SaveHotel::where('id_user', $validated['id_user'])
                    ->where('id_hotel', $validated['id_hotel'])
                    ->first(); 

        if($save){
            $save->update([
                'is_saved' => true
            ]); 
        }else{
            $save = SaveHotel::create([
                'id_user' => $validated['id_user'],
                'id_hotel' => $validated['id_hotel'], 
                'is_saved' => true
            ]); 
        }

        return response()->json([
            'message' => 'Data Save Hotel berhasil disimpan', 
            'data' => $save, 
        ], 201); 
    }

    public function update(Request $request, SaveHotel $saveHotel){
        $saveHotel->update([
            'is_saved' => !$saveHotel->is_saved
        ]); 

        return response()->json([
            'message' => 'Status Save Hotel berhasil diubah',
            'data' => $saveHotel
        ], 200); 
    }

}