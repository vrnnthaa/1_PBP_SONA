<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FasilitasHotel extends Model{
    protected $table = 'fasilitas_hotel';
    protected $primaryKey = 'id_fasilitasHotel';
    public $timestamps = false;

    protected $fillable = [
        'id_hotel',
        'nama_fasilitasHotel',
        'keterangan_fasilitasHotel'
    ];

    protected $casts = [
        'id_fasilitasHotel' => 'integer',
        'id_hotel' => 'integer'
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel');
    }
}