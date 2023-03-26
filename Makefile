.PHONY: clean
clean:
	flutter clean

.PHONY: doc
doc:
	flutter doctor -v


# アプリ起動
.PHONY: run-dev
run-dev:
	flutter run --dart-define-from-file=dart_defines/dev.json

.PHONY: run-prod
run-prod:
	flutter run --dart-define-from-file=dart_defines/prod.json

# アプリビルド(Android)
.PHONY: build-dev
build-devdoc:
	flutter build apk --dart-define-from-file=dart_defines/dev.json

.PHONY: build-prod
build-prod:
	flutter build apk --dart-define-from-file=dart_defines/prod.json

.PHONY: build-release
build-release:
	flutter build appbundle --release --dart-define-from-file=dart_defines/prod.json

# アプリビルド(iOS)
.PHONY: build-ios-dev
build-ios-dev:
	flutter build ios --dart-define-from-file=dart_defines/dev.json

.PHONY: build-ios-prod
build-ios-prod:
	flutter build ios --dart-define-from-file=dart_defines/prod.json