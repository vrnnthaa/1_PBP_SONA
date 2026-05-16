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
        'is_delete'
    ];

    protected $casts = [
        'is_delete' => 'boolean',
        'rating_hotel' => 'decimal:2'
    ];

    public function kamar(): HasMany
    {
        return $this->hasMany(Kamar::class, 'id_hotel', 'id_hotel');
    }

    public function gambarHotel(): HasMany
    {
        return $this->hasMany(GambarHotel::class, 'id_hotel', 'id_hotel');
    }

    public function fasilitasHotel(): BelongsToMany
    {
        return $this->belongsToMany(
            FasilitasHotel::class,
            'hotel_fasilitas',
            'id_hotel',
            'id_fasilitasHotel',
            'id_hotel',
            'id_fasilitas'
        );
    }

    // Scope: hotel aktif (tidak dihapus)
    public function scopeActive($query)
    {
        return $query->where('is_delete', false);
    }
}