xcodeproj:
	PF_DEVELOP=1 swift run xcodegen

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.2.3 \
		bash -c 'make test-swift'

build-release-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.2.3 \
		bash -c 'make build-release-swift'

test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme Gen_macOS \
		-destination platform="macOS" \
		-derivedDataPath ./.derivedData \
		| xcpretty

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme Gen_iOS \
		-destination platform="iOS Simulator,name=iPhone XR,OS=12.2" \
		| xcpretty

test-swift:
	swift test --parallel --enable-test-discovery -v

build-release-swift:
	swift build --enable-test-discovery -c release

test-playgrounds: test-macos
	find . \
		-path '*.playground/*' \
		-name '*.swift' \
		-exec swift -F .derivedData/Build/Products/Debug/ -suppress-warnings {} +

format:
	swift format --in-place --recursive \
		./Package.swift ./Sources ./Tests

test-all: test-linux test-macos test-ios test-playgrounds
