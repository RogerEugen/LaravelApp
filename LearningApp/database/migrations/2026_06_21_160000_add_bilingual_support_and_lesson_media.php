<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('expertise')->nullable()->after('role');
            $table->text('bio')->nullable()->after('expertise');
        });

        Schema::table('topics', function (Blueprint $table) {
            $table->string('title_sw')->nullable()->after('title');
            $table->text('description_sw')->nullable()->after('description');
        });

        Schema::table('lessons', function (Blueprint $table) {
            $table->string('title_sw')->nullable()->after('title');
            $table->text('short_description_sw')->nullable()->after('short_description');
            $table->longText('content_sw')->nullable()->after('content');
            $table->longText('code_example_sw')->nullable()->after('code_example');
            $table->text('real_life_example_sw')->nullable()->after('real_life_example');
            $table->string('video_path')->nullable()->after('real_life_example_sw');
            $table->unsignedTinyInteger('video_duration_seconds')->nullable()->after('video_path');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->text('question_sw')->nullable()->after('question');
            $table->text('explanation_sw')->nullable()->after('explanation');
        });

        Schema::table('quiz_options', function (Blueprint $table) {
            $table->text('option_text_sw')->nullable()->after('option_text');
        });

        Schema::create('lesson_resources', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lesson_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('title_sw')->nullable();
            $table->text('description')->nullable();
            $table->text('description_sw')->nullable();
            $table->text('url');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lesson_resources');

        Schema::table('quiz_options', fn (Blueprint $table) => $table->dropColumn('option_text_sw'));
        Schema::table('quizzes', fn (Blueprint $table) => $table->dropColumn(['question_sw', 'explanation_sw']));
        Schema::table('lessons', fn (Blueprint $table) => $table->dropColumn([
            'title_sw', 'short_description_sw', 'content_sw', 'code_example_sw',
            'real_life_example_sw', 'video_path', 'video_duration_seconds',
        ]));
        Schema::table('topics', fn (Blueprint $table) => $table->dropColumn(['title_sw', 'description_sw']));
        Schema::table('users', fn (Blueprint $table) => $table->dropColumn(['expertise', 'bio']));
    }
};
