<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pembayaran extends Model {
    use SoftDeletes; //biar datanya engga kehapus permanen

    protected $table = 'Pembayaran';
    protected $primaryKey = 'id_pembayaran';

    protected $fillable = [
        'id_pemesanan',
        'tanggal_pembayaran',
        'jumlah_bayar',
        'status_pembayaran',
        'metode_pembayaran',
    ];

    protected $casts = [
        'tanggal_pembayaran'    => 'date',
        'jumlah_bayar'          => 'decimal:2',
    ];

    const STATUS_PENDING = 'pending';
    const STATUS_PAID = 'paid';
    const STATUS_EXPIRED = 'expired';
    const STATUS_FAILED = 'failed';

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