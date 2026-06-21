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
            ['username' => 'rogers'],
            [
                'name' => 'Rogers App Owner',
                'email' => 'rogers@learnlaravel.co.tz',
                'password' => 'roger123',
                'role' => 'admin',
                'is_active' => true,
            ],
        );

        User::updateOrCreate(
            ['email' => 'asha.demo@learnlaravel.co.tz'],
            [
                'name' => 'Asha Demo',
                'username' => 'ashademo',
                'password' => 'password123',
                'role' => 'student',
                'is_active' => true,
            ],
        );

        User::updateOrCreate(
            ['username' => 'neema.support'],
            [
                'name' => 'Neema Laravel Expert',
                'email' => 'neema@learnlaravel.co.tz',
                'password' => 'support123',
                'role' => 'support',
                'expertise' => 'Laravel APIs, Eloquent ORM & Authentication',
                'bio' => 'Laravel support expert helping learners solve practical backend challenges.',
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

        $englishTopics = [
            'utangulizi-wa-laravel' => ['Introduction to Laravel', 'Understand Laravel, MVC, and the development environment.'],
            'routes-na-controllers' => ['Routes and Controllers', 'Learn how URLs connect to application logic.'],
            'database-na-eloquent' => ['Database and Eloquent', 'Use migrations, models, and relationships to manage data.'],
        ];

        foreach ($englishTopics as $slug => [$title, $description]) {
            $topic = Topic::where('slug', $slug)->first();
            $topic?->update([
                'title_sw' => $topic->title,
                'description_sw' => $topic->description,
                'title' => $title,
                'description' => $description,
            ]);
        }

        $englishLessons = [
            'laravel-ni-nini' => [
                'What is Laravel?',
                'Discover Laravel and its advantages in web development.',
                "Laravel is a PHP framework for building web applications and APIs with elegant syntax.\n\nIt provides routing, Eloquent ORM, validation, authentication, queues, and testing in one productive ecosystem.",
                'Think of Laravel as a building foundation: routes are doors, controllers are work rooms, and the database is the information store.',
                'What is Laravel?',
                ['A' => 'A PHP framework', 'B' => 'A database', 'C' => 'An Android OS', 'D' => 'A CSS library'],
                'Laravel is a web framework built with PHP.',
            ],
            'muundo-wa-mvc' => [
                'MVC Architecture',
                'Understand Models, Views, and Controllers.',
                "MVC separates application responsibilities.\n\nModels manage data, Views present interfaces, and Controllers receive requests and coordinate responses.",
                'In a restaurant, the waiter is the Controller, the kitchen is the Model, and the served plate is the View.',
                'Which MVC component manages data?',
                ['A' => 'View', 'B' => 'Model', 'C' => 'Route', 'D' => 'Blade'],
                'The Model manages data and business rules.',
            ],
            'basic-routing' => [
                'Basic Routing',
                'Create GET and POST routes.',
                "A route tells Laravel what to do when a request arrives.\n\nGET reads data, POST creates data, PUT/PATCH updates data, and DELETE removes data.",
                'A route is an address, while its controller is the office that receives and handles the request.',
                'Which HTTP method creates a new record?',
                ['A' => 'GET', 'B' => 'DELETE', 'C' => 'POST', 'D' => 'HEAD'],
                'POST sends a new resource to the server.',
            ],
            'controllers-na-validation' => [
                'Controllers and Validation',
                'Handle requests and validate safe input.',
                "Controllers keep request logic inside dedicated classes.\n\nValidation ensures data has the expected structure before it is stored.",
                'Validation is like a security guard checking a form before it enters an office.',
                'Which status code commonly represents API validation errors?',
                ['A' => '200', 'B' => '201', 'C' => '404', 'D' => '422'],
                'Laravel commonly returns HTTP 422 for validation errors.',
            ],
            'migrations-na-models' => [
                'Migrations and Models',
                'Create a database schema and an Eloquent model.',
                "A migration is version control for your database schema. A model is a class representing a table.\n\nMigrations let every team member build the same schema.",
                'A migration is a building plan; a model is the manager who knows how to access its information.',
                'Which command runs migrations?',
                ['A' => 'php artisan migrate', 'B' => 'php artisan serve', 'C' => 'composer test', 'D' => 'npm run dev'],
                'php artisan migrate runs migrations that have not yet been executed.',
            ],
        ];

        foreach ($englishLessons as $slug => $english) {
            $lesson = Lesson::where('slug', $slug)->first();
            if (! $lesson) {
                continue;
            }
            $lesson->update([
                'title_sw' => $lesson->title,
                'short_description_sw' => $lesson->short_description,
                'content_sw' => $lesson->content,
                'code_example_sw' => $lesson->code_example,
                'real_life_example_sw' => $lesson->real_life_example,
                'title' => $english[0],
                'short_description' => $english[1],
                'content' => $english[2],
                'real_life_example' => $english[3],
            ]);
            $quiz = $lesson->quizzes()->first();
            if (! $quiz) {
                continue;
            }
            $quiz->update([
                'question_sw' => $quiz->question,
                'explanation_sw' => $quiz->explanation,
                'question' => $english[4],
                'explanation' => $english[6],
            ]);
            foreach ($quiz->options as $option) {
                $option->update([
                    'option_text_sw' => $option->option_text,
                    'option_text' => $english[5][$option->option_key],
                ]);
            }
        }
    }
}
