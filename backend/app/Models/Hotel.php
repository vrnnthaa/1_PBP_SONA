<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Hotel extends Model
{
    protected $table = 'hotel';
    protected $primaryKey = 'id_hotel';
    public $timestamps = false;

    protected $fillable = [
        'nama_hotel',
        'kota',
        'alamat',
        'deskripsi',
        'rating_hotel',
        'is_delete',
        'latitude',
        'longitude'
    ];

    public function kamar(): HasMany
    {
        return $this->hasMany(Kamar::class, 'id_hotel', 'id_hotel');
    }

    public function gambarHotel(): HasMany
    {
        return $this->hasMany(GambarHotel::class, 'id_hotel', 'id_hotel');
    }

    public function fasilitas(): BelongsToMany
    {
        return $this->belongsToMany(Fasilitas::class, 'fasilitas_hotel','id_hotel','id_fasilitas');
    }

     public function reviews()
    {
        return $this->hasMany(Review::class, 'id_hotel', 'id_hotel')
            ->where('is_delete', false);
    }
}