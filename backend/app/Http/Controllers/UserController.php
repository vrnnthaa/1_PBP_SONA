<?php 

namespace App\Http\Controllers; 

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController 
{
    public function index(Request $request)
    {
        $user = $request->user();

        if(!$user)
        {
            return response()->json([
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        $ordersCount = \App\Models\Pembayaran::where('status_pembayaran', \App\Models\Pembayaran::STATUS_PAID)
            ->whereHas('pemesanan', function ($query) use ($user) {
                $query->where('id_user', $user->id_user);
            })->count();

        $userData = $user->toArray();
        $userData['orders_count'] = $ordersCount;

        return response()->json([
            'message' => 'Data user berhasil diambil',
            'data' => $userData,
        ], 200);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        if(!$user)
        {
            return response()->json([
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        $user->update([
            'nama' => $request->nama ?? $user->nama,
            'telp_no' => $request->nomor_telp ?? $user->nomor_telp,
            'email' => $request->email ?? $user->email,
            'photo_profile' => $request->photo_profile ?? $user->photo_profile,
        ]);

        return response()->json([
            'message' => 'Data user berhasil diubah',
            'data' => $user
        ], 200); 
    }

    public function changePassword(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if(!Hash::check($request->password, $user->password))
        {
            return response()->json([
                'message' => 'Password lama salah.'
            ], 400);
        }

        $user->password = Hash::make($request->password_baru);
        $user->save();

        return response()->json([
            'message' => 'Password berhasil diubah',
            'data' => $user,
        ], 200);
    }

    public function changePin(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        if (!password_verify($request->pin_lama, $user->pin)) {
            return response()->json([
                'message' => 'Incorrect current PIN'
            ], 400);
        }

        $user->pin = Hash::make($request->pin_baru);
        $user->save();

        return response()->json([
            'message' => 'PIN updated successfully'
        ], 200);
    }

    public function verifyPin(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        if (!$request->pin) {
            return response()->json([
                'message' => 'PIN is required'
            ], 400);
        }

        if (!password_verify($request->pin, $user->pin)) {
            return response()->json([
                'message' => 'Incorrect PIN'
            ], 400);
        }

        return response()->json([
            'message' => 'PIN is valid'
        ], 200);
    }

    public function changeFingerprint(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        $user->sidik_jari = Hash::make($request->sidik_jari);
        $user->save();

        return response()->json([
            'message' => 'Fingerprint berhasil didaftarkan',
            'data' => $user
        ], 200);
    }
}


?>