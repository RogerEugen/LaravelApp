<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'name' => 'Learn Laravel Kiswahili API',
        'status' => 'online',
        'api' => url('/api/v1'),
    ]);
});
