<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
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
