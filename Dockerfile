FROM eclipse-temurin:11-jdk-jammy as builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw clean install

FROM eclipse-temurin:11-jre-jammy
WORKDIR /opt/app
EXPOSE 2020
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar
RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Africa/Lagos /etc/localtime
ENTRYPOINT ["java",  "-XX:+UseSerialGC", "-Xms256m", "-Xmx256m", "-jar", "/opt/app/*.jar"]
