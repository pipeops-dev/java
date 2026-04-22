FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install

FROM eclipse-temurin:17-jre-jammy
WORKDIR /opt/app
EXPOSE 2020
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar

# Create a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /opt/app

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Africa/Lagos /etc/localtime

USER appuser

ENTRYPOINT ["java",  "-XX:+UseSerialGC", "-Xms256m", "-Xmx256m", "-jar", "/opt/app/*.jar"]
