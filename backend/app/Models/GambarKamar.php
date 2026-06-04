<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GambarKamar extends Model
{
    protected $table = 'gambar_kamar';
    protected $primaryKey = 'id_gambarkamar';

    protected $fillable = [
        'id_kamar',
        'nama_gambarkamar',
        'keterangan_gambarkamar',
        'url_gambarkamar',
    ];

    public function kamar()
    {
        return $this->belongsTo(Kamar::class, 'id_kamar', 'id_kamar');
    }
}