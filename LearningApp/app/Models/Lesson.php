<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Lesson extends Model
{
    protected $fillable = [
        'topic_id', 'title', 'slug', 'short_description', 'content',
        'code_example', 'real_life_example', 'order_number',
        'estimated_minutes', 'is_active', 'title_sw', 'short_description_sw',
        'content_sw', 'code_example_sw', 'real_life_example_sw',
        'video_path', 'video_duration_seconds',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'order_number' => 'integer',
            'estimated_minutes' => 'integer',
        ];
    }

    public function topic(): BelongsTo
    {
        return $this->belongsTo(Topic::class);
    }

    public function quizzes(): HasMany
    {
        return $this->hasMany(Quiz::class)->orderBy('order_number');
    }

    public function progress(): HasMany
    {
        return $this->hasMany(UserProgress::class);
    }

    public function resources(): HasMany
    {
        return $this->hasMany(LessonResource::class);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('order_number');
    }
}
