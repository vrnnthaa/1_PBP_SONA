<?php
//deven

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Notifications\Notifiable;
use App\Models\Pemesanan;
use App\Models\Review;
use App\Models\SaveHotel;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'users';
    protected $primaryKey = 'id_user';
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'photo_profile',
        'nama',
        'telp_no',
        'email',
        'password',
        'pin',
        'sidik_jari',
        'tanggal_lahir',
    ];

    protected $hidden = [
        'password',
        'pin',
    ];

    // public function setPasswordAttribute($value)
    // {
    //     $this->attributes['password'] = Hash::make($value);
    // }

    // public function setPinAttribute($value)
    // {
    //     $this->attributes['pin'] = Hash::make($value);
    // }

    // public function pemesanans() {
    //     return $this->hasMany(Pemesanan::class, 'id_user', 'id_user');
    // }

    // public function reviews() {
    //     return $this->hasMany(Review::class, 'id_user', 'id_user');
    // }

    public function saveHotels() {
        return $this->hasMany(SaveHotel::class, 'id_user', 'id_user');
    }
}
