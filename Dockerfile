# Build stage
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /opt/app
EXPOSE 2020

# Create a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /opt/app

COPY --from=builder /opt/app/target/*.jar /opt/app/app.jar

# Set timezone
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Africa/Lagos /etc/localtime

USER appuser

ENTRYPOINT ["java", "-XX:+UseSerialGC", "-Xms256m", "-Xmx256m", "-jar", "/opt/app/app.jar"]
