<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
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
        'rating_hotel'
    ];
    protected $casts = [
        'id_hotel' => 'integer',
        'rating_hotel' => 'decimal:2'
    ];
    public function fasilitasHotels(): HasMany
    {
        return $this->hasMany(FasilitasHotel::class, 'id_hotel', 'id_hotel');
    }

    public function gambarHotels(): HasMany
    {
        return $this->hasMany(GambarHotel::class, 'id_hotel', 'id_hotel');
    }
}