<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Fasilitas extends Model
{
    protected $table = 'fasilitas';
    protected $primaryKey = 'id_fasilitas';
    public $timestamps = false;

    protected $fillable = [
        'nama_fasilitas',
        'icon_fasilitas'
    ];

    public function hotels(): BelongsToMany
    {
        return $this->belongsToMany( Hotel::class, 'fasilitas_hotel', 'id_fasilitas', 'id_hotel');
    }
}