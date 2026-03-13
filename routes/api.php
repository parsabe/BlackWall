<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ChatController; // Make sure to import your controller!

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Add your Blackwall chat route here
Route::post('/chat/send', [ChatController::class, 'sendMessage']);