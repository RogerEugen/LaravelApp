<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lesson;
use App\Models\Quiz;
use App\Models\Topic;
use App\Models\UserProgress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LearningController extends Controller
{
    public function dashboard(Request $request): JsonResponse
    {
        $user = $request->user('sanctum');
        $userId = $user?->id;
        $total = Lesson::active()->count();
        $completed = $userId
            ? UserProgress::where('user_id', $userId)->where('is_completed', true)->count()
            : 0;
        $last = $userId
            ? UserProgress::with('lesson.topic')->where('user_id', $userId)->latest('updated_at')->first()
            : null;

        return $this->success([
            'user' => $user,
            'hero' => [
                'eyebrow' => 'LARAVEL KWA KISWAHILI',
                'title' => 'Jenga web applications za kisasa kwa ujasiri.',
                'subtitle' => 'Jifunze Laravel hatua kwa hatua bila kulazimika kufungua akaunti.',
            ],
            'slides' => [
                [
                    'title' => 'Framework inayopendwa duniani',
                    'description' => 'Laravel inaaminiwa na mamilioni ya developers duniani kote na ina jamii hai katika nchi zaidi ya 34.',
                    'icon' => 'public',
                ],
                [
                    'title' => 'Jenga kwa kasi',
                    'description' => 'Routing, authentication, queues, validation na Eloquent ORM vinapatikana katika mfumo mmoja safi.',
                    'icon' => 'bolt',
                ],
                [
                    'title' => 'Kutoka beginner hadi professional',
                    'description' => 'Masomo ya Kiswahili, code halisi, mifano ya maisha na quiz zitakujengea uwezo wa kutengeneza project.',
                    'icon' => 'school',
                ],
            ],
            'benefits' => [
                ['title' => 'Syntax safi', 'description' => 'Code inayosomeka na kutunzwa kwa urahisi.'],
                ['title' => 'Ecosystem kubwa', 'description' => 'Zaidi ya packages 30 za Laravel pamoja na community yenye nguvu.'],
                ['title' => 'Kazi na biashara', 'description' => 'Jenga APIs, dashboards, e-commerce na mifumo mikubwa.'],
            ],
            'stats' => [
                'total_topics' => Topic::active()->count(),
                'total_lessons' => $total,
                'completed_lessons' => $completed,
                'progress_percentage' => $total ? (int) round(($completed / $total) * 100) : 0,
                'developers' => 'Millions+',
                'community_countries' => '34+',
            ],
            'continue_learning' => $last?->lesson ? [
                'lesson_id' => $last->lesson->id,
                'lesson_title' => $last->lesson->title,
                'topic_title' => $last->lesson->topic->title,
            ] : null,
        ]);
    }

    public function topics(Request $request): JsonResponse
    {
        $userId = $request->user('sanctum')?->id;
        $topics = Topic::active()
            ->ordered()
            ->with(['lessons' => fn ($query) => $query->active()->ordered()])
            ->get()
            ->map(fn (Topic $topic) => [
                'id' => $topic->id,
                'title' => $topic->title,
                'slug' => $topic->slug,
                'description' => $topic->description,
                'icon' => $topic->icon,
                'level' => $topic->level,
                'lesson_count' => $topic->lessons->count(),
                'completed_count' => $userId
                    ? UserProgress::where('user_id', $userId)
                        ->whereIn('lesson_id', $topic->lessons->pluck('id'))
                        ->where('is_completed', true)->count()
                    : 0,
            ]);

        return $this->success($topics);
    }

    public function topic(Request $request, Topic $topic): JsonResponse
    {
        abort_unless($topic->is_active, 404);
        $userId = $request->user('sanctum')?->id;
        $progress = $userId
            ? UserProgress::where('user_id', $userId)
                ->whereIn('lesson_id', $topic->lessons()->pluck('id'))
                ->get()->keyBy('lesson_id')
            : collect();

        $lessons = $topic->lessons()->active()->ordered()->get()->map(fn (Lesson $lesson) => [
            'id' => $lesson->id,
            'title' => $lesson->title,
            'short_description' => $lesson->short_description,
            'estimated_minutes' => $lesson->estimated_minutes,
            'order_number' => $lesson->order_number,
            'is_completed' => (bool) ($progress[$lesson->id]?->is_completed ?? false),
            'best_score' => $progress[$lesson->id]?->best_score ?? 0,
        ]);

        return $this->success([
            'id' => $topic->id,
            'title' => $topic->title,
            'description' => $topic->description,
            'level' => $topic->level,
            'lessons' => $lessons,
        ]);
    }

    public function lesson(Request $request, Lesson $lesson): JsonResponse
    {
        abort_unless($lesson->is_active, 404);
        $userId = $request->user('sanctum')?->id;
        $progress = $userId
            ? UserProgress::firstOrCreate(['user_id' => $userId, 'lesson_id' => $lesson->id])
            : null;
        $previous = Lesson::active()->where('topic_id', $lesson->topic_id)
            ->where('order_number', '<', $lesson->order_number)->latest('order_number')->first();
        $next = Lesson::active()->where('topic_id', $lesson->topic_id)
            ->where('order_number', '>', $lesson->order_number)->oldest('order_number')->first();

        return $this->success([
            'id' => $lesson->id,
            'topic_id' => $lesson->topic_id,
            'topic_title' => $lesson->topic->title,
            'title' => $lesson->title,
            'short_description' => $lesson->short_description,
            'content' => $lesson->content,
            'code_example' => $lesson->code_example,
            'real_life_example' => $lesson->real_life_example,
            'estimated_minutes' => $lesson->estimated_minutes,
            'has_quiz' => $lesson->quizzes()->active()->exists(),
            'is_completed' => (bool) $progress?->is_completed,
            'requires_login_for_quiz' => true,
            'navigation' => [
                'previous_lesson_id' => $previous?->id,
                'next_lesson_id' => $next?->id,
            ],
        ]);
    }

    public function complete(Request $request, Lesson $lesson): JsonResponse
    {
        $progress = UserProgress::updateOrCreate(
            ['user_id' => $request->user()->id, 'lesson_id' => $lesson->id],
            ['is_completed' => true, 'completed_at' => now()],
        );

        return $this->success($progress, 'Somo limekamilika. Hongera!');
    }

    public function quiz(Request $request, Lesson $lesson): JsonResponse
    {
        $quizzes = $lesson->quizzes()->active()->with('options')->get()->map(fn (Quiz $quiz) => [
            'id' => $quiz->id,
            'question' => $quiz->question,
            'difficulty' => $quiz->difficulty,
            'options' => $quiz->options->map->only(['id', 'option_key', 'option_text'])->values(),
        ]);

        return $this->success([
            'lesson_id' => $lesson->id,
            'lesson_title' => $lesson->title,
            'questions' => $quizzes,
        ]);
    }

    public function submitQuiz(Request $request, Lesson $lesson): JsonResponse
    {
        $data = $request->validate([
            'answers' => ['required', 'array', 'min:1'],
            'answers.*.quiz_id' => [
                'required', 'integer',
                Rule::exists('quizzes', 'id')->where('lesson_id', $lesson->id),
            ],
            'answers.*.selected_option_id' => ['required', 'integer', 'exists:quiz_options,id'],
        ]);

        $results = [];
        $correct = 0;

        foreach ($data['answers'] as $answer) {
            $quiz = Quiz::with('options')->findOrFail($answer['quiz_id']);
            $selected = $quiz->options->firstWhere('id', $answer['selected_option_id']);
            abort_unless($selected, 422, 'Chaguo halipo kwenye swali hili.');
            $correctOption = $quiz->options->firstWhere('is_correct', true);
            $isCorrect = (bool) $selected->is_correct;
            $correct += $isCorrect ? 1 : 0;
            $results[] = [
                'question' => $quiz->question,
                'selected_answer' => $selected->option_text,
                'correct_answer' => $correctOption?->option_text,
                'is_correct' => $isCorrect,
                'explanation' => $quiz->explanation,
            ];
        }

        $score = (int) round(($correct / count($data['answers'])) * 100);
        $progress = UserProgress::firstOrCreate([
            'user_id' => $request->user()->id,
            'lesson_id' => $lesson->id,
        ]);
        $progress->update(['best_score' => max($progress->best_score, $score)]);

        return $this->success([
            'score_percentage' => $score,
            'correct_answers' => $correct,
            'total_questions' => count($data['answers']),
            'passed' => $score >= 60,
            'results' => $results,
        ], $score >= 60 ? 'Hongera, umefaulu!' : 'Jaribu tena; unaweza!');
    }

    public function progress(Request $request): JsonResponse
    {
        $items = UserProgress::with('lesson.topic')
            ->where('user_id', $request->user()->id)
            ->latest('updated_at')
            ->get()
            ->map(fn (UserProgress $item) => [
                'lesson_id' => $item->lesson_id,
                'lesson_title' => $item->lesson->title,
                'topic_title' => $item->lesson->topic->title,
                'is_completed' => $item->is_completed,
                'best_score' => $item->best_score,
                'completed_at' => $item->completed_at,
            ]);

        return $this->success($items);
    }

    private function success(mixed $data, string $message = 'Taarifa zimepatikana.'): JsonResponse
    {
        return response()->json(['success' => true, 'message' => $message, 'data' => $data]);
    }
}
