<?php

namespace App\Events;

use App\Models\ChatMessage;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatMessageSent implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public function __construct(public ChatMessage $chatMessage)
    {
        $this->chatMessage->loadMissing('sender:id,name,username,role');
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat.'.$this->chatMessage->recipient_id),
            new PrivateChannel('chat.'.$this->chatMessage->sender_id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'chat.message';
    }

    public function broadcastWith(): array
    {
        return [
            'message' => [
                'id' => $this->chatMessage->id,
                'sender_id' => $this->chatMessage->sender_id,
                'recipient_id' => $this->chatMessage->recipient_id,
                'message' => $this->chatMessage->message,
                'created_at' => $this->chatMessage->created_at?->toISOString(),
                'sender' => $this->chatMessage->sender,
            ],
        ];
    }
}
