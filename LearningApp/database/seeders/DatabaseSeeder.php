<?php

namespace Database\Seeders;

use App\Models\Lesson;
use App\Models\Quiz;
use App\Models\Topic;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'demo@learnlaravel.co.tz'],
            [
                'name' => 'Demo Student',
                'username' => 'demostudent',
                'password' => 'password123',
                'role' => 'student',
                'is_active' => true,
            ],
        );

        User::updateOrCreate(
            ['username' => 'rogerscharleseugen'],
            [
                'name' => 'Rogers Charles Eugen',
                'email' => 'rogerscharleseugen@learnlaravel.co.tz',
                'password' => 'roger123',
                'role' => 'admin',
                'is_active' => true,
            ],
        );

        $topics = [
            [
                'title' => 'Utangulizi wa Laravel',
                'slug' => 'utangulizi-wa-laravel',
                'description' => 'Fahamu Laravel, MVC na mazingira ya kuanzia kutengeneza web application.',
                'icon' => 'rocket',
                'level' => 'Beginner',
                'lessons' => [
                    [
                        'title' => 'Laravel ni nini?',
                        'slug' => 'laravel-ni-nini',
                        'short_description' => 'Tambua Laravel na faida zake katika web development.',
                        'content' => "Laravel ni PHP framework ya kutengeneza web applications na APIs kwa syntax safi.\n\nInakupa routing, database ORM, validation, authentication, queues na testing katika mfumo mmoja. Hii inapunguza code ya kurudia na kufanya project iwe rahisi kuitunza.",
                        'code_example' => "<?php\n\nuse Illuminate\\Support\\Facades\\Route;\n\nRoute::get('/karibu', function () {\n    return response()->json(['message' => 'Karibu Laravel!']);\n});",
                        'real_life_example' => 'Fikiria Laravel kama msingi wa nyumba: routing ni milango, controllers ni vyumba vya kazi, na database ni ghala la taarifa.',
                        'quiz' => [
                            'question' => 'Laravel ni nini?',
                            'options' => ['A' => 'PHP framework', 'B' => 'Database', 'C' => 'Android OS', 'D' => 'CSS library'],
                            'correct' => 'A',
                            'explanation' => 'Laravel ni framework inayotumia lugha ya PHP.',
                        ],
                    ],
                    [
                        'title' => 'Muundo wa MVC',
                        'slug' => 'muundo-wa-mvc',
                        'short_description' => 'Elewa Model, View na Controller.',
                        'content' => "MVC hutenganisha majukumu ya application.\n\nModel hushughulikia data, View huonyesha interface, na Controller hupokea request na kuratibu majibu. Mgawanyo huu hufanya code iwe rahisi kusoma na kupanua.",
                        'code_example' => "php artisan make:model Course -m\nphp artisan make:controller CourseController",
                        'real_life_example' => 'Mgahawa: mhudumu ni Controller, jikoni ni Model, na sahani anayoona mteja ni View.',
                        'quiz' => [
                            'question' => 'Sehemu gani ya MVC hushughulikia data?',
                            'options' => ['A' => 'View', 'B' => 'Model', 'C' => 'Route', 'D' => 'Blade'],
                            'correct' => 'B',
                            'explanation' => 'Model ndiyo huwasiliana na data na business rules.',
                        ],
                    ],
                ],
            ],
            [
                'title' => 'Routes na Controllers',
                'slug' => 'routes-na-controllers',
                'description' => 'Jifunze namna URL inaunganishwa na logic ya application.',
                'icon' => 'route',
                'level' => 'Beginner',
                'lessons' => [
                    [
                        'title' => 'Basic Routing',
                        'slug' => 'basic-routing',
                        'short_description' => 'Tengeneza GET na POST routes.',
                        'content' => "Route inaeleza Laravel ifanye nini request inapofika.\n\nGET hutumika kusoma taarifa, POST kutuma mpya, PUT/PATCH kusasisha, na DELETE kufuta.",
                        'code_example' => "Route::get('/courses', [CourseController::class, 'index']);\nRoute::post('/courses', [CourseController::class, 'store']);",
                        'real_life_example' => '/courses ni anwani; controller ni ofisi inayopokea na kushughulikia ombi.',
                        'quiz' => [
                            'question' => 'HTTP method gani hutumika kuunda record mpya?',
                            'options' => ['A' => 'GET', 'B' => 'DELETE', 'C' => 'POST', 'D' => 'HEAD'],
                            'correct' => 'C',
                            'explanation' => 'POST hutumika kutuma resource mpya kwenda server.',
                        ],
                    ],
                    [
                        'title' => 'Controllers na Validation',
                        'slug' => 'controllers-na-validation',
                        'short_description' => 'Pokea request na hakiki input salama.',
                        'content' => "Controller huweka request logic katika class maalum.\n\nValidation inahakikisha data ina muundo unaotarajiwa kabla ya kuhifadhiwa. Laravel hurudisha errors za 422 moja kwa moja kwa API.",
                        'code_example' => "\$data = \$request->validate([\n    'title' => ['required', 'string', 'max:255'],\n]);\n\nCourse::create(\$data);",
                        'real_life_example' => 'Validation ni kama mlinzi anayekagua fomu kabla haijaingia ofisini.',
                        'quiz' => [
                            'question' => 'Validation error ya API mara nyingi hurudisha status gani?',
                            'options' => ['A' => '200', 'B' => '201', 'C' => '404', 'D' => '422'],
                            'correct' => 'D',
                            'explanation' => 'Laravel hutumia HTTP 422 kwa validation errors.',
                        ],
                    ],
                ],
            ],
            [
                'title' => 'Database na Eloquent',
                'slug' => 'database-na-eloquent',
                'description' => 'Tumia migrations, models na relationships kuendesha data.',
                'icon' => 'database',
                'level' => 'Intermediate',
                'lessons' => [
                    [
                        'title' => 'Migrations na Models',
                        'slug' => 'migrations-na-models',
                        'short_description' => 'Tengeneza schema na Eloquent model.',
                        'content' => "Migration ni version control ya database schema. Model ni class inayowakilisha table.\n\nKwa migrations timu nzima inaweza kujenga schema sawa kwa command moja.",
                        'code_example' => "Schema::create('courses', function (Blueprint \$table) {\n    \$table->id();\n    \$table->string('title');\n    \$table->timestamps();\n});",
                        'real_life_example' => 'Migration ni ramani ya jengo; model ni msimamizi anayejua namna ya kupata taarifa ndani yake.',
                        'quiz' => [
                            'question' => 'Command gani huendesha migrations?',
                            'options' => ['A' => 'php artisan migrate', 'B' => 'php artisan serve', 'C' => 'composer test', 'D' => 'npm run dev'],
                            'correct' => 'A',
                            'explanation' => 'php artisan migrate hutekeleza migrations ambazo bado hazijaendeshwa.',
                        ],
                    ],
                ],
            ],
        ];

        foreach ($topics as $topicIndex => $topicData) {
            $lessons = $topicData['lessons'];
            unset($topicData['lessons']);
            $topic = Topic::updateOrCreate(['slug' => $topicData['slug']], [
                ...$topicData,
                'order_number' => $topicIndex + 1,
                'is_active' => true,
            ]);

            foreach ($lessons as $lessonIndex => $lessonData) {
                $quizData = $lessonData['quiz'];
                unset($lessonData['quiz']);
                $lesson = Lesson::updateOrCreate(
                    ['topic_id' => $topic->id, 'slug' => $lessonData['slug']],
                    [...$lessonData, 'order_number' => $lessonIndex + 1, 'estimated_minutes' => 10, 'is_active' => true],
                );
                $quiz = Quiz::updateOrCreate(
                    ['lesson_id' => $lesson->id, 'order_number' => 1],
                    ['question' => $quizData['question'], 'explanation' => $quizData['explanation'], 'difficulty' => 'Easy', 'is_active' => true],
                );

                foreach ($quizData['options'] as $key => $text) {
                    $quiz->options()->updateOrCreate(
                        ['option_key' => $key],
                        ['option_text' => $text, 'is_correct' => $key === $quizData['correct']],
                    );
                }
            }
        }
    }
}
