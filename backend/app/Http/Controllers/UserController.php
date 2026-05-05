<?php 

namespace App\Http\Controllers; 

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index($id)
    {
        $user = User::find($id);

        if(!$user)
        {
            return response()->json([
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'message' => 'Data user berhasil diambil',
            'data' => $user,
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if(!$user)
        {
            return response()->json([
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        $user->update([
            'nama' => $request->nama ?? $user->nama,
            'telp_no' => $request->nomor_telp ?? $user->nomor_telp,
            'foto_profile' => $request->foto_profile ?? $user->foto_profile,
        ]);

        return response()->json([
            'message' => 'Data user berhasil diubah',
            'data' => $user
        ], 200); 
    }

    public function changePassword(Request $request, $id)
    {
        $user = User::find($id);

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

        $user->password = $request->password_baru;
        $user->save();

        return response()->json([
            'message' => 'Password berhasil diubah',
            'data' => $user,
        ], 200);
    }

    public function changePin(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if (!Hash::check($request->pin_lama, $user->pin)) {
            return response()->json([
                'message' => 'PIN lama salah'
            ], 400);
        }

        $user->pin = $request->pin_baru;
        $user->save();

        return response()->json([
            'message' => 'PIN berhasil diubah'
        ], 200);
    }
}

?>