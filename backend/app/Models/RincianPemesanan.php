<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RincianPemesanan extends Model
{
    protected $table = 'rincian_pemesanan';
    protected $primaryKey = 'id_rincianpemesanan';
    public $timestamps = false;

    protected $fillable = [
        'id_pemesanan',
        'jumlah_kamar',
        'sub_total',
        'is_delete',
        'id_kamar',
    ];

    protected $attributes = [
        'is_delete' => false,
    ];

    protected $casts = [
        'jumlah_kamar' => 'integer',
        'sub_total' => 'decimal:2',
        'is_delete' => 'boolean',
    ];

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class, 'id_pemesanan', 'id_pemesanan');
    }

    public function kamar()
    {
        return $this->belongsTo(Kamar::class, 'id_kamar', 'id_kamar');
    }
}