<?php 

namespace App\Models; 

use Illuminate\Database\Eloquent\Model; 
use Illuminate\Database\Eloquent\Factories\HasFactory; 
use App\Models\User; 
use App\Models\Hotel; 

class SaveHotel extends Model{
    use HasFactory; 

    protected $table = 'save_hotel'; 

    protected $primaryKey = 'id_savehotel';

    protected $keyType = 'int';

    public $timestamps = false;

    protected $fillable = [
        'id_user',
        'id_hotel',
        'is_saved',
    ];

    public function user(){
        return $this->belongsTo(User::class, 'id_user', 'id_user'); 
    }
    public function hotel(){
        return $this->belongsTo(Hotel::class, 'id_hotel', 'id_hotel'); 
    }
}