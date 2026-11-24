
# Stage 1: Build the Java backend
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /build/backend

COPY backend/pom.xml .
COPY backend/src ./src

RUN mvn -B -DskipTests package

# Stage 2: Run the application
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy compiled Java classes and runtime dependencies
COPY --from=build /build/backend/target/classes ./backend/target/classes
COPY --from=build /build/backend/target/lib ./backend/target/lib

# Copy frontend
COPY frontend ./frontend

# Correct the frontend filename expected by ApiServer.java
RUN cp /app/frontend/index.html /app/frontend/ashford-market-terminal.html

# Runtime configuration
ENV STATIC_DIR=/app/frontend
ENV BIND_HOST=0.0.0.0

EXPOSE 8080

WORKDIR /app/backend

# Start Java application
CMD ["java", "-cp", "target/classes:target/lib/*", "com.ashford.terminal.App"]
