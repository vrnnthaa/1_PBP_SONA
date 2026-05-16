<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pemesanan extends Model {
    use SoftDeletes;

    protected $table = 'pemesanan';
    protected $primaryKey = 'id_pemesanan';

    protected $fillable = [
        'id_user',
        'check_in',
        'check_out',
        'jumlah_pengunjung',
        'total_biaya',
        'status_pemesanan',
    ];

    protected $casts = [
        'check_in'             => 'datetime',
        'check_out'            => 'datetime',
        'total_biaya'          => 'decimal:2',
        'jumlah_pengunjung'    => 'integer',
    ];

    const STATUS_PENDING = 'pending';
    const STATUS_CONFIRMED = 'confirmed';
    const STATUS_CANCELLED = 'canceled';
    
    //relation
    public function user() {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function pembayaran() {
        return $this->hasOne(Pembayaran::class, 'id_pembayaran', 'id_pembayaran');
    }

    public function review() {
        return $this->hasOne(Review::class, 'id_review', 'id_review');
    }
    
    //=======
    //Scope
    //=======
    public function scopePending($query){
        return $query->where('status_pemesanan', self::STATUS_PENDING);
    }

    public function scopeConfirmed($query){
        return $query->where('status_pemesanan', self::STATUS_CONFIRMED);
    }

    public function scopeCancelLed($query){
        return $query->where('status_pemesanan', self::STATUS_CANCELLED);
    }
}
//alvin