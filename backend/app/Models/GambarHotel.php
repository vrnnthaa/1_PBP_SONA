<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GambarHotel extends Model
{
    protected $table = 'gambar_hotel';
    protected $primaryKey = 'id_gambarhotel';
    public $timestamps = false;

    protected $fillable = [
        'id_hotel',
        'nama_gambarhotel',
        'keterangan_gambarhotel',
        'url_gambarhotel'
    ];

    protected $casts = [
        'id_gambarhotel' => 'integer',
        'id_hotel' => 'integer'
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel');
    }
}