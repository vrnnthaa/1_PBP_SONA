<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GambarHotel extends Model
{
    protected $table = 'gambar_hotel';
    protected $primaryKey = 'id_gambarHotel';
    public $timestamps = false;

    protected $fillable = [
        'id_hotel',
        'nama_gambarHotel',
        'keterangan_gambarHotel',
        'url_gambarHotel'
    ];
    protected $casts = [
        'id_gambarHotel' => 'integer',
        'id_hotel' => 'integer'
    ];
    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel');
    }
}