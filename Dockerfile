FROM swift:5.1

WORKDIR /package

COPY . ./

RUN swift package resolve
RUN swift package clean
RUN swift build -c release
CMD swift test --parallel
