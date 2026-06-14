<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class ReviewController
{
    public function index(Request $request)
    {
        $reviews = Review::with([
            'user',
            'hotel',
            'pemesanan',
        ])
            ->where('id_user', $request->id_user)
            ->where('is_delete', false)
            ->get();

        return response()->json([
            'message' => 'Data Review berhasil diambil',
            'data' => $reviews,
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_user' => 'required|integer|exists:users,id_user',
            'id_pemesanan' => 'required|integer|exists:pemesanan,id_pemesanan',
            'komentar' => 'required|string',
            'rating' => 'required|numeric|min:1|max:5',
            'photo_review' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $pemesanan = Pemesanan::with(['kamar'])
            ->where('id_pemesanan', $validated['id_pemesanan'])
            ->where('id_user', $validated['id_user'])
            ->first();

        if (!$pemesanan) {
            return response()->json([
                'message' => 'Data pemesanan tidak ditemukan atau bukan milik Anda.',
            ], 404);
        }

        if (Carbon::parse($pemesanan->check_out)->isFuture()) {
            return response()->json([
                'message' => 'Anda baru bisa memberikan review setelah melewati tanggal checkout.',
            ], 400);
        }

        $existingReview = Review::where('id_pemesanan', $validated['id_pemesanan'])->first();

        if ($existingReview) {
            return response()->json([
                'message' => 'Anda sudah memberikan review untuk pemesanan ini.',
            ], 400);
        }

        if (!$pemesanan->kamar) {
            return response()->json([
                'message' => 'Data kamar dari pemesanan tidak ditemukan.',
            ], 404);
        }

        $photoPath = null;
        if ($request->hasFile('photo_review')) {
            $photoPath = $request->file('photo_review')->store('reviews', 'public');
        }

        $review = Review::create([
            'id_user' => $validated['id_user'],
            'id_pemesanan' => $pemesanan->id_pemesanan,
            'id_hotel' => $pemesanan->kamar->id_hotel,
            'komentar' => $validated['komentar'],
            'rating' => $validated['rating'],
            'photo_review' => $photoPath,
            'tanggal_review' => now()->format('Y-m-d H:i:s'),
            'is_delete' => false,
        ]);

        $idHotel = $review->id_hotel;
        $averageRating = Review::where('id_hotel', $idHotel)
            ->where('is_delete', false)
            ->avg('rating');
        $rating = $averageRating ? round($averageRating, 1) : 0;

        \App\Models\Hotel::where('id_hotel', $idHotel)->update([
            'rating_hotel' => $rating,
        ]);

        \App\Models\Kamar::where('id_hotel', $idHotel)->update([
            'rating_kamar' => $rating,
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
                'message' => 'Data review tidak ditemukan.',
            ], 404);
        }

        if ($review->id_user != $request->id_user) {
            return response()->json([
                'message' => 'Unauthorized. Anda tidak memiliki akses untuk menghapus review ini.',
            ], 403);
        }

        $review->update([
            'is_delete' => true,
        ]);

        $idHotel = $review->id_hotel;
        $averageRating = Review::where('id_hotel', $idHotel)
            ->where('is_delete', false)
            ->avg('rating');
        $rating = $averageRating ? round($averageRating, 1) : 0;

        \App\Models\Hotel::where('id_hotel', $idHotel)->update([
            'rating_hotel' => $rating,
        ]);

        \App\Models\Kamar::where('id_hotel', $idHotel)->update([
            'rating_kamar' => $rating,
        ]);

        return response()->json([
            'message' => 'Review berhasil dihapus.',
        ], 200);
    }

    public function byHotel($idHotel)
    {
        $reviews = Review::with(['user:id_user,nama,photo_profile'])
            ->where('id_hotel', $idHotel)
            ->where('is_delete', false)
            ->orderByDesc('tanggal_review')
            ->get();

        $totalReview = $reviews->count();
        $averageRating = $totalReview > 0
            ? round((float) $reviews->avg('rating'), 1)
            : 0;

        return response()->json([
            'message' => 'Data review hotel berhasil diambil',
            'data' => [
                'id_hotel' => (int) $idHotel,
                'total_review' => $totalReview,
                'average_rating' => $averageRating,
                'reviews' => $reviews,
            ],
        ], 200);
    }

    public function getRoomReviews($id_kamar)
    {
        $reviews = Review::with([
                'user:id_user,nama,photo_profile',
                'pemesanan:id_pemesanan,id_kamar,is_delete',
            ])
            ->where('is_delete', false)
            ->whereHas('pemesanan', function ($query) use ($id_kamar) {
                $query->where('id_kamar', $id_kamar)
                      ->where('is_delete', false);
            })
            ->orderByDesc('tanggal_review')
            ->get();

        $totalReview = $reviews->count();
        $averageRating = $totalReview > 0
            ? round((float) $reviews->avg('rating'), 1)
            : 0;

        return response()->json([
            'message' => 'Data review kamar berhasil diambil',
            'data' => [
                'id_kamar' => (int) $id_kamar,
                'total_review' => $totalReview,
                'average_rating' => $averageRating,
                'reviews' => $reviews,
            ],
        ], 200);
    }
}