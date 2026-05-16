<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\FasilitasHotelController;
use App\Http\Controllers\GambarHotelController;

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


// Hotel
Route::get('/hotels', [HotelController::class, 'index']);
Route::get('/hotels/{id_hotel}', [HotelController::class, 'show']);
Route::post('/hotels', [HotelController::class, 'store']);
Route::put('/hotels/{id_hotel}', [HotelController::class, 'update']);
Route::delete('/hotels/{id_hotel}', [HotelController::class, 'destroy']);

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