<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class FasilitasHotel extends Model
{
    protected $table = 'kamar_fasilitas';
    protected $primaryKey = 'id_fasilitas';
    public $timestamps = false;

    protected $fillable = [
        'nama_fasilitasKamar',
        'keterangan_fasilitasKamar'
    ];

    public function hotels(): BelongsToMany
    {
        return $this->belongsToMany(
            Hotel::class,
            'fasilitas_hotel',
            'id_hotel_fasilitas',
            'id_hotel',
            'id_fasilitas',
            'id_hotel'
        );
    }
}