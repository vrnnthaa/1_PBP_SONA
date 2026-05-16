<?php
namespace App\Http\Controllers;
use App\Models\FasilitasHotel;
use App\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FasilitasHotelController
{
    public function index(Request $request)
    {
        $query = FasilitasHotel::with('hotel');

        // Filter berdasarkan id_hotel jika ada
        if ($request->has('id_hotel')) {
            $query->where('id_hotel', $request->id_hotel);
        }

        $fasilitasHotels = $query->paginate($request->per_page ?? 10);

        return response()->json([
            'success' => true,
            'data' => $fasilitasHotels
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_hotel' => 'required|exists:hotel,id_hotel',
            'nama_fasilitasHotel' => 'required|string|max:255',
            'keterangan_fasilitasHotel' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $fasilitasHotel = FasilitasHotel::create([
            'id_hotel' => $request->id_hotel,
            'nama_fasilitasHotel' => $request->nama_fasilitasHotel,
            'keterangan_fasilitasHotel' => $request->keterangan_fasilitasHotel
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Fasilitas hotel berhasil ditambahkan',
            'data' => $fasilitasHotel->load('hotel')
        ], 201);
    }

    public function show($id)
    {
        $fasilitasHotel = FasilitasHotel::with('hotel')->find($id);

        if (!$fasilitasHotel) {
            return response()->json([
                'success' => false,
                'message' => 'Fasilitas hotel tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $fasilitasHotel
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $fasilitasHotel = FasilitasHotel::find($id);

        if (!$fasilitasHotel) {
            return response()->json([
                'success' => false,
                'message' => 'Fasilitas hotel tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'id_hotel' => 'sometimes|exists:hotel,id_hotel',
            'nama_fasilitasHotel' => 'sometimes|string|max:255',
            'keterangan_fasilitasHotel' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['id_hotel', 'nama_fasilitasHotel', 'keterangan_fasilitasHotel']);
        $fasilitasHotel->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Fasilitas hotel berhasil diupdate',
            'data' => $fasilitasHotel->fresh('hotel')
        ], 200);
    }

    public function destroy($id)
    {
        $fasilitasHotel = FasilitasHotel::find($id);

        if (!$fasilitasHotel) {
            return response()->json([
                'success' => false,
                'message' => 'Fasilitas hotel tidak ditemukan'
            ], 404);
        }

        $fasilitasHotel->delete();

        return response()->json([
            'success' => true,
            'message' => 'Fasilitas hotel berhasil dihapus'
        ], 200);
    }

    public function getByHotel($hotelId)
    {
        $hotel = Hotel::find($hotelId);

        if (!$hotel) {
            return response()->json([
                'success' => false,
                'message' => 'Hotel tidak ditemukan'
            ], 404);
        }

        $fasilitasHotels = FasilitasHotel::where('id_hotel', $hotelId)->get();

        return response()->json([
            'success' => true,
            'data' => $fasilitasHotels,
            'hotel' => $hotel->nama_hotel
        ], 200);
    }
}