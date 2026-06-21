<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('topics', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('icon')->default('school');
            $table->string('level')->default('Beginner');
            $table->unsignedInteger('order_number')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index(['is_active', 'order_number']);
        });

        Schema::create('lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('topic_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('slug');
            $table->text('short_description')->nullable();
            $table->longText('content');
            $table->longText('code_example')->nullable();
            $table->text('real_life_example')->nullable();
            $table->unsignedInteger('order_number')->default(0);
            $table->unsignedInteger('estimated_minutes')->default(10);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['topic_id', 'slug']);
            $table->index(['topic_id', 'is_active', 'order_number']);
        });

        Schema::create('quizzes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_id')->constrained()->cascadeOnDelete();
            $table->text('question');
            $table->text('explanation')->nullable();
            $table->string('difficulty')->default('Easy');
            $table->unsignedInteger('order_number')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('quiz_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_id')->constrained()->cascadeOnDelete();
            $table->string('option_key', 5);
            $table->text('option_text');
            $table->boolean('is_correct')->default(false);
            $table->timestamps();
            $table->unique(['quiz_id', 'option_key']);
        });

        Schema::create('user_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('lesson_id')->constrained()->cascadeOnDelete();
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->unsignedTinyInteger('best_score')->default(0);
            $table->timestamps();
            $table->unique(['user_id', 'lesson_id']);
            $table->index(['user_id', 'is_completed']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_progress');
        Schema::dropIfExists('quiz_options');
        Schema::dropIfExists('quizzes');
        Schema::dropIfExists('lessons');
        Schema::dropIfExists('topics');
    }
};
