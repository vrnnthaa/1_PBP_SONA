<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pemesanan extends Model
{
    public $timestamps = false;

    protected $table = 'pemesanan';
    protected $primaryKey = 'id_pemesanan';

    protected $fillable = [
        'id_user',
        'id_kamar',
        'check_in',
        'check_out',
        'jumlah_pengunjung',
        'total_biaya',
        'status_pemesanan',
        'is_delete',
    ];

    protected $attributes = [
        'is_delete' => false,
        'status_pemesanan' => self::STATUS_AKTIF,
    ];

    protected $casts = [
        'id_user' => 'integer',
        'id_kamar' => 'integer',
        'check_in' => 'date',
        'check_out' => 'date',
        'jumlah_pengunjung' => 'integer',
        'total_biaya' => 'float',
        'is_delete' => 'boolean',
    ];

    public const STATUS_TIDAK_AKTIF = 'tidak aktif';
    public const STATUS_AKTIF = 'aktif';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_MENUNGGU_REVIEW = 'menunggu review';
    public const STATUS_SUDAH_REVIEW = 'sudah review';

    protected static function booted()
    {
        static::addGlobalScope('active', function ($builder) {
            $builder->where('is_delete', false);
        });
    }

    public function delete()
    {
        $this->is_delete = true;
        return $this->save();
    }

    public function restore()
    {
        $this->is_delete = false;
        return $this->save();
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function kamar()
    {
        return $this->belongsTo(Kamar::class, 'id_kamar', 'id_kamar');
    }

    public function pembayaran()
    {
        return $this->hasOne(Pembayaran::class, 'id_pemesanan', 'id_pemesanan');
    }

    public function review()
    {
        return $this->hasOne(Review::class, 'id_pemesanan', 'id_pemesanan');
    }

    public function addons()
    {
        return $this->hasMany(AddOn::class, 'id_pemesanan', 'id_pemesanan');
    }

    public function scopeTidakAktif($query)
    {
        return $query->where('status_pemesanan', self::STATUS_TIDAK_AKTIF);
    }

    public function scopeAktif($query)
    {
        return $query->where('status_pemesanan', self::STATUS_AKTIF);
    }

    public function scopeCancelled($query)
    {
        return $query->where('status_pemesanan', self::STATUS_CANCELLED);
    }

    public function scopeMenungguReview($query)
    {
        return $query->where('status_pemesanan', self::STATUS_MENUNGGU_REVIEW);
    }

    public function scopeSudahReview($query)
    {
        return $query->where('status_pemesanan', self::STATUS_SUDAH_REVIEW);
    }
}