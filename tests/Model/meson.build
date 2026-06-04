tests = [
    'SubscriptionTest'
]

test_sources = []
foreach test : tests
    test_sources += test + '.vala'
endforeach

additional_test_sources = [
    'Main.vala'
]

test_executable = executable(
    'io.github.leolost2605.ema.tests',
    common_test_sources,
    additional_test_sources,
    test_sources,
    ema_model_sources,
    dependencies: ema_deps,
    install: false,
)

foreach test : tests
    test(test, test_executable, args: 'EmA' + test, suite: ['EmA', 'EmA/Model'], is_parallel: true)
endforeach

