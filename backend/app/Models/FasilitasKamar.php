<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FasilitasKamar extends Model
{
    protected $table = 'fasilitas_kamar';
    protected $primaryKey = 'id_fasilitaskamar';

    protected $fillable = [
        'nama_fasilitaskamar',
        'icon_fasilitaskamar',
        'keterangan_fasilitaskamar',
    ];

    public function kamars()
    {
        return $this->belongsToMany(
            Kamar::class,
            'kamar_fasilitas',
            'id_fasilitaskamar',
            'id_kamar'
        );
    }
}