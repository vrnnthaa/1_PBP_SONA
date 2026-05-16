<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Review extends Model
{
    protected $table = 'review';
    protected $primaryKey = 'id_review';
    public $timestamps = false;

    protected $fillable = [
        'id_user',
        'id_pemesanan',
        'id_hotel',
        'komentar',
        'rating',
        'photo_review',
        'tanggal_review',
        'is_delete',
    ];
    
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class, 'id_pemesanan', 'id_pemesanan');
    }

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel');
    }
}