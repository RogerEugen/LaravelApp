<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserProgress extends Model
{
    protected $table = 'user_progress';

    protected $fillable = ['user_id', 'lesson_id', 'is_completed', 'completed_at', 'best_score'];

    protected function casts(): array
    {
        return ['is_completed' => 'boolean', 'completed_at' => 'datetime', 'best_score' => 'integer'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }
}
