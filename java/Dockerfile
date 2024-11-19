FROM cgr.dev/chainguard/jdk:latest-dev

COPY . /home/build/
RUN ./mvnw package
RUN ls -l target

FROM cgr.dev/chainguard/jre:latest

COPY --from=0 /home/build/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
