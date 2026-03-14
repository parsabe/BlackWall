<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ChatController;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\ConversationManagerController;

// Put these near your other chat-related routes
Route::put('/chat/{id}/rename', [ConversationManagerController::class, 'rename'])->name('chat.rename');
Route::delete('/chat/{id}', [ConversationManagerController::class, 'destroy'])->name('chat.destroy');


Route::get('/', function () {
    return view('chat');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});
require __DIR__.'/auth.php';
