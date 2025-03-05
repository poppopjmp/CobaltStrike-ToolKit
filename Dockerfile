# Use a recent Ubuntu version
FROM ubuntu:22.04

# Metadata
MAINTAINER poppopjmp

# Build argument for the Cobalt Strike license key
ARG CS_KEY

# Install necessary packages, including OpenJDK 17
RUN apt-get update && apt-get install -y wget curl net-tools openjdk-17-jdk-headless

# Set JAVA_HOME and update PATH
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

# Create a non-root user for security
RUN useradd -ms /bin/bash csuser

# Download and install Cobalt Strike (replace with the latest download method)
# This section needs to be adapted based on the current Cobalt Strike download process.
# This example assumes a direct download link, which may change.
RUN wget -O cobaltstrike.tgz "YOUR_COBALT_STRIKE_DOWNLOAD_LINK" && \
    tar xvf cobaltstrike.tgz && \
    mv cobaltstrike /opt/ && \
    echo "$CS_KEY" > /opt/cobaltstrike/.cobaltstrike.license && \
    /opt/cobaltstrike/update

# Clean up package lists and temporary files
RUN apt-get clean && apt-get autoremove && rm cobaltstrike.tgz

# Set working directory and expose the default port
WORKDIR /opt/cobaltstrike
EXPOSE 50050

# Switch to the non-root user
USER csuser

# Set the entry point to the Cobalt Strike team server
ENTRYPOINT ["./teamserver"]
