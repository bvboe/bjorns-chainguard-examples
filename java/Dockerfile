FROM cgr.dev/chainguard/jdk:latest-dev AS builder

COPY . /home/build/
RUN ./mvnw package
RUN ls -l target

FROM cgr.dev/chainguard/jre:latest

COPY --from=builder /home/build/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
