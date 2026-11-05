FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /workspace

COPY pom.xml ./
RUN mvn -B -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests clean package

FROM tomcat:9.0.123-jdk11-temurin
RUN rm -rf /usr/local/tomcat/webapps/* \
    && mkdir -p /var/lib/incluyelab/IncluyeLab

COPY --from=build /workspace/target/Portal_Empleo_Inclusivo.war \
    /usr/local/tomcat/webapps/Portal_Empleo_Inclusivo.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
