# 使用包含 JDK 11 的 Gradle 镜像作为构建环境
FROM gradle:jdk11 AS build
WORKDIR /home/gradle/src
COPY --chown=gradle:gradle . /home/gradle/src
RUN chmod +x ./gradlew
RUN ./gradlew installDist

# 使用包含 JRE 11 的镜像作为运行环境
FROM openjdk:11-jre-slim
EXPOSE 8080
WORKDIR /app
# 从构建阶段复制已编译的应用程序
COPY --from=build /home/gradle/src/build/install/src/ /app/
# 如果需要，复制配置文件或其他资源
COPY --from=build /home/gradle/src/fauceth.properties /app/
COPY --from=build /home/gradle/src/chains.json /app/
# 设置容器启动时执行的命令
ENTRYPOINT ["/app/bin/src"]
