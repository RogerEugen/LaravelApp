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
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
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

    public function supports(): JsonResponse
    {
        return $this->success(User::where('role', 'support')->latest()->get());
    }

    public function storeSupport(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'username' => ['required', 'string', 'max:100', 'unique:users,username'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'expertise' => ['required', 'string', 'max:255'],
            'bio' => ['nullable', 'string', 'max:1000'],
        ]);
        $data['role'] = 'support';
        $data['is_active'] = true;
        $data['password'] = Hash::make($data['password']);

        return $this->success(User::create($data), 'Support expert created.', 201);
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
        $data = $this->validateLesson($request);
        $resources = $data['resources'] ?? [];
        unset($data['resources'], $data['video'], $data['video_duration_seconds']);
        $lesson = Lesson::create($data);
        $this->saveLessonMedia($request, $lesson, $resources);

        return $this->success($lesson, 'Somo limetengenezwa.', 201);
    }

    public function updateLesson(Request $request, Lesson $lesson): JsonResponse
    {
        $data = $this->validateLesson($request, $lesson);
        $resources = $data['resources'] ?? [];
        unset($data['resources'], $data['video'], $data['video_duration_seconds']);
        $lesson->update($data);
        $this->saveLessonMedia($request, $lesson, $resources);

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
        $quiz = Quiz::create(collect($data)->except(['options', 'options_sw', 'correct_key'])->all());
        $this->saveOptions($quiz, $data['options'], $data['correct_key'], $data['options_sw'] ?? []);

        return $this->success($quiz->load('options'), 'Quiz imetengenezwa.', 201);
    }

    public function updateQuiz(Request $request, Quiz $quiz): JsonResponse
    {
        $data = $this->validateQuiz($request);
        $quiz->update(collect($data)->except(['options', 'options_sw', 'correct_key'])->all());
        $quiz->options()->delete();
        $this->saveOptions($quiz, $data['options'], $data['correct_key'], $data['options_sw'] ?? []);

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
            'title_sw' => ['nullable', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', Rule::unique('topics')->ignore($topic)],
            'description' => ['required', 'string'],
            'description_sw' => ['nullable', 'string'],
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
            'title_sw' => ['nullable', 'string', 'max:255'],
            'slug' => [
                'required', 'string', 'max:255',
                Rule::unique('lessons')->where('topic_id', $request->integer('topic_id'))->ignore($lesson),
            ],
            'short_description' => ['nullable', 'string'],
            'short_description_sw' => ['nullable', 'string'],
            'content' => ['required', 'string'],
            'content_sw' => ['nullable', 'string'],
            'code_example' => ['nullable', 'string'],
            'code_example_sw' => ['nullable', 'string'],
            'real_life_example' => ['nullable', 'string'],
            'real_life_example_sw' => ['nullable', 'string'],
            'video' => ['nullable', 'file', 'mimetypes:video/mp4,video/webm,video/quicktime', 'max:30720'],
            'video_duration_seconds' => ['nullable', 'required_with:video', 'integer', 'min:1', 'max:60'],
            'resources' => ['nullable', 'array', 'max:10'],
            'resources.*.title' => ['required_with:resources', 'string', 'max:255'],
            'resources.*.title_sw' => ['nullable', 'string', 'max:255'],
            'resources.*.description' => ['nullable', 'string'],
            'resources.*.description_sw' => ['nullable', 'string'],
            'resources.*.url' => ['required_with:resources', 'url', 'max:2000'],
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
            'question_sw' => ['nullable', 'string'],
            'explanation' => ['nullable', 'string'],
            'explanation_sw' => ['nullable', 'string'],
            'difficulty' => ['required', Rule::in(['Easy', 'Medium', 'Hard'])],
            'order_number' => ['required', 'integer', 'min:0'],
            'is_active' => ['required', 'boolean'],
            'options' => ['required', 'array', 'size:4'],
            'options.*' => ['required', 'string', 'max:500'],
            'options_sw' => ['nullable', 'array', 'size:4'],
            'options_sw.*' => ['nullable', 'string', 'max:500'],
            'correct_key' => ['required', Rule::in(['A', 'B', 'C', 'D'])],
        ]);
    }

    private function saveOptions(Quiz $quiz, array $options, string $correctKey, array $optionsSw = []): void
    {
        foreach (['A', 'B', 'C', 'D'] as $index => $key) {
            $quiz->options()->create([
                'option_key' => $key,
                'option_text' => $options[$index],
                'option_text_sw' => $optionsSw[$index] ?? null,
                'is_correct' => $key === $correctKey,
            ]);
        }
    }

    private function saveLessonMedia(Request $request, Lesson $lesson, array $resources): void
    {
        if ($request->hasFile('video')) {
            if ($lesson->video_path) {
                Storage::disk('public')->delete($lesson->video_path);
            }
            $lesson->update([
                'video_path' => $request->file('video')->store('lesson-videos', 'public'),
                'video_duration_seconds' => $request->integer('video_duration_seconds'),
            ]);
        }

        if ($request->has('resources')) {
            $lesson->resources()->delete();
            foreach ($resources as $resource) {
                $lesson->resources()->create($resource);
            }
        }
    }

    private function success(mixed $data, string $message = 'Taarifa zimepatikana.', int $status = 200): JsonResponse
    {
        return response()->json(['success' => true, 'message' => $message, 'data' => $data], $status);
    }
}
