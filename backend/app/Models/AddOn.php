<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AddOn extends Model {
    public $timestamps = false;

    protected $table = 'add_on';
    protected $primaryKey = 'id_addon';

    protected $fillable = [
        'id_kamar',
        'nama_addon',
        'keterangan_addon',
    ];

    //Relation
    public function kamar() {
        return $this->belongsTo(Kamar::class, 'id_kamar', 'id_kamar');
    }

}
//alvin

