  
FROM openjdk:11-jre-slim

RUN apt update

EXPOSE 8080

ADD target/helloworld.jar helloworld.jar

CMD java -XX:+UnlockExperimentalVMOptions $JVM_OPTS -jar /helloworld.jar