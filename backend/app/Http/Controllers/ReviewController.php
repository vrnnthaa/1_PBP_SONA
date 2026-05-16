<?php 

namespace App\Http\Controllers; 

use App\Models\Review; 
use App\Models\Pemesanan; 
use Illuminate\Http\Request; 
use Carbon\Carbon;

class ReviewController
{
    public function index(Request $request){
        $reviews = Review::with(
            'user',
            'hotel',
            'pemesanan'
        )->where('id_user', $request->id_user)
         ->where('is_delete', false)
         ->get(); 

        return response()->json([
            'message' => 'Data Review berhasil diambil', 
            'data' => $reviews, 
        ], 200); 
    }

    public function store(Request $request){
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id_user',
            'id_pemesanan' => 'required|integer|exists:pemesanan,id_pemesanan',
            'komentar' => 'required|string',
            'rating' => 'required|numeric|min:1|max:5',
            'photo_review' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]); 

        $pemesanan = Pemesanan::where('id_pemesanan', $validated['id_pemesanan'])
            ->where('id_user', $validated['id_user'])
            ->first();

        if (!$pemesanan) {
            return response()->json([
                'message' => 'Data pemesanan tidak ditemukan atau bukan milik Anda.'
            ], 404);
        }

        if (Carbon::parse($pemesanan->tanggal_checkout)->isFuture()) {
            return response()->json([
                'message' => 'Anda baru bisa memberikan review setelah melewati tanggal checkout.'
            ], 400);
        }

        $existingReview = Review::where('id_pemesanan', $validated['id_pemesanan'])->first();
        
        if ($existingReview) {
            return response()->json([
                'message' => 'Anda sudah memberikan review untuk pemesanan ini.'
            ], 400);
        }

        $photoPath = null;
        if ($request->hasFile('photo_review')) {
            $photoPath = $request->file('photo_review')->store('reviews', 'public');
        }

        $review = Review::create([
            'id_user' => $validated['id_user'],
            'id_pemesanan' => $pemesanan->id_pemesanan,
            'id_hotel' => $pemesanan->id_hotel, 
            'komentar' => $validated['komentar'],
            'rating' => $validated['rating'],
            'photo_review' => $photoPath,
            'tanggal_review' => now()->format('Y-m-d H:i:s'),
            'is_delete' => false
        ]);

        return response()->json([
            'message' => 'Data Review berhasil disimpan', 
            'data' => $review, 
        ], 201); 
    }

    public function destroy(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                'message' => 'Data review tidak ditemukan.'
            ], 404);
        }

        if ($review->id_user != $request->id_user) {
            return response()->json([
                'message' => 'Unauthorized. Anda tidak memiliki akses untuk menghapus review ini.'
            ], 403);
        }

        // Soft delete menggunakan field is_delete
        $review->update([
            'is_delete' => true
        ]);

        return response()->json([
            'message' => 'Review berhasil dihapus.',
        ], 200);
    }

}