<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuizOption extends Model
{
    protected $fillable = ['quiz_id', 'option_key', 'option_text', 'option_text_sw', 'is_correct'];

    protected function casts(): array
    {
        return ['is_correct' => 'boolean'];
    }

    protected $hidden = ['is_correct'];

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class);
    }
}
