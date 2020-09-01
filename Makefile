# files
.packages: pubspec.yaml
	@rm pubspec.lock
	pub get

lib/models/%.freezed.dart: .build-runner-trigger .packages

lib/models/%.g.dart: lib/models/%.freezed.dart

.build-runner-trigger: $(wildcard lib/models/*.freezed.dart)
	touch .build-runner-trigger
	echo pub run build_runner build --delete-conflicting-outputs

generate2: $(wildcard lib/models/*.freezed.dart) $(wildcard lib/models/*.g.dart) .build-runner-trigger

# targets
.PHONY: get build generate watch test coverage doc publish

get: .packages

build: .build-runner-completed

generate: get
	pub run build_runner build --delete-conflicting-outputs
	
watch: get
	pub run build_runner watch --delete-conflicting-outputs

test: get
	pub run test

coverage: get
	@rm -rf coverage
	pub run test_coverage
	lcov --remove coverage/lcov.info -o coverage/lcov.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'lib/src/models/*.dart'
	genhtml -o coverage coverage/lcov.info
	xdg-open coverage/index.html || start coverage/index.html

doc: get
	@rm -rf doc
	dartdoc --show-progress 

publish: get
	rm lib/src/.gitignore
	pub publish
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart'
	echo '*.g.dart'
