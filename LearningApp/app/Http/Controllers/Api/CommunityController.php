<?php

namespace App\Http\Controllers\Api;

use App\Events\ChatMessageSent;
use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;

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
        if ($request->user()->role === 'admin') {
            $contacts = User::where('role', 'student')
                ->withCount(['sentMessages as unread_count' => fn ($query) => $query
                    ->where('recipient_id', $request->user()->id)
                    ->whereNull('read_at')])
                ->latest()
                ->get(['id', 'name', 'username', 'email', 'is_active', 'created_at']);
        } else {
            $contacts = User::where('role', 'admin')
                ->where('is_active', true)
                ->get(['id', 'name', 'username', 'email']);
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

        $messages = ChatMessage::with('sender:id,name,username,role')
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

        broadcast(new ChatMessageSent($message));

        return response()->json([
            'success' => true,
            'message' => 'Ujumbe umetumwa.',
            'data' => $message->load('sender:id,name,username,role'),
        ], 201);
    }

    private function ensureCanChat(User $current, User $other): void
    {
        $allowed = ($current->role === 'admin' && $other->role === 'student')
            || ($current->role === 'student' && $other->role === 'admin');

        abort_unless($allowed && $other->is_active, 403, 'Mazungumzo haya hayaruhusiwi.');
    }
}
