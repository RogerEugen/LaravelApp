<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CommunityController;
use App\Http\Controllers\Api\LearningController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
    Route::get('/users/{user}/profile-photo', [AuthController::class, 'profilePhoto']);
    Route::get('/notification-sound', [AuthController::class, 'notificationSound']);
    Route::get('/dashboard', [LearningController::class, 'dashboard']);
    Route::get('/topics', [LearningController::class, 'topics']);
    Route::get('/topics/{topic}', [LearningController::class, 'topic']);
    Route::get('/lessons/{lesson}', [LearningController::class, 'lesson']);
    Route::get('/lessons/{lesson}/video', [LearningController::class, 'video']);

    Route::middleware(['auth:sanctum', 'active'])->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/profile', [AuthController::class, 'updateProfile']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/lessons/{lesson}/complete', [LearningController::class, 'complete']);
        Route::get('/lessons/{lesson}/quiz', [LearningController::class, 'quiz']);
        Route::post('/lessons/{lesson}/quiz', [LearningController::class, 'submitQuiz']);
        Route::get('/progress', [LearningController::class, 'progress']);

        Route::post('/broadcasting/auth', [CommunityController::class, 'authorize']);
        Route::get('/realtime/config', [CommunityController::class, 'config']);
        Route::get('/community/contacts', [CommunityController::class, 'contacts']);
        Route::get('/community/conversations/{user}', [CommunityController::class, 'conversation']);
        Route::post('/community/conversations/{user}', [CommunityController::class, 'send']);

        Route::prefix('admin')->middleware('admin')->group(function () {
            Route::get('/dashboard', [AdminController::class, 'dashboard']);
            Route::get('/users', [AdminController::class, 'users']);
            Route::patch('/users/{user}/toggle', [AdminController::class, 'toggleUser']);
            Route::get('/supports', [AdminController::class, 'supports']);
            Route::post('/supports', [AdminController::class, 'storeSupport']);

            Route::get('/topics', [AdminController::class, 'topics']);
            Route::post('/topics', [AdminController::class, 'storeTopic']);
            Route::put('/topics/{topic}', [AdminController::class, 'updateTopic']);
            Route::delete('/topics/{topic}', [AdminController::class, 'deleteTopic']);

            Route::get('/lessons', [AdminController::class, 'lessons']);
            Route::post('/lessons', [AdminController::class, 'storeLesson']);
            Route::put('/lessons/{lesson}', [AdminController::class, 'updateLesson']);
            Route::delete('/lessons/{lesson}', [AdminController::class, 'deleteLesson']);

            Route::get('/quizzes', [AdminController::class, 'quizzes']);
            Route::post('/quizzes', [AdminController::class, 'storeQuiz']);
            Route::put('/quizzes/{quiz}', [AdminController::class, 'updateQuiz']);
            Route::delete('/quizzes/{quiz}', [AdminController::class, 'deleteQuiz']);
        });
    });
});
