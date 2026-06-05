<?php 

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Http\Controllers\Controller;

class AuthController extends Controller
{
    public function register(Request $request)
    {

        if(!$request->nama)
        {
            return response()->json([
                'message' => 'Name is required',
                'field' => 'name',
            ], 400);
        }

        if(!$request->tanggal_lahir)
        {
            return response()->json([
                'message' => 'Date of birth is required',
                'field' => 'date_of_birth',
            ], 400);
        }

        if(!$request->telp_no)
        {
            return response()->json([
                'message' => 'Phone number is required',
                'field' => 'telp_no',
            ], 400);
        }

        if(!$request->email)
        {
            return response()->json([
                'message' => 'Email is required',
                'field' => 'email',
            ], 400);
        }

        if(!$request->password)
        {
            return response()->json([
                'message' => 'Password is required',
                'field' => 'password',
            ], 400);
        }

        $cek = User::where('email', $request->email)->first();
        if($cek)
        {
            return response()->json([
                'message' => 'Email is already used',
                'field' => 'email',
            ], 400);
        }

        //regex cek format email
        if (!preg_match("/^[\w\.-]+@[\w\.-]+\.\w+$/", $request->email)) {
            return response()->json([
                'message' => 'Email format is not valid',
                'field' => 'email',
            ], 400);
        }

        if(strlen($request->password) < 6)
        {
            return response()->json([
                'message' => 'Password must be at least 6 characters',
                'field' => 'password',
            ], 400);
        }

        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'telp_no' => $request->telp_no,
            'tanggal_lahir' => $request->tanggal_lahir,
            'sidik_jari' => null,
            'photo_profile' => null,
            'pin' => null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Register Successful',
            'token' => $token,
            'data' => $user,
        ], 201);
    }

    public function setPin(Request $request)
    {

        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated'
            ], 401);
        }

        if (!$request->pin) {
            return response()->json([
                'message' => 'PIN is required'
            ], 400);
        }

        if(strlen($request->pin) < 4) {
            return response()->json([
                'message' => 'Must be a 4 digit PIN'
            ], 400);
        }

        $user->pin = Hash::make($request->pin);
        $user->save();

        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'PIN Succesfully saved, please log in again',
            'data' => $user
        ], 200);
    }

    public function googleAuth(Request $request)
    {
        if (!$request->email) {
            return response()->json([
                'message' => 'Email is required',
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            $user = User::create([
                'nama' => $request->nama ?? 'Google User',
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'telp_no' => $request->telp_no,
                'tanggal_lahir' => $request->tanggal_lahir,
                'sidik_jari' => null,
                'photo_profile' => null,
                'pin' => null,
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Google Auth Success',
            'token' => $token,
            'has_pin' => !is_null($user->pin),
            'data' => $user,
        ]);
    }

    public function login(Request $request)
    {
        if (!$request->email && !$request->password) {
            return response()->json([
                'message' => 'Email and password are required',
                'field' => 'both',
            ], 400);
        }

        if (!$request->email) {
            return response()->json([
                'message' => 'Email is required',
                'field' => 'email',
            ], 400);
        }

        if (!$request->password) {
            return response()->json([
                'message' => 'Password is required',
                'field' => 'password',
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Email not found',
                'field' => 'email',
            ], 404);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Incorrect password',
                'field' => 'password',
            ], 400);
        }

        if (!$user->pin) {
            return response()->json([
                'message' => 'Please set your PIN first'
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'data' => $user
        ], 200);
    }

    public function me(Request $request)
    {
        return response()->json([
            'message' => 'Data user berhasil diambil',
            'data' => $request->user(),
        ]);
    }
    
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged Out'
        ]);
    }
}

?>