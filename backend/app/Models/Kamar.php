<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

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
        'is_delete',
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
    public function pemesanan(){
        return $this->hasMany(Pemesanan::class, 'id_kamar', 'id_kamar');
    }
}