FROM norionomura/swift:swift-5.0-branch

WORKDIR /package

COPY . ./

RUN swift package resolve
RUN swift package clean
RUN swift build -c release
CMD swift test --parallel
