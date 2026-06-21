<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\Lesson;
use App\Models\Quiz;
use App\Models\Topic;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    public function dashboard(): JsonResponse
    {
        return $this->success([
            'users' => User::where('role', 'student')->count(),
            'active_users' => User::where('role', 'student')->where('is_active', true)->count(),
            'topics' => Topic::count(),
            'lessons' => Lesson::count(),
            'quizzes' => Quiz::count(),
            'messages' => ChatMessage::count(),
            'recent_users' => User::where('role', 'student')->latest()->limit(5)->get(),
        ]);
    }

    public function users(Request $request): JsonResponse
    {
        $users = User::where('role', 'student')
            ->when($request->string('search')->isNotEmpty(), function ($query) use ($request) {
                $search = '%'.$request->string('search').'%';
                $query->where(fn ($inner) => $inner->where('name', 'like', $search)
                    ->orWhere('email', 'like', $search));
            })
            ->latest()
            ->paginate(20);

        return $this->success($users);
    }

    public function toggleUser(User $user): JsonResponse
    {
        abort_if($user->role === 'admin', 422, 'Admin hawezi kuzimwa hapa.');
        $user->update(['is_active' => ! $user->is_active]);

        return $this->success($user, $user->is_active ? 'User amewashwa.' : 'User amesimamishwa.');
    }

    public function topics(): JsonResponse
    {
        return $this->success(Topic::withCount('lessons')->ordered()->get());
    }

    public function storeTopic(Request $request): JsonResponse
    {
        $data = $this->validateTopic($request);
        $topic = Topic::create($data);

        return $this->success($topic, 'Mada imetengenezwa.', 201);
    }

    public function updateTopic(Request $request, Topic $topic): JsonResponse
    {
        $topic->update($this->validateTopic($request, $topic));

        return $this->success($topic, 'Mada imesasishwa.');
    }

    public function deleteTopic(Topic $topic): JsonResponse
    {
        $topic->delete();

        return $this->success(null, 'Mada imefutwa.');
    }

    public function lessons(): JsonResponse
    {
        return $this->success(Lesson::with('topic:id,title')->withCount('quizzes')->ordered()->get());
    }

    public function storeLesson(Request $request): JsonResponse
    {
        $lesson = Lesson::create($this->validateLesson($request));

        return $this->success($lesson, 'Somo limetengenezwa.', 201);
    }

    public function updateLesson(Request $request, Lesson $lesson): JsonResponse
    {
        $lesson->update($this->validateLesson($request, $lesson));

        return $this->success($lesson, 'Somo limesasishwa.');
    }

    public function deleteLesson(Lesson $lesson): JsonResponse
    {
        $lesson->delete();

        return $this->success(null, 'Somo limefutwa.');
    }

    public function quizzes(): JsonResponse
    {
        return $this->success(Quiz::with(['lesson:id,title', 'options'])->latest()->get());
    }

    public function storeQuiz(Request $request): JsonResponse
    {
        $data = $this->validateQuiz($request);
        $quiz = Quiz::create(collect($data)->except(['options', 'correct_key'])->all());
        $this->saveOptions($quiz, $data['options'], $data['correct_key']);

        return $this->success($quiz->load('options'), 'Quiz imetengenezwa.', 201);
    }

    public function updateQuiz(Request $request, Quiz $quiz): JsonResponse
    {
        $data = $this->validateQuiz($request);
        $quiz->update(collect($data)->except(['options', 'correct_key'])->all());
        $quiz->options()->delete();
        $this->saveOptions($quiz, $data['options'], $data['correct_key']);

        return $this->success($quiz->load('options'), 'Quiz imesasishwa.');
    }

    public function deleteQuiz(Quiz $quiz): JsonResponse
    {
        $quiz->delete();

        return $this->success(null, 'Quiz imefutwa.');
    }

    private function validateTopic(Request $request, ?Topic $topic = null): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', Rule::unique('topics')->ignore($topic)],
            'description' => ['required', 'string'],
            'icon' => ['nullable', 'string', 'max:50'],
            'level' => ['required', Rule::in(['Beginner', 'Intermediate', 'Advanced'])],
            'order_number' => ['required', 'integer', 'min:0'],
            'is_active' => ['required', 'boolean'],
        ]);
    }

    private function validateLesson(Request $request, ?Lesson $lesson = null): array
    {
        return $request->validate([
            'topic_id' => ['required', 'exists:topics,id'],
            'title' => ['required', 'string', 'max:255'],
            'slug' => [
                'required', 'string', 'max:255',
                Rule::unique('lessons')->where('topic_id', $request->integer('topic_id'))->ignore($lesson),
            ],
            'short_description' => ['nullable', 'string'],
            'content' => ['required', 'string'],
            'code_example' => ['nullable', 'string'],
            'real_life_example' => ['nullable', 'string'],
            'order_number' => ['required', 'integer', 'min:0'],
            'estimated_minutes' => ['required', 'integer', 'min:1'],
            'is_active' => ['required', 'boolean'],
        ]);
    }

    private function validateQuiz(Request $request): array
    {
        return $request->validate([
            'lesson_id' => ['required', 'exists:lessons,id'],
            'question' => ['required', 'string'],
            'explanation' => ['nullable', 'string'],
            'difficulty' => ['required', Rule::in(['Easy', 'Medium', 'Hard'])],
            'order_number' => ['required', 'integer', 'min:0'],
            'is_active' => ['required', 'boolean'],
            'options' => ['required', 'array', 'size:4'],
            'options.*' => ['required', 'string', 'max:500'],
            'correct_key' => ['required', Rule::in(['A', 'B', 'C', 'D'])],
        ]);
    }

    private function saveOptions(Quiz $quiz, array $options, string $correctKey): void
    {
        foreach (['A', 'B', 'C', 'D'] as $index => $key) {
            $quiz->options()->create([
                'option_key' => $key,
                'option_text' => $options[$index],
                'is_correct' => $key === $correctKey,
            ]);
        }
    }

    private function success(mixed $data, string $message = 'Taarifa zimepatikana.', int $status = 200): JsonResponse
    {
        return response()->json(['success' => true, 'message' => $message, 'data' => $data], $status);
    }
}
