<?php 

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        if(!$request->nama || !$request->telp_no || !$request->email || !$request->password)
        {
            return response()->json([
                'message' => 'Nama, nomor telepon, email, dan password wajib diisi'
            ], 400);
        }

        $cek = User::where('email', $request->email)->first();
        if($cek)
        {
            return response()->json([
                'message' => 'Email sudah digunakan'
            ], 400);
        }

        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => $request->password,
            'telp_no' => $request->telp_no,
            'photo_profile' => null,
            'pin' => null,
        ]);

        return response()->json([
            'message' => 'Register berhasil, lanjut set PIN',
            'id_user' => $user->id_user
        ], 201);
    }

    public function setPin(Request $request)
    {
        if (!$request->id_user) {
            return response()->json([
                'message' => 'ID user wajib diisi'
            ], 400);
        }

        $user = User::find($request->id_user);

        if (!$user) {
            return response()->json([
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if (!$request->pin) {
            return response()->json([
                'message' => 'PIN wajib diisi'
            ], 400);
        }

        $user->pin = $request->pin;
        $user->save();

        return response()->json([
            'message' => 'PIN berhasil disimpan'
        ], 200);
    }

    public function login(Request $request)
    {
        if (!$request->email || !$request->password) {
            return response()->json([
                'message' => 'Email dan password wajib diisi'
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Password salah'
            ], 400);
        }

        if (!$user->pin) {
            return response()->json([
                'message' => 'Silakan set PIN terlebih dahulu'
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $token,
            'data' => $user
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }
}

?>