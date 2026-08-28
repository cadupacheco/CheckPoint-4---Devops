FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

COPY . .

RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests


FROM eclipse-temurin:21-jre

WORKDIR /app

RUN groupadd -r dimdim && useradd -r -g dimdim dimdim

COPY --from=build /app/target/*.jar app.jar

USER dimdim

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]