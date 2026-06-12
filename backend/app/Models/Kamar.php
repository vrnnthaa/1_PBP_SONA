<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kamar extends Model
{
    protected $table = 'kamar';
    protected $primaryKey = 'id_kamar';
    public $timestamps = false;

    protected $fillable = [
        'id_hotel',
        'nama_kamar',
        'tipe_kamar',
        'harga',
        'status_kamar',
        'deskripsi',
        'rating_kamar',
        'kapasitas',
        'ukuran_kamar',
        'offer',
        'occupancy',
        'is_delete',
    ];

    protected $casts = [
        'harga' => 'integer',
        'kapasitas' => 'integer',
        'rating_kamar' => 'float',
        'ukuran_kamar' => 'integer',
        'status_kamar' => 'boolean',
        'is_delete' => 'boolean',
        'offer' => 'array',
        'occupancy' => 'array',
    ];

    public function fasilitasKamar()
    {
        return $this->hasMany(FasilitasKamar::class, 'id_kamar', 'id_kamar');
    }

    public function gambarKamar()
    {
        return $this->hasMany(GambarKamar::class, 'id_kamar', 'id_kamar');
    }

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel');
    }

    public function pemesanan()
    {
        return $this->hasMany(Pemesanan::class, 'id_kamar', 'id_kamar');
    }
}