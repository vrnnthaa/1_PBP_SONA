<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/set-pin', [AuthController::class, 'setPin']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::prefix('user')
    ->controller(UserController::class)
    ->group(function () {
        Route::get('/{id}', [UserController::class, 'index']);
        Route::put('/{id}', [UserController::class, 'update']);
        Route::put('/change-password/{id}', [UserController::class, 'changePassword']);
        Route::put('/change-pin/{id}', [UserController::class, 'changePin']);
    });
});

//Alvin punya
use App\Http\Controllers\PemesananController;
use App\Http\Controllers\PembayaranController;
use App\Http\Controllers\AddOnController;

// ^-^
// PEMESANAN
// T-T
Route::get('/pemesanan/status/{status}', [PemesananController::class, 'getByStatus']);
Route::get('/pemesanan/user/{id_user}', [PemesananController::class, 'getByUser']);
Route::get('/pemesanan', [PemesananController::class, 'index']);
Route::get('/pemesanan/{id}', [PemesananController::class, 'show']);
Route::post('/pemesanan', [PemesananController::class, 'store']);
Route::put('/pemesanan/{id}', [PemesananController::class, 'update']);
Route::delete('/pemesanan/{id}', [PemesananController::class, 'destroy']);

// ^-^
// PEMBAYARAN
// T-T
Route::get('/pembayaran/pemesanan/{id_pemesanan}', [PembayaranController::class, 'getByPemesanan']);
Route::get('/pembayaran', [PembayaranController::class, 'index']);
Route::get('/pembayaran/{id}', [PembayaranController::class, 'show']);
Route::post('/pembayaran', [PembayaranController::class, 'store']);
Route::put('/pembayaran/{id}', [PembayaranController::class, 'update']);
Route::delete('/pembayaran/{id}', [PembayaranController::class, 'destroy']);

// ^-^
// Add-On
// T-T
Route::get('/addon/kamar/{id_kamar}', [AddOnController::class, 'getByKamar']);
Route::get('/addon', [AddOnController::class, 'index']);
Route::get('/addon/{id}', [AddOnController::class, 'show']);
Route::post('/addon', [AddOnController::class, 'store']);
Route::put('/addon/{id}', [AddOnController::class, 'update']);
Route::delete('/addon/{id}', [AddOnController::class, 'destroy']);