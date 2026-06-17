<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model {
    public $timestamps = false;

    protected $table = 'pembayaran';
    protected $primaryKey = 'id_pembayaran';

    protected $fillable = [
        'id_pemesanan',
        'tanggal_pembayaran',
        'jumlah_bayar',
        'status_pembayaran',
        'metode_pembayaran',
        'is_delete',
    ];

    protected $attributes = [
        'is_delete' => false,
    ];

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

    protected $casts = [
        'tanggal_pembayaran'    => 'datetime',
        'jumlah_bayar'          => 'decimal:2',
    ];

    const STATUS_PENDING = 'menunggu pembayaran';
    const STATUS_PAID = 'pembayaran terverifikasi';
    const STATUS_EXPIRED = 'pembayaran gagal';
    const STATUS_FAILED = 'pembayaran gagal';

    //Relation
    public function pemesanan() {
        return $this->belongsTo(Pemesanan::class, 'id_pemesanan', 'id_pemesanan');
    }

    //==========
    //Scopes
    //==========
    public function scopePaid($query) {
        return $query->where('status_pembayaran', self::STATUS_PAID);
    }

    public function scopePending($query) {
        return $query->where('status_pembayaran', self::STATUS_PENDING);
    }

}

//alvin