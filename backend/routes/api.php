<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\FasilitasHotelController;
use App\Http\Controllers\GambarHotelController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\KamarController;
use App\Http\Controllers\GambarKamarController;
use App\Http\Controllers\FasilitasKamarController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/google-auth', [AuthController::class, 'googleAuth']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/set-pin', [AuthController::class, 'setPin']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::prefix('user')
    ->controller(UserController::class)
    ->group(function () {
        Route::put('/change-fingerprint', [UserController::class, 'changeFingerprint']);
        Route::put('/change-password', [UserController::class, 'changePassword']);
        Route::put('/change-pin', [UserController::class, 'changePin']);
        Route::get('/{id}', [UserController::class, 'index']);
        Route::put('/{id}', [UserController::class, 'update']);
    });
});

Route::get('/gambar-kamar', [GambarKamarController::class, 'index']);
Route::get('/gambar-kamar/{id_gambarkamar}', [GambarKamarController::class, 'show']);
Route::post('/gambar-kamar', [GambarKamarController::class, 'store']);
Route::put('/gambar-kamar/{id_gambarkamar}', [GambarKamarController::class, 'update']);
Route::delete('/gambar-kamar/{id_gambarkamar}', [GambarKamarController::class, 'destroy']);
Route::get('/kamar/{id_kamar}/gambar', [GambarKamarController::class, 'byKamar']);

Route::get('/fasilitas-kamar', [FasilitasKamarController::class, 'index']);
Route::get('/fasilitas-kamar/{id_fasilitaskamar}', [FasilitasKamarController::class, 'show']);
Route::post('/fasilitas-kamar', [FasilitasKamarController::class, 'store']);
Route::put('/fasilitas-kamar/{id_fasilitaskamar}', [FasilitasKamarController::class, 'update']);
Route::delete('/fasilitas-kamar/{id_fasilitaskamar}', [FasilitasKamarController::class, 'destroy']);

Route::get('/reviews/room/{id_kamar}', [ReviewController::class, 'getRoomReviews']);

Route::get('/reviews/hotel/{idHotel}', [ReviewController::class, 'byHotel']);
Route::get('/reviews', [ReviewController::class, 'all']);
Route::get('/hotel/{id_hotel}/available-rooms', [KamarController::class, 'getAvailableRooms']);

// Hotel
Route::get('/hotels', [HotelController::class, 'index']);
Route::get('/hotels/{id_hotel}', [HotelController::class, 'show']);
Route::post('/hotels', [HotelController::class, 'store']);
Route::put('/hotels/{id_hotel}', [HotelController::class, 'update']);
Route::delete('/hotels/{id_hotel}', [HotelController::class, 'destroy']);
Route::get('/hotels/search', [HotelController::class, 'search']);

// Fasilitas Hotel
Route::get('/fasilitas-hotel', [FasilitasHotelController::class, 'index']);
Route::get('/fasilitas-hotel/{id_fasilitas}', [FasilitasHotelController::class, 'show']);
Route::post('/fasilitas-hotel', [FasilitasHotelController::class, 'store']);
Route::put('/fasilitas-hotel/{id_fasilitas}', [FasilitasHotelController::class, 'update']);
Route::delete('/fasilitas-hotel/{id_fasilitas}', [FasilitasHotelController::class, 'destroy']);

// Gambar Hotel
Route::get('/gambar-hotel', [GambarHotelController::class, 'index']);
Route::get('/gambar-hotel/{id_gambarhotel}', [GambarHotelController::class, 'show']);
Route::post('/gambar-hotel', [GambarHotelController::class, 'store']);
Route::put('/gambar-hotel/{id_gambarhotel}', [GambarHotelController::class, 'update']);
Route::delete('/gambar-hotel/{id_gambarhotel}', [GambarHotelController::class, 'destroy']);
Route::get('/hotels/{id_hotel}/gambar', [GambarHotelController::class, 'byHotel']);


//Alvin punya
use App\Http\Controllers\PemesananController;
use App\Http\Controllers\PembayaranController;
use App\Http\Controllers\AddOnController;
use App\Http\Controllers\SaveHotelController;

// ^-^
// SAVE HOTEL
// T-T
Route::get('/save-hotels', [SaveHotelController::class, 'index']);
Route::post('/save-hotels', [SaveHotelController::class, 'store']);
Route::put('/save-hotels/{id}', [SaveHotelController::class, 'update']);

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

