<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AddOn extends Model {
    public $timestamps = false;

    protected $table = 'add_on';
    protected $primaryKey = 'id_addon';

    protected $fillable = [
        'id_pemesanan',
        'nama_addon',
        'harga_addon',
        'keterangan_addon',
    ];

    protected $casts = [
        'id_pemesanan' => 'integer',
        'harga_addon' => 'float',
    ];

    //Relation
    public function pemesanan() {
        return $this->belongsTo(Pemesanan::class, 'id_pemesanan', 'id_pemesanan');
    }

}
//alvin

