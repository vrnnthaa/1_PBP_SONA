<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

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
    ];

    public function kamar()
    {
        return $this->hasMany(Kamar::class, 'id_hotel', 'id_hotel');
    }

    public function gambarHotel()
    {
        return $this->hasMany(GambarHotel::class, 'id_hotel', 'id_hotel');
    }

    public function fasilitasHotel()
    {
        return $this->belongsToMany(FasilitasHotel::class, 'hotel_fasilitas', 'id_hotel', 'id_fasilitasHotel');
    }
}