FROM amazoncorretto:21-alpine-jdk
MAINTAINER wallacebiscaro

ENV OTEL_SERVICE_NAME=soap-acl-spring
ENV OTEL_EXPERIMENTAL_RESOURCE_DISABLED_KEYS=process.command_args
ENV OTEL_JAVAAGENT_DEBUG=false

COPY opentelemetry-javaagent.jar opentelemetry-javaagent.jar
COPY target/soap-acl-spring-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-Dspring.profiles.active=noauth", "-javaagent:opentelemetry-javaagent.jar", "-jar", "/app.jar"]