<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LessonResource extends Model
{
    protected $fillable = ['lesson_id', 'title', 'title_sw', 'description', 'description_sw', 'url'];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }
}
