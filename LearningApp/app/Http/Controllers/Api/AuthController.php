<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        $user = User::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Akaunti imetengenezwa vizuri.',
            'data' => $this->authData($user, $data['device_name'] ?? 'android-app'),
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'login' => ['required_without:email', 'string'],
            'email' => ['required_without:login', 'nullable', 'string'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        $login = $data['login'] ?? $data['email'];
        $user = User::where('email', $login)->orWhere('username', $login)->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Barua pepe au nenosiri si sahihi.'],
            ]);
        }

        if (! $user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Akaunti hii imesimamishwa. Wasiliana na admin.'],
            ]);
        }

        $user->tokens()->where('name', $data['device_name'] ?? 'android-app')->delete();

        return response()->json([
            'success' => true,
            'message' => 'Karibu tena!',
            'data' => $this->authData($user, $data['device_name'] ?? 'android-app'),
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'data' => ['user' => $request->user()]]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:100'],
            'profile_photo' => ['sometimes', 'required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $user = $request->user();

        if ($request->hasFile('profile_photo')) {
            if ($user->profile_photo_path) {
                Storage::disk('public')->delete($user->profile_photo_path);
            }

            $data['profile_photo_path'] = $request->file('profile_photo')
                ->store('profile-photos', 'public');
        }

        unset($data['profile_photo']);
        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully.',
            'data' => ['user' => $user->fresh()],
        ]);
    }

    public function profilePhoto(User $user): mixed
    {
        abort_unless(
            $user->profile_photo_path && Storage::disk('public')->exists($user->profile_photo_path),
            404,
        );

        return response()->file(Storage::disk('public')->path($user->profile_photo_path), [
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    public function notificationSound(): mixed
    {
        return response()->file(public_path('sounds/notification.mp3'), [
            'Content-Type' => 'audio/mpeg',
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['success' => true, 'message' => 'Umetoka salama.']);
    }

    private function authData(User $user, string $deviceName): array
    {
        return [
            'user' => $user,
            'token' => $user->createToken($deviceName)->plainTextToken,
            'token_type' => 'Bearer',
        ];
    }
}
