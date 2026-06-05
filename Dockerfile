# ADAMS Spring Boot JSP/Servlet app for Render
# Build stage: compile/package the executable WAR with Maven + JDK 17
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml ./
RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -q -DskipTests package

# Runtime stage: run the Spring Boot executable WAR
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /app/target/adams-postgresql-springboot.war app.war

EXPOSE 8080
ENV JAVA_OPTS=""
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.war"]
