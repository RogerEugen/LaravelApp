<?php

namespace App\Http\Controllers\Api;

use App\Events\ChatMessageSent;
use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Log;

class CommunityController extends Controller
{
    public function config(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'app_key' => config('broadcasting.connections.reverb.key'),
                'host' => env('REVERB_PUBLIC_HOST', $request->getHost()),
                'port' => (int) env('REVERB_PUBLIC_PORT', 8080),
                'scheme' => env('REVERB_PUBLIC_SCHEME', 'ws'),
                'channel' => 'private-chat.'.$request->user()->id,
            ],
        ]);
    }

    public function authorize(Request $request): mixed
    {
        return Broadcast::auth($request);
    }

    public function contacts(Request $request): JsonResponse
    {
        if (in_array($request->user()->role, ['admin', 'support'], true)) {
            $contacts = User::where('role', 'student')
                ->withCount(['sentMessages as unread_count' => fn ($query) => $query
                    ->where('recipient_id', $request->user()->id)
                    ->whereNull('read_at')])
                ->latest()
                ->get(['id', 'name', 'username', 'email', 'is_active', 'profile_photo_path', 'created_at']);
        } else {
            $contacts = User::whereIn('role', ['admin', 'support'])
                ->where('is_active', true)
                ->get(['id', 'name', 'username', 'email', 'role', 'expertise', 'bio', 'profile_photo_path']);
        }

        return response()->json(['success' => true, 'data' => $contacts]);
    }

    public function conversation(Request $request, User $user): JsonResponse
    {
        $this->ensureCanChat($request->user(), $user);

        ChatMessage::where('sender_id', $user->id)
            ->where('recipient_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $messages = ChatMessage::with('sender:id,name,username,role,profile_photo_path')
            ->where(function ($query) use ($request, $user) {
                $query->where('sender_id', $request->user()->id)
                    ->where('recipient_id', $user->id);
            })
            ->orWhere(function ($query) use ($request, $user) {
                $query->where('sender_id', $user->id)
                    ->where('recipient_id', $request->user()->id);
            })
            ->oldest()
            ->limit(200)
            ->get();

        return response()->json(['success' => true, 'data' => $messages]);
    }

    public function send(Request $request, User $user): JsonResponse
    {
        $this->ensureCanChat($request->user(), $user);
        $data = $request->validate(['message' => ['required', 'string', 'max:2000']]);

        $message = ChatMessage::create([
            'sender_id' => $request->user()->id,
            'recipient_id' => $user->id,
            'message' => trim($data['message']),
        ]);

        try {
            broadcast(new ChatMessageSent($message));
        } catch (\Throwable $exception) {
            Log::warning('Realtime broadcast failed; message remains stored.', [
                'message_id' => $message->id,
                'error' => $exception->getMessage(),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Ujumbe umetumwa.',
            'data' => $message->load('sender:id,name,username,role'),
        ], 201);
    }

    private function ensureCanChat(User $current, User $other): void
    {
        $staffRoles = ['admin', 'support'];
        $allowed = (in_array($current->role, $staffRoles, true) && $other->role === 'student')
            || ($current->role === 'student' && in_array($other->role, $staffRoles, true));

        abort_unless($allowed && $other->is_active, 403, 'Mazungumzo haya hayaruhusiwi.');
    }
}
