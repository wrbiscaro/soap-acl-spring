FROM amazoncorretto:21-alpine-jdk
MAINTAINER wallacebiscaro
COPY target/soap-acl-spring-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-Dspring.profiles.active=noauth", "-jar", "/app.jar"]