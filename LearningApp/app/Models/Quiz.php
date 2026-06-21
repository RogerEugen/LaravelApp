<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Quiz extends Model
{
    protected $fillable = ['lesson_id', 'question', 'question_sw', 'explanation', 'explanation_sw', 'difficulty', 'order_number', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'order_number' => 'integer'];
    }

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }

    public function options(): HasMany
    {
        return $this->hasMany(QuizOption::class);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
