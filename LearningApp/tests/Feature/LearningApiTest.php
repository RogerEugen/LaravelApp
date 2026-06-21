<?php

use App\Events\ChatMessageSent;
use App\Models\Lesson;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed();
});

it('registers a mobile user and returns a sanctum token', function () {
    $this->postJson('/api/v1/register', [
        'name' => 'Asha',
        'email' => 'asha@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'device_name' => 'android-7',
    ])->assertCreated()
        ->assertJsonPath('success', true)
        ->assertJsonStructure(['data' => ['user', 'token', 'token_type']]);
});

it('allows guests to browse learning content', function () {
    $this->getJson('/api/v1/dashboard')
        ->assertOk()
        ->assertJsonPath('data.stats.developers', 'Millions+')
        ->assertJsonCount(3, 'data.slides');

    $this->getJson('/api/v1/topics')
        ->assertOk()
        ->assertJsonCount(3, 'data');

    $this->getJson('/api/v1/lessons/'.Lesson::first()->id)
        ->assertOk()
        ->assertJsonPath('data.requires_login_for_quiz', true);
});

it('authenticates and stores learning progress', function () {
    $user = User::where('role', 'student')->first();
    $token = $user->createToken('test')->plainTextToken;

    $lesson = Lesson::first();
    $this->withToken($token)->postJson("/api/v1/lessons/{$lesson->id}/complete")
        ->assertOk()
        ->assertJsonPath('data.is_completed', true);
});

it('rejects protected endpoints without a token', function () {
    $this->getJson('/api/v1/progress')->assertUnauthorized();
    $this->getJson('/api/v1/lessons/'.Lesson::first()->id.'/quiz')->assertUnauthorized();
});

it('allows the owner admin to manage users and content', function () {
    $admin = User::where('username', 'rogerscharleseugen')->firstOrFail();
    expect($admin->role)->toBe('admin');
    expect(password_verify('roger123', $admin->password))->toBeTrue();
    $token = $admin->createToken('admin-test')->plainTextToken;

    $this->withToken($token)->getJson('/api/v1/admin/dashboard')
        ->assertOk()
        ->assertJsonPath('data.topics', 3);

    $student = User::where('role', 'student')->firstOrFail();
    $this->withToken($token)->patchJson("/api/v1/admin/users/{$student->id}/toggle")
        ->assertOk()
        ->assertJsonPath('data.is_active', false);
});

it('supports realtime community messages between student and admin', function () {
    Event::fake([ChatMessageSent::class]);
    $student = User::where('role', 'student')->firstOrFail();
    $admin = User::where('role', 'admin')->firstOrFail();
    $token = $student->createToken('chat-test')->plainTextToken;

    $this->withToken($token)->postJson("/api/v1/community/conversations/{$admin->id}", [
        'message' => 'Naomba msaada kuhusu routes.',
    ])->assertCreated()
        ->assertJsonPath('data.sender_id', $student->id);

    Event::assertDispatched(ChatMessageSent::class);
});
