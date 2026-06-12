<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasColumn('users', 'photo_profile')) {
            Schema::table('users', function (Blueprint $table) {
                $table->text('photo_profile')->nullable()->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('users', 'photo_profile')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('photo_profile', 255)->nullable()->change();
            });
        }
    }
};
